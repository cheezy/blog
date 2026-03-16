---
date: '2026-03-13T09:47:00-04:00'
draft: false
title: 'Strides New Enhanced Workflow'
tags: ["AI", "Agile", "Continuous Delivery"]
---

Over the past two weeks, a lot of enhancements have been made to the Stride Workflow. I wanted to take the time to detail them here as I think they are a good example of how one can direct an AI agent to perform specific tasks in a repeatable manner.

### What is Stride?

For those new here: [Stride](https://www.stridelikeaboss.com) is a kanban-based task management platform built specifically for Human and AI agent collaboration. It is very different than the typical "let the agents run through a lot of tasks and we'll check at the end" mode of working with AI. Instead, Stride gives the human (team) multiple places where they can insert themselves into the workflow. Enough of that for now as I want this post to focus on the workflow enhancements.

### Claude Code Only (for now)

Several of the [Skills](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview) and [Subagents](https://code.claude.com/docs/en/sub-agents) you see detailed in this post are currently only available in [Claude Code](https://code.claude.com/). Over time, I hope to bring much of what I've built to other popular agents. Unless I specifically state that the feature is Claude Code only, you can assume it is available in Claude Code, GitHub Copilot, Cursor, Windsurf, Gemini, and OpenCode.

#### Step 0: Creating the requirements

This step has nothing to do with Stride, but it's the first step in the workflow. Teams will use a brainstorming Skill or Subagent to create a detailed requirements document for the next feature they wish to build. The team would typically review this document together and iterate with the agent until they are satisfied with the details. I use the [superpowers brainstorming](https://github.com/obra/superpowers) Skill and find it to be perfect for my needs.

#### Step 1: Getting the requirements into Stride

The next step is very easy, but a lot of behind-the-scenes magic takes place at this time. One would simply ask the agent to break the requirements document (created in the previous step) down into goals and tasks (or simply tasks for smaller features) and upload them to Stride.

At this time, one of two [Stride Skills](https://github.com/cheezy/stride/tree/main/skills) will be invoked. The **stride-creating-goals** and **stride-creating-tasks** skills show the agent what constitutes a [task](https://cheezyworld.ca/post/what-is-a-task/) in Stride and how to format and upload the information using the Stride API.

I will not go into all of the details of what is included in a task (follow the link in the previous paragraph), but it is responsible for a lot of Stride's success. Establishing the details of each task up front alleviates the need for developers to type detailed prompts and constantly course correct later. When this step is complete, the requirements will be broken down into manageable tasks and uploaded to the _Backlog_ column in Stride. Tasks that are in the _Backlog_ column are not available for agents to work on.

#### Step 2: Human review of Tasks

At this point in the workflow, we have yet another opportunity for the team to review the tasks and make any necessary adjustments before the agents begin working on them. There are three critical things to do at this stage.

1. The team should ensure they are in agreement with the `acceptance criteria` that were created as it will be used by a subagent later in the workflow
2. The team should decide which tasks they want to review and which tasks they are comfortable with the agent working on without human review. Tasks that need review can be identified by simply checking the `Needs Review` checkbox on the task.
3. Add any missing tasks that were not created by the agent. These are often organizational tasks and can be either flagged as `Human Tasks` (agent will not work on) or additional work for an agent to complete.

Once the team is satisfied with the task details they can simply drag the tasks to the _Ready_ column in Stride. This will make them available for agents to work on.

#### Step 3: Agent Claims a Task

With the tasks in the _Ready_ column, agents can now claim them and begin working on them. This is where things get very interesting.

##### Step 3.1: Fetching Task Details

The agent will use the **stride-claiming-tasks** Skill to see if there is a task available to claim. If there is, the agent will start by running a hook.

##### Step 3.2: The **before_doing** Hook

[Hooks](https://github.com/cheezy/kanban/blob/main/docs/AGENT-HOOK-EXECUTION-GUIDE.md) are a set of commands that the developers have specified should run at specific times during the workflow. The developers will have specified what commands the agent must complete successfully prior to starting work on a task. Often the **before_doing** hook is used to refresh the local codebase from a central server. If, for any reason, the commands are not successful, the agent will invoke the **hook-diagnostician** SubAgent to help diagnose and fix the issue. The agent is not able to move forward until this step passes. This SubAgent is only available in Claude Code at this time.

##### Step 3.3: Claiming the Task

Now that the first hook has passed, the agent is ready to begin working on the task. But there are a few things that need to happen first. When the agent makes the API call to claim the task, the task is moved to the _Doing_ column in Stride and then the agent performs the additional activities based on the details of the task. Here is a breakout:

| Task Attributes | task-decomposer | task-explorer | Plan Agent |
|---|---|---|---|
| small, 0-1 key_files | Skip | Skip | Skip |
| small, 2+ key_files | Skip | Run | Skip |
| medium (any) | Skip | Run | Run |
| large (any) | Skip | Run | Run |
| Defect type | Skip | Run | Skip (unless large) |
| Large complexity, not yet decomposed | Run | Skip | Skip |
| 25+ hour estimate, not yet decomposed | Run | Skip | Skip |

##### Step 3.3.1: Enrich the task if it is incomplete

There are cases where a human may have created a task via the Stride UI. Often the human does not have the time or knowledge to fully enrich the task with all the details the agent would like to have available during implementation. In these cases, the agent will use the **task-enricher** Skill to enrich the task with the desired details. This Skill is only invoked if there is critical information missing. This skill is only available in Claude Code.

###### Step 3.3.2: Break down large tasks

If the task is large or complex, the agent will use the **task-decomposer** SubAgent to break it down into smaller, more manageable tasks. This SubAgent will use the **stride-creating-tasks** skill to create the new tasks and place them in the Ready column. Next, the agent will begin working on one of the newly created smaller tasks. This SubAgent is currently only available in Claude Code.

###### Step 3.3.3: Explore the codebase

Next, the agent will invoke the **task-explorer** SubAgent to explore the codebase to understand the context of the change. Specifically, the SubAgent looks at the code files specified in the `key_files` and also reads the `patterns_to_follow`, `where_context`, `acceptance_criteria`, and `testing_strategy` fields of the Task to direct its exploration. The knowledge and information it gathers is then returned to the implementation agent to inform its work. This SubAgent is currently only available in Claude Code.

###### Step 3.3.4: Break the activity down into small implementation steps

At this point the agent has what it needs to begin the implementation. For tasks that are flagged as medium or large the agent will invoke its internal Plan SubAgent to create the steps to implement the task. This is not part of Stride, but Stride will inform the agent to do this at this point. This is only available in Claude Code.

#### Step 4: Implement the changes

We are now at the point where the agent is ready to start working on the task. It might seem like it has taken a lot of time to get to this point, but the previous steps happen very quickly, and you may not notice all of the work that has already been performed.

##### Step 4.1: Make the change

This is where the agent does its thing. Code is written, tests are written, and eventually the agent believes it has completed the task.

##### Step 4.2: Validate the accuracy of the changes

Before moving on to complete the task, the agent might invoke the **task-reviewer** SubAgent. This SubAgent will review the changes made by the agent and ensure that they are correct and complete. This table shows when the agent will be invoked.

| Task Attributes | stride:task-reviewer |
|---|---|
| small, 0-1 key_files | Skip |
| small, 2+ key_files | Run |
| medium (any) | Run |
| large (any) | Run |
| Defect type | Run |

The agent does the following review:

- looks at the `acceptance criteria` defined on the Task and compares them with the code changes. Any acceptance criteria that cannot be mapped to a change is flagged as incomplete.
- looks at the `pitfalls` defined on the Task and ensures the pitfalls have not been realized.
- looks at the `patterns to follow` defined on the Task and ensures the changes followed those patterns.
- looks at the `testing strategy` defined on the Task and ensures the agent has implemented that strategy.
- looks for basic code quality issues that are easy to detect.

If the change does not pass the review, a report is returned to the agent and the agent is informed to address the shortcomings. The agent must have a clean review in order to continue to the next step. This SubAgent is only available in Claude Code.

> **FYI**: A new feature that is under development now and should be available by sometime next week is to have the **task-reviewer** SubAgent create a report that shows compliance via the review and attach that report to the Task. I feel this will be valuable for tracking and auditing purposes. Stay tuned.

##### Step 4.3: The **after_doing** Hook

The final step in the implementation is to execute the **after_doing** hook. Like the **before_doing** hook, this is a user-defined set of commands that must pass in order for the task to be considered complete. Often this is where a final test run takes place as well as quality checks like static code analysis, linting, and security scans. If the hooks do not pass, the **hook-diagnostician** SubAgent will be invoked to help diagnose the issue.

#### Step 5: Complete the Review Process

With implementation finished, we now enter the review process. This gives the team an opportunity to dictate how the agent behaves. There are two hooks that must be executed successfully and an optional pause while a review of the changes is conducted.

##### Step 5.1: The **stride-completing-tasks** Skill

At this point the agent will invoke the **stride-completing-tasks** skill. This skill will guide the agent through the remainder of the workflow.

##### Step 5.2: The **before_review** Hook

The **before_review** hook is executed at the beginning of the review process. This hook can be used for things like creating a pull request, deploying the changes to an environment where it can be validated, or anything that makes sense at this stage of the workflow. Like all of the hooks in this workflow, the developers define the commands that are executed at this point. If the hooks do not pass, the **hook-diagnostician** SubAgent will be invoked to help diagnose the issue.

##### Step 5.3: Invoking the _complete_ endpoint

The agent will now call the _/api/tasks/:id/complete_ endpoint with the output of the **after_doing** and **before_review** hooks. Also, the agent must provide additional details that are added to the Task. Those details are `completion_summary`, `actual_complexity`, `time_spent_minutes`, and `actual_files_changed`. This moves the task to the _Review_ column on the board. 

##### Step 5.4: The optional agent pause

When the tasks are in the _Backlog_ column, before the agent begins working on them, the team can check a `needs review` checkbox. Checking this value causes the agent to [pause and wait](https://github.com/cheezy/kanban/blob/main/docs/REVIEW-WORKFLOW.md) for human review at this point in the workflow before continuing. If the checkbox was not checked, then the agent immediately moves to the next step.

Once the team has completed their review, they need to update the Task. The `Review Status` field dictates the next steps:

- `Approved`: This task is ready to be moved to the _Done_ column.
- `Rejected`: These changes need to be reverted and the task should be moved back to the _Ready_ column.
- `Changes Requested`: The task should be moved back to the _Doing_ column and the agent will continue work based on the feedback provided in the `Review Notes` field.

Once the task has been updated with the review information, the developer simply lets the agent know that the review is complete and the agent will continue the workflow.

##### Step 5.5: The **after_review** Hook

This is the final hook in the workflow, and it is often used to push code to a central server, start pipelines, or anything else that should occur with completed work. If the hooks do not pass, the **hook-diagnostician** SubAgent will be invoked to help diagnose the issue.

#### Step 6: The task is moved to the _Done_ column

A final API call is made with the results of the **after_review** hook. This moves the task to the _Done_ column and the agent is ready to claim the next task.

### Summary

The workflow defined here is the result of running several thousand tasks through Stride and making small adjustments based on the results. I feel it is a great example of how to use the features available to the agents to create a robust and efficient workflow.
