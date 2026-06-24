---
date: '2026-06-24T10:37:00-04:00'
draft: false
title: 'Are Code Reviews and Pull Requests a Thing of the Past?'
tags: ["AI", "Continuous Delivery"]
---

The pull request is one of the most entrenched rituals in modern software development. Open a branch, push your work, open a PR, wait for a colleague to read the diff, address their comments, wait again, and finally merge. We have built entire products, careers, and cultural norms around this loop. It is so universal that most developers have never seriously questioned whether it should exist.

I want to question it. Because once you have an AI-driven workflow that is tuned well, the traditional pull request and the human code review that rides along with it are, in most cases, no longer necessary. That is a strong claim, so let me be careful about what I mean by it - and then let me be equally honest about the fact that plenty of organizations are going to keep requiring reviews anyway, and what the right answer looks like for them.

## What code review was actually for

It helps to remember why we review code in the first place. Strip away the ritual and there are really only a handful of jobs a code review does:

1. **Catch defects** before they reach production.
2. **Enforce standards** - style, architecture, naming, test coverage, security practices.
3. **Spread knowledge** so more than one person understands a given piece of the system.
4. **Create a gate** - a deliberate pause where a second human takes responsibility for what ships.

For decades these jobs were bundled together and assigned to a human reviewer because a human was the only thing capable of doing any of them. The pull request was the container we built to hold all four jobs in one place.

It is worth being honest about how hard that container actually is to do well, because the ritual hides the difficulty. To review a change properly, a person has to reassemble context that lives in a dozen different places. The code is in the repository, but the requirements it is supposed to satisfy are in Jira - or in a Confluence page, or a Slack thread, or a comment on a ticket that links to another ticket. The reviewer has to hold the diff in one window and the acceptance criteria in another and mentally check one against the other, hoping the ticket was actually kept up to date as the work evolved.

The standards are worse. Some of them are written down - a style guide, an architecture decision record, a security checklist - but most of them are not. They live in the heads of the senior developers who have been on the team longest, and they surface only when a change happens to violate one. Two different reviewers will enforce two different sets of unwritten rules, and the same reviewer will enforce different rules on different days depending on what they happen to remember. There is no single authoritative place a reviewer can go to know what "good" means for this codebase, so "good" becomes whatever the person looking at it this time believes it to be.

And all of this competes for attention with the reviewer's own work. A code review is almost never anyone's primary job. It is the thing you do between your own tasks, when a notification interrupts you, on a change someone else is blocked on. It takes the back burner to whatever you were already building, which is exactly why PRs sit for hours or days, why reviews get skimmed under deadline pressure, and why "LGTM" so often means "I trust you and I am busy." The job is genuinely hard - it requires assembling scattered context and applying mostly-undocumented judgment - and we hand it to people in the margins of their day and expect rigor.

The interesting thing about AI-driven delivery is that it pulls these four jobs apart and hands most of them to mechanisms that are faster, more consistent, and available continuously rather than whenever a colleague has a free half hour. It also addresses the fragmentation directly: when the requirements, the standards, and the verification steps are encoded into the task and the loop instead of scattered across Jira tickets and senior developers' memories, the context no longer has to be reassembled by hand every single time.

## Why a well-tuned AI workflow doesn't need the human review

When I say "tuned well," I mean something specific. I mean a workflow where the standards a reviewer used to enforce by hand have been moved down into the loop itself: linters, type checkers, test suites, security skills, and architectural conventions encoded as hooks and subagents that run on every change. I have written before about how [mechanical gating beats prose](/post/mechanical-gating-works) - the same principle applies here. A human reviewer reminding you to add a test is an aspiration. A hook that refuses to complete the work until the test exists is a guarantee.

Walk back through the four jobs with that in mind.

**Catching defects.** A well-configured agent runs the full test suite, runs static analysis, and frequently runs a dedicated review subagent against its own diff before the work is ever called done. This happens on every change, not on the changes a busy reviewer happened to look at closely. The defect-catching job is not removed - it is automated and made continuous.

**Enforcing standards.** This is the job humans were always worst at. Human reviewers are inconsistent: they enforce the rules they remember, on the days they have energy, with a thoroughness that varies wildly with how long the diff is. A skill or a linter does not get tired on a 900-line diff. Standards enforcement is precisely the kind of mechanical work that belongs in code, not in a person's head.

**Spreading knowledge.** This was always the weakest justification in practice. Most PR approvals are rubber stamps - a quick scroll, a "LGTM," and a merge. Real knowledge transfer happened in design conversations and pairing, not in the review tool. And in an AI workflow the relevant context lives in the task definition and the agent's record of what it did, which is more durable than a teammate's fading memory of a diff they skimmed last Tuesday.

