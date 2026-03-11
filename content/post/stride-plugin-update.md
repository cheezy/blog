---
date: '2026-03-11T14:13:00-04:00'
draft: false
title: 'Teaching AI Agents to Look Before They Leap'
tags: ["AI", "Continuous Delivery"]
---

The Stride Claude Code plugin just shipped version 1.1, and the headline feature is **subagent orchestration** — the ability for an AI agent to dispatch specialized sub-agents at key points in the task lifecycle. Instead of one agent doing everything sequentially, the primary agent now coordinates a team: an explorer that reads the codebase before coding starts, and a reviewer that checks the work before tests run.

This post covers what changed and how it works.

## The Problem: Coding Without Context

Stride's workflow has always been disciplined. The plugin enforces a strict claim-implement-complete loop with hooks at every transition. Each hook must succeed before the workflow advances. Skip a hook, and the API rejects your request.

But between claiming a task and starting to code, there was a gap. The agent would claim a task, read the task details, and start implementing. For simple tasks — a one-file change with clear instructions — this worked fine. For anything more complex, the agent was coding blind:

- It didn't know the current state of the files it was about to modify
- It hadn't read the test files to understand existing patterns
- It hadn't looked at the code referenced in `patterns_to_follow`
- It hadn't checked whether the approach it was about to take matched the codebase conventions

The result was predictable. Medium and large tasks would take a considerable amount of time as the agent was figuring out the current state of the code and where to make changes.

The same problem existed in reverse at task completion. The agent would finish coding and immediately run the `after_doing` hook. If the hook passed, great. But automated tests and static code analysis can't check whether the implementation actually meets the task's acceptance criteria, follows the specified patterns, or avoids the pitfalls the task author explicitly warned about.

## The Solution: Specialized Subagents

Version 1.1 introduces two custom agents and an orchestration skill that ties them into the existing workflow.

### stride:task-explorer

After claiming a task, the primary agent can dispatch `stride:task-explorer` — a read-only agent that does targeted codebase exploration guided by the task's metadata. It reads every file listed in `key_files`, finds the corresponding test files, searches for patterns referenced in `patterns_to_follow`, checks the `where_context`, and returns a structured summary.

The explorer doesn't guess what to look at. It uses the task metadata as a map. If the task says "modify `lib/kanban/tasks.ex` following the pattern in `lib/kanban/boards.ex`", the explorer reads both files, extracts the relevant pattern, and tells the primary agent exactly what to replicate.

### stride:task-reviewer

Before running completion hooks, the primary agent can dispatch `stride:task-reviewer` — a code review agent that validates the git diff against the task's requirements. It checks each acceptance criterion against the diff, scans for pitfall violations, verifies pattern compliance, and confirms the testing strategy was followed.

The reviewer returns issues categorized as Critical, Important, or Minor — with file and line references. Critical issues (missed acceptance criteria, pitfall violations) must be fixed before proceeding. This catches problems that automated tests can't: "Did you actually implement what was asked?" is a question `mix test` can't answer.

### stride-subagent-workflow

The orchestration skill is the traffic controller. It contains a decision matrix that determines which subagents to dispatch based on task complexity and the number of key files:

| Task Attributes | Explorer | Plan | Reviewer |
| --- | --- | --- | --- |
| small, 0-1 key_files | Skip | Skip | Skip |
| small, 2+ key_files | Run | Skip | Run |
| medium (any) | Run | Run | Run |
| large (any) | Run | Run | Run |

Simple tasks get zero overhead — the agent codes directly. Complex tasks get the full treatment: explore, plan, implement, review. The skill also integrates Claude Code's built-in Plan agent for medium and large tasks, creating a three-phase pre-implementation workflow: explore the code, design the approach, then execute.

## How It Fits Into the Workflow

The updated workflow looks like this:

```
1.  Task Discovery       GET /api/tasks/next
2.  Execute before_doing hook (git pull, deps.get)
3.  Claim task           POST /api/tasks/claim
4.  [NEW] Explore        stride:task-explorer reads key_files and patterns
5.  [NEW] Plan           Plan agent designs approach (conditional)
6.  Implementation       Write the code
7.  [NEW] Code Review    stride:task-reviewer validates diff vs acceptance criteria
8.  Execute after_doing  hook (tests, linting)
9.  Execute before_review hook (PR creation)
10. Mark Complete        PATCH /api/tasks/:id/complete
11. Review/Continue      needs_review gate
```

Steps 4, 5, and 7 are conditional. They add zero overhead for small tasks and 10-30 seconds for complex ones. The subagent workflow is also Claude Code-specific — agents running in other environments (Cursor, Windsurf, Continue) skip subagent steps automatically and proceed directly to implementation using the task metadata as their guide.

## Other Changes in 1.1

### Enhanced Existing Skills

The `stride-claiming-tasks` skill now points agents to the subagent workflow after a successful claim. The `stride-completing-tasks` skill includes a new step 1.5 for pre-completion code review, with an updated flowchart showing the optional review branch.

## What's Next

The subagent architecture opens the door to more specialized agents.

## Getting Started

If you're already using the Stride plugin, update to 1.1:

```
/plugin update stride
```

If you're new to Stride, install the plugin:

```
/plugin marketplace add cheezy/stride-marketplace
/plugin install stride@stride-marketplace
```

The subagent features activate automatically for medium and large tasks. No configuration needed — the decision matrix handles it.
