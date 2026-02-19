---
date: '2026-02-19T13:01:01-05:00'
draft: false
title: 'Stride Has New Skills'
tags: ["AI", "Agile", "Continuous Delivery"]
---

When you build an API designed for AI agents, you quickly discover something humbling: agents make the same mistakes over and over. Not because they're incapable, but because they're working from memory instead of reference material. I spent a few hours fixing this in Stride, and the results surprised me.

## The Problem

Stride is a kanban-based task management platform built for AI agents. Agents claim tasks, execute lifecycle hooks, implement features, and mark work complete --- all through a REST API. The system works well when agents format their requests correctly. The trouble is, they often don't.

I kept seeing the same failures:

- **Wrong field types.** `verification_steps` sent as `["mix test", "mix credo"]` (an array of strings) instead of the required array of objects with `step_type`, `step_text`, and `position` fields.
- **Invalid enum values.** `"type": "task"` or `"type": "bug"` instead of the valid values `"work"`, `"defect"`, or `"goal"`.
- **Wrong root keys.** The batch endpoint at `POST /api/tasks/batch` expects `"goals"` as the root JSON key, but agents consistently sent `"tasks"` --- a reasonable guess that happens to be wrong.
- **Missing hook results.** Agents calling the claim endpoint without `before_doing_result`, or the complete endpoint without both `after_doing_result` and `before_review_result`.
- **Wrong data shapes.** `actual_files_changed` sent as a JSON array instead of a comma-separated string.

These weren't edge cases. They accounted for a significant share of all 422 validation errors. And the root cause was always the same: the agent was constructing the request from memory, without consulting a reference.

## The Diagnosis

I traced the problem to three gaps in the system:

**1. No machine-readable field reference.** The onboarding endpoint returned workflow instructions and file templates, but nothing that said "the `type` field accepts exactly these three values." Agents had to rely on whatever they remembered from documentation they may or may not have read.

**2. Skills lacked inline field guidance.** The Claude Code skills (markdown files that guide agent behavior during claiming, completing, and creating tasks) described the *workflow* clearly but didn't include the *field formats* needed to construct valid requests. An agent following the claiming skill knew to execute the `before_doing` hook first, but had no quick reference for the exact shape of the claim request body.

**3. No version tracking.** When I updated a skill on the server, agents continued using their locally installed (now outdated) copy indefinitely. There was no mechanism to detect or signal that local skills were stale.

## The Fix: Three Goals, Eleven Task (using Stride terminology)

I broke the work into three goals and let Stride manage the execution.

### Goal 1: API Field Reference Schema

I added a structured `api_schema` map to the onboarding response. It's not documentation prose --- it's a machine-readable reference that agents can consult before constructing any request:

```json
{
  "api_schema": {
    "request_formats": {
      "claim_task": {
        "endpoint": "POST /api/tasks/claim",
        "required_body": {
          "identifier": "string (e.g. 'W47')",
          "agent_name": "string",
          "before_doing_result": "hook_result_format (see below)"
        }
      },
      "batch_create": {
        "endpoint": "POST /api/tasks/batch",
        "root_key": "goals",
        "note": "Root key MUST be 'goals', NOT 'tasks'"
      }
    },
    "task_fields": {
      "type": {"type": "enum", "values": ["work", "defect", "goal"], "required": true},
      "priority": {"type": "enum", "values": ["low", "medium", "high", "critical"], "required": true}
    },
    "embedded_objects": {
      "verification_steps": {
        "type": "array_of_objects",
        "NOT_strings": "This MUST be an array of objects, NOT an array of strings",
        "required_fields": {
          "step_type": "string ('command' or 'manual' only)",
          "step_text": "string",
          "position": "integer >= 0"
        }
      }
    }
  }
}
```

The schema covers request formats for every endpoint (create, batch, claim, complete), the hook result format, all task fields with types and valid values, and embedded object structures with explicit WRONG vs. RIGHT examples. When an agent sees `"⚠️_NOT_strings"` next to the verification_steps definition, the message is hard to miss.

### Goal 2: Inline Field Guidance in Skills

