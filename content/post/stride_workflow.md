---
date: '2026-01-06T08:05:52-05:00'
draft: false
title: 'The Stride Workflow'
tags: ["AI", "Agile", "Continuous Delivery"]
---

## How do I work with Stride to get work done?

It starts with a Backlog - a list of Tasks in the Backlog column. If you are not sure how to build out your backlog, check out the [Getting Started with Stride](/post/getting_started_with_stride/) post.

Once you have some tasks in your backlog that are ready to be worked on, you can move them to the "Ready" column. This is where Stride will look for work to assign to agents. This is where the human lets go for a while to let the agents work.

### The AI Workflow

You can start the workflow by simply asking your agile to work on the next task in Stride. This is what happens:

1. The Agent [discovers the next task](https://github.com/cheezy/kanban/blob/main/docs/api/get_tasks_next.md) available for work - Call GET /api/tasks/next to find available tasks

2. The Agent can [claim the task](https://github.com/cheezy/kanban/blob/main/docs/api/post_tasks_claim.md) - Call POST /api/tasks/claim

   - Receives before_doing hook metadata
   - Task moves to Doing column

3. The Agent executes the before_doing hook (blocking, 60s timeout)

    - Example: Pull latest code, setup workspace

4. The Agent works on the task - Implement changes, write code, run tests

    - Do the actual implementation work
    - Write tests, fix bugs, add features

5. The Agent executes the after_doing hook (blocking, 120s timeout)

    - Example: Run tests, build project, lint code
    - If this fails the Agent attempts to fix the issues
    - This validates your work is ready for completion

6. The Agent [completes the task](https://github.com/cheezy/kanban/blob/main/docs/api/patch_tasks_id_complete.md) - Call PATCH /api/tasks/:id/complete

    - Receives before_review and optionally after_review hooks in response
    - Task moves to Review column (or Done if needs_review=false)

7. Execute before_review hook (non-blocking, 60s timeout)

    - Example: Create PR, generate documentation
    - Execute this after /complete succeeds

8. The Agent Stops Here if needs_review=true

    - It does not execute after_review hook yet!
    - It waits for human reviewer to approve/reject the task
    - Human reviewer sets review_status through the UI or API
    - The process proceeds to step 9 only when notified of approval by Human

9. The Agent [finalizes the review](https://github.com/cheezy/kanban/blob/main/docs/api/patch_tasks_id_mark_reviewed.md) - Call PATCH /api/tasks/:id/mark_reviewed

    - This is called after receiving human approval (if needs_review=true)
    - Or called immediately after step 7 (if needs_review=false)
    - If approved: receives after_review hook, task moves to Done
    - If changes requested: task returns to Doing, repeat from step 4

10. The Agent executes the after_review hook (non-blocking, 60s timeout)

    - Example: Deploy to production, notify stakeholders
    - This executes ONLY after /mark_reviewed returns approved status
    - Or executes immediately after step 7 if needs_review=false

11. Dependencies automatically unblock - Next tasks become available

This may seem like a very long complex workflow but you will be amazed at how fast the Agents will complete tasks! Also, the workflow is designed to allow the Human to control how things progress. The [Hooks](https://github.com/cheezy/kanban/blob/main/docs/AGENT-HOOK-EXECUTION-GUIDE.md) allow the developer to specify what happens at critical points in the workflow. Also, specifying that a Task needs review allows the Human to review all of the work performed by an Agent before having it move on to the next Task.

### Deciding What's Next

Making decisions on what tasks to work on next is part of the magic of Stride. At first this process might seem complex but it is designed to allow work to flow smoothly and avoid conflicts that might arrise. Here are the steps Stride takes to decide what task to offer an Agent:

1. Only tasks in the "Ready" column are considered

2. Status Filtering

    - Task status must be either:
        - :open (never claimed), OR
        - :in_progress with an expired claim (claim_expires_at < now)

3. [Capability](https://github.com/cheezy/kanban/blob/main/docs/AGENT-CAPABILITIES.md) Matching

    - The task's required_capabilities must match the agent's capabilities
    - Logic: Either the task has NO required capabilities, OR the agent's capabilities include ALL of the task's required capabilities

4. Dependency Checking

    - The task's dependencies must be satisfied
    - Logic: Either the task has NO dependencies, OR ALL dependency tasks are completed

5. Key File Conflict Detection - When an Agent creates tasks it adds the files it expects to change in the course of the work. This information is used for this step.

    - Checks for file conflicts with tasks currently in "Doing" or "Review" columns
    - If the task has key_files, ensures none of those files are being worked on by other in-progress tasks
    - This prevents multiple agents from working on the same files simultaneously

6. Sorting Priority

    - Tasks are ordered by:
        - Priority (descending: Critical > High > Medium > Low)
        - Position in the Ready column (ascending: top of column first)

#### Summary

The claim endpoint prioritizes tasks by priority first, then position, while ensuring:

- The Agent has the required capabilities
- All dependencies are complete
- No file conflicts with in-progress work
- The task is available (not currently claimed or claim has expired)

This ensures agents get the most important, ready-to-work task that they're capable of handling and won't create conflicts with other ongoing work.
