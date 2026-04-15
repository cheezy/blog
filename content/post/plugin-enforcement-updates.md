---
date: '2026-04-14T19:44:22-04:00'
draft: false
title: 'Stride Plugin Updates: From "Go Fast" to "Go Right"'
tags: ["AI", "Continuous Delivery"]
---

During a recent session on a friends computer where an AI agent implemented 17 Stride tasks back-to-back,I discovered something uncomfortable: the agent skipped nearly every mandatory workflow step. The `task-explorer` was used once, then never again. The `task-reviewer` was never invoked. The `hook-diagnostician` was never called when hooks failed. The `stride-subagent-workflow` skill — labeled MANDATORY — was ignored entirely. This was shocking to me as I have not see this on my own computer. I realized that I had enough contained in my configuration to force the agent to do what I wanted but not everybody had that config.

The agent wasn't malfunctioning. It was optimizing. Given competing instructions to "follow every step" and "work continuously without stopping," it resolved the tension by choosing speed over process. And every skill it skipped was one the system allowed it to skip.

This led us to a core insight that shaped everything I did today:

> **Instructions the agent can ignore will eventually be ignored under pressure. Gates the agent cannot bypass will always be followed.**

## Root Cause Analysis

I identified four root causes:

1. **Instructions without enforcement are eventually ignored.** Skills said MANDATORY, but nothing prevented the agent from skipping them. The API accepted completion requests without evidence that exploration or review had occurred.

2. **Too many disconnected skills.** Agents had to remember to invoke 6+ separate skills at specific moments in a workflow. Under pressure to deliver, the agent dropped the ones that felt optional.

3. **Conflicting emphasis.** The `AUTOMATION NOTICE` sections in the claiming and completing skills emphasized "work continuously without ANY user prompts." This primed agents to prioritize throughput, which they generalized to skipping process steps.

4. **No hard gates.** The `after_doing` and `before_review` hooks are enforced because the API rejects requests without their results. The subagent steps (exploration, review) had no equivalent enforcement.

## What I Changed

Today's work addresses the first three causes through five coordinated changes across all five Stride plugins (Claude Code, Copilot CLI, Gemini CLI, Codex CLI, OpenCode) and all supporting documentation.

### 1. Reframed Automation Notices

**The old messaging:**

> "This is a FULLY AUTOMATED workflow. Do NOT prompt the user between steps."
> "The agent should work continuously without asking 'Should I continue?'"

**The new messaging:**

> "The workflow IS the automation. Every step exists because skipping it caused failures."
> "Following every step IS the fast path. Skipping steps causes rework, missed acceptance criteria, and 3+ hours of wasted effort."

The new text preserves the "don't prompt the user" instruction — that part was correct — but explicitly lists the mandatory steps and frames following them as the fast path rather than an obstacle to speed.

### 2. The stride-workflow Orchestrator

This is the biggest change. Instead of requiring agents to remember 6+ separate skills and invoke each at the right moment, I created a single `stride-workflow` orchestrator skill.

An agent invokes it once after deciding to work on Stride tasks, and the skill walks through the complete lifecycle:

```
stride-workflow invoked
  → Step 0: Prerequisites check (.stride_auth.md, .stride.md)
  → Step 1: Task discovery (GET /api/tasks/next)
  → Step 2: Claim the task (with before_doing hook)
  → Step 3: Explore the codebase (subagent dispatch or manual review)
  → Step 4: Plan implementation (conditional on complexity)
  → Step 5: Implement the changes
  → Step 6: Code review (subagent dispatch or self-verify)
  → Step 7: Execute hooks (after_doing, before_review)
  → Step 8: Complete the task (PATCH /api/tasks/:id/complete)
  → Step 9: Loop back to Step 1 or stop
```

The orchestrator adapts to each platform:

| Platform | Exploration | Review | Hooks |
|----------|-------------|--------|-------|
| **Claude Code** | Subagent dispatch (task-explorer) | Subagent dispatch (task-reviewer) | Automatic via hooks.json |
| **Copilot CLI** | Custom agents (explorer, reviewer) | Custom agents | Manual execution |
| **Gemini CLI** | Custom agents | Custom agents | Automatic via tool.execute hooks |
| **Codex CLI** | Custom agents with fallback | Custom agents with fallback | Manual execution |
| **OpenCode** | Custom agents with fallback | Custom agents with fallback | Automatic via tool.execute hooks |

