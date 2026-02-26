---
date: '2026-02-26T11:21:00-05:00'
draft: false
title: 'Building the Learning Management System - Creating the Backlog'
tags: ["AI", "Continuous Delivery"]
---

In this post, we continue to show how the process we outlined in the post [The New Team](/post/the-new-team/) works. If you haven't read the initial post, I recommend you do so before reading this one.

## Creating the Backlog

In the [previous post](/post/lms1/), we created a set of requirements for the Learning Management System. In this post, we will turn that set of requirements into a backlog of tasks that we will use to build the system.

In this simulation, the team will use Claude Code with a set of [Skills](https://code.claude.com/docs/en/skills) provided by [Stride](https://stridelikeaboss.com) to build out the backlog from the document created earlier. This Skill will inform Claude of what details we want to capture in each task. This will be used by agents to build the system.

### Why Tasks?

Many developers that are not using Stride or a similar tool, try to provide prompts to AI agents to direct them on their work. Simple prompts are not effective as they lack so many details. It is no wonder that many developers complain that AI didn't implement their requirements properly.

The [tasks](https://cheezyworld.ca/post/what-is-a-task/) as defined by Stride are very detailed and include concerns that might not be thought of initially. This is a large part of the secret of this approach to development. Some of the information that exists in Stride Tasks are:

-  `title` - Short description (required)
- `description` - Detailed explanation
- `acceptance_criteria` - Definition of done
- `priority` - :low, :medium, :high, or :critical (required)
- `complexity` - :small, :medium, or :large
- `why` - Problem/value explanation
- `what` - Specific change description
- `where_context` - Location in code/UI
- `estimated_files` - Files expected to change
- `patterns_to_follow` - Code patterns to replicate
- `database_changes` - Schema modifications needed
- `validation_rules` - Input validation requirements
- `key_files` - Critical files to modify (embeds)
- `verification_steps` - How to verify completion (embeds)
- `pitfalls` - What NOT to do
- `out_of_scope` - Explicitly excluded functionality
- `required_capabilities` - Agent skills needed (e.g., ["code_generation", "testing"])
- `security_considerations` - Security implications
- `testing_strategy` - Comprehensive testing approach
- `integration_points` - External systems/events involved
- `technology_requirements` - Specific tools/libraries needed
- `telemetry_event` - Event name to emit
- `metrics_to_track` - What to measure
- `logging_requirements` - Logging expectations
- `error_user_message` - User-facing error message
- `error_on_failure` - Error to raise on failure
- `dependencies` - Task identifiers that must complete first
- `parent_id` - Parent goal (for hierarchical structure)
- `needs_review` / `review_status` - Review workflow

There are additional fields in the task that are used for internal purposes and also to support a review process. We'll describe the review process in a later post.

### Building the Backlog

The video is not that exciting. Most of the time is spent waiting for Claude to work out the details of the tasks. In my opinion, this is time well spent.

{{< youtube xFuugLMfD3M >}}

### What happens next?

After the backlog is uploaded to Stride, the team will review the tasks and make any necessary changes. This is one field that is very important. It is the `Needs Review` field. If this field is set to true, the agent implementing the task will wait for the human reviewer to give them the okay or request changes prior to grabbing the next task. This is yet another way for Humans to be involved in the process.

Once the teams are happy with the details of the tasks they can simply move them to the `Ready` column on the board. That signals to the agent that they are _ready_ for implementation. That is where the next post will pick up.
