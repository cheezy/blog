---
date: '2026-03-20T12:19:00-04:00'
draft: false
title: 'The future of software engineering: My Thoughts - Part 2'
tags: ["AI", "Continuous Delivery"]
---

This is part 2 in a series where I discuss my thoughts on the Thoughtworks retreat report titled [The future of software engineering](https://www.thoughtworks.com/content/dam/thoughtworks/documents/report/tw_future%20_of_software_development_retreat_%20key_takeaways.pdf). If you haven't read [part 1](/post/tw-retreat-response/), I'd encourage you to do so first as it provides a lot of context.

In part 2, I will discuss the second and third categories from the report. Let's jump right in.

### 2. The middle loop: a new category of work

The report states _"The retreat's strongest first-mover concept. Nobody in the industry has named this yet."_ It goes on to say:

> Software development has long been described in terms of two loops. The inner loop is the developer's personal cycle of writing, testing and debugging code. The outer loop is the broader delivery cycle of CI/CD, deployment and operations. The retreat identified a third: a middle loop of supervisory engineering work that sits between them.
>
> This middle loop involves directing, evaluating and fixing the output of AI agents. It requires a different skill set than writing code. It demands the ability to decompose problems into agent-sized work packages, calibrate trust in agent output, recognize when agents are producing plausible-looking but incorrect results and maintain architectural coherence across many parallel streams of agent-generated work.

I had to think about this one a lot. The loop of directing, evaluating and fixing the **output** was something that I felt I had to do somewhat regularly last year. But as the agents became more powerful, I felt this type of work became less necessary. Eventually, I decided to address this issue head on.

#### Getting the agent to produce the right thing

When I first started using agents to write my code I started by typing a prompt. Obviously, the prompt had very little context and contained few of the details the agent needed to accurately implement my desired change. I tried to compensate by asking the agent to take extremely small steps. This worked okay, but I did have to maintain that middle loop discussed in the report. It felt bad, and I was unable to accept this as the new normal.

The idea of verifying the accuracy _after_ the agent completed a task was a form of rework. To me, rework is waste and I always feel the need to try to eliminate it. I would prefer for the agent to have all necessary information it needed to get it right the first time. This meant that I needed to abandon the idea of using prompts and instead use a more structured approach.

In mid-December I started asking my agent what information it needed to complete a task accurately. I also asked what format was the easiest for it to consume. This started a process of providing the agent with structured inputs, seeing how accurate the output was, and iterating on the inputs until I felt confident in the results. The outcome was what became Stride's [task](https://cheezyworld.ca/post/what-is-a-task/) definition. This task includes a lot of information about what to build. Here is a sampling of some of the fields:

|  |  | |
|---|---|---|
| `name` | `description` | `acceptance criteria` |
| `why` | `what` | `patterns to follow` |
| `validation rules` | `database changes` | `pitfalls` |
| `security considerations` | `integration points` | `out of scope` |
| `telemetry events` | `metrics to track` | `logging requirements` |

This approach forces me to spend a little more time up front ensuring that I provide the agent with the information it needs, but I spend almost no time afterwards verifying the output. The [Stride Skills](https://github.com/cheezy/stride) guide the agent in the creation of these detailed tasks.

The next piece of my approach is to ensure the output matches the task details. The Stride [task reviewer](https://github.com/cheezy/stride/blob/main/agents/task-reviewer.md) [SubAgent](https://code.claude.com/docs/en/sub-agents) handles this. It compares the code changes to the task specification and ensures that the implementation matches the specification. If it doesn't, the SubAgent provides the details to the coding agent and asks it to fix the issues. If everything is okay, this SubAgent attaches a review report to the task so a human can review it later.

The final piece of my approach is to perform a quick review of the application changes using a tool like [Tidewave](https://tidewave.ai/). Tidewave allows me to make the changes in the browser while I am looking at the application and see the results immediately.

##### UPDATE

I was using Stride to build a full plugin for GitHub Copilot and one of the tasks was sent back to the implementation agent for rework by the **task reviewer** SubAgent before it was permitted to mark it as complete. I thought you might want to see how this works. Here is the report as it was added to the finished task.

```markdown
## Review Summary

2 issues found (0 Critical, 2 Important, 0 Minor)

### Issues

**1. [Important] task-decomposer missing example section**
- The full worked example (~140 lines) was dropped during port
- Fixed: Added back the complete example section

**2. [Important] task-decomposer codebase search instruction genericized**
- "Grep" changed to "Search" and added "or similar project instruction files"
- Judgment call: kept as reasonable generalization for Copilot platform

### Acceptance Criteria
| # | Criterion | Status |
|---|-----------|--------|
| 1 | All 4 agent files exist with .agent.md extension | Met |
| 2 | Correct YAML frontmatter (name, description, tools) | Met |
| 3 | Instructions preserve ALL original logic | Met (after fix) |
| 4 | No Claude Code-specific references remain | Met |
| 5 | Tools arrays minimal and read-only | Met |
| 6 | hook-diagnostician: [read, search] only | Met |
| 7 | Other 3: [read, search, glob] | Met |
```

Notice how the first issue in the example states that it was **Fixed** and the third acceptance criterion states that it was **Met (after fix)**? When the **task reviewer** SubAgent compared the changes to the acceptance criteria, it discovered that the third one was not met. It sent the task back to the implementation agent to fix this and once the fix was in place the SubAgent ran the report again. What you see here is the final report that was attached to the Task in Stride.

### 3. Agent topologies and enterprise architecture

The report states _"Conway's Law didn't retire. It got more complicated"_

> The retreat introduced the concept of "agent topologies" as an extension of the Team Topologies framework. The premise: if organizations design systems that mirror their communication structures, what happens when agents become first-class participants in those structures?
>
> Unlike humans, agents can be duplicated instantly and deployed across multiple teams without onboarding friction. A specialized database agent can exist on every team simultaneously, bringing consistent expertise without the centralization bottleneck that comes with a single human database specialist. This sounds like a pure win, but the retreat identified several complicating factors.

It goes on to list three complicating factors:

1. **The speed mismatch**: Agents burn through backlogs so fast they collide with slow organizational dependencies.  ...  The result is not faster delivery. It is the same speed with more frustration, because the bottleneck has shifted from engineering capacity to everything else.

2. **Agent drift**: Agents that learn from their context will diverge over time. ...  This mirrors the human problem of team-specific norms, but on an accelerated timeline.

3. **Decision fatigue as the new bottleneck**: If agents can produce work faster than leaders can review and approve it, the constraint shifts from production capacity to decision-making capacity. Middle managers who previously served as coordination points now become approval bottlenecks.

I have seen all three of these problems and they have led me to conclude that it is not possible to bring AI into an organization without significant disruption. In the pre-AI days, we built our entire organization and process around a certain pace of development and level of quality. Our requirements process was designed to deliver user stories to the teams just-in-time. The testing organization was sized to the stream of changes. This carries forward to everything that touches development - for example, providing language translations for applications, legal review of text used in software, pipelines, operations, etc.

When the pace of development increases dramatically and the quality goes up by the same factor, the entire organization needs to be restructured to accommodate the new reality. This, in my opinion, is the most difficult part of transforming into an AI-driven organization.

It is not possible to simply layer AI on top of your existing Scrum or other Agile process. They are not compatible. If you go down this route, you will need to slow down AI and accept the fact that your organization will be less productive than it could be.

In February I wrote a [post on where I think this could be going](https://cheezyworld.ca/post/the-new-team/). I think this concept addresses **the speed mismatch** and **decision fatigue as the new bottleneck**.  In essence:

- Teams will be comprised of a product owner and a couple of developers
- Teams will collaborate with AI to quickly build out the requirements for their work
- Teams will collaborate with AI to quickly build out the code for their work
- Specialized Agents will be built to handle external requirements like language translations, legal verbiage, production support, etc.

I am totally fine with **agent drift** in the same way I am fine with different teams having different norms. Instead of trying to drive **standardization** across the organization, I would rather teach developers details on how to build out quality [Skills](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview), [SubAgents](https://code.claude.com/docs/en/sub-agents), and [Agent Hooks](https://platform.claude.com/docs/en/agent-sdk/hooks) so they can harness AI to produce what is appropriate for them in their context.

### Summary

The second and third category from the Thoughtworks paper discuss very important issues that need to be addressed by any organization that is trying to be successful with AI driven development. First of all, knowing how to direct AI to build the correct features and ensuring that it does that is _fundamental to success_. Secondly, understanding that AI is disruptive to your entire organization and if you want to be successful _you need to be ready to make changes_ to see the full benefit.
