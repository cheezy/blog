---
date: '2026-01-12T10:23:45-05:00'
draft: false
title: 'Adopting AI Driven Development'
tags: ["AI", "Agile", "Continuous Delivery"]
---

## Sharing what worked

I have often wondered why some companies have had great success adopting AI for software development while others have had the opposite experience. Some people talk about AI "Slop" meaning very bad code written by AI. At the same time many of us see AI producing code that is high quality, well factored, and well tested. Is it possible that the way one approaches this technology has an impact on the outcome?

I do not believe that everyone that follows a specific approach will see the same outcome. But I do think it is good to see how others are doing it and with that in mind I will share a journey with one of my clients that ended in success.

## The Context

The client is a large (multi-billion) company but I was only working with one product group. That group has 3 delivery teams each with 5 developers, 2 testers, and a product owner. There are designers in the mix although they were not on the teams.

The tech stack consisted of an Angular UI and a Spring Boot services layer. The application communicated with a backend mainframe and other services both inside and outside of the company. The teams I worked with were responsible for the Angular and Spring development.

The application was deployed to production every two weeks and the teams kept a two week cadence.

## The Start

After a _lot_ of conversation with management and the teams it was decided to explore AI to see what benefits the company could achieve. I explained that there was a need to spend some money because the "free" tools really do not demonstrate what is possible. Also, there would be the need to "unlock" some machines to allow developers to install the tools necessary to perform the exploration. Through conversations the company decided to designate two  (_trusted_) developers (one Angular and one Spring) to work with me on an experiment. They would allow those developers to install the tools necessary and the company would pay for premium tools until we completed the experiment. This whole process took about two months to decide and the experiment was to run two months but we were supposed to report back with an interim report after one month.

## The Experiment

