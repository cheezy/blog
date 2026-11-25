---
date: '2026-11-16T18:38:00-05:00'
draft: false
title: 'Scaling the New Team'
description: "How to scale a small AI-driven team of one SME and two engineers: copy the team, and add a thin layer of Quality Lead, Developer Lead and Product Owner."
tags: ["AI", "Agile", "Continuous Delivery"]
---

In February of 2026 I wrote about [The New Team](/post/the-new-team/): a very small team built for AI-driven development, with one person who knows what to build and one or two developers whose agents build it. At the time, the post was based on the successes of a few experiments at two different clients.

Since then I've used this structure on many teams. It works. The small team consistently delivers far more than the traditional Agile team it replaces, and it does so with less coordination, not more. If your delivery org is currently a single team then this is the right shape for you. So the question I get asked now isn't "does it work?" It's "what happens when we need more than one of these teams?"

This post answers that question. I'll describe the basic team as it looks today, how to scale it to several teams with a thin layer of leadership above them, and the roles that layer needs: a **Quality Lead**, a **Developer Lead** and a **Product Owner**.

## Why the shape has to change

When agents do the building, building stops being the bottleneck. The constraint doesn't disappear, though. It moves to the work only people can do well:

- **Upstream: deciding what to build.** Clear intent, acceptance criteria and priorities become the scarce input. User testing becomes an upstream problem too: when building is cheap, the expensive mistake is building the wrong thing, so validate the idea before it's built, not after.
- **Downstream: judging what was built.** Review, validation and learning from real users become the scarce capacity. Agent-built work arrives with its tests already written and passing, so a separate testing phase becomes less necessary as quality rises.
- **Dependencies.** Legal review, translations and other outside teams used to hide inside a six-week build. Now they take far longer than the build itself.

The traditional team was designed around the old constraint: how fast people can write code. The new team is designed around these.

## The building block: an SME and two engineers

![The basic development team: 1 SME per team, critical because any role with deep knowledge can fill it, they drive understanding of the requirements, and a compact team clarifies quickly. 2 engineers per team, developers or quality engineers matched to the work, with little coordination overhead, efficient code review, and a 5x multiplier that comes from the structure, not the headcount](/img/scaling-team-building-block.png)

The basic team is three people, with agents doing the building.

**One subject-matter expert (SME).** In my original post I called this person the Product Owner. In practice, the title turned out not to matter. I've seen the role filled well by Product Owners, business systems analysts and testers. What matters is their depth of knowledge of the application. The SME owns the upstream constraint: they drive the team's understanding of the requirements and keep context across the work. A compact team can clarify a requirement in a conversation, not a meeting.

**Two engineers.** They can be developers or quality engineers, matched to what the work needs. They own the downstream constraint: judging what the agents built, and reviewing each other's work. Why two and not four or five?

- **Little coordination overhead.** Two people working through a backlog with their agents rarely step on each other.
- **No knowledge silos.** Each engineer knows what the other is changing.
- **Code review stays personal and thorough.** With two engineers, review is a conversation between two people who both know the code, not a queue.

The structure, not the headcount, is what produces the results. Across the teams I've worked with, this structure has delivered about five times the throughput of the team it replaced. Adding a third or fourth engineer doesn't add to that. It adds coordination.

## Scaling: copy the team, don't grow it

![Add teams, with a thin layer above: a Quality Lead and a Developer Lead, each coordinating across teams, above Team 1, Team 2 and Team 3, each an SME and 2 engineers. Caution: beyond three teams, overhead and coordination complexity grow exponentially, so put more governance, support roles and documentation in place before you scale further](/img/scaling-team-multi-team.png)

When an application needs more capacity, the instinct is to make the team bigger. Don't. Instead, replicate the basic team. Every team stays one SME and two engineers.

Above the teams sits a deliberately thin layer of two people who coordinate across all of them: a **Quality Lead** and a **Developer Lead**. Between them they keep several fast-moving teams coherent.

A word of caution, from experience: up to three teams, two leads can keep everything aligned. Beyond three, the overhead and coordination complexity climb quickly. Start with two teams and add more only if you need them. Scaling beyond three teams requires significant governance, support roles and documentation and might not be worth the effort.

### The Quality Lead

The Quality Lead owns whether the work is ready to go to production.

- **Non-functional testing.** Coordinates performance, scalability and reliability testing with the specialist teams that run it.
- **Manual testing.** Coordinates what manual testing remains, which is very little. That includes agent-driven exploratory testing and user acceptance testing.
- **Release readiness.** Confirms that every quality gate is met before production.