**The gate.** This is the one that survives, and it is worth separating cleanly from the other three. Sometimes you genuinely want a human to pause and take responsibility before something ships - not because the machine can't check it, but because the decision carries risk that a person should own. That is a real need. But notice it is a much narrower need than "review every change." It applies to a fraction of the work, and it is about judgment and accountability, not about reading every line of every diff.

So the honest summary is: three of the four jobs are done better by the loop itself, and the fourth - the gate - is real but should be applied surgically, not universally. A workflow that is tuned well has already absorbed jobs one through three. What is left is deciding which changes deserve a human gate.

## But plenty of companies will still require reviews

I am not naive about this. Even granting everything above, a large number of organizations are going to keep requiring pull request reviews on every change for a long time. Sometimes for good reasons and sometimes for bad ones:

- **Regulatory and compliance requirements** that mandate a documented second pair of eyes on changes to certain systems. SOX, HIPAA, and various audit frameworks effectively require a review trail.
- **Contractual obligations** to customers who demand human sign-off.
- **Genuine high-stakes surfaces** - the billing engine, the auth layer, the data-deletion path - where the cost of a defect justifies a human gate regardless of how good the automation is.
- **Organizational trust that hasn't caught up yet.** This is the most common reason, and it is not irrational. Trust in an automated workflow is earned over time, and a company that has not yet built that trust is right to be cautious.

The mistake is to treat all of these the same way the old world did - by routing every single change through the same heavyweight human review. That is what the traditional pull request forces you to do. The better answer is a workflow that lets you apply the human gate exactly where it is needed and nowhere else.

## The traditional approach vs. what Stride does

