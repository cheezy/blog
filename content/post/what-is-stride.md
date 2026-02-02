---
date: '2026-02-02T09:19:27-05:00'
draft: false
title: 'What is Stride?'
tags: ["AI", "Agile", "Continuous Delivery"]
---

At its most basic level, [Stride](https://stridelikeaboss.com) is a _smart_ kanban board where teams and AI agents can collaborate to build software. There are several tools available now that provide this basic capability, but Stride differentiates itself in several important and meaningful ways. This post will cover those differentiators while walking you through a Stride AI Optimized board explaining what the team and AI agents do at each step.

![Stride AI Optimized Board](/img/stride-board.png)

## Backlog

The Backlog column is where your agent will upload the Goals and Tasks that describe the work to be done.

In order to come up with this backlog you will want to use one of the brainstorming plugins for your agent. I use the [Superpowers Brainstorm](https://github.com/obra/superpowers) plugin. The purpose of using a plugin like this is to assist in refining your ideas and creating the backlog quickly. Quickly is imperative because the agents will work through your Tasks much faster than you might be used to. The output of this brainstorming session should be a detailed document written into the project structure. It is a good idea to take a little time to review this document and make sure it aligns with your vision. I do want to make it clear that the goal is not to have a document that is 100% complete. Trying to achieve that level of completeness at this stage is futile. You will have an opportunity to adjust once the backlog is implemented. My target is 70 - 80%.

Once you have the document produced during the brainstorming session with your agent, you simply ask the agent to build [Goals and Tasks](https://github.com/cheezy/kanban/blob/main/docs/TASK-WRITING-GUIDE.md) and upload them to Stride. This is an area where Stride is very different from other tools. Stride requires a Task format that provides a lot of details. These details help the agent during implementation. A lot of the details are really not targeting the team members so it is possible for the team to [manage what fields are shown](https://github.com/cheezy/kanban/blob/main/docs/TASK-FORM-FIELD-VISIBILITY.md) when they look at the Task details.

![Task Field Visibility](/img/field-visibility.png)

Once the Goals and Tasks are uploaded to Stride the team is ready to review, implement, and then review again.

## Backlog -> Ready

The agent is not able to begin working on Tasks that are in the Backlog column. Instead, this is the time for the team to review the Tasks and make any last minute adjustments.

There is one decision that needs to be made at this time - and that is what Tasks should be reviewed. What this means is that once we ask the agent to begin implementing Tasks it will complete a Task and then move directly to the next Task unless a team member specifies that they want the agent to pause while they review the work. This is indicated by checking the _Needs Review_ checkbox on a Task. By default it is not checked.

![Needs Review Checkbox](/img/needs_review.png)

Once you are happy with the tasks and you have identified what tasks need to be reviewed, you simply drag the tasks to the Ready column on the board.

## Ready -> Doing

Now that we have some Tasks in the Ready column, we simply ask the agent to begin working on Tasks in Stride. The agent asks Stride if there are Tasks available and if there is a Task the agent **claims** it. When the agent claims a Task, the Task is assigned to the developer controlling the agent and the task is moved to the Doing column. Now the agent can begin implementation.  There are a few important things happening behind the scenes that I want to explain.

The first thing I wish to detail is how Stride determines what Task to assign the agent. When there are several Tasks in the Ready column, Stride will look at priority and position in the column. Higher priority Tasks are selected first and if multiple Tasks have the same priority then the Task higher in the column is selected first. Next, Stride looks at dependencies that were defined when the Tasks were uploaded to the Backlog column. Finally, Stride tries to assign Tasks to agents based on their [capabilities](https://github.com/cheezy/kanban/blob/main/docs/AGENT-CAPABILITIES.md) and attempts to minimize having multiple agents working in the same area of code. The overarching goal here is to deliver the highest priority Task to the agent while trying to minimize issues that might arise during the implementation.

The next thing I want to detail is that the developer has already defined what the agent should do at different points in the development workflow. These are defined in the Stride [Hooks](https://github.com/cheezy/kanban/blob/main/docs/AGENT-HOOK-EXECUTION-GUIDE.md). After the agent is notified that there are Tasks available to _claim_ the agent will execute the **before_doing** hook. The developer defines what happens here but this is typically the place where the local codebase is refreshed from the repository and a short lived feature branch is created. Other things can happen here like fetching the latest dependencies, etc. The results of running the commands in this hook must be provided when the agent _claims_ the task so it is not possible for the agent to skip this step. Also, after the agent has completed the implementation of the Task they are required to execute the **after_doing** hook. This hook can contain things like run the entire test suite, run a code formatter to ensure proper formatting, run static code analysis to ensure code cleanliness, and commit the code locally. Again, the results of executing this hook must be provided in the next request to Stride.

Here are the hooks I use for developing Stride:

![Doing Hooks](/img/doing-hooks.png)

## Doing -> Review

When the agent notifies that a Task has been implemented the Task is moved to the Review column. Behind the scenes the agent has updated some data in the Task. They have written information related to how long it took to implement the Task, how many files they changed compared to how many they estimated during Task creation, and implementation notes.

If _needs review_ was not set for this Task then the agent continues to the next step. If _needs review_ was set then the agent must follow the [Review Workflow](https://github.com/cheezy/kanban/blob/main/docs/REVIEW-WORKFLOW.md). In this workflow the agent will pause and not perform any additional work until they are informed that the review is complete. The reviewer will now perform the review. When they are finished they must update the Task that is sitting in the Review column marking the Tasks "Approved", "Changes Requested", or "Rejected". If approved, the task is moved to the next step. If changes are requested then the agent will read the review notes and continue working on the Task. If the Task is rejected then the agent will undo the changes and move the Task back to Ready.

Similar to the Doing column, the Review column has a set of hooks. There is a **before_review** hook that must successfully run before a Task can be moved to the Review column. This is typically where the agent will rebase the code from the main repository and possibly re-run the tests. Also there is an **after_review** hook that must run. This is the final step in the workflow so the developer typically has the code rebased one final time, quality checks are performed, and the code is pushed to the main repository triggering the deployment pipeline.

Here are my review hooks for Stride development

![Review Hooks](/img/review-hooks.png)

## Review -> Done

We have reached the end of the line for our Task workflow. Once the Review is complete the agent simply moves the Task to the Done column and will start back at the beginning by asking if there is a Task ready to be worked on.

## Summary

Stride tries to strike a balance between allowing the agents to freely work on Tasks while providing the team with the ability to steer and course correct.

### The team members are responsible for:

- Reviewing the Tasks that are in the Backlog column and moving them to the Ready column
- Specifying the **before_doing**, **after_doing**, **before_review**, and **after_review** hooks to ensure the agent follows the team's standards and processes
- Reviewing and accepting Tasks that are marked as needing review

### The agent is responsible for:

- Creating the details for each Task
- Following the Stride workflow - executing the hooks and moving the Task across the board
- Responding to team feedback provided during the Review Workflow
