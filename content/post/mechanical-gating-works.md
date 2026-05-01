---
date: '2026-05-01T09:37:42-04:00'
draft: false
title: 'Prose-Only Enforcement Is Unreliable. Mechanical Gating Works.'
tags: ["AI", "Continuous Delivery"]
---

As many of you know, I've built a tool called [Stride](https://stridelikeaboss.com).  It is a human / AI collaboration tool that offers a robust workflow with many features to drive collaboration and predictability. It takes the form of a hosted kanban-like app that manages the detailed tasks and agent plugins for all of the major AI agents. Even though it has several thousand users now, I have struggled with forcing the agents to always follow the workflow defined in the plugins. The plugins define a lifecycle that is decomposed into seven skills — one orchestrator (`stride-workflow`) and six sub-skills that handle individual phases (`stride-claiming-tasks`, `stride-completing-tasks`, and so on). The sub-skills exist because each phase has a non-trivial API contract that the agent has to get exactly right. The plugins also contain four subagents and a hook designed to execute developer defined commands at specific times during the lifecycle of the work.

The orchestrator is supposed to be the only entry point. Agents invoke `stride-workflow` once at the start of a session, and the orchestrator dispatches the appropriate sub-skill at the appropriate phase. **That's the design.**

**Here's what kept happening instead.**

A user types **"claim the next stride task"** into Claude Code. The skill matcher scans descriptions, finds `stride-claiming-tasks` (description starts with *"MANDATORY before calling POST /api/tasks/claim"*), and loads it. By the time the agent is reading the skill body, it's already past the orchestrator. The skill body opens with this:

```
## ⚠️ THIS SKILL IS MANDATORY — NOT OPTIONAL ⚠️

If you are about to call `POST /api/tasks/claim`, you MUST have invoked
this skill first.
```

The agent sees that and thinks: yes, I'm in the right skill. It claims the task. Two paragraphs later there's a note that says *"after claiming, you must invoke `stride-workflow`"*. By then the API call is already made, the task is in `doing`, and the orchestrator's pre-claim phases (prerequisites check, enrichment, environment setup) are skipped permanently.

Multiple sessions confirmed it. Calling out the violation in the prompt didn't help. Adding bigger emoji headers didn't help. Adding a "STOP" block at the end of the skill didn't help, because the end of the skill is reached *after* the work is done.

A downstream Claude wrote me a remarkably honest letter about it:

> Treat this as evidence: prose-only enforcement is unreliable. Mechanical gating works.

That sentence has been rattling around in my head ever since.

## Three layers, ranked by what they actually prevent

The feedback letter recommended three layers of defense, ranked by enforcement strength. I implemented all three in the latest versions of the plugins. Looking at them in order from weakest to strongest is instructive — it makes visible exactly where prose stops working and where mechanical enforcement starts.

**Layer 3 (weakest, but free): a "STOP" block as the very first thing in every sub-skill body.**

```markdown
## STOP — orchestrator check

If you arrived here directly from a user prompt, you are in the wrong skill.
Invoke `stride:stride-workflow` instead. Do not read further.
Sub-skills are dispatched by the orchestrator only.
```

This is pure prose. It works only if the agent reads the first H2 carefully and decides to act on it before scanning further. It's the cheapest possible thing — a few markdown lines — and it's better than nothing because reading order matters: putting the warning *before* the API contract is strictly better than putting it after.

But it's still prose. An agent in a hurry — and agents are always in a hurry — may register the block, register that it's been told to leave, and then keep reading anyway because the next section looks useful. There is no enforcement here. There is only a sign.

**Layer 2 (medium): reframe the descriptions so the matcher stops picking sub-skills on user prompts.**

Before:

```yaml
description: MANDATORY before calling GET /api/tasks/next or POST /api/tasks/claim.
  Contains required before_doing hook execution pattern and claim request format.
```

After:

```yaml
description: INTERNAL — invoked only by stride:stride-workflow. Do NOT invoke from
  a user prompt. Contains the claim API contract and before_doing hook execution
  pattern, used during the orchestrator's claim phase.
```

The description is what the skill matcher reads to decide which skill to load. The original description matched the user's literal phrasing — *"claim a task"* — and pulled the agent past the orchestrator. The reframed version reads as internal-only and the matcher's relevance score drops. Simultaneously, the orchestrator's description was amplified to explicitly enumerate user-intent phrases (`claim a task`, `work on the next stride task`, `complete a stride task`). Now when a user says "claim a task," the matcher's most natural answer is the orchestrator.

