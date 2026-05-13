---
date: '2026-05-12T10:43:42-04:00'
draft: false
title: 'The Security Review Plugin: My latest addition to the Stride plugin library'
tags: ["AI", "Continuous Delivery"]
---

Yesterday I typed the following into Claude Code:

```
/stride-security-review:security-review --full
```

Forty-two agent dispatches and roughly twelve minutes later, I had a 72-finding security review of Stride. The breakdown was sobering: 0 critical, 12 high, 15 medium, 38 low, 7 info. Some of those findings I knew about from having ran a different security review tool. That previous tool found 17 items. The rest were new to me.

Then I spent the rest of the day fixing them - or more accurately watching Claude fix them.

This post is about the plugin that made that possible. What it is, why it works, what it costs, and the honest version of when you should and should not reach for it.

## What it is

`stride-security-review` is a Claude Code plugin. Installing it gives you one slash command and one agent — that's it. No configuration, no SaaS dashboard, no token budget to argue about.

```bash
/plugin marketplace add cheezy/stride-marketplace
/plugin install stride-security-review@stride-marketplace
```

The slash command takes a few flags. The two that matter most:

| Invocation | Question it answers |
|---|---|
| `/stride-security-review:security-review` | Is this PR safe to merge? (diff against `HEAD`) |
| `/stride-security-review:security-review --full` | What latent issues are in this codebase right now? |

Diff mode is the default and the one most teams will actually adopt — it's the PR-time check. Full mode is the one I ran yesterday: it enumerates every tracked text file, batches them in groups of 10, dispatches a `stride-security-reviewer` agent on each batch in parallel, and merges the results.

