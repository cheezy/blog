---
date: '2026-10-05T19:25:00-04:00'
draft: false
title: 'The Stride Plugin Gets Leaner, Faster and Harder to Fool'
tags: ["AI", "Continuous Delivery", "Stride"]
---

The Stride plugin for Claude Code is what turns a coding agent into a Stride teammate: it claims tasks, explores the code, implements, sends the work through review and completes it. Over the last few releases we went through that loop measuring where time and tokens actually went and why reviewers kept sending work back. Then we fixed what we found.

None of this changes how you start. You still ask the agent to work a task, a goal or the queue. What changes is what happens next: long sessions stay small, reviews settle in fewer rounds, and the agent gets better at catching its own mistakes before a reviewer, or you, has to.

## Long sessions no longer snowball

Ask the agent to work through a goal or your Ready queue, and it now hands **each task to its own isolated runner** automatically. The runner claims the task, explores, implements, gets the review and completes it in its own context, then reports back in a few lines. Your main conversation only sees those short reports, not every file read, diff and review along the way.

You notice this most on long sessions. Before, every task left its whole working history in the main conversation, so the fifth task paid for the first four. Now each task starts from roughly the same place.

On a measured multi-task run, each task added **about 4,000 to 6,000 tokens** to the main conversation. On an earlier run without isolation, tasks at the same points in the session added **109,000 to 205,000**. Only **3.5–6.6%** of the tokens a task used reached the main conversation, against **75–85%** before. The work itself still costs tokens, but it now happens out of the way and is thrown away when the task is done.

A few details:

- **Small, one-file tasks still run in the main conversation.** Starting a separate runner has a fixed cost that a tiny task never earns back.
- **A single task stays in the main conversation** unless you ask for isolation.
- **You can turn it off.** Tell the agent not to isolate tasks, or set `STRIDE_DISPATCHER_MODE=0`, and every task runs in the main conversation as before. Nothing written inside a task can switch this on or off; only you can.

## Reviews settle in fewer rounds

Two changes cut down the review loop.

**Round two has to be earned.** After the reviewer's first pass, the agent fixes what it found. Then it starts a second full review only when it has a reason to:

- the fixes changed actual code (not just docs, comments or test wording);
- the first round found something critical;
- the first round found a security problem of any size.

Otherwise the fixes are recorded in the completion notes, where you can see them, and the task moves on. A typo fix in a changelog no longer buys a whole second review.

**The reviewer sees the task exactly as written.** When the agent claims a task, the plugin saves the full task to a file. The explorer and reviewer read their instructions from that file rather than from the agent retyping them into each request. Retyped copies tended to paraphrase the acceptance criteria, and a reworded criterion is a common reason Stride rejects a completion. Reading the original avoids that.

On the measured run, every task finished with **one** review, against **three** per task at the same points in the earlier run.

## Better first reviews

We also looked at *why* work came back from review. In the period we studied, 29% of reviewed tasks needed at least a second round. Most of the problems were things a careful check could have caught, so the agent and reviewer now do those checks:

- **Every listed test is accounted for.** If a task lists the unit tests, integration tests and edge cases it needs, the reviewer now matches each one to a real test that checks that behaviour. A test with a matching name isn't enough. A listed test that was never written is flagged.
- **New tests have to prove they can fail.** For each test it adds or changes, the agent briefly breaks the code the test protects, confirms the test fails, then puts the code back and confirms it passes. You may see this happen during a task. It catches tests that would pass no matter what. The restore never uses a git command that could throw away uncommitted work, and the agent checks the working tree is exactly as it was before the review starts.
- **Statements get fact-checked.** When a change adds a factual statement to docs, comments, changelogs or instructions, such as "three files", a path, a version number or "this function returns…", the reviewer checks it against the repository. A false statement is flagged with the command that disproved it.
- **Matching files don't get left behind.** When a change touches one half of a matched pair, such as a bash script with a PowerShell twin, or a rule stated in two places, the reviewer checks the other half. If one side changed and the other didn't, it says so.
- **Stale task text is caught early.** Tasks are written when a goal is planned, and earlier tasks in the same goal can make them out of date. The explorer now checks what the task says about the current code before work starts, and lists any contradictions first.

Throughout, the reviewer still never runs your tests or your code. It reads, searches and checks history. Running tests stays with the agent and your normal hooks.

## Better tasks from the start

When the agent writes tasks for you (creating a task, planning a goal, or filling in a sparse task), two things are new:

- **Test plans come with a behaviour/test matrix by default.** Any task with testable behaviour gets a table pairing each behaviour with the test that covers it, across seven categories: happy path, boundaries, errors, empty input, concurrency, wiring and data contracts. Categories that don't apply are marked as such, with a reason. The reviewer later checks each row, so the matrix carries through from planning to review.
- **Tasks are checked for contradictions before they're created.** The agent makes sure each verification step is at least as broad as the requirement it checks, that no instruction contradicts a pitfall or security note, and that each acceptance criterion fits on one line. Where two instructions could conflict, the task says which one wins. Anything it can't settle shows up as an **open question** in the task, rather than being quietly decided for you.

## Fewer interruptions while the agent works

The agent often waits while a helper (the explorer, the reviewer, a task runner) works in the background. Stride's end-of-turn check used to treat that wait as the agent trying to quit with a task still claimed, and blocked it. That cost an extra round trip every time.

The check now lets the agent pause while one of Stride's own helpers is still running, for up to 30 minutes per wait. On the measured run that meant **3** blocks across three tasks, against **2 per task** before. It isn't zero yet: the check can still misread a claim held by a background runner, and we're working on that.

## Less waiting, less reading

Some smaller changes take time and tokens out of every task:

- **Picking the next task is lighter.** The agent now asks Stride for a short summary of the next task and gets the full details once, when it claims it. Before, it downloaded every task twice.
- **The agent can read while it waits.** While the explorer surveys the code, the main agent reads the task's key files and drafts its approach. It still makes no edits until the explorer reports back.
- **The instructions are shorter.** Background and history moved out of the instructions the agent reads on every task into separate reference documents. Every rule and check stays in place.

## You'll know when you're out of date

All of this only helps once it's installed. The agent loads the plugin version on your machine, not the latest release. So the agent now checks at the start of each session and tells you if your plugin is older than the published version:

> stride plugin 1.82.0 is installed but the marketplace publishes 1.85.0 - update with: /plugin marketplace update stride-marketplace, then /plugin update stride@stride-marketplace

It's a one-line note, never a blocker. If it can't reach the network, it stays quiet.

## What we measured, and what we didn't

We measured one multi-task session on the new plugin against an earlier session on an older version, comparing tasks at the same points in each session. The figures above come from that comparison. Three caveats:

- The two sessions ran different tasks, so we compare per task and per request rather than session totals.
- The tasks didn't get faster overall. Average time per task was about 30 minutes on both runs. The gain is a main conversation that stays small without costing extra time.
- The review-quality checks shipped after that measurement. We haven't yet measured how much they reduce second rounds, so we're not quoting a number.

## Getting it

All of this is in Stride plugin **1.85.0**. In Claude Code, run:

```
/plugin marketplace update stride-marketplace
/plugin update stride@stride-marketplace
```

Then start your next session as usual. Ask the agent to work your queue, and the main conversation should stay small all the way to the last task.
