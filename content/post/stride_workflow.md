---
date: '2026-01-06T08:05:52-05:00'
draft: false
title: 'The Stride Workflow'
tags: ["AI", "Agile", "Continuous Delivery"]
---

## How do Humans collaborate with AI?

When I decided to make Stride a Human-AI collaboration tool I spent some time thinking about when and how Humans would want to interject themselves into an AI driven worflow. Those of you that know me know that I have spent a significant portion of my life helping teams optimize their work and achieve better flow. With AI in the mix it causes us to rethink some of what helps us achieve that flow. We have to be realistic about what Humans do best (at this time) and what AI does best and find a way to optimize around these things. At the same time, many Humans are not comfortable (at this time) with letting AI take over completely and they want to be involved in the process. This is what I came up with:

1. Humans might want to look at a set of Tasks before AI works on them. This way they could make adjustments to the Tasks or provide additional context.
2. Humans might want to specify that certain things happen at different points in the worflow. For example, before starting a new Task the Agent should ensure they are working on the latest code or when an Agent finishes a Task they should run certain quality and security checks. This is done through [hooks](https://github.com/cheezy/kanban/blob/main/docs/AGENT-HOOK-EXECUTION-GUIDE.md).
3. Humans might want to review the work completed by an Agent before the Agent moves on to the next Task so they can either approve or ask for modifications. The Human would specify which Tasks they want to review during the backlog refinement process.

The workflow that emerged from this is what is embodied in the Stride Workflow.

### See it in action

This video picks up where the [Getting Started with Stride](/post/getting_started_with_stride) video left off. It shows the full workflow in action. It is kind of boring and I sped it up a lot so you can see it grabbing tasks and moving them across the board. Here are the _hooks_ from my `.stride.md` file so you can see what the Agent is doing as it works on the Tasks and moves them across the board:

#### before_doing

```bash
echo "Starting task $TASK_IDENTIFIER: $TASK_TITLE"
git pull origin main
```

#### after_doing

```bash
echo "Running quality checks for $TASK_IDENTIFIER"
mix test --cover
mix format --check-formatted
mix credo --strict
mix sobelow --config .sobelow_config.exs
```

#### before_review

```bash
echo "Rebasing code for $TASK_IDENTIFIER"
git rebase --autostash origin/main
```

#### after_review

```bash
echo "Finished $TASK_IDENTIFIER"
git commit -a -m "Complete task $TASK_IDENTIFIER: $TASK_TITLE"
```

Notice that in my `after_review` hook I do not automatically _push_ the changes to the remote repository after each task. Instead I specify that a Task that finishes what would be a deployable change _needs review_. This allows me to review the changes before they are pushed to the main branch and deployed to users. There is more information about the _needs review_ concept later in this post.

{{< youtube kS_JZBQPR7Y >}}


## What is the Stride Workflow and how do I work with Stride to complete Tasks?

It starts with a Backlog - a list of Tasks in the **Backlog** column. If you are not sure how to build out your backlog, check out the [Getting Started with Stride](/post/getting_started_with_stride/) post. You should work with the Agent to continuously refine new Tasks as you will need a lot of them. An important part of reviewing the Tasks is deciding which Tasks you want to _review_ after the Agent completes them. You identify these Tasks by checking the Needs Review checkbox.

![Needs Review Checkbox](/img/needs_review.png)

Once you have Tasks in your backlog that are ready to be worked on, you can move them to the **Ready** column. This is where Stride will look for work to assign to Agents. This is where the human lets go for a while to let the Agents do their work.

You will need a lot more tasks in the **Ready** column than you think. The Agents will work much faster than you have experienced with traditional development workflows. Also, when you consider multiple Agents (from multiple developers) will be requesting Tasks you will often see a backlog depleated quickly. Now imagine where each developer is running more than one Agent and you can start to see why we use the Agents to initially create the Tasks. We will need a lot of them.

### The AI Workflow

You can start the workflow by simply asking your agile to work on the next Task in Stride. This is what happens:

1. The Agent [discovers the next Task](https://github.com/cheezy/kanban/blob/main/docs/api/get_tasks_next.md) available for work

2. The Agent executes the `before_doing` hook (blocking, 60s timeout)

   - Example: Pull latest code, setup workspace
   - Capture exit_code, output, and duration_ms
   - **Hook must succeed (exit_code 0) to proceed**

3. The Agent [claims the Task](https://github.com/cheezy/kanban/blob/main/docs/api/post_tasks_claim.md)

   - **REQUIRED:** Include `before_doing_result` parameter with hook execution result
   - API validates hook was executed and succeeded
   - Task moves to **Doing** column

4. The Agent works on the Task - Implement changes, writes code, run tests

5. The Agent executes the `after_doing` hook (blocking, 120s timeout)

   - Example: Run tests, build project, lint code
   - Capture exit_code, output, and duration_ms
   - **Hook must succeed (exit_code 0) to proceed**
   - If this fails, DO NOT call `/complete` - fix the issues first
   - This validates your work is ready for completion

6. The Agent executes the `before_review` hook (blocking, 60s timeout)

   - Example: Create PR, generate documentation
   - Capture exit_code, output, and duration_ms
   - **Hook must succeed (exit_code 0) to proceed**
   - If this fails, DO NOT call `/complete` - fix the issues first
   - This prepares the task for review

7. The Agent [completes the Task](https://github.com/cheezy/kanban/blob/main/docs/api/patch_tasks_id_complete.md)

   - **REQUIRED:** Include BOTH `after_doing_result` AND `before_review_result` parameters
   - **Only call this AFTER both hooks succeed**
   - API validates both hooks were executed and succeeded
   - Task moves to **Review** column (or **Done** if `needs_review=false`)

8. The Agent stops here if the Human checked the **Needs Review** checkbox

   - Wait for human reviewer to approve/reject the task
   - Human reviewer sets review_status through the UI or API
   - Agent proceeds to step 9 only when notified of approval

9. The Agent executes the `after_review` hook (blocking, 60s timeout)

   - Example: Deploy to production, notify stakeholders
   - Capture exit_code, output, and duration_ms
   - **Hook must succeed (exit_code 0) to proceed**
   - If this fails fix the issues before doing anything else

10. The Agent [finalizes the review](https://github.com/cheezy/kanban/blob/main/docs/api/patch_tasks_id_mark_reviewed.md)

    - **REQUIRED:** Include `after_review_result` parameter with hook execution result
    - API validates hook was executed and succeeded
    - If approved: task moves to **Done**
    - If changes requested: task returns to **Doing**, repeat from step 4

11. Dependencies are automatically unblock - Next tasks become available

### Deciding What's Next

Making decisions on what Tasks to work on next is part of the magic of Stride. At first this process might seem complex but it is designed to allow work to flow smoothly and avoid conflicts that might arise. Here are the steps Stride takes to decide what Task to offer an Agent:

1. Only Tasks in the **Ready** column are considered

2. Status Filtering

    - Task status must be either:
        - :open (never claimed), OR
        - :in_progress with an expired claim (claim_expires_at < now)

3. [Capability](https://github.com/cheezy/kanban/blob/main/docs/AGENT-CAPABILITIES.md) Matching

    - The Task's required capabilities must match the Agent's capabilities
    - Logic: Either the Task has NO required capabilities, OR the Agent's capabilities include ALL of the Task's required capabilities

4. Dependency Checking

    - The Task's dependencies must be satisfied
    - Logic: Either the Task has NO dependencies, OR ALL dependency Tasks are completed

5. Key File Conflict Detection - When an Agent creates Tasks it adds the files it expects to change in the course of the work. This information is used for this step.

    - Checks for file conflicts with Tasks currently in **Doing** or **Review** columns
    - If the Task has key files specified, Stride ensures none of those files are being worked on by other in-progress Tasks
    - This prevents multiple Agents from working on the same files simultaneously

6. Sorting Priority

    - Tasks are ordered by:
        - Priority (descending: Critical > High > Medium > Low)
        - Position in the **Ready** column (ascending: top of column first)

#### Summary

The claim endpoint prioritizes Tasks by priority first, then position, while ensuring:

- The Agent has the required capabilities
- All dependencies are complete
- No file conflicts with in-progress work
- The Task is available (not currently claimed or claim has expired)

This ensures Agents get the most important, ready-to-work Task that they're capable of handling and won't create conflicts with other ongoing work.
