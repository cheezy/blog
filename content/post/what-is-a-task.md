---
date: '2026-01-14T10:24:27-05:00'
draft: false
title: 'What is a task?'
tags: ["AI", "Agile", "Continuous Delivery"]
---

In my pursuit of trying to get the most out of my AI Agents I have spent a lot of time exploring how one can deliver requirements in such a way that they can be understood by Humans and provide the details that will make the Agent implementation successful. Knowing that there is typically a pause between when the requirements is established / captured and when the Agent starts working on it, I wanted to make sure that much of the context and details the Agent had during the planning session was captured in a way that it can be use later during implementation.

## How I started

When I first started using Agents to write my code I took a very basic (and naive) approach. I would ask my Agent to create a plan for my requirements and write it into a local Markdown file. Here is a portion of a plan that I created a while ago:

```shell
#### Phase 3: Board Management UI
- [ ] **Create board list LiveView**
  - [ ] Create `lib/kanban_web/live/board_live/index.ex`
  - [ ] Implement `mount/3` to load user\'s boards
  - [ ] Use streams for board collection
  - [ ] Create template with board cards
  - [ ] Add "New Board" button
  - [ ] Add edit/delete actions for each board
- [ ] **Create board show LiveView**
  - [ ] Create `lib/kanban_web/live/board_live/show.ex`
  - [ ] Load board with preloaded columns and tasks
  - [ ] Display board name and description
  - [ ] Show all columns with their tasks
  - [ ] Add "New Column" button
- [ ] **Create board form component**
  - [ ] Create `lib/kanban_web/live/board_live/form_component.ex`
  - [ ] Build form for creating/editing boards
  - [ ] Add validation and error display
  - [ ] Handle form submission
- [ ] **Add routes**
  - [ ] Add routes in `lib/kanban_web/router.ex` under authenticated scope
  - [ ] `live "/boards", BoardLive.Index, :index`
  - [ ] `live "/boards/new", BoardLive.Index, :new`
  - [ ] `live "/boards/:id/edit", BoardLive.Index, :edit`
  - [ ] `live "/boards/:id", BoardLive.Show, :show`
```

As you can see, each step is simply one short line of text. Although this is fairly easy for a Human to understand, there is not a lot of context or details provided to the Agent. Days later when the Agent worked on these tasks it had to make a lot of assumptions and spend time re-gaining what context it had during the planning session or the previous development session.

Although this worked I could see that it was not the best way to capture the requirements of the system. There were often a lot of details that I had to work with the Agent to implement after they would complete one of these tasks.

## Requirement Challenges

With my client work we were running into challenges building enough requirements to keep the Agents busy. I knew the only way to solve this problem was to have the Agent help us write the requirements and then break those requirements down into tasks that the Agents could work on.

But what shape should a task take? What should be included and what is important for an Agent?

## Defining The Task

I started to ask a few Agents what they thought a task should look like. More specifically I asked them what information would they like to have available during implementation to make it easier to implement. I also asked them what details they had available when I asked the to create the simple plans that were never captured in the Markdown files.

Once I had this information I put it to the test. I asked an Agent to create a plan in this new format. Later with a new session I would ask the Agent to implement the plan that was in the new format. After the implementation I would ask the Agent what information was missing. I would also ask what information was there but not useful.

