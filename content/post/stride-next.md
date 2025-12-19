---
date: '2025-12-19T08:32:51-05:00'
draft: false
title: 'Stride goes full AI'
tags: ["AI", "Agile", "Continuous Delivery"]
---

## Building an AI-Optimized Kanban System: A Human-AI Collaboration Experiment

I'm embarking on an experiment to build a Kanban task management system specifically designed for AI-human collaboration. This isn't just another project management tool—it's a system where AI agents and humans work together as peers on software development tasks.

## The Vision

Most task management tools treat tasks as simple items with a title and description. But when you're working with AI agents (like Claude, GPT-4, or custom agents), they need much more context to be effective. They need to understand:

- **Why** the work matters (the problem being solved)
- **What** specifically needs to be built
- **Where** in the codebase to make changes
- **How** to verify their work is correct
- **What** common pitfalls to avoid

My goal is to create a Kanban system that provides this rich context in a structured format that both humans and AI can understand and act upon. In fact the entire system was designed by asking AI what wold be the best way to delivery tasks for it to complete. This is what is becoming know as AI UX - creating the user experience targeting AI.

## The Core Concept: Tasks as Rich Metadata

Traditional task: "Add user authentication"

AI-optimized task includes:
```json
{
  "identifier": "W42",
  "title": "Add user authentication",
  "type": "work",
  "complexity": "large",
  "estimated_files": "5-6",
  "priority": 1,
  "status": "open",

  "why": "Users need secure login to access personalized features",
  "what": "Implement email/password auth with session management",
  "where_context": "Authentication system, user module",

  "patterns_to_follow": "Follow existing Guardian JWT pattern in lib/app/auth",
  "database_changes": "Add users table, sessions table with indexes",

  "key_files": [
    {
      "path": "lib/app/auth.ex",
      "note": "Main auth logic",
      "position": 1
    },
    {
      "path": "lib/app_web/controllers/session_controller.ex",
      "note": "Login/logout endpoints",
      "position": 2
    },
    {
      "path": "lib/app/schemas/user.ex",
      "note": "User schema with password hashing",
      "position": 3
    }
  ],

  "verification_steps": [
    {
      "type": "command",
      "text": "mix test test/app/auth_test.exs",
      "expected_result": "All auth tests pass",
      "position": 1
    },
    {
      "type": "command",
      "text": "mix credo --strict",
      "expected_result": "No warnings",
      "position": 2
    },
    {
      "type": "manual",
      "text": "Test login flow in browser",
      "expected_result": "User can login, logout, and session persists",
      "position": 3
    }
  ],

  "telemetry_event": "[:app, :auth, :login_success]",
  "metrics_to_track": ["Login attempts", "Failed logins", "Session duration"],
  "logging_requirements": "Log all login attempts with user ID and IP",

  "error_user_message": "Login failed. Please check your credentials.",
  "error_on_failure": "Return 401 Unauthorized, log attempt",
  "validation_rules": "Email must be valid format, password minimum 8 characters",

  "pitfalls": [
    {
      "text": "Don't store passwords in plain text - use bcrypt",
      "position": 1
    },
    {
      "text": "Remember to handle session timeout (60 minutes)",
      "position": 2
    },
    {
      "text": "Avoid exposing user existence in error messages",
      "position": 3
    }
  ],

  "out_of_scope": [
    {
      "text": "OAuth integration (separate task W43)",
      "position": 1
    },
    {
      "text": "Two-factor authentication (future enhancement)",
      "position": 2
    },
    {
      "text": "Password reset flow (follow-up task)",
      "position": 3
    }
  ],

  "technology_requirements": "Phoenix Guardian for JWT\nBcrypt for password hashing\nPhoenix LiveView for UI",

  "required_capabilities": ["code_generation", "testing", "database_design"],
  "dependencies": ["W15", "W22"],
  "needs_review": true
}
```

This structure gives AI agents everything they need to complete the task autonomously while providing humans with clear guidance about scope and expectations.

## The Features

### Phase 1: Database Schema Foundation

First, I'm extending the database to store 18 categories of task information:

- **Core fields**: title, description, type, complexity, priority
- **Context fields**: why, what, where, patterns to follow
- **Technology fields**: key files, verification steps, database changes
- **Observability**: telemetry events, metrics, logging requirements
- **Error handling**: validation rules, user messages, failure scenarios
- **Guidance**: pitfalls to avoid, out-of-scope items
- **Lifecycle tracking**: who created/completed, when, actual vs estimated effort
- **Dependencies**: task relationships and blocking chains

### Phase 2: Rich Task UI

