---
date: '2026-01-09T07:08:31-05:00'
draft: false
title: 'Stride Has Skills'
tags: ["AI", "Agile", "Continuous Delivery"]
---

I am excited to announce a major enhancement to Stride's AI agent workflow: **Claude Code Skills**. These skills enforce best practices and prevent common mistakes that waste hours of development time.

### What Are Claude Code Skills?

Claude Code Skills are specialized instructions that guide AI agents through complex workflows. Think of them as expert advisors that activate at critical decision points, ensuring agents follow established patterns and avoid known pitfalls.

Unlike traditional documentation that agents must search through and interpret, skills are:

- **Contextually triggered** - Automatically invoked when relevant to the current task
- **Prescriptive** - Provide step-by-step workflows, not just explanations
- **Preventative** - Stop mistakes before they happen, not after
- **Self-contained** - Include everything needed: workflows, examples, common mistakes, and quick references

When properly configured, Claude Code automatically discovers and uses these skills, making them feel like native capabilities rather than external documentation.

## The Four Stride Skills

We've implemented four skills that cover the complete Stride workflow:

### 1. stride-claiming-tasks

**Purpose:** Ensures proper task claiming workflow with hook execution before claiming.

**The Problem:** Agents claiming tasks before executing the `before_doing` hook end up working with outdated code, missing dependencies, and facing merge conflicts. 

**The Solution:** This skill enforces a strict claiming workflow:

1. Verify `.stride_auth.md` and `.stride.md` files exist
2. Find available tasks via `GET /api/tasks/next`
3. Review task details thoroughly
4. Execute the `before_doing` hook (60s timeout, blocking)
5. Only call `POST /api/tasks/claim` after the hook succeeds
6. Begin implementation immediately after claiming

**Impact:** Setup time for a new task is reduced as the Agent is very clear on what is expected.

### 2. stride-completing-tasks

**Purpose:** Ensures both `after_doing` and `before_review` hooks are executed before marking tasks complete.

**The Problem:** Agents calling the completion endpoint before running validation hooks bypass quality gates. Humans want to be sure that all quality gates and preparation for review have been completed before marking a task as complete. This Skill saves time as it instructs the Agent on the proper workflow and prevents post-completion rework.

**The Solution:** This skill enforces proper completion workflow:

1. Execute `after_doing` hook (120s timeout, blocking) - runs tests, linters, build
2. Execute `before_review` hook (60s timeout, blocking) - creates PR, generates docs
3. Only call `PATCH /api/tasks/:id/complete` after both hooks succeed
4. Include both hook results in the API request
5. If `needs_review=true`, stop and wait for human approval
6. If `needs_review=false`, execute `after_review` hook and continue

**Impact:** Reduction in post-completion rework and assurances from the Human that hooks workflow has been followed.

### 3. stride-creating-tasks

**Purpose:** Requires comprehensive task specifications to prevent wasted time during implementation.

**The Problem:** Minimal task specifications force agents to spend hours discovering information that should have been provided upfront. Tasks like "Add dark mode" without context waste hours exploring which files to modify, what patterns to follow, and how to persist settings.

**The Solution:** This skill enforces a comprehensive task specification checklist including:

- Clear title format: `[Verb] [What] [Where]`
- Complete description: WHY this matters and WHAT needs to be done
- Key files that will be modified (prevents merge conflicts)
- Verification steps as array of objects
- Testing strategy with unit, integration, and manual test arrays
- Acceptance criteria
- Patterns to follow with file references
- Pitfalls to avoid

**Impact:** Reduction in implementation time.

### 4. stride-creating-goals

**Purpose:** Enforces proper goal structure with nested tasks and correct batch format.

**The Problem:** Creating goals with incorrect structure causes API rejections (422 errors to date in Stride), silently ignored dependencies, and nested tasks without proper specifications. Although I have spent time improving the error messages on the upload APIs, Agents are still struggling with the correct format.

**The Solution:** This skill enforces:

- Correct batch format: root key must be `"goals"`, not `"tasks"`
- Proper dependency patterns: indices for within-goal tasks, identifiers for existing tasks
- Never specify identifiers for new tasks (system auto-generates)
- Each nested task must follow the full stride-creating-tasks requirements
- Clear guidance on when to use goals vs. flat tasks (25+ hours = goal)

**Impact:** Reduction in format errors.

