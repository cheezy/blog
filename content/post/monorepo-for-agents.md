---
date: '2026-11-18T08:52:00-05:00'
draft: false
title: 'Why Your Agent Needs a Monorepo'
description: "Split frontend and backend repositories make AI agents build features in pieces. Why a monorepo and vertical slices fix it, and what to do if you can't move."
tags: ["AI", "Agile", "Continuous Delivery"]
---

In [Scaling the New Team](/post/scaling-the-new-team/) I listed five things that have to be in place for a small AI-driven team to deliver. One of them was that **the agent can see everything**: all the code is in source control the agent can read, and I prefer a monorepo or, if that isn't possible, a meta-repo. That's one line in that post, but it trips up more organizations than any of the other four. So this post is about that one line.

The short version: if your application is split across a frontend repository and a backend repositories, with frontend developers working in one and backend developers working in the other, your agents will build every feature in pieces. Each piece is built by an agent that can only see half of the change. That's an antipattern, and the fix is to restructure the code, and the team, so that one agent can see and change every layer at once.

## The antipattern: frontend developers and backend developers

Most teams I meet are organized like this. The web application lives in one repository and the API lives in another. Sometimes the database migrations live in a third. Frontend developers work in the first, backend developers work in the second, and the two sides agree on an API contract that lives somewhere else: a wiki page, a comment on a ticket, a thread in a chat channel.

![Two repositories, two developers, two halves of one change. On the left, a web-app repository with its frontend developer and Agent A, outlined as what Agent A can see. On the right, an api-service repository with its backend developer and Agent B, outlined as what Agent B can see. Between them, the API contract is a wiki page, a ticket comment or a chat thread. Each agent sees one side, and neither agent can see the whole feature](/img/monorepo-split-repos.png)

When each developer adds an agent, the structure stays exactly the same. The frontend developer's agent works in the frontend repository and the backend developer's agent works in the backend repository. Each agent is very good at the half of the feature it can see. Neither of them can see the feature.

## A change made in pieces

Here's what that looks like for a small feature: show the delivery window on an order.

![The same change made in pieces and made whole. Split across two repositories, with two tickets, two agents and two reviews: on day 1 the story is split into a backend ticket and a frontend ticket; on day 2 Agent B adds delivery_window to the API and ships it; on days 3 and 4 the frontend ticket waits for the next free developer; on day 5 Agent A reads the ticket and guesses the response shape; on day 6 integration breaks because the field name and the date format disagree; on days 7 and 8 there is rework in both repositories, reviewed twice, then shipped. In one repository, with one ticket, one agent and one review: on day 1 one agent changes the migration, the endpoint, the screen and the tests for every layer in one commit, the build tells it straight away if the layers disagree, and the change is reviewed once and shipped. No hand-off, no waiting, nothing guessed](/img/monorepo-change-in-pieces.png)

The story is split into a backend ticket and a frontend ticket, because that's how the work is organized. The backend agent adds the field to the API and the change ships. The frontend ticket waits until a frontend developer is free. When it's picked up, the frontend agent reads the ticket, maybe the wiki page, and builds the screen against the response it expects. It expects a `deliveryWindow` with a start and end date. The API returns `delivery_window` as a single string. Nobody finds out until the two halves meet, and then both repositories need rework, two more reviews and another wait.

None of this is new. Teams split this way have always paid for hand-offs, waiting and integration surprises. What's new is the ratio. When building a change takes the agent an hour, the days spent waiting for the other half become almost all of the time it takes to deliver the feature. The agent didn't make delivery faster. It made the queue more obvious.

## Why it's worse with an agent

When two people split a feature, the gap between them is filled with conversation. The frontend developer walks over, or sends a message, and asks what the field is called. It's slow, but it works.

An agent doesn't walk over. It works from what's in front of it: the code in its working directory, the ticket, and whatever documents you gave it. When the answer to a question is in the other repository, the agent doesn't stop and ask. It fills the gap with the most plausible answer it can come up with, and plausible answers look correct. The field name it guesses follows the conventions of its own codebase. The error handling it writes handles the errors it imagines the API returns. Its tests pass, because its tests are built on the same guesses.

![Half the code means guessing, all the code means checking. An agent in one of two repositories has to guess the field names the other side uses, the date, money and ID formats it sends, which errors come back and when, whether the other side's tests still pass, and what else breaks when it changes something. An agent in one repository can check: it reads the schema, the endpoint and the screen, follows a value from the database to the page, uses the error the endpoint really returns, runs every layer's tests before it hands over, and finds every caller before it changes something. An agent can only build what it can see](/img/monorepo-guess-or-check.png)

This is the core of the problem. An agent can only build what it can see. Give it half the code and it will guess at the other half, confidently and at speed. Give it all the code and it will check.

## The fix: one repository, vertical slices

Restructure the code into a monorepo: one repository that holds the web application, the API, the business logic, the database schema and the tests for all of them. Then give each feature to one person and their agent, end to end.

![One repository, one vertical slice through every layer. A single repository holds web/ for screens and components, api/ for endpoints and the contract, core/ for business rules, db/ for schema and migrations, and test/ for tests for every layer. One agent cuts down through all five layers, each marked with a check: one feature, one change, one commit. What the agent can do now: read every layer before it changes any of them, rename a field everywhere in a single change, run the tests for every layer and see them fail before a person does, and hand over one change, reviewed once, that works end to end](/img/monorepo-vertical-slice.png)