Building a comprehensive UI that:
- Displays all task metadata in an organized, readable format
- Provides a detailed task creation form
- Includes board-level field visibility toggles (so you can hide fields you don't need)
- Shows AI vs human badges (track who created/completed each task)

### Phase 3: AI Agent API

The heart of the system—a RESTful JSON API that enables AI agents to:

**Authentication:**
```bash
GET /api/tasks/next
Authorization: Bearer kan_dev_abc123xyz...
```

**Task Discovery:**
```bash
GET /api/tasks/next
# Returns the next task you're capable of completing
# Filters by capabilities, dependencies, and availability
```

**Atomic Task Claiming:**
```bash
POST /api/tasks/:id/claim
# Atomically claims a task with 60-minute timeout
# Auto-releases if not completed within timeout
```

**Task Completion with Rich Summary:**
```bash
PATCH /api/tasks/:id/complete
{
  "completed_by": "ai_agent:claude-sonnet-4.5",
  "actual_complexity": "large",
  "actual_files_changed": 8,
  "time_spent_minutes": 45,
  "completion_summary": {
    "files_changed": [...],
    "tests_added": [...],
    "verification_results": {...},
    "estimation_feedback": {...},
    "follow_up_tasks": [...]
  }
}
```

**Bulk Task Upload:**
```bash
POST /api/tasks/bulk
{
  "tasks": [
    {
      "title": "Add user authentication",
      "complexity": "large",
      "why": "Users need secure login",
      "what": "Implement email/password auth",
      ...
    },
    {
      "title": "Add password reset",
      "complexity": "medium",
      "dependencies": ["W42"],
      ...
    }
  ]
}
# Creates multiple tasks in a single request
# Perfect for agents uploading entire feature breakdowns
```

**Agent Documentation Endpoint:**
```bash
GET /api/agent/info
# Returns comprehensive JSON documentation about:
# - System workflow
# - API endpoints
# - Hook system
# - Best practices
# - Common pitfalls
```

### Phase 4: Task Management & Dependencies

- **Dependency graphs** with circular dependency detection
- **Automatic unblocking** when prerequisite tasks complete
- **Hierarchical task trees** (Epics → Features → Tasks)
- **Estimation feedback loop** (track actual vs estimated complexity)

## The AI-Human Collaboration Workflow

One of the most interesting aspects of this system is how AI agents and humans work together:

### Task Design Phase

1. **AI Designs Tasks**: An AI agent analyzes a feature request and breaks it down into detailed tasks using the bulk upload API
2. **Upload to Backlog**: All tasks are created via `POST /api/tasks/bulk` and land in a "Backlog" column
3. **Human Review**: A human reviews the AI-generated task breakdown, checking:
   - Are the tasks well-defined?
   - Are dependencies correct?
   - Is the complexity estimation reasonable?
   - Are any tasks missing or unnecessary?
4. **Move to Ready**: The human moves approved tasks from "Backlog" to "Ready" column
5. **AI Executes Work**: Only tasks in "Ready" column are available via `GET /api/tasks/next` for agents to claim

This creates a **design-review-execute loop** where:

- AI agents handle the tedious work of breaking down features into detailed tasks
- Humans provide oversight and approval before work begins
- AI agents execute the approved work autonomously
- Humans review completed work (if `needs_review=true`)

### Example Flow

```text
1. Human: "We need user authentication"
2. AI Agent: Designs 8 tasks → POST /api/tasks/bulk → Land in Backlog
3. Human: Reviews tasks → Moves 6 to Ready, edits 1, deletes 1
4. AI Agent: GET /api/tasks/next → Claims W42 from Ready
5. AI Agent: Completes W42 → Creates 2 follow-up tasks → Land in Backlog
6. Human: Reviews new tasks → Approves → Moves to Ready
7. Repeat...
```

This workflow ensures humans stay in control while leveraging AI for the heavy lifting.

## Innovative Features

### 1. Agent Workflow Hooks

AI agents can execute custom commands at workflow transition points via an `AGENTS.md` configuration file:

```markdown
# AGENTS.md

## agent:claude-sonnet-4.5

capabilities:
  - code_generation
  - testing
  - documentation

hooks:
  after_claim:
    - git checkout -b task-{TASK_ID}
    - git pull origin main

  before_complete:
    - mix test
    - mix format --check-formatted
    - mix credo --strict

  after_complete:
    - git add .
    - git commit -m "{TASK_TITLE}"
    - git push origin task-{TASK_ID}
```

This enables agents to follow your team's workflow automatically.

### 2. Optional Human Review

Tasks have a `needs_review` flag (defaults to `false`):
- **When false**: Agent completes task → automatic quality checks run → task moves to Done
- **When true**: Agent completes task → quality checks run → waits for human approval

This lets you specify which tasks need human oversight and which can be fully autonomous.

### 3. Real-Time PubSub Updates

When an AI agent makes changes via API, all connected users see updates immediately via Phoenix PubSub:
- Task claimed → UI shows "Claimed by claude-sonnet-4.5"
- Task moved → UI reflects new column
- Task completed → UI updates status and shows completion summary

No page refresh needed.

### 4. Capability Matching

Tasks specify required capabilities:
```json
{
  "required_capabilities": ["code_generation", "testing", "database_design"]
}
```

Agents declare their capabilities:
```json
{
  "capabilities": ["code_generation", "testing", "documentation"]
}
```

The `GET /api/tasks/next` endpoint only returns tasks the agent is capable of completing.

### 5. Follow-Up Task Creation

When agents discover follow-up work during task completion, they don't just document it—they **create new tasks**:

```bash
# Complete current task
PATCH /api/tasks/42/complete
{
  "completion_summary": {
    "follow_up_tasks": [
      "Add password reset flow",
      "Implement 2FA support"
    ]
  }
}

# Immediately create follow-up tasks
POST /api/tasks
{
  "title": "Add password reset flow",
  "why": "Follow-up from W42: Users need password reset capability",
  "dependencies": [42]
}
```

This ensures discovered work doesn't get lost.

## Scaling with Multiple Agents and Teams

One of the most powerful aspects of this system is its ability to scale horizontally—multiple agents can work on the same backlog simultaneously, dramatically accelerating delivery.

### Multi-Agent Collaboration

**Single Backlog, Multiple Workers:**

```text
Ready Column:
├── W42: Add user authentication
├── W43: Add password reset
├── W44: Implement logging
├── W45: Add API documentation
└── W46: Write integration tests

Agent 1 (Claude Sonnet): GET /api/tasks/next → Claims W42 (requires code_generation)
Agent 2 (Claude Opus):   GET /api/tasks/next → Claims W44 (requires code_generation)
Agent 3 (GPT-4):         GET /api/tasks/next → Claims W46 (requires testing)
```

**How It Works:**

1. **Atomic Claiming**: The `POST /api/tasks/:id/claim` endpoint uses database-level locking to ensure only one agent can claim a task
2. **Capability Filtering**: Each agent only sees tasks matching their capabilities via `GET /api/tasks/next`
3. **Dependency Awareness**: Agents can't claim tasks blocked by incomplete dependencies
4. **60-Minute Timeout**: If an agent gets stuck, the task auto-releases for another agent to try

**Benefits:**

- **Parallel Execution**: Independent tasks complete simultaneously
- **Specialization**: Agents with different capabilities work on appropriate tasks (testing, documentation, database, etc.)
- **Resilience**: If one agent fails, others continue; failed tasks become available for retry
- **Load Balancing**: Work distributes automatically based on availability and capability

### Multi-Team Collaboration

**Same backlog, different teams:**

```text
Scenario: Multiple teams (or companies) working on the same product

Team A (Internal):
├── Agent 1: Full codebase access, all capabilities
├── Agent 2: Full codebase access, all capabilities
└── Human reviewers with domain knowledge

Team B (Contractors):
├── Agent 3: Limited to documentation tasks
├── Agent 4: Limited to testing tasks
└── Human reviewers (external)

Shared Backlog:
├── Ready Column: Tasks available to all
├── Each agent claims based on capabilities
├── Each team reviews their agent's work
├── Real-time PubSub keeps everyone synchronized
```

**Use Cases:**

1. **Agency + Client**: Agency AI agents handle implementation, client AI agents handle documentation
2. **Distributed Teams**: Multiple time zones, agents work 24/7 across all zones
3. **Specialized Teams**: Frontend team agents + Backend team agents + DevOps agents
4. **Outsourced Work**: Internal agents for core features, contractor agents for peripheral features

**Coordination Features:**

- **Task Visibility**: All teams see the same board in real-time via PubSub
- **Dependency Chains**: Teams can't break dependencies (blocked tasks aren't claimable)
- **Capability-Based Segmentation**: Limit certain agents to certain task types
- **Audit Trail**: Track which agent/team completed which work via `completed_by_agent` field

