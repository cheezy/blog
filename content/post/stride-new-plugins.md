---
date: '2026-03-24T12:37:00-04:00'
draft: false
title: 'Stride Goes Multi-Platform: Copilot, Gemini, and Zero-Prompt Hook Execution'
tags: ["AI", "Continuous Delivery"]
---

Prior to today, Stride had excellent support for Claude Code via six Skills and four SubAgents. All other agents were only provided with Skills without the enforcement and additional capabilities added by the SubAgents.

Today I shipped three updates that fundamentally change how AI agents interact with Stride. Two new platform extensions bring Stride's full workflow and support to [GitHub Copilot](https://github.com/cheezy/stride-copilot) and [Google Gemini CLI](https://github.com/cheezy/stride-gemini). And a new Claude Code hooks integration eliminates the most persistent friction point that still existed in the Claude Code agent workflow: permission prompts.

## The Problem I'm Solving

Stride was built on a simple premise: AI agents are most effective when they collaborate closely with humans and when they follow a structured workflow. Claim a task, execute setup hooks, do the work, run validation, mark it complete. Every step has a purpose. The hooks ensure code is current before you start and tested before you finish.

But until now, this workflow had two limitations:

1. **It only worked in Claude Code.** Developers using GitHub Copilot or Google Gemini CLI could only use a few of Stride's skills and could not leverage additional capabilities provided by the SubAgents.

2. **Even in Claude Code, hook execution was painful.** Every hook command execution triggered a permission dialog. The user had already defined these commands in `.stride.md` — they clearly wanted them to run — but the CLI's permission system didn't know that.

Today's release fixes both.

## Stride for GitHub Copilot and Google Gemini CLI

Both extensions ship the same six workflow skills and four specialized agents that Claude Code users already know — adapted for each platform's native conventions.

### Skills

- **stride-claiming-tasks** — Task discovery and claiming with `before_doing` hook execution
- **stride-completing-tasks** — Dual-hook completion with `after_doing` and `before_review`
- **stride-creating-tasks** — Task creation with validated field formats
- **stride-creating-goals** — Batch goal creation with correct API structure
- **stride-enriching-tasks** — Codebase exploration to fill in sparse task specs
- **stride-subagent-workflow** — Decision matrix for exploration, planning, and review

Each skill contains the exact API fields, hook execution patterns, and validation rules needed for that workflow phase. The content is adapted for each platform's conventions but the substance is identical — an agent using Copilot or Gemini follows the same workflow as one using Claude Code.

### Agents

- **task-explorer** — Reads key files, finds related tests, searches for patterns before implementation begins
- **task-reviewer** — Reviews changes against acceptance criteria and pitfalls, producing structured review reports
- **task-decomposer** — Breaks goals and large tasks into dependency-ordered child tasks
- **hook-diagnostician** — Parses hook failure output and returns prioritized fix plans

These are the same agents Claude Code users have been using through the Stride plugin's subagent workflow. Copilot ships them in `.github/agents/` where agent mode picks them up automatically. Gemini CLI ships them through its native extension system.

### Installation

**GitHub Copilot:**

```bash
copilot plugin install https://github.com/cheezy/stride-copilot
```

**Google Gemini CLI:**

```bash
gemini extensions install https://github.com/cheezy/stride-gemini
```


## Why Multi-Platform Matters

AI-assisted development isn't a single-tool story. Teams use different editors, different AI providers, different workflows. A senior developer might use Claude Code while a teammate prefers Copilot. A contractor might work in Gemini CLI.

Stride's task management doesn't care which AI tool claims the task. The API is the same. The hooks are the same. The workflow is the same. What matters is that every agent — regardless of platform — follows the structured approach that prevents the failures I've seen over and over: claiming tasks without pulling latest code, marking work complete without running tests, creating tasks with missing specifications that waste hours during implementation.

By shipping platform-native extensions instead of lowest-common-denominator adaptations, each agent gets an experience that feels right for its environment while maintaining the workflow discipline that makes Stride effective.

## Zero-Prompt Hook Execution

Now for the change that Claude Code users have been waiting for.

### The Permission Problem

Here's what hook execution looked like before today:

```
Agent: Running before_doing hook...
CLI: ⚠️ Allow Bash(git pull origin main)? [y/n]
User: y
CLI: ⚠️ Allow Bash(mix deps.get)? [y/n]
User: y
CLI: ⚠️ Allow Bash(mix ecto.migrate)? [y/n]
User: y
```

Multiply this by four hooks (before_doing, after_doing, before_review, after_review) with multiple commands each, and you're clicking through many permission dialogs per task. For every task. All day.

The irony is thick: the user wrote these commands in `.stride.md`. They're not surprised by tests running — they put it there specifically because they want it to run. But Claude Code's permission system operates at the tool level, not the intent level. Every Bash command triggers a prompt regardless of context.