There are other flags — `--json` for piping, `--maestro` for the seven-layer agentic-AI taxonomy, `--rci` for recursive criticism passes, `--baseline` for suppressing already-acknowledged findings, `--patches` for inline auto-fix diffs. They compose: `--full --maestro --rci 2 --baseline ci.json --patches lib/` is a valid invocation. Read the [README](https://github.com/cheezy/stride-security-review) for the full taxonomy.

## Why it works

There are roughly three things doing the heavy lifting under the hood.

**It's a real agent, not a regex.** A `grep` hit on `eval(` is not a finding; `eval(user_input)` flowing in from an HTTP boundary is. The agent reads the actual diff (or the actual file, in full mode), traces trust boundaries, and writes a description that names the source, the sink, and the realistic worst-case outcome. The output isn't a list of rule IDs — it's a paragraph for each issue that you can hand to a developer who has never seen the codebase, and they will understand what to fix and why.

**It filters its own noise.** The plugin's [README](https://github.com/cheezy/stride-security-review#what-it-deliberately-ignores) lists what the agent will not report: pure denial-of-service, generic rate-limiting concerns (unless they sit on an authentication endpoint), memory exhaustion alone, hypothetical risks not realizable through the changed code, style-as-security. This is the difference between a tool you actually keep in the loop and one you mute after week two. The 72 findings I got on Stride were 72 things I had reasons to act on, not 720 with a 90% triage tax.

**It speaks JSON.** Every finding carries a `vulnerability_class`, a `cwe` array, an `owasp` array, a `severity`, a `confidence`. With `--json` the entire document is pipeable. The Stride hook that auto-commits work after `mix test` could just as easily run `/stride-security-review:security-review --json` and refuse to mark a task `done` if the diff introduces a critical. The plugin doesn't ship that hook — it ships the data shape that makes building it trivial.

## The real story: running it against Stride

Stride is an Elixir/Phoenix kanban app I've been building in the open for months. It has authentication, an API token system, a multi-tenant board model, a metrics dashboard, and a LiveView for every interactive surface. It has 442 tracked files and around 2,700 tests. It is also, until today, a codebase that had never been through a top-to-bottom security review.

The full scan ran for about twelve minutes. The agent dispatched 42 parallel batches, skipped 30 files (29 binaries, one oversized test fixture), and returned a single merged JSON document. The high-severity findings were the ones that mattered. Here are a few examples:

1. **`config/runtime.exs`** had `sockopts: [{:verify, :verify_none}]` on the production SMTP mailer. Translation: every outgoing password-reset email could be intercepted and modified by anyone on a hop between the app and the mail relay. CWE-295. One-line fix.
2. **`api/task_controller.ex`** PATCH and POST actions cast the entire JSON payload into the Task schema. Translation: any agent with a board-scoped API token could `PATCH` a task to `{"status": "completed", "review_status": "approved", "completed_by_id": <victim>}` and bypass every workflow gate. CWE-915. Two related fixes, one strict allow-list changeset per direction.
3. **`metrics_excel.ex`** wrote `task.title` and `board.name` verbatim into Excel cells. Translation: a title like `=cmd|'/C calc'!A1` would execute the formula on whoever opened the export. CWE-1236. Twenty-line fix: one `safe_text/1` helper, applied at every cell construction site.
4. **`board_live/show.ex`** had seven places where `Columns.get_column!(id)` or `Tasks.get_task!(id)` ran on a client-supplied id with no board-scope check. Translation: an owner of board A could `delete_column` against a column id from board B and the LiveView would oblige. CWE-639. The fix was to replace each with the existing `*_for_board/2` variants — defenses that already shipped in the codebase but weren't being used at every call site.

None of these were exotic. None required novel exploit research. All of them sat in code that had passed test runs, static code analysis, and security scans for months. The combination of `verify_none`, mass-assignment, formula injection, and unscoped IDOR is what auditors find on the first sweep of every codebase, and the only reason they aren't critical is that this app doesn't run a Federal Reserve. They would be critical on the next thing I ship.

## How the workflow actually went

The plugin gives you findings. It does not, on its own, fix anything. The interesting part of today was the workflow that wrapped around the findings.

After the scan I asked Claude to write the results into a file. After I completed a review of the contents of the file, I asked Claude Code to create a goal and tasks for the high-severity items and add them to Stride. I did the same for the medium-severity and low-severity items as well. Then I told it to start claiming tasks from Stride.

For each task: claim it, dispatch a `task-explorer` subagent to map the call sites, implement, run a `task-reviewer` subagent against the diff, hook the test suite, commit. By dinnertime all of the tasks were completed. Test count went from 2,690 to 2,762 — 72 new regression tests asserting the exploit no longer works.

The agent did not invent any of those fixes. The fixes were already obvious once the finding was articulated clearly. What it bought me was the cycle time. Instead of one finding per afternoon, it was one task per five-to-ten minutes, with a dispassionate reviewer subagent calling out the things I would have missed.

If you ever wondered what the AI-driven development loop is supposed to look like, this was it: the same person doing the work, but with the boring parts of "find the issue, explain the issue, write the test, run the suite" handled by something that doesn't get tired between the second and twelfth invocation.

## What it costs

Honest accounting:

- **Tokens.** Every batch in a full scan is an agent dispatch. Forty-two batches for Stride wasn't free. The diff-mode default is much cheaper — single dispatch, single file. As a rule, run `--full` on a cadence (quarterly, on every release branch, before vendoring an upstream), and run the diff mode on every PR.
- **False positives.** The agent's filter is good, not perfect. On the 72 findings I got, I disputed exactly one (a "low" about a `.bak` file that was already excluded by git ignore in a follow-up). Your mileage will vary by language and by how much LLM/agent code you have — the framework-specific rule packs (Django, Phoenix, Rails) and the MAESTRO-derived agentic-AI classes have less wear on them than the core ten.
- **Findings that need humans.** Three of Stride's medium findings were supply-chain pinning tasks that I unclaimed and left for interactive work later — they needed real commit SHAs from upstream repos and SHA256 digests from Docker Hub, and getting a SHA wrong breaks CI. The plugin correctly identified them. Acting on them required a person at a keyboard. That's the right division of labor.

## When to reach for it

Reach for diff mode (`/stride-security-review:security-review`):

- On every PR that touches authentication, authorization, user input handling, cryptography, secrets, database queries, shell-outs, file uploads, redirects, or response rendering.
- Before merging anything that changes a Dockerfile, CI workflow, or production config.
- As the final pre-push check on any branch you can't easily revert.

Reach for full mode (`/stride-security-review:security-review --full`):

- When you onboard the plugin onto an existing repo. You want a baseline before you start gating PRs.
- On a quarterly cadence. The codebase changes underneath you; latent issues accumulate.
- When you vendor or fork an upstream codebase and intend to ship it.
- When something tangentially related has been disclosed in the wider ecosystem and you want a fresh sweep.

Do not reach for it when:

- You need provable correctness (formal verification, fuzzing, manual code review against a threat model — those are different tools).
- You're auditing a binary, a closed system, or a runtime configuration that isn't checked into the repo.
- You want it to fix things autonomously without you looking. The findings are good. The fixes are still yours (and Claudes') to write and verify.

## Where to get it

The marketplace is public. The plugin is MIT-licensed. The agent prompt is a markdown file you can read and fork. Issues at <https://github.com/cheezy/stride-security-review>.

```bash
/plugin marketplace add cheezy/stride-marketplace
/plugin install stride-security-review@stride-marketplace
/stride-security-review:security-review --full
```

If you find a finding it should have caught and missed, that's the contribution shape that helps most — open an issue with the smallest possible reproducing diff. The agent prompt has a documented template for extending vulnerability classes and framework packs. Adding a new framework pack (Spring, Express, Gin, Laravel, FastAPI) is a single PR.

That is the plugin. Twelve minutes to ask the question, the rest of an afternoon to do something about the answer. There are worse trades.
