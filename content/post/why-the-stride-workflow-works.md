---
date: '2026-11-22T11:11:00-05:00'
draft: false
title: 'Why the Stride Workflow works so well'
description: "Why the Stride workflow works for teams building software with AI agents: rich tasks, enforced quality gates, targeted human review and clear insight."
tags: ["AI", "Agile", "Continuous Delivery", "Stride"]
---

Most teams start with AI agents the same way: a developer opens a chat window, describes what they want, and watches the agent write code. For one person on one change, that works. For a team it falls apart quickly. Nobody else can see what the agent was asked to do. The requirements live in one developer's prompt history. Two agents change the same file at the same time. Quality depends on whether the developer remembered to ask for tests. When the work is done, the reviewer has a diff and nothing to judge it against.

[Stride](https://www.stridelikeaboss.com) exists because I kept running into those problems, first on my own projects and then with clients. Over the past year it has grown from a kanban board with an API into a platform and a set of agent plugins that together define one way of working. I've written about many of the pieces individually. This post pulls them together and explains why the whole works as well as it does, especially for teams.

The short version: **people own deciding what to build and judging what was built; agents own the building; and the workflow between them is enforced, not suggested.** Everything below is a consequence of that idea.

## The board is the contract

Every AI-optimized board in Stride has the same five columns: **Backlog**, **Ready**, **Doing**, **Review** and **Done**. The product page describes it in one line: people specify in Backlog, agents pull from Ready, and people review in Review.

That simple layout does a lot of work.

- **Backlog is the human staging area.** Agents never take work from the Backlog. It's where people sharpen the scope of each task, confirm it has a clear reason and acceptance criteria, add context, and decide which tasks they want to review when they're finished.
- **Ready is the contract.** Dragging a task into Ready is the go signal. It says "this is specified well enough that an agent can build it without asking me anything." Agents claim only from Ready.
- **Doing, Review and Done are where the agents work**, and where people step back in only when they've asked to.

Because the rules are the same on every board, everyone on the team knows what a card's position means. A task in Ready has been looked at by a person. A task in Review is waiting on a person. A task in Done passed every gate the team defined. Nobody has to ask.

## Start from a real specification, not a one-line prompt

An agent can only build what it understands, and a backlog full of one-line tasks forces it to guess. The [stride-ideation](https://github.com/cheezy/stride-ideation) plugin fixes this before a single task reaches the board.

1. **`/ideate`** runs an interactive question-and-answer session that turns a fuzzy idea into a committed requirements document covering the goal, the problem, the outcome, assumptions, constraints, non-goals and success metrics.
2. **`/stridify`** decomposes that document into a goal with small, dependency-ordered tasks and sends them to Stride.
3. **The goal and its tasks land in the Backlog**, where people curate them before moving them to Ready.

The requirements document is committed to the repository, so the reasoning behind the work is kept alongside the code it produced. And because the agent does the decomposition, the team gets the volume of well-formed tasks it needs. As I wrote in [The Stride Workflow](/post/stride_workflow/), you will need a lot more tasks in Ready than you think. Agents work fast, and several developers each running agents will empty a backlog quickly.

## The task carries the context

The biggest single lesson I learned building Stride is that the shape of the task matters more than the prompt. I described how I arrived at that shape in [What is a task?](/post/what-is-a-task/). A Stride task carries far more than a title:

- **Why** it matters and **what** to build
- **Where** it lives in the code, and the **key files** it will touch
- **Acceptance criteria** that define done
- **Patterns to follow** from the existing codebase
- **Pitfalls** to avoid
- A **testing strategy** with unit tests, integration tests, manual tests and edge cases
- **Verification steps**, **security considerations** and the **telemetry and logging** it needs
- **Dependencies**, **priority**, **complexity** and whether it **needs review**

Most of that is written by the agent during planning, so people don't have to type it all. People review it and adjust it. Then, possibly days later and in a completely different session, a different agent claims the task and has everything it needs to work without a round trip. That separation between planning and building is what lets the work be shared. The developer who planned a task doesn't have to be the one whose agent builds it.

The same fields that guide the agent become the standard the finished work is judged against. People review against criteria they wrote. Agents record their actuals, such as the complexity they experienced, the files they actually changed and the time spent, so the team can compare them with the estimates and get better at planning.

## Stride decides what's next, so agents don't collide

When several agents from several developers ask for work at the same time, something has to decide who gets what. In Stride, the server does. When an agent asks for the next task, Stride only considers tasks that are:

- in the **Ready** column and not already claimed (or whose claim has expired);
- **unblocked**, meaning every task they depend on is Done;
- a **match for the agent's capabilities**; and
- **free of file conflicts**, meaning none of the task's key files are being changed by another task in Doing or Review.

From what's left, the highest priority task nearest the top of the Ready column wins. Claims are atomic, so two agents can never claim the same task, and a claim that isn't completed expires so the work goes back to the pool.

This is the part teams notice first. Without it, parallel agents create merge conflicts faster than people can untangle them. With it, five agents can work through the same backlog without stepping on each other, and nobody has to coordinate it by hand.

## A fixed loop with gates that can't be skipped

Once a task is claimed, the agent runs the same loop every time. The [Stride plugin](https://github.com/cheezy/stride) carries the task from claim to completion with hooks, subagents and skills:

1. **Claim.** The `before_doing` hook runs on the developer's machine: pull the latest code, fetch dependencies, run migrations, so the agent starts from a known state.
2. **Explore.** A read-only `task-explorer` subagent reads the key files, finds the tests that cover them and looks for existing patterns. For medium and larger tasks, a planner turns that map into a step-by-step plan.
3. **Implement.** The agent writes the code and its tests, guided by the task, the explorer's map and the plan.
4. **Review.** A `task-reviewer` subagent checks the diff against the task's acceptance criteria, pitfalls, patterns and testing strategy. If the project has a `CODE-REVIEW.md` file, every bullet in it becomes a review check. Critical and important findings must be fixed and re-reviewed before the task can move on.
5. **Validate.** The `after_doing` hook runs your quality gate: the full test suite, formatting, static analysis, security scanning, the build. If anything fails, the task does not complete. The agent fixes the problem and runs the hook again.

Optional gates slot into the same loop. When the [security review plugin](/post/the-security-review-plugin/) is installed and a task lists security considerations, a security reviewer checks the same diff. When the [exploratory testing plugin](/post/stride-exploratory-testing-sharper/) is installed and a task lists manual tests, a time-boxed exploratory session runs against a safe, non-production copy of the app.

Two things make this loop trustworthy.

**The gates are yours.** Hooks are plain shell commands in a `.stride.md` file at the root of your project. Stride doesn't impose a test framework or a linter. It runs whatever your project already runs, at fixed points in the loop, on the developer's own machine.

**The gates are enforced.** Early on I learned that agents skip steps they're only asked to follow. I wrote about it in [Prose-Only Enforcement Is Unreliable. Mechanical Gating Works.](/post/mechanical-gating-works/). Today the plugins block out-of-order steps, and the API won't accept a claim or a completion without the results of the hooks that were supposed to run. The task records which workflow steps actually ran and what the reviewer found, so there is evidence, not just a claim that it was done.

This is what turns "the agent usually writes tests" into "nothing reaches Done in a broken state."

## Human review exactly where it matters

Some changes deserve a person's sign-off before they ship. Most don't. Routing every change through the same heavyweight review, as the traditional pull request does, wastes your scarcest resource. I made the full argument in [Are Code Reviews and Pull Requests a Thing of the Past?](/post/code-reviews/).

Stride lets the team decide per task, during backlog refinement, using the **Needs Review** checkbox.

- **When `needs_review` is true**, the completed task stops in the Review column. It shows up in the review queue, the shared list of finished work waiting on a person, oldest first with how long each has waited. The reviewer sees the completion summary, the full diff file by file, and the [task-reviewer's report](/post/review-report/): evidence for each acceptance criterion, and how the work did on the testing strategy, patterns and pitfalls. They approve, or they request changes with notes the agent picks up. On approval the `after_review` hook fires to merge, deploy or notify, and the task moves to Done.
- **When `needs_review` is false**, the task never pauses. It goes straight to Done, the `after_review` hook fires, and the change ships with no one waiting on it.

Either way, the agent moves on to the next task in Ready and keeps going until Ready is empty. Only a task that asked for review holds up the run.

This changes what a reviewer does. They're no longer reassembling context from a ticket, a Slack thread and a diff, then re-reviewing everything from scratch. The requirements, the standards and the automated review are all in front of them. Their job becomes judging whether the result is right and checking what the machine might have missed. That's a much better use of a person's attention, and it's why review doesn't become the bottleneck as the agents speed up.

## Works with the agent your team already uses

Teams rarely agree on one coding agent, and they shouldn't have to. Stride has [plugins](/post/stride-new-plugins/) for Claude Code, GitHub Copilot CLI, Gemini CLI, Codex CLI, OpenCode and Pi. Each one teaches the same loop: claim a task, run the hooks in `.stride.md`, do the work, complete it. On paid boards, any MCP client can also work the board through Stride's [MCP server](/post/stride-mcp/).

The result is that one developer using Claude Code and another using Codex work the same board, under the same gates, and their work is reviewed the same way. The workflow belongs to the team, not to a tool.

## Insight into how things are progressing

When agents do the building, work moves faster than anyone can follow by watching the board. A team needs to know how things are going without asking anyone, and without someone assembling a status report. Stride gives everyone the same view, at every level from a single task up to a dated release.

### Progress at a glance

- **The Boards page** shows every board you belong to, with how many tasks are in To Do, Doing, Review and Done, how many were finished over the last 14 days, and when work last moved. It refreshes every 30 seconds, so a stalled board stands out.
- **Goals track their own progress.** Every goal shows how many of its tasks are complete, with a progress bar split by column, so you can see at a glance whether the remaining work is waiting in Backlog, being built in Doing or sitting in Review.
- **The Agents page** shows each agent as working, waiting for review or idle, with its completions today and over seven days, its success rate and its claims, plus a live feed of claims, completions and reviews. An agent holding a task too long, or one that has gone quiet, is flagged as stalled.
- **My Work** lists every open task assigned to you across all your boards, most urgent first.

### Delivery targets

Goals tell you how a piece of work is going. Most teams also have to answer a harder question: *will we make the date?* That's what **delivery targets** are for.

A delivery target is a name and a date, such as "Mobile release, December 15". You attach goals to it, and they can come from any of your boards, so one target can cover the mobile team's goals, the platform team's migration and the API work they depend on. The target's page shows the combined progress of all its goals as one segmented progress bar, with a row for each goal showing where its tasks are.

The most useful part is that **Stride estimates the completion date for you**, and nobody has to update it. The estimate comes from how the team has actually been working:

1. Stride looks at every task already completed on the boards the target's goals live on, and takes the **median lead time**: the typical time from a task being created to it reaching Done.
2. It counts the **tasks remaining** across all of the target's goals.
3. It multiplies the two and counts forward from right now. The day that lands on is the estimated completion date.

For example, if tasks on those boards typically take four hours from creation to Done and 30 tasks remain, the estimate is five days from now. As tasks finish, the remaining count drops and the date moves. As the team's history grows, the median reflects how it works today. There is no velocity to calculate and no burndown to maintain.

Stride then compares the estimate with the date you committed to and gives every target one of four statuses:

- **On track:** nothing suggests the target will be late.
- **At risk:** either the estimated completion date falls after the target date, or the share of work completed is more than 15 percentage points behind the share of the calendar that has passed. A target that is 40% done when 60% of its time has gone is at risk, even if the estimate hasn't slipped yet.
- **Missed:** the date has passed and the work isn't finished.
- **Complete:** every goal on the target is done.

The status is calculated from the current state of the work every time you look, so it can never go stale. When a target you own becomes at risk or misses its date, Stride notifies you once, rather than every hour after. On the Agents page, an at-risk target comes with an explanation: the goals that are stalling it and the stuck or idle agents behind them. The target's owner, or the board's owner, can reassign or reprioritize a stalled goal right there.

This is what turns "how's it going?" from a meeting into a glance. The Product Owner can see every target across every team's boards, which ones are at risk and why, and act on it.

### Metrics

Targets tell you whether you'll make a date. [Metrics](/post/metrics/) tell you how the work is flowing so you can improve it. Every board has a Metrics Dashboard with four measures:

- **Throughput:** how many tasks are completed each day.
- **Cycle time:** how long a task takes from being claimed to being completed, which is the time spent actively working on it.
- **Lead time:** how long a task takes from being created to being completed, including the time it waited in Backlog and Ready.
- **Wait time:** how long work sits idle, split into time waiting in the backlog before an agent claims it and time waiting in Review for a person to look at it.

You can look at today, the last 7, 30 or 90 days, or all time, with or without weekends. On an AI-optimized board you can narrow the numbers to a single agent. Each metric has its own page that exports to PDF or Excel.

Above the boards, workspace metrics show median cycle time, median lead time, throughput and review wait time across all the boards you choose, along with cumulative flow and a leaderboard of the agents and people finishing work.

Review wait time deserves a special mention. In an agent-driven team the risk is rarely that the agents are slow. It's that finished work piles up waiting for a person. Seeing that number grow is the early warning to rebalance which tasks get the **Needs Review** flag, or who is reviewing them.

Two more sources of insight round this out. On AI-optimized boards, the **Compliance** page shows how often agents ran each workflow step and why they skipped any they didn't run, so you can confirm your gates are actually being followed. And [task telemetry](/post/telemetry/) sends events for claims, completions, reviews and hook results to the dashboards and alerts your team already uses.

## Built for teams

Everything so far would help a single developer. What makes Stride a team platform is that the work stays visible to everyone, and that it can be run the way your organization runs everything else.

**Hear about work where you already are.** [Notifications](/post/stride-notifications/) tell you when something needs you, such as a review request, an assignment, a released claim or an at-risk target, in Stride, by email, or in a weekly digest. Board events can go to [Slack, Discord or your own webhook](/post/webhooks-slack-discord/), so the team hears about finished work in the channels it already uses.

**Talk about the work on the work.** Every task has a [comment thread](/post/stride-comments-know-who/) where people and agents discuss it together, and every comment shows who wrote it, human or agent. Type **@** and part of a name to mention a teammate on the board. They're notified in Stride and by email, and the link takes them straight to the comment, outlined so they can find it even in a long thread. Agents can read and post comments through the API too, so an agent can answer a question from a reviewer, or @mention the SME when a requirement is unclear, in the same place everyone else is talking. When an agent mentions you, the notification names both the agent and the person it was working for. The conversation stays attached to the task, so the next person to pick it up has the whole story.

**Govern it like the rest of your systems.** An [Organization](/post/organizations/) groups boards into [workspaces](/post/workspaces/), typically one per team, each with its own members and boards. Org-admins can require [two-factor authentication](/post/stride-two-factor-authentication/), connect [single sign-on](/post/single-sign-on/) and SCIM provisioning, and read or [stream](/post/audit-log-streaming/) the [audit log](/post/stride-audit-log/).

### How it fits the team

In [Scaling the New Team](/post/scaling-the-new-team/) I described the team I now recommend: a subject-matter expert and two engineers, with a thin layer of leads above several teams. When building stops being the bottleneck, the constraint moves to deciding what to build and judging what was built. Stride's workflow is shaped around exactly those two constraints:

- **The SME** owns the Backlog. They run ideation, sharpen tasks, set priorities and decide which tasks need review.
- **The engineers** own the gates: the hooks in `.stride.md`, the rules in `CODE-REVIEW.md`, and the review queue. They judge what the agents built and review each other's changes.
- **The Quality Lead** uses the Compliance page, the review wait times and the optional security and exploratory testing gates to confirm the work is ready for production.
- **The Developer Lead** keeps the hooks, the pipelines and the cross-team dependencies coherent, and watches cycle time and the Agents page for work that is stuck.
- **The Product Owner** works at the level of goals and delivery targets. Stride's estimates and at-risk warnings show them progress across every team's boards without asking for a status report.

Each role has a place on the board, and the board shows each of them what they need. That's why the same small team can deliver several times what a larger traditional team did. Almost none of its time goes to coordination, because the workflow is doing the coordinating.

## Why it works

Pull all of this together and the reasons are simple:

1. **Clear handoffs.** People specify in Backlog, agents pull from Ready, people review in Review. Everyone knows whose move it is.
2. **Context that survives.** The task carries the why, the what and the how from planning into building and on into review.
3. **No collisions.** Dependencies, capabilities and key files decide who works on what, so parallel agents don't fight.
4. **Guaranteed quality.** Your own gates run on every change, and they can't be skipped.
5. **Review where it counts.** People sign off on the changes that need judgment, with the evidence in front of them, and everything else flows.
6. **One workflow for every agent.** The team's process doesn't depend on which tool each developer prefers.
7. **Insight without status reports.** Goal progress, delivery targets with automatic completion estimates, flow metrics and compliance keep the whole team, and the people above it, informed without meetings.

None of these ideas is new on its own. Kanban, definition of done, continuous integration and targeted review have been around for a long time. What's new is that agents will follow them every time when the workflow enforces them, and that frees the people on the team to spend their time on the two things only they can do well.

If you want to see it run, drop a `.stride.md` in your project, get an API token for your agent, and point it at a board. Stride is free for individuals and small teams, and free to self-host. You can [get started here](https://www.stridelikeaboss.com).