Each of the four Stride skills (claiming, completing, creating tasks, creating goals) was enhanced with inline field reference material. Rather than making agents leave the skill to look up field formats, I brought the reference to them.

For the **claiming skill**, I added:
- A hook result format table showing the exact three fields (`exit_code`, `output`, `duration_ms`) with types and examples
- A claim request checklist with every field including the optional `skills_version`
- WRONG vs. RIGHT examples that show common mistakes side by side

For the **completing skill**, I added:
- A completion request field reference covering all required fields
- A reminder that `actual_files_changed` must be a comma-separated string, not an array
- The same hook result format table for consistency

For the **creating tasks** and **creating goals** skills, I added:
- Field quick reference tables with exact valid values for enums
- Embedded object format sections with explicit WRONG/RIGHT examples for `verification_steps`, `key_files`, and `testing_strategy`
- Batch endpoint root key reminders (for goals skill)

Every skill now ends with a standard footer pointing to the `api_schema` in the onboarding response and the full API reference. Agents always know where to look for more detail.

### Goal 3: Skill Versioning and Staleness Detection

This was the most interesting piece. I needed a way to tell agents "your local skills are outdated" without adding a separate version-checking step to their workflow.

The solution: **piggyback on existing API calls.**

I added a `@skills_version` module attribute to `AgentJSON` as a single source of truth:

```elixir
@skills_version "1.0"
def skills_version, do: @skills_version
```

The onboarding response now includes `skills_version: "1.0"`, and each skill's YAML frontmatter includes the same version. Agents note this version when they install skills.

Then I modified the three most common task endpoints (`next`, `claim`, `complete`) to accept an optional `skills_version` parameter. Every response now includes `current_skills_version`. If the agent sends a version that doesn't match, the response includes an additional `skills_update_required` block:

```json
{
  "data": { "..." },
  "current_skills_version": "1.0",
  "skills_update_required": {
    "current_version": "1.0",
    "your_version": "0.8",
    "action": "Call GET /api/agent/onboarding and re-install all skills",
    "reason": "Your local skills are outdated."
  }
}
```

This costs nothing in the normal case (agent sends matching version, no extra data returned) and catches staleness automatically when it matters. The agent doesn't need to poll or check --- it just includes its version with the calls it's already making.

## Implementation Details

The staleness detection lives in a single private function in `TaskJSON`:

```elixir
defp maybe_add_skills_version(response, assigns) do
  current = KanbanWeb.API.AgentJSON.skills_version()
  response = Map.put(response, :current_skills_version, current)

  case assigns[:agent_skills_version] do
    nil -> response
    "" -> response
    version when version == current -> response
    stale_version ->
      Map.put(response, :skills_update_required, %{
        current_version: current,
        your_version: stale_version,
        action: "Call GET /api/agent/onboarding and re-install all skills...",
        reason: "Your local skills are outdated..."
      })
  end
end
```

All three `show/1` clauses in `TaskJSON` pipe through this function. The controller threads the `skills_version` parameter from the request into the assigns. Clean separation, minimal coupling.

## What I Learned

**Reference material beats training.** Agents don't need longer explanations of *why* `verification_steps` must be objects. They need a quick-reference table showing the exact format, placed where they'll see it when constructing the request. WRONG/RIGHT examples are more effective than paragraphs of explanation.

**Put guidance at the point of use.** The `api_schema` in the onboarding response is useful, but the inline tables in each skill are what actually prevent errors. An agent following the claiming workflow sees the claim request format without context-switching to another document.

**Version detection should be passive.** Asking agents to check their skill version before every operation would add friction and they'd skip it. Piggybacking on existing API calls means staleness detection happens automatically with zero extra effort.

## What's Next

Version 1.0 of the schema and skills is deployed. When agents start sending `skills_version` with their requests, I'll be able to track adoption and measure the actual reduction in validation errors. If the inline guidance works as expected, the next step is expanding the `api_schema` to cover response formats as well, giving agents a complete contract for every endpoint.

The broader lesson: when your users are AI agents, the traditional approach of "write good docs and hope they read them" doesn't work. You need to put the right information in the right place at the right time --- and make the system tell agents when their information is out of date.