## How to Install the Skills

The skills are distributed automatically through Stride's onboarding endpoint and are **automatically installed by AI agents** when they fetch the onboarding data. This means Skills work exactly like the `.stride.md` and `.stride_auth.md` configuration files - agents create them automatically.

### Automatic Installation (Recommended)

When an AI agent (like Claude Code) calls the onboarding endpoint from their project root directory, it should automatically:

1. Fetch the onboarding data: `GET https://www.stridelikeaboss.com/api/agent/onboarding`
2. Create `.stride_auth.md` from `file_templates.stride_auth_md`
3. Create `.stride.md` from `file_templates.stride_md`
4. **Create all 4 Skills** from `claude_code_skills.available_skills` array

The onboarding endpoint's `critical_first_steps` and `quick_start` sections now explicitly instruct agents to create all Skills automatically, just like they create the configuration files.

### Manual Installation (If Needed)

If you need to manually install the skills or update them:

```bash
# Fetch onboarding data and extract all skills at once
curl -s https://www.stridelikeaboss.com/api/agent/onboarding > /tmp/onboarding.json

# Create directories
mkdir -p ~/.claude/skills/{stride-claiming-tasks,stride-completing-tasks,stride-creating-tasks,stride-creating-goals}

# Extract and save each skill
jq -r '.claude_code_skills.available_skills[0].content' /tmp/onboarding.json > ~/.claude/skills/stride-claiming-tasks/SKILL.md
jq -r '.claude_code_skills.available_skills[1].content' /tmp/onboarding.json > ~/.claude/skills/stride-creating-tasks/SKILL.md
jq -r '.claude_code_skills.available_skills[2].content' /tmp/onboarding.json > ~/.claude/skills/stride-completing-tasks/SKILL.md
jq -r '.claude_code_skills.available_skills[3].content' /tmp/onboarding.json > ~/.claude/skills/stride-creating-goals/SKILL.md

# Clean up
rm /tmp/onboarding.json
```

### Automatic Discovery

Claude Code will automatically discover these skills when you start or restart a session. The skills will be invoked automatically when relevant:

- **stride-claiming-tasks**: Before calling `POST /api/tasks/claim`
- **stride-completing-tasks**: Before calling `PATCH /api/tasks/:id/complete`
- **stride-creating-tasks**: Before calling `POST /api/tasks` for individual tasks
- **stride-creating-goals**: Before calling `POST /api/tasks` or `POST /api/tasks/batch` for goals

## Best Practices

### Reload Skills with Each Session

Skills may be updated with bug fixes or improvements. At the start of each new Claude Code session:

```bash
# Fetch latest skills
curl -s https://www.stridelikeaboss.com/api/agent/onboarding | jq '.claude_code_skills'
```

Check if the skills have changed and update your local copies if needed.

### Let the Skills Guide You

When a skill is invoked, follow its guidance:

- Read the "Iron Law" - the core principle that must never be violated
- Review "The Critical Mistake" - understand what you're preventing
- Follow the workflow step-by-step
- Check "Red Flags" if you're tempted to skip steps
- Use the Quick Reference Card for at-a-glance reminders

### Trust the Process

It may feel like skills add overhead initially. In reality, they save massive amounts of time by preventing mistakes and pay for themselves within the first task.

## What's Next

These four skills establish the foundation for disciplined AI agent workflows. Future enhancements may include:

- Skills for review workflows (approving, rejecting, requesting changes)
- Skills for dependency management
- Skills for unclaiming tasks properly
- Skills for handling blocked tasks

## Getting Started

Ready to boost your agent productivity? Install the skills and start experiencing the difference:

1. Visit the [onboarding endpoint](https://www.stridelikeaboss.com/api/agent/onboarding)
2. Follow the installation instructions
3. Start a new Claude Code session
4. Watch the skills activate automatically

For detailed documentation on each skill, see the [onboarding endpoint](https://www.stridelikeaboss.com/api/agent/onboarding) or visit our [getting started guide](https://www.stridelikeaboss.com/docs/GETTING-STARTED-WITH-AI.md).

## Not using Claude Code?

Users of other Agents should not feel left out. We are planning to provide enhanced instructions for several other Agents in the near future including _GitHub Copilot_, _Cursor_, _Windsurf Cascade_, _Aider_, and _Continue.dev_. Stay tuned and keep an eye on my blog for updates.