Now the delivery window feature is one ticket. The agent reads the schema, the endpoint and the screen before it writes anything. It adds the migration, the field, the endpoint change, the screen and the tests for each layer, in one change. If the screen expects a field the endpoint doesn't return, a test fails right there, in the agent's own run, before any person looks at it. The person reviews one change that works from the database to the page, and it ships.

The things that were hard become ordinary:

- **Renaming something is one change.** Rename a field and the agent finds and updates every caller, on both sides, in the same commit. In split repositories that's a coordinated release.
- **The contract is code, not a document.** The endpoint and the screen that calls it are both in front of the agent. There's no wiki page to drift out of date.
- **Tests cover the seams.** The tests that matter most are the ones that cross layers, and they can only run where all the layers are.
- **One review, of a whole change.** Reviewing half a feature tells you very little. Reviewing a whole one tells you whether it works.

## Restructure the team, too

Moving the code into one repository isn't enough if the team is still organized as frontend developers and backend developers. If the work is still split into a frontend ticket and a backend ticket, you'll get the same pieces, just in one repository.

The team has to change with the code. In [The New Team](/post/the-new-team/) the engineers aren't frontend or backend engineers. Each one owns a feature end to end, and their agent does the work in every layer. The engineer's job is to judge what the agent built across all of those layers, not to build one of them. A strong frontend developer and a strong backend developer don't lose their depth in this structure. They review each other's work and bring that depth to every feature, instead of to half of each one.

## How to get there

You don't need a big migration to start. A few steps get most of the value:

1. **Bring the repositories together.** Create one repository with a top-level directory for each application, such as `web/`, `api/` and `db/`. Tools like `git subtree` can bring each repository in with its history intact.
2. **Keep the builds working as they are.** Each application can keep its own language, build tool and deployment. A monorepo isn't a monolith. You can still deploy the frontend and the backend independently.
3. **Build one pipeline.** Run the tests for every layer a change touches, including the tests that cross layers, on every change.
4. **Tell the agent how the repository is laid out.** Add instructions at the root (an `AGENTS.md`, a `CLAUDE.md`, or whatever your agent reads) that describe each directory and how to run each layer's tests. Start the agent at the root, not in a subdirectory.
5. **Write the tickets as vertical slices.** One feature, one ticket, through every layer it needs.

People usually raise three concerns. "The repository will be too big for the agent." The agent doesn't read every file. It searches for what it needs, and it can only find what's there. "Different teams own different parts." Ownership can be expressed with code owners and reviews, not with repository boundaries. "Our frontend and backend are in different languages." That's fine. Many monorepos hold several languages, and agents handle that well.

## If you can't move to a monorepo, use a meta-repo

Sometimes the code really can't move. The repositories belong to different departments, they're shared with other products, or the politics of merging them would cost more than the change is worth. If you're in that position, a **meta-repo** is your best choice.

A meta-repo is a parent workspace that checks out every repository side by side. It holds a script to clone and update all of them, and the agent instructions at the top that describe each repository and how to run its tests. The agent starts in the workspace, not in one of the repositories, so it can read the schema, the endpoint and the screen before it changes any of them. It can make one feature's changes across every repository in one session. That removes most of the guessing, and it's far better than giving each agent one repository.

But a meta-repo only fixes what the agent can see. It doesn't fix how the change is delivered. The feature is still delivered in pieces, and the pieces bring their own problems:

- **Multiple commits.** One feature becomes a commit in each repository. Nothing ties them together except a ticket number in the commit messages, so the history of the feature is spread across repositories. Rolling it back means finding and reverting every one of them.
- **Multiple reviews.** Each repository has its own pull request, its own reviewers and its own approval rules. Each reviewer sees half a change again, often at different times. One half can be approved while the other has changes requested, and the agent's single, consistent change has to be reworked on one side without breaking the other.
- **Half a change can be merged.** The backend change merges while the frontend change is still waiting for review, or fails its build. Now the main branches disagree. The frontend may call a field the backend doesn't return yet, or the backend may have removed a field the frontend still uses. If each repository deploys when it merges, that disagreement reaches production as errors.
- **No build checks the whole change.** Each repository's pipeline tests its change against the other repository's main branch, not against the other half of the change. The test that would catch the mismatch has nowhere to run unless you build a pipeline that checks out the matching branches together.
- **Stale checkouts.** The agent reads whatever is checked out in the workspace. If one repository hasn't been updated, the agent builds against old code, and its change looks right until it meets the current version.
- **Every change has to be safe in either order.** Because either half can ship first, every change has to be backward compatible. Add the new field before you use it, and stop using the old one before you remove it. A rename becomes three releases instead of one commit. That's extra work, and extra time, that a monorepo doesn't need.

You can reduce these problems with some discipline:

1. **Update every repository before the agent starts** a task, so it never builds against stale code.
2. **Use the same branch name in every repository** for a feature, and link the pull requests to each other and to the ticket.
3. **Test the branches together.** Before anything merges, run the cross-layer tests against all of a feature's branches at once.
4. **Merge in a known order.** Merge the backward-compatible half first, usually the backend, then the half that depends on it.
5. **Count the feature as done only when every piece is merged and deployed**, not when the first one is.

Even then, the meta-repo is a workaround. The agent sees the whole change, but people still review it, merge it and release it in pieces. Use a meta-repo when you have to, and keep pushing toward one repository.

## An agent can only build what it can see

When we split code by layer and people by specialty, we were optimizing for how people work: each person can only hold so much of a system in their head. Agents change the economics. An agent can read every layer of the application in minutes, but only if every layer is somewhere it can read.

If your agents keep building the half of the feature they can see, don't blame the agents. Show them the rest of the code.