I tried solving this in software. CLAUDE.md instructions saying "don't prompt." Skill documentation saying "hooks are pre-authorized." None of it worked because the prompting happens in the CLI harness, not in the LLM.

### The Solution: Claude Code Hooks

Claude Code has a hook system that executes shell commands at lifecycle events — _PreToolUse_, _PostToolUse_, _SessionStart_, and others. These hooks run on the harness itself, not through Claude's Bash tool. No tool call means no permission prompt.

The Stride plugin now ships two new files:

**`hooks/hooks.json`** registers the plugin's hooks with Claude Code:

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Bash",
      "hooks": [{
        "type": "command",
        "command": "${CLAUDE_PLUGIN_ROOT}/hooks/stride-hook.sh post"
      }]
    }],
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{
        "type": "command",
        "command": "${CLAUDE_PLUGIN_ROOT}/hooks/stride-hook.sh pre"
      }]
    }]
  }
}
```

**`hooks/stride-hook.sh`** is the bridge between Claude Code's event system and Stride's `.stride.md` format. When a Bash tool call fires, the script:

1. Reads the command from the hook's JSON input
2. Checks if it's a Stride API call (claim, complete, or mark_reviewed)
3. Determines which `.stride.md` section to execute
4. Parses that section and runs each uncommented command
5. Exits 2 on failure to block the tool call (in PreToolUse context)

The routing is straightforward:

| Event | API Pattern | Stride Hook |
|---|---|---|
| PostToolUse | `/api/tasks/claim` | `before_doing` |
| PreToolUse | `/api/tasks/:id/complete` | `after_doing` |
| PostToolUse | `/api/tasks/:id/complete` | `before_review` |
| PostToolUse | `/api/tasks/:id/mark_reviewed` | `after_review` |

The `after_doing` hook is the critical one. It runs as a PreToolUse hook on the completion API call, which means if your tests fail, the completion call is blocked. The agent can't mark work done until validation passes. This is the same guarantee the existing workflow provides, but now it's enforced deterministically by the harness rather than relying on the LLM to follow instructions.

### Generic by Design

The script doesn't know or care what's in your `.stride.md`. It parses whatever you've defined and runs it. One team might have:

```markdown
## after_doing

```bash
mix test --cover
mix format --check-formatted
mix credo --strict
mix sobelow --config
git commit -a -m "Completed task $TASK_IDENTIFIER: $TASK_TITLE"
```​
```

Another might have:

```markdown
## after_doing

```bash
npm test
npx eslint .
git add -A && git commit -m "$TASK_IDENTIFIER done"
```​
```

Both work. The script reads the section, skips comments and empty lines, and executes each command. No assumptions about language, framework, or tooling.

### Environment Variables

Stride hooks use environment variables like `$TASK_IDENTIFIER` and `$TASK_TITLE` — most commonly in git commit messages. In the old flow, the agent set these explicitly before running hooks. In the new flow, the script extracts them from the Stride API response after a successful claim and caches them to a temp file (`.stride-env-cache`). Every subsequent hook loads the cache before executing commands, so variable references in `.stride.md` resolve correctly throughout the entire task lifecycle.

The cache is cleaned up automatically after the `after_review` hook completes.

### Structured Diagnostics

When a hook fails, the script doesn't just exit with an error code. It emits structured JSON:

```json
{
  "hook": "after_doing",
  "status": "failed",
  "failed_command": "mix test --cover",
  "command_index": 0,
  "exit_code": 1,
  "stdout": "...",
  "stderr": "...",
  "commands_completed": [],
  "commands_remaining": ["mix credo --strict", "mix sobelow --config"]
}
```

Claude receives this as structured context and can reason about the failure almost as well as if it had run the command itself. The hook-diagnostician agent has been updated to parse this format, producing fix plans that reference the specific command position in the sequence.

## What This Means in Practice

For Claude Code users: enable the updated Stride plugin and your hooks run silently. No permission dialogs. No clicking through prompts. The workflow you defined in `.stride.md` executes exactly as you wrote it, every time.

For Copilot users: install the Stride Copilot extension and your agent follows the same structured workflow that Claude Code agents have been using. Same skills, same API, same quality gates.

For Gemini CLI users: install the Stride Gemini extension and get the full package — skills plus custom agents for exploration, review, decomposition, and diagnostics.

For teams: your agents can now work across platforms while maintaining consistent workflow discipline. The task board doesn't care which AI tool is doing the work. It cares that hooks ran, tests passed, and the completion API was called with the right fields.

## What's Next?

I will be looking for ways to bring the same level of support as I have just added to Copilot and Gemini to other popular agents. If you have one that you would like to see supported, please let me know.

Also, I will be bringing the same Stride Hook enhancements to agents that support this pattern.