I had already spent more than six months diving into AI and the tools that were available so I was able to recommend a toolset. This allowed us to skip a time consuming evaluation. We selected [Claude Code](https://www.claude.com/product/claude-code) from Anthropic. It was by far the best choice at that time (and still is IMO) for software development.

We were able to install the tools on the developers machines but before we started I wanted to get some [guidance](https://agents.md) (we'll call this the AGENTS file) in place for the Agent. We looked online and were able to find a decent starter config for Angular and for Spring. We downloaded these files and modified them to match some of the standards and toolsets for the application. Now we were ready to get started with the experiment.

The two developers still had to perform their regular team tasks so we decided that we would meet twice a week for 2 hours each session. We started with small changes and worked our way up to larger tasks and did not commit any of the changes made by the Agent. Throughout the experiments we followed this process:

1. Ask the agent to perform some task
2. Review the change. If it was acceptable then we would revert the code and move on to the next change.
3. If the change was not acceptable then we would ask the Agent to correct the problem and update our AGENTS file so it would not make the same mistake again.

    - After it did this we would revert the code (but not the updated changes to the AGENTS file) and start a clean session, and ask the Agent to perform the task again. We would repeat this until the Agent easily got the request correct.

We called this the **training stage** as we were continuing to _train_ the Agent through the AGENTS file we were building. Here are a few of the examples of some of the tasks we asked the Agents to perform starting from simple to more complex:

- Ask the Agent to refactor some code that already had good tests in place.
- Ask the Agent to refactor some code and write tests for it.
- Ask the Agent to improve upon the design (larger refactorings) of some existing code.
- Ask the Agent to remove a feature toggle that did not have A/B code.
- Ask the Agent to remove a feature toggle that did have A/B code.
- Ask the Agent to implement a simple task.

We kept increasing the scope of what we asked the Agent to do and continued to update our AGENTS file. Some things that made their way into our AGENTS file are:

- Design standards (SOLID, DRY, KISS, YAGNI, etc.)
- Code quality, style, and formatting
- Testing standards and how to thoroughly test code
  - This lead to explanations on how to read our code coverage output
- Framework specific best practices
- Quality requirements that must be met with every change

As our AGENTS file became more specific we started to see a improvement in what the Agent was producing. We started to run our static analysis tool against the code the Agent produced and we were excited about the results. We were achieving over 90% test coverage and the tests were good quality and organized well.

By the time we reached the one month milestone we had not merged any of the changes but we did create some PRs (not to be merged) so other developers could see what was being produced. Excitement was starting to build and people were talking. When we got in a room with management to discuss the results of the first month they were already aware of what was going on. They asked both developers if they believed this was a viable approach and both stated that it was. At that time a decision was made to get one of the three teams configured and trained and let them perform feature work for a two week period.

### The workshop

We decide to run a workshop with the selected team since they really had not had direct exposure to the tools prior to this time. The workshop consisted of one half day with Spring developers getting the tools setup and performing a simple task, one half day with the Angular developers getting the tools setup and performing a simple task, and an entire afternoon with the whole team mobbing on a simple task from the team's backlog.

### The first two weeks

The team decided to leave everything about the way they had been working up to that time in place. Same backlog, same process, same everything. The only difference was that they were now using the Agent to write the code. Half way through day three the developers had already completed all of the tasks that would have taken them two weeks before the introduction of AI. The testers had barely started. After a discussion the team decided that the developers would not take on any more work as it would only make the testing constraint worse. Instead the developers would work on solutions to some issues they discovered over the past two days. The issues were:

- The developers were spending far more time performing PR review than they were working with AI to write the code.
- Other teams were not happy with the pace and depth of change coming from the team. It was making code merges and understanding the changes difficult.

At the end of the two week period the team had a restrospective. Here are my notes from the meeting:

```text
100% 200% development more productive
	We were sitting in a Farrari and doing a Fred Flintstone
After discussion developers 4x but PO and Test are unchanged.
QA found 2 defects
I asked “What happens when you find no defects?”
A lot of discussion about restraint. “Too easy to have it refactor all of the code”

Issues:
* Cannot review code fast enough. Not sure what to do about this.
* No good way to keep AGENTS files in sync
* Other teams complained about the large change to codebase and they had trouble keeping up with the changes
* Updates were happening so fast that developers frequently ran into git conflicts

Keep doing it?
YES
```

At this time I wrote some of my own observations:

- It will not be long until QA will not be needed to test the behaviour of the stories. What will we do?
- Product Owners will be unable to stay ahead of the developers following the traditional story elaboration / Jira process
- Proper Git behaviour is essential - constant rebasing and small steps

## Beyond The Experiment

Over time the other two teams came onboard and now all three teams are using the Agent to write the majority of the code. The teams were forced to come up with solutions for the constraints.

### The Testing Constraint

#### There was absolutely no way the testers could stay ahead of the developers on their team when the developers were having the Agents write their code

Over time the teams discovered that the quality of the code changes as well as the quality of the unit and integration tests were much higher than they were before the Agents were introduced. Also, the agents would _"manually"_ test changes before completion. The team has come to the conclusion that there is far less traditional testing needed. The testers have been primarily relegated to testing critical updates and non functional requirements. IMO AI will take over many of these tasks over time.

### The Product / Backlog Constraint

#### It didn't take long for the teams to realize that the primary constraint to delivering product became the flow of refined tasks

The traditional approach of stakeholder collaboration and task refinement was too slow and couldn't keep the developers and agents busy.

I started experimenting with the product owners to see if we could utilize AI to help with the task refinement process. During the experimentation we came to a huge realization - our tasks do not have to be exactly correct as the cost to make an adjustment or change is very small due to AI speeding up the development process. We ended up adopting a process of having the product owner and tech lead work with the Agent to produce a backlog of many tasks for the Agents. The goal was to get the backlog 90% correct. As the Agent was completing tasks the product owner would work on the backend with the developers to make adjustments. This seemed to work well but there were still some issues with the process.

This iterative approach to try to build out tasks for the Agents is what led me to build [Stride](https://cheezyworld.ca/post/stride_workflow/).

### The Development Constraint

There were two constraints that the developers faced after they were past the initial learning curve of working with the Agents They were both related to the pace of change:

#### 1. Taking much longer to review the PR than to produce the code

The constraint was discussed a lot. Some of the suggestions were:

- Enhance our pipeline to check many of the things we would check in the code review
- Pair program with the Agent - two developers and an Agent - and have the developers spend more time reviewing the code as it was being produced
- Add an Agent to our process that could perform the code reviews on behalf of the team

In the end they did not follow any of these suggestions. Over time they realized that their standards were already embodied in the AGENTS file they were providing to the Agents and they were really not discovering anything of significance that needed changed. Also they discovered (like the product owners) that the cost of making adjustments was very low and they could iterate quickly on code that needed changed.

#### 2. Merge conflicts were greater as the Agent was producing the code faster and refactoring and cleaning up the code in the process

The code merging was a problem that we did not resolved. During our investigation we realized that an Agent can fairly accurately estimate what files they will need to change before they make the change. We started adding this information to the tasks and manually tried to manage this risk by selecting tasks that would avoid conflicts. I baked this knowledge into Stride. When an Agent asks Stride what task they can work on next, Stride will not give them a task if another Agent is working on a task that will touch the same files.

## Conclusion

The first thing I pondered in this post was why some people have a good experience while others have a bad experience with AI even when using the same tools. I still do not know the answer (or more likely answers) to this question but I can offer this experience of one transition to AI driven development that went well.