### The Developer Lead

The Developer Lead owns whether the work is technically sound and fits the bigger system.

- **Architecture adherence.** Works with the enterprise architects to keep designs within standards.
- **Technical integration.** Sets integration requirements and manages the dependencies between teams.
- **Infrastructure and pipelines.** Oversees the environments, CI/CD, deployment and provisioning.
- **Technical strategy.** Drives technical decisions, tool choices and engineering practices.

Both leads share ownership of quality. Neither can hand it to the other. The difference is where they look: the Quality Lead looks at the release, the Developer Lead looks at the system.

## The Product Owner: bridging strategy and delivery

The Quality Lead and Developer Lead own whether the work is good. The **Product Owner** owns whether it's the right work.

This is the biggest change from my original post. With one team, the person who knew what to build could also speak for the business. With three teams, that's too much for one person who is also working inside a team. So each team keeps its SME, and the Product Owner moves up a level to become the bridge between the business's strategic direction and every team's delivery.

The Product Owner's work falls into two halves.

**Shaping the work**

- **Business collaboration** with stakeholders, strategists and designers on direction and requirements.
- **Work breakdown.** Partners with the SMEs to turn strategic requirements into delivery targets the teams can act on.
- **Prioritization and sequencing** of features and releases, based on business value.

**Steering the outcome**

- **Strategic vision.** Keeps every team pointed at shared objectives and success metrics.
- **Production sign-off.** Gives the business approval a release needs before it goes to production.
- **Cross-organization coordination.** Manages dependencies and expectations with the rest of the organization.

The Product Owner owns the upstream constraint, deciding what to build, across every team. The SMEs own it within their own team.

## What makes it work

The structure only delivers if five things are in place. Each one removes a kind of waiting.

1. **Vertical slices, even across political boundaries.** Each team owns a feature end to end, through every layer, even when the layers belong to different departments. That's the hard part, and it's political, not technical. In some cases this will not be possible, but know that creating dependencies between teams creates inaccuracies, waiting, and slows down delivery.
2. **The agent can see everything.** All the code is in source control the agents can read, across every team and system. An agent can only build what it can see. I prefer a mono-repo or if that is not possible a meta-repo.
3. **True continuous integration.** Most code [merges automatically](/post/code-reviews/) once it passes the gates. When agents produce changes all day, a person merging each one is a queue.
4. **Rapid design iterations.** Development starts before the UI/UX design is finished, and the design and the code evolve together. A working version is the fastest way to find out whether a design is right.
5. **Streamlined production deployments.** Releasing to production is routine, not an event. If every release needs a change board and a weekend, all the speed upstream piles up at the end.

## The advantages

Put together, here's what this structure gives you over the traditional team:

- **Throughput from structure, not headcount.** A three-person team with agents delivers several times what a much larger traditional team did, because almost none of its time goes to coordination.
- **Clear ownership of the real constraints.** The SMEs and the Product Owner own deciding what to build. The engineers, the Quality Lead and the Developer Lead own judging what was built. Nobody is left guarding a constraint that no longer exists.
- **Scale without slowing down.** Adding a team adds capacity without growing any one team's communication overhead. The thin leadership layer keeps the teams coherent without becoming a bureaucracy.
- **Quality that's built in, not inspected in.** Quality gates live in the pipeline and the agents' workflow. The Quality Lead spends their time on the hard cases and on raising the bar, not on triage.
- **Fewer layers, faster decisions.** Four tiers from the executive sponsor to the delivery team means a decision doesn't wait in line on its way down, and feedback doesn't wait on its way up.
- **The business sees progress every week.** Working software in UAT every week and a monthly showcase replace the status report.

## What to watch for

This isn't free of risk, and I'd rather be honest about the three I see most often:

- **Review overload.** Agents can produce work faster than people can judge it. Unreviewed work piles up, or gets waved through. Decide up front what needs a person's sign-off, and let the gates handle the rest.
- **Building the wrong thing faster.** Cheap delivery amplifies weak discovery. Clear intent and early validation matter more now, not less.
- **Hollowed-out roles.** If you remove layers without redesigning careers, you lose the people who know how things actually work. Many of your best SMEs, leads and Product Owners are already in the organization today, in different roles.

Most organizations adopting AI are treating it as a developer productivity tool and leaving everything around the developers untouched. That's buying a faster engine and keeping the same traffic lights. Faster delivery into the same organization just means faster queueing. If you want the speed AI makes possible, you have to change the shape of the organization it's delivering into.