The individual skills (`stride-claiming-tasks`, `stride-completing-tasks`, etc.) remain fully functional for standalone use — resuming a partially completed task, or agents that need just the API format. But the orchestrator is the recommended entry point.

### 3. Claiming Gate

All five plugins' claiming skills now include a non-negotiable gate after a successful claim. Instead of a gentle "Recommended: Use the Workflow Orchestrator" section, the claiming skill now demands orchestrator invocation as the next step. The standalone mode section includes a workflow violation warning.

This is defense-in-depth: if an agent skips the orchestrator and invokes the claiming skill directly, it still gets pushed back toward the orchestrator.

### 4. Completion Verification Checklist

All five plugins' completing skills now include a 4-item verification checklist before the agent can call the completion endpoint:

1. Did you activate `stride-workflow` after claiming?
2. Did you explore the codebase (key_files, patterns, related tests)?
3. Did you review your changes against the acceptance criteria?
4. Are you ready for the `after_doing` hook (tests pass, credo clean)?

If any answer is no, the agent is instructed to go back and complete the step before proceeding. This is the last line of defense before the API call.

### 5. Workflow Telemetry 

A "Workflow telemetry and compliance tracking" item was also added to the plugins and Stride. Each completion now carries a `workflow_steps` array recording which of the six phases (`explorer`, `planner`, `implementation`, `reviewer`, `after_doing`, `before_review`) ran — or were legitimately skipped per the decision matrix, with a `reason` string. The array added to all `Tasks` (JSONB), exposed via the task JSON view, and aggregated to power a new compliance dashboard accessible view the Metrics page.

All five plugins were updated to collect and submit the array. This closes the observability gap that made the original 17-task skipping invisible until manual review. Compliance is now measurable per-task, per-agent, and in aggregate.


### 6. Documentation Updates

Every piece of supporting documentation was updated to reference the orchestrator and use the new process-over-speed messaging:

- **AI-WORKFLOW.md** — `stride-workflow` as the primary entry point, reframed all CRITICAL notices
- **GETTING-STARTED-WITH-AI.md** — `stride-workflow` in all five platform sections
- **MULTI-AGENT-INSTRUCTIONS.md** — Updated skills lists for Claude Code, Copilot, and Gemini
- **REVIEW-WORKFLOW.md** — Orchestrator in the continuous work loop
- **AGENT-HOOK-EXECUTION-GUIDE.md** — Orchestrator reference in overview
- **STRIDE-SKILLS-PLAN.md** — All deployed skills listed
- **Onboarding endpoint docs** — Updated with `stride-workflow` reference

## Plugin Releases

All changes shipped today in coordinated releases:

| Plugin | Version | Key Changes |
|--------|---------|-------------|
| **stride** (Claude Code) | 1.8.0 | Orchestrator, reframed notices, claiming gate, verification checklist |
| **stride-copilot** | 2.4.0 | Same changes, adapted for Copilot's `activate` syntax |
| **stride-gemini** | 1.4.0 | Same changes, with tool.execute hook integration |
| **stride-codex** | 1.3.0 | Same changes, with graceful fallback for agents |
| **stride-opencode** | 1.3.0 | Same changes, with tool.execute hook integration |

## Design Principles

Three principles guided today's work:

**1. Recommend without removing.** The orchestrator is the preferred path, but individual skills remain fully functional. An agent resuming a partially completed task shouldn't need to restart the entire orchestrator flow.

**2. Defense in depth.** Three layers of enforcement now exist: the orchestrator guides agents through every step; the claiming gate catches agents that skip the orchestrator; the completion checklist catches agents that bypassed both. No single layer needs to be perfect.

**3. Reframe, don't restrict.** The original automation notices weren't wrong about "don't prompt the user." They were wrong about what "fast" means. The new messaging keeps the correct instruction and reframes speed: following the process IS the fast path, because skipping steps causes rework that takes longer than the steps themselves.

## What's Next

The soft enforcement gates are a necessary foundation, but the core insight remains: instructions the agent can ignore will eventually be ignored. The next phase focuses on hard gates — API-level enforcement that makes skipping exploration or review structurally impossible, and skills version enforcement to ensure agents run the latest process.

The goal isn't to make agents slower. It's to make the fast path and the correct path the same path.