This is where I want to contrast the old container with what I have built into [Stride](https://stridelikeaboss.com).

In the traditional model, the pull request is the unit of review, and review is binary and ambient. Every change becomes a PR. Every PR sits in a queue waiting for human attention. The reviewer's job is undifferentiated - they look at the trivial copy change and the auth refactor with the same tool, the same ceremony, and roughly the same friction. The result is a system where the low-risk work is over-reviewed and slowed down, while the high-risk work gets the same skim as everything else because the reviewer is drowning in volume. The gate is applied everywhere, which means it is applied carefully nowhere.

Stride takes the gate and makes it an explicit, per-task decision rather than an ambient default.

### The `needs_review` flag

Every task in Stride carries a `needs_review` flag, and what happens when the work is finished depends entirely on it.

![Needs review](/img/needs_review.png)

When an agent finishes the work and runs its validation hooks, what happens next depends on that flag. If `needs_review` is false, the task moves straight to _Done_ - the automated gates have already run, and there is nothing a human gate would add. If `needs_review` is true, the task does not move to _Done_. It moves into a review state and waits for a human.

The crucial design choice is who sets that flag and when. Agents do not get to decide that their own work is exempt from review. A human decides which tasks require a human gate, deliberately, as part of defining the work - marking the auth change and the billing change as `needs_review: true` while letting the routine work flow through on the strength of the automated checks alone. The decision about where to spend human attention is made once, up front, by a person who understands the risk - not implicitly, by the mere fact that a diff exists.

This is the inversion of the traditional model. In the old world, review is the default and skipping it is the exception you have to argue for. In Stride, the automated loop is the default and the human gate is the exception you deliberately mark.

### The Review queue

The flag needs somewhere to land, and that is the Review queue page. Instead of human attention being scattered across a pile of pull requests in a Git host - each one a context switch into a diff view - the tasks that were explicitly marked as needing a human gate collect in one place. A reviewer opens the Review queue and sees exactly the work that a person decided was worth a person's judgment. Nothing else is in there competing for attention.

The difference in experience is the whole point. A traditional reviewer faces a queue that is mostly noise - trivial changes they have to clear to get to the one that matters. A Stride reviewer faces a queue that is all signal, because the filtering happened at task-definition time. When a reviewer approves a task, it moves to _Done_ and any dependent work unblocks; the gate did its narrow job and got out of the way.

The queue also solves the fragmentation problem I described earlier. Remember that the hardest part of a traditional review is reassembling context that lives in a dozen places - the diff in one window, the acceptance criteria in a Jira ticket, the standards in a senior developer's head. Stride attacks that directly with a [task-reviewer subagent](https://github.com/cheezy/stride/blob/main/agents/task-reviewer.md) that runs before the work is ever offered up for a human gate. The subagent receives every field the task supplies - the acceptance criteria, the pitfalls the author explicitly warned against, the patterns to follow, the testing strategy, the security considerations - and checks the diff against each one, item by item. It also reads the project's `CODE-REVIEW.md` and evaluates the change against every standard the team has bothered to write down. The output is a structured report: each acceptance criterion marked met or not met with a file-and-line reference, each pitfall checked, each project standard evaluated.

Here is what that looks like in Stride today.

![Review Queue Summary](/img/review_queue_top_summary.png)

At the top of the review screen sits the summary - a high-level verdict on how the task fared against the criteria it was defined with, so the reviewer knows within seconds whether this is a clean pass or something that needs a closer look. Two buttons drive the decision. **Approve** clears the task and moves it straight to the _Done_ column of the board; the gate did its job and the work ships. **Request change** opens a text area where the reviewer describes what needs to be different, and the task drops back to _In Progress_ for the agent to address the feedback. There is no branch to check out, no PR thread to manage, no second round trip through a Git host - the reviewer's judgment goes straight back to the agent that did the work, and the loop closes.

![Review Queue Details](/img/review_queue_details.png)

Scroll down from the summary and you reach the detail - the full report the task-reviewer subagent produced, laid out section by section. The security considerations are checked off first, then every acceptance criterion appears as its own row: a green pass marker, the criterion in the task's own wording, and a one-line note on the evidence that satisfied it, so a reviewer can see at a glance that all six of six were met and read exactly _why_ each one passed. Below that come the review checks - the testing strategy broken out into unit, integration, and manual tests, then the patterns and pitfalls the task author specified, each with its own verdict. This is the part that replaces the diff-archaeology of a traditional review. Instead of reverse-engineering whether a change did what it was supposed to, the reviewer reads a checklist where the requirements and the evidence sit side by side, already cross-referenced against the actual code.

![Review Queue File Diffs](/img/review_queue_file_diffs.png)

And when the reviewer does want to look at the code itself, it is right there too. Below the checklist sits the full diff for the task - every file the change touched, with the familiar red-and-green line-by-line view and the complete list of affected files. The point is not that the diff disappears; experienced reviewers will always want to read the code for the changes that matter. The point is that the diff is no longer the _starting_ point. It arrives last, after the requirements, the standards, and the verification results have already framed what to look for - so the reviewer reads the code with a checklist in hand rather than a blank slate.

![CODE-REVIEW.md](/img/code_review.png)

This is where the "standards live in a senior developer's head" problem finally gets solved. A team writes down the things it actually cares about in a `CODE-REVIEW.md` file that lives in the repository - one bullet per rule, grouped under headings like _Authentication and authorization_ or _LiveView / context boundary_. These are exactly the unwritten conventions a human reviewer used to enforce inconsistently from memory: no Ecto queries directly in a LiveView, public functions documented, error tuples for fallible operations, no hardcoded colors. Writing them down once turns the tribal knowledge into a checklist the machine can run.

![Review Queue Code Review](/img/review_queue_code_review.png)

And run it the machine does. On every task, the agent reads each line of `CODE-REVIEW.md` and evaluates the diff against it individually. The result is the panel above: every rule the team wrote down appears as its own row, marked either **N/A** when the change does not touch the area the rule governs - a check about LiveView rendering simply does not apply to a pure context-module change - or **MET** with a one-line note pointing at the evidence in the code. Nothing gets skipped because the reviewer was tired, and nothing gets enforced selectively because a particular reviewer happened to feel strongly about it that day. Every rule is considered against every change, every time, and the reviewer can see at a glance which rules were in play and which sat out. The consistency that human reviewers could never quite deliver is exactly what an agent working from an explicit list does best.

## Where this lands

I do not think the pull request disappears tomorrow, and I do not think every team should rip out their review process this quarter. Trust is earned, regulations are real, and some surfaces will always warrant a human pause.

But I do think the era of reviewing every change by hand is ending, and that clinging to it is going to look, in a few years, the way manual deployment looks now - a thing we did because the tools forced us to, long after the underlying need had been automated away. The four jobs of code review have come apart. Three of them belong in the loop. The fourth - the human gate - is real but narrow, and it deserves a tool that treats it as the deliberate exception it is, rather than a tax on every line of code that ships.

Taken to its conclusion, this points at something larger than a better review screen. Stride can become the single place where everything a review needs is pulled together - the requirements, the standards checklist, the verification results, and the diff - and where the human gate, when it is warranted, actually happens. The pull request stops being the container. The task does. And once the task is the container, the Git mechanics that the pull request existed to manage can move underneath it: accepting a task moves it to _Done_, and an `after_review` or `after_goal` hook simply integrates the code - merging the branch, kicking off the deploy, whatever the team's integration step is. The reviewer never opens a Git host, never manages a branch, never clicks "merge" in a separate tool. They make the one judgment that needed a human - approve or request change - and the plumbing follows automatically. The pull request, in other words, does not just become unnecessary; its remaining mechanical job gets absorbed into the hook that fires the moment a human says yes.

That is the bet behind the `needs_review` flag and the Review queue: keep the human gate exactly where human judgment adds value, and let everything else move at the speed the automation has already earned.