This process repeated itself many times. Shortly I started using the new task template to enhance [Stride](https://www.stridelikeaboss.com). I was using the new task structure to build a system that could manage tasks. I was constantly trying ideas with the Agent to make the task structure better and more useful.

I arrived at a task structure that an Agent can easily create during planning, the Human can review and make addjustments as necessary, and that the Agents find thorough enough to later complete the implementation.

## My Task

Below is a portion of the [@moduledoc](https://hexdocs.pm/elixir/writing-documentation.html) from the Task module in Stride. It has a lot details and might be a bit overwhelming but it is a good example of what a task should look like.

Several of the fields (_actual_complexity, actual_files_changed, and time_spent_minutes_) are not for requiremnts but are instead used to capture information about the actual implementation that can be used for Agent learning by comparing to the estimates created during planning. The _needs_review_ field is used for the Human to let the Agent know that they should pause and wait for the Human to review the completed task, read the status and notes (review_status, and review_notes) when the Human lets them know the review is complete, and then take the appropriate action based on the results of the review.

```elixir

  @moduledoc """
  Schema and validations for tasks in the Stride task management system.

  Tasks represent work items that can be assigned to humans or AI agents.
  They support hierarchical relationships (goals with children), dependency
  tracking, capability matching, and comprehensive metadata for AI-assisted
  development.

  ## Task Types

  - `:work` - Feature implementation, enhancement, or general development work
  - `:defect` - Bug fix or correction
  - `:goal` - Large initiative containing multiple child tasks

  ## Task Lifecycle

  1. Created in Ready column (`:open` status)
  2. Claimed by agent or assigned to human (`:in_progress` status, claim tracking)
  3. Work completed (`:completed` status, completion metadata)
  4. Optional review cycle (`:needs_review`, review tracking)
  5. Finalized as Done or returned for changes

  ## Field Categories

  ### Core Fields
  - `title` - Short description (required)
  - `description` - Detailed explanation
  - `acceptance_criteria` - Definition of done
  - `type` - :work, :defect, or :goal (required)
  - `priority` - :low, :medium, :high, or :critical (required)
  - `complexity` - :small, :medium, or :large
  - `status` - :open, :in_progress, :completed, or :blocked

  ### Planning & Context
  - `why` - Problem/value explanation
  - `what` - Specific change description
  - `where_context` - Location in code/UI
  - `estimated_files` - Files expected to change

  ### Implementation Guidance
  - `patterns_to_follow` - Code patterns to replicate
  - `database_changes` - Schema modifications needed
  - `validation_rules` - Input validation requirements
  - `key_files` - Critical files to modify (embeds)
  - `verification_steps` - How to verify completion (embeds)
  - `pitfalls` - What NOT to do
  - `out_of_scope` - Explicitly excluded functionality

  ### AI Context
  - `required_capabilities` - Agent skills needed (e.g., ["code_generation", "testing"])
  - `security_considerations` - Security implications
  - `testing_strategy` - Comprehensive testing approach
  - `integration_points` - External systems/events involved
  - `technology_requirements` - Specific tools/libraries needed

  ### Observability
  - `telemetry_event` - Event name to emit
  - `metrics_to_track` - What to measure
  - `logging_requirements` - Logging expectations

  ### Error Handling
  - `error_user_message` - User-facing error message
  - `error_on_failure` - Error to raise on failure

  ### Tracking & Relationships
  - `dependencies` - Task identifiers that must complete first
  - `parent_id` - Parent goal (for hierarchical structure)
  - `created_by` / `created_by_agent` - Creator tracking
  - `completed_by` / `completed_by_agent` - Completer tracking
  - `claimed_at` / `claim_expires_at` - Claim tracking
  - `needs_review` / `review_status` - Review workflow
  - `actual_complexity` / `actual_files_changed` / `time_spent_minutes` - Actuals vs estimates

```

I think it is important to call out a few additional fields as they really help set this task structure apart from what I have seen elsewhere. Let's look at the details of _key_files_, _verification_steps_, and _testing_strategy_.

#### key_files

During planning the Agent can estimate what files they will need to change during the course of implementation. They will capture this information in a field named _key_files_. This is later used by Stride to try to minimize change conflicts. Here is the definition from the code:

```elixir
# Critical Files (Embedded Array of Objects)
# Format: [%{file_path: "lib/auth.ex", note: "Main auth logic", position: 0}, ...]
# Validates: Array of objects with file_path (string), note (string), position (integer)
embeds_many :key_files, KeyFile, on_replace: :delete
```
and here is an example from the comments in the code:

```elixir
key_files: [
    %{file_path: "lib/auth/oauth.ex", note: "Main OAuth logic", position: 0},
    %{file_path: "test/auth/oauth_test.exs", note: "Test coverage", position: 1}
]
```

#### verification_steps

This field captures what steps the Agent will perform to ensure that this task has been completed accurately. Let's look at the definition:

```elixir
# Verification Steps (Embedded Array of Objects)
# Format: [%{step_type: "command", step_text: "mix test", expected_result: "All pass", position: 0}, ...]
# Validates: step_type must be "command" or "manual", all fields required
embeds_many :verification_steps, VerificationStep, on_replace: :delete
```

and an example:

```elixir
verification_steps: [
    %{step_type: "command", step_text: "mix test test/auth/oauth_test.exs", expected_result: "All OAuth tests pass", position: 0},
    %{step_type: "command", step_text: "mix credo --strict lib/auth/oauth.ex", expected_result: "No code issues", position: 1},
    %{step_type: "manual", step_text: "Test OAuth flow in browser with valid credentials", expected_result: "Successfully authenticate and receive token", position: 2},
    %{step_type: "manual", step_text: "Test OAuth flow with expired token", expected_result: "Proper error message and redirect", position: 3}
]
```

#### testing_strategy

In addition to verification, the Agent captures what type of tests will be writtena and additional non-automated tests.

```elixir
# Comprehensive testing approach - Validated: Map with string or array values
# Example: %{"unit_tests" => ["Test token gen"], "edge_cases" => ["Expired tokens", "Invalid emails"]}
field :testing_strategy, :map, default: %{}
```

and an example:

```elixir
testing_strategy: %{
    "unit_tests" => ["Test token generation", "Test token validation"],
    "integration_tests" => ["Full OAuth2 flow"],
    "edge_cases" => ["Expired tokens", "Invalid client IDs"]
}
```

## Summary

The amount of details in the task might be overwhelming. In practice the majority of the information capture is for the Agent and the Human can safely ignore it. Providing the best of both worlds (Human readable, Agent implementable) is a challenge and this structure might continue to evolve as our Agents and Humans interactions continue to improve.