This is closer to enforcement, because the matcher is mechanical — it doesn't get tired, it doesn't skim, it doesn't rationalize. But the matcher is probabilistic. A sufficiently specific user prompt or a different matcher implementation in another tool can still pull a sub-skill. Layer 2 reduces the failure rate; it doesn't eliminate it.

**Layer 1 (strongest): a PreToolUse hook on the `Skill` tool that blocks sub-skill invocations unless an orchestrator marker file is present.**

The orchestrator writes a marker on entry:

```bash
mkdir -p "$CLAUDE_PROJECT_DIR/.stride"
printf '{"session_id":"%s","started_at":"%s","pid":%d}\n' \
  "$CLAUDE_SESSION_ID" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$$" \
  > "$CLAUDE_PROJECT_DIR/.stride/.orchestrator_active"
```

The hook reads that marker on every Skill tool invocation. If the requested skill is one of the six protected sub-skills, and the marker is missing or older than four hours, the hook returns:

```json
{"decision": "block",
 "reason": "stride:stride-claiming-tasks can only be invoked from inside
            stride:stride-workflow. Invoke stride:stride-workflow first."}
```

…with exit code 2. Claude Code interprets that as a hard block. The Skill tool call never happens. The sub-skill body is never loaded. The agent can't make the API call because the agent can't even read the API contract.

This is the difference. Layers 2 and 3 *recommend*. Layer 1 *prevents*.

## Aspirations versus guarantees

Here's the framing that finally clicked for me: every word of prose you write to instruct an LLM is an *aspiration*. Every mechanical gate you add is a *guarantee*.

Aspirations have value — they shape behavior in the common case, they reduce the rate of mistakes, they make the system easier to reason about for humans. But they don't bound the worst case. An agent that's tired, distracted by an unusual user prompt, optimizing for speed, or just reading sloppily can blow through any number of "MANDATORY" headers.

Guarantees bound the worst case. The PreToolUse hook doesn't reduce the rate of bypasses; it makes bypass *impossible*.

This applies far beyond LLM tooling. The same logic explains why we use type checkers instead of "please don't pass `null` here" comments, why we use database constraints instead of "the application code shouldn't insert duplicate users," why we use sandboxes instead of "the script promises not to delete `/`." Whenever an action has high cost and a wide blast radius, prose is the wrong layer. The lower in the stack you can install the gate, the harder it is to bypass.

## When prose is enough — and when it isn't

I don't want to overclaim. Prose enforcement is fine in plenty of contexts:

- **Low-stakes deviations.** If the agent picks the wrong style, the wrong variable name, the wrong commit message format — prose guidance is cheap, fast to update, and the cost of a violation is minor.
- **Self-correcting loops.** If a violation immediately produces an error the agent can see and fix, prose plus error messages plus a retry loop is often enough.
- **Cases where a determined user needs to override.** A gate that can't be turned off becomes a wall. Prose with an `allow-direct` escape hatch (or, in the Stride case, both — gate by default, env var to bypass) preserves agency.

Prose stops working when:

- **The violation is silent.** The agent skips a phase, no error fires, and the consequence shows up later — a missing review, an unclaimed task, a corrupted state. By the time you notice, the prompt is gone.
- **The cost of a violation is high.** Pushing to the wrong branch, deleting the wrong file, sending a real Slack message instead of a test one. Prose says "be careful." Gates say "this won't happen."
- **The instruction conflicts with the agent's local incentives.** If the agent is graded on speed, "always invoke the orchestrator first" loses to "skip the boilerplate and just run." Prose can't beat incentives. Gates don't have to.

The Stride orchestrator-bypass case sits squarely in the second and third buckets: the violation was silent (the task entered `doing` looking normal), the cost was significant (skipped pre-work hooks, missing context), and the agent's incentive was always to take the most-direct-looking path. Prose alone was never going to hold.

## The bumper sticker

So: **Prose-only enforcement is unreliable. Mechanical gating works.**

It's not a license to gate everything — gates are expensive to build, they have to be maintained, they need escape hatches, and they fight the agent's autonomy in ways prose doesn't. But for the small set of behaviors that actually have to hold, every time, no exceptions, prose is the wrong tool. Build the gate. The cost of the gate is paid once. The cost of the bypass is paid every session.

If you're shipping a tool, an API, or a workflow that an LLM is expected to follow, ask yourself: which of my "rules" are aspirations, and which need to be guarantees? Treat the answers differently. The first set goes in markdown. The second set goes in code that runs before the agent's chosen action can complete.