### Example: 3 Agents, 15 Tasks, 8 Hours vs 24 Hours

**Sequential (Single Agent):**
```text
Agent works alone:
- Hour 1-3:   Completes W42 (large)
- Hour 4-5:   Completes W43 (medium)
- Hour 6-7:   Completes W44 (medium)
- Hour 8-24:  Continues through remaining 12 tasks
Total: 24 hours
```

**Parallel (Three Agents):**
```text
All agents work simultaneously:
- Hour 1-3:   Agent 1: W42, Agent 2: W43, Agent 3: W44
- Hour 4-5:   Agent 1: W45, Agent 2: W46, Agent 3: W47
- Hour 6-8:   All agents continue claiming available tasks
Total: ~8 hours (3x faster)
```

**Real-World Scenario:**

```text
Monday 9 AM: Human designer uploads 50 tasks to Backlog
Monday 9:30 AM: Human reviews, moves 30 tasks to Ready
Monday 10 AM: 5 agents start claiming tasks
Monday 6 PM: 25 tasks complete, 5 in progress
Tuesday 10 AM: All 30 tasks complete
```

Instead of 5-7 days with a single agent, the work completes in ~1.5 days with parallel execution.

### Coordination Challenges Solved

**Problem: Two agents claim the same task**
- **Solution**: Atomic locking at database level ensures only one succeeds

