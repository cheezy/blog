---
date: '2026-03-17T14:52:00-04:00'
draft: false
title: 'Closing the Loop: How We Added Traceability to Stride'
tags: ["AI", "Continuous Delivery"]
---

When AI agents review code, their findings shouldn't vanish into the ether. That was the driving insight behind the `review_report` feature we shipped in [Stride](https://stridelikeaboss.com) v1.25 and the [Stride plugin](https://github.com/cheezy/stride) v1.4 this week. Here's the story of what we built, why it matters, and how all the pieces fit together.

## The Problem

Stride's task-reviewer SubAgent already did excellent work — it checks code changes against `acceptance criteria`, verifies `pitfall` avoidance, validates `pattern compliance` and alignment of the `testing strategy`. But the review output lived only in the agent's conversation context. Once the agent completed the task, the structured findings were gone. Human reviewers opening a task in the _Review_ or _Done_ column had no visibility into what the AI had already checked.

We needed a way to **persist review findings on the task itself**, so that anyone — human or machine — could see exactly what was reviewed and what the outcome was.

## What We Built

The implementation touched every layer of the stack: database, schema, API, UI, documentation, internationalization, and the Stride plugin.

### 1. Database Migration & Schema

We added a `review_report` text column to the `tasks` table via an Ecto migration. The field is **optional** — it's included in the changeset's cast list but not in `validate_required`. Existing tasks and workflows are completely unaffected.

### 2. API Integration

The `PATCH /api/tasks/:id/complete` endpoint now accepts an optional `review_report` parameter. Agents submit their structured review findings at completion time alongside the existing fields like `completion_notes` and `time_spent_minutes`:

```json
{
  "agent_name": "Claude Opus 4.6",
  "time_spent_minutes": 45,
  "completion_notes": "Implemented feature X. All tests passing.",
  "review_report": "## Review Summary\n\nApproved — 0 issues found.\n\n### Acceptance Criteria\n| # | Criterion | Status |\n|---|-----------|--------|\n| 1 | Feature works correctly | Met |"
}
```

The field is also returned in **all** task JSON responses — `GET /api/tasks`, `GET /api/tasks/:id`, `GET /api/tasks/next`, and the task tree endpoint — so any consumer of the API has full access to review findings.

### 3. Task Detail UI

When a task has a review report, it renders in a distinct blue-themed panel in the task detail view, positioned between the Review Status and Completion sections:

Key design decisions:
- **Conditional rendering** — the section only appears when there's actually a report to show
- **Whitespace preservation** — `whitespace-pre-wrap` renders markdown-style formatting faithfully
- **Scrollable** — `max-h-96 overflow-y-auto` keeps long reports from blowing out the page layout

### 4. Stride Plugin Updates (v1.4.0)

The plugin changes ensure AI agents actually *produce and submit* review reports during their workflow. Three components were updated:

**`stride-completing-tasks` skill** — Added `review_report` to all four documentation sections: the API request JSON example, the field reference table, the quick reference card, and a new step 1.5 that instructs agents to capture reviewer output before calling the completion endpoint. The field is clearly documented as optional — agents omit it when no review was performed.

**`stride-subagent-workflow` skill** — Updated Phase 3 (Code Review) to instruct agents to capture the task-reviewer agent's return value and pass it as `review_report` in the completion API call. This capture happens regardless of whether the review outcome is "Approved" or "Issues found." When the reviewer is skipped (e.g., small tasks with 0–1 key files), the field is simply omitted.

**`stride:task-reviewer` agent** — Added an "Output persistence" note clarifying that the structured review output will be stored on the Stride task record. This nudges the agent to always produce a complete, well-formatted review — even for clean approvals — since the report is now permanently visible.

## Why This Matters

This feature creates a **complete audit trail** for AI-assisted code review. When a human reviewer opens a task in the _Review_ or _Done_ column, they can see this report that compares the code produced by the AI agent to the original task specification.

Let's take a look at what is included in the report and how the SubAgent evaluates the changes against the task.

1. **Acceptance Criteria Verification**:
   - Parse each line of `acceptance_criteria` on the taskas a separate requirement
   - For each criterion, search the diff for corresponding code changes that satisfy it
   - Mark each criterion as: Met (with file:line reference), Partially Met (with explanation of what's missing), or Not Met
   - If any criterion is Not Met, flag it as a Critical issue
   - If any criterion is Partially Met, flag it as an Important issue

2. **Pitfall Detection**:
   - Read each entry in the `pitfalls` array on the task
   - Scan the diff for any code that violates a listed pitfall
   - For each violation found, flag it as Critical with the specific file:line reference and the pitfall it violates
   - Pitfall violations are always Critical because the task author explicitly warned against them

3. **Pattern Compliance**:
   - If `patterns_to_follow` is provided, verify the implementation follows the referenced patterns
   - Check: module structure, function naming, error handling approach, return value format
   - Flag deviations as Important with a description of how the implementation differs from the expected pattern
   - Note whether deviations are justified improvements or problematic departures

4. **Testing Strategy Alignment**:
   - If `testing_strategy` is provided, check whether the diff includes appropriate tests
   - For `unit_tests`: verify test files exist for new functions
   - For `integration_tests`: verify end-to-end test scenarios are covered
   - For `edge_cases`: verify edge case handling in both code and tests
   - Flag missing test coverage as Important

5. **General Code Quality**:
   - Check for obvious bugs, off-by-one errors, or missing error handling in new code
   - Check for hardcoded values that should be configurable
   - Flag issues as Minor unless they could cause runtime failures (then Critical)

This shifts the human reviewer's role from "re-review everything from scratch" to "validate AI findings and check what the AI might have missed." It's a force multiplier for review throughput.

It also establishes **traceability** — if a bug ships, you can look at the task's review report to understand what was checked and what wasn't. That's valuable for improving both the AI reviewer's prompts and the team's task specifications over time.

---

*Stride v1.25.0 and Stride Plugin v1.4.0 are available now. The review_report field is fully backward compatible — no action required for existing tasks or integrations.*