**Problem: Agent A completes W42, but Agent B claimed W43 which depends on W42**
- **Solution**: Dependency system automatically unblocks W43 when W42 completes

**Problem: Agent gets stuck on a task**
- **Solution**: 60-minute timeout auto-releases the task for another agent

**Problem: How do humans track which agent did what?**
- **Solution**: `completed_by_agent` field tracks every completion, visible in UI

**Problem: Agents with different capabilities claim inappropriate tasks**
- **Solution**: Capability matching ensures agents only see tasks they can complete

### The Future: Swarm Intelligence

Imagine a backlog of 100 tasks representing a major feature. Instead of:
- **Traditional**: 1 developer, 4 weeks
- **AI-Assisted**: 1 developer + 1 AI agent, 2 weeks
- **AI Swarm**: 1 developer (oversight) + 10 AI agents, 3 days

The system is designed for this future—where human developers focus on architecture and review while AI agents handle implementation at scale.









## Eating Our Own Dog Food

Here's where it gets meta: **I'm using the system to build itself**.

The plan:
1. **Tasks 01-06**: Build manually (database, UI, authentication)
2. **Task 07**: Implement the CRUD API
3. **Task 08+**: Use the API to create and manage all remaining tasks

Once the database is created, I will import all of the tasks for this project into that new structure.

From there I will be constructing the UI. As I build the UI, I will be simulating the overall workflow in the system.

The API work is next. Once the API is functional, I'll use it exclusively to:
- Create new tasks via `POST /api/tasks`
- Claim tasks via `POST /api/tasks/claim`
- Update status via `PATCH /api/tasks/:id`
- Complete tasks via `PATCH /api/tasks/:id/complete`

This will validate that the API actually works for real-world task management and catch UX issues before AI agents encounter them.

## Why This Matters

Traditional project management tools are designed for humans to assign work to other humans. But we're entering an era where:

1. **AI agents can complete meaningful work** (write code, tests, documentation)
2. **Agents need structured context** to work effectively
3. **Humans and agents collaborate** as peers on the same team
4. **Transparency is critical** (who did what, when, and how well)

This system is my attempt to build infrastructure for that future. A Kanban board where an AI agent can:
- Understand what needs to be done
- Claim tasks it's capable of completing
- Execute work following team conventions (via hooks)
- Report back with detailed completion summaries
- Create follow-up tasks when needed
- All while humans track progress in real-time

## What I'm Learning

As I build this, I'm discovering:

- **Rich metadata helps humans too**: Even without AI agents, having structured verification steps and key files makes tasks clearer
- **The API-first approach forces clarity**: If you can't explain a task to an API consumer, you haven't defined it well enough
- **Estimation feedback is valuable**: Tracking actual vs estimated complexity creates a learning loop
- **Hooks are powerful**: Being able to customize agent behavior at workflow points enables team-specific conventions

## Following Along

I'm documenting this journey openly. The codebase and all design documents will be available at [github.com/cheezy/kanban] (when I push it).

The epic is broken down into digestible tasks with clear acceptance criteria, verification steps, and examples. Each task has:
- **WHY**: The problem being solved
- **WHAT**: The specific implementation
- **WHERE**: The code areas affected
- **HOW**: Verification commands to run

You can follow the same format for your own AI-optimized tasks.

## The Bigger Picture

This isn't just about building a better Kanban board. It's about exploring what software development looks like when AI agents are first-class team members.

Some questions I'm trying to answer:
- What information do AI agents need to work autonomously?
- How do we balance autonomy with human oversight?
- How do we track and learn from agent performance?
- What workflow conventions enable effective human-AI collaboration?

I don't have all the answers yet. But I'm building a system flexible enough to experiment and learn.

## Want to Try It?

Stride is live and is a usable kanban application. You can visit it at [stride.cheezy.dev](https://stridelikeaboss.com). Changes will show up every day or so. Be sure to check out the changelog which you can assess via the About page.

If you're interested in AI-human collaboration for software development, stay tuned. This is going to be an interesting experiment.

