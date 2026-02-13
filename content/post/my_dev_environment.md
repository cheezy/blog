---
date: '2026-02-13T07:26:00-05:00'
draft: false
title: 'My AI Development Environment'
tags: ["AI", "Agile", "Continuous Delivery", "elixir"]
---

I see a lot of people posting about how bad AI is at creating code. I, along with everybody I work with, am having the opposite experience where AI is producing high-quality code that is well factored and tested. For a long time it has been a mystery how people can have such opposite experiences.

I now have three cases where close friends were making such statements and I offered to have a chat to understand their experience. In each case, they were using tools that were far from ideal and the tools they had were not configured at all. When I told them about options to provide AI with more instructions and constrain / direct how it works they were surprised.

Because of this experience I am convinced that a large percentage of people that are having a bad experience with AI are not using the right tools or not configuring the tools they have well enough. This post is to try to address this issue. I will be going into details about how I have my environment set up so you can start to understand what is possible.

## My Tools

I use [Claude Code](https://claude.com/product/claude-code) and [Tidewave](https://tidewave.ai) for my development. I also use [Windsurf](https://windsurf.com) for my editor. The Claude Code and Tidewave combo is so central to what I do that my son and I have a term we use - *ClaudeWave*.

### Windsurf

I will not be going into details about Windsurf as it is the least important part of this setup. I only use it to occasionally review code, update configuration files, and to perform diffs prior to pushing code to my repository. I am using it to write this blog post.

### Tidewave

Tidewave is just pure awesomeness. It has enhanced my productivity and has simplified a lot of what I do. This post is not about promoting Tidewave, but I do suggest you check it out.

Tidewave using Claude Code as its AI provider via the [claude-code-acp adapter](https://github.com/zed-industries/claude-code-acp). What that means is that when I am using Tidewave, I am really using Claude Code with all of the benefits of Tidewave. Always make sure you are using the latest Tidewave and the latest claude-code-acp adapter as that determines what model it is able to use. There really is no other configuration I need to call out.

### Claude Code

Since Claude Code is the agent I use to write code, the vast majority of my configuration is here. The configuration needs to be broken down into two parts - the configuration that is common across all projects I am working on and the configuration that is specific to a project.

#### Common Claude Code Configuration

The primary configuration file for Claude Code is `~/.claude-code/settings.json`

```json
{
  "env": {
    "CLAUDE_CODE_MAX_OUTPUT_TOKENS": "64000",
    "CLAUDE_CODE_EFFORT_LEVEL": "high"
  },
  "includeCoAuthoredBy": false,
  "permissions": {
    "allow": [
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(git checkout:*)",
      "Bash(git pull:*)",
      "Bash(git push:*)",
      "Bash(git branch:*)",
      "Bash(git fetch:*)",
      "Bash(git rebase:*)",
      "Bash(git status:*)",
      "Bash(git log:*)",
      "Bash(git diff:*)",
      "Bash(git stash:*)",
      "Bash(git merge:*)",
      "Bash(mix deps.get:*)",
      "Bash(mix ecto.migrate:*)",
      "Bash(mix test:*)",
      "Bash(mix format:*)",
      "Bash(mix credo:*)",
      "Bash(mix sobelow:*)",
      "Bash(mix assets.build:*)",
      "Bash(curl:*)"
    ]
  },
  "model": "opus",
  "enabledPlugins": {
    "ast-grep@ast-grep-marketplace": true,
    "frontend-design@claude-code-plugins": true,
    "elixir-phoenix-guide@elixir-claude-optimization": true
  }
}
```

In this configuration file you can see some environment variables I set to adjust the runtime, some commands that I allow Claude Code to run without asking me for permission, the model that I want Claude Code to use, and some plugins that I have installed. There are many other options that you should explore, but these are the ones that have given me the best experience. `CLAUDE_CODE_EFFORT_LEVEL` is new in `opus 4.6`. Not listed in this file but critical to my [workflow](https://cheezyworld.ca/post/using-stride-to-enhance-stride/), I have the four Stride Skills at this level. These were installed during the [Stride onboarding process](https://github.com/cheezy/kanban/blob/main/docs/GETTING-STARTED-WITH-AI.md). 

The [elixir-phoenix-guide](https://github.com/j-morgan6/elixir-claude-optimization) plugin is a plugin that delivers a lot of knowledge to my agent about the tools and frameworks I am using. Specifically it has the following:

Skills:

* elixir-essentials
* phoenix-liveview-essentials
* ecto-essentials
* phoenix-uploads

Agents:

* liveview-checklist
* project-structure
* ecto-conventions
* testing-guide

The other plugins I use are nice to haves, but not required.


#### MCP Servers

There are a few MCP servers that I have configured. They are [hexdocs](https://hexdocs.pm/hexdocs_mcp/readme.html), [sequential-thinking](https://github.com/modelcontextprotocol/servers/tree/main/src/sequentialthinking), [filesystem](https://www.pulsemcp.com/servers/modelcontextprotocol-filesystem), [postgres](https://www.pulsemcp.com/servers/modelcontextprotocol-postgres), and tidewave. You might ask why I have the Tidewave MCP server. The ACP adapter (mentioned above) is how Tidewave talks to Claude Code but when I am working in Claude having the Tidewave MCP server allows Claude to access the tools provide by Tidewave.  

#### Project Specific Claude Code Configuration

The majority of the Claude Code configuration is project specific. Since these can vary slightly from project to project, I will be reviewing the configuration I use while developing the [Stride](https://StrideLikeABoss.com) application. Let's start with the most generic and move toward the more specific.

##### .claude-code/settings.json

At the project level my settings.json only contains one setting. It is for the superpowers plugin. I use the brainstorm skill to create the requirements for each feature of the applications I build.

```json
{
  "enabledPlugins": {
    "superpowers@superpowers-marketplace": true
  }
}
```

##### AGENTS.md

Since August of 2025 when you create a new Phoenix project it automatically creates an `AGENTS.md` file in the root of the project. This file contains detailed context coding agents need to perform their tasks. I have added to the generated file to provide my specific requirements. There is too much here to list it all, but I'll highlight the important parts that I added to what was generated. I removed a lot of details about how to handle Dark Mode but you can go to my [AGENTS.md](https://github.com/cheezy/kanban/blob/main/AGENTS.md) file to see it all.

```markdown
## Project guidelines

- Use `mix precommit` alias when you are done with all changes and fix any pending issues
- Use the already included and available `:req` (`Req`) library for HTTP requests, **avoid** `:httpoison`, `:tesla`, and `:httpc`. Req is included by default and is the preferred HTTP client for Phoenix apps
- Use the HexDoc mcp server to read the documentation about project dependencies
- When you add a new dependency or update an existing dependency run `mix usage_rules.sync AGENTS.md --all --link-to-folder deps --inline usage_rules:all` to update the AGENTS.md file
- Always provide translations of all text that is visible in the UI
- Never put Ecto queries directly in LiveViews. Instead always put them in the appropriate context module

### Module design and complexity

**IMPORTANT**: When working with modules that are becoming too large or complex:

- **Monitor module size and complexity**: If a module exceeds ~500-600 lines or contains deeply nested logic with high cyclomatic complexity, consider refactoring
- **Break out logical concerns**: Extract related functionality into separate, focused modules that handle a single responsibility
- **Use helper modules**: For complex domains (like task management), consider creating dedicated modules for specific sub-concerns:
  - Positioning logic (e.g., `Tasks.Positioning`)
  - Dependency management (e.g., `Tasks.Dependencies`)
  - Validation logic (e.g., `Tasks.Validation`)
  - Query builders (e.g., `Tasks.Queries`)
- **Extract helper functions**: When a function becomes complex (cyclomatic complexity > 9), extract complex conditional logic into smaller, well-named helper functions
- **Maintain clear module boundaries**: Each module should have a clear, single purpose with a well-defined public API
- **Document module organization**: When splitting modules, update documentation to explain the new structure and how modules relate to each other

This approach improves:
- Code maintainability and readability
- Test isolation and coverage
- Collaboration between developers
- Ability to reason about individual components
- Credo compliance and code quality metrics

### UI/UX guidelines

- **Always follow existing application styles and patterns** when adding new UI elements
- Before creating custom styles, check `core_components.ex` for existing components like `<.input>`, `<.button>`, `<.form>`, etc.
- When adding form fields, use the standard component structure with `fieldset`, `label`, and `span.label` classes to match existing forms
- New buttons should use the `<.button>` component without custom classes unless specifically requested
- Maintain consistency with existing color schemes, spacing, and typography throughout the application

### Dark Mode Verification Guidelines

**CRITICAL**: Always verify UI changes work in BOTH light and dark modes before considering a task complete.

...

### Quality guidelines  

**ALWAYS** follow these quality guidelines:

- **IMPORTANT**: When you complete a task that has new functions write unit tests for the new function
- **IMPORTANT**: When you complete a task that updates code make sure all existing unit tests pass and write new tests if needed
- Each time you write or update a unit test run them with `mix test` and ensure they pass
- **IMPORTANT**: When you complete a task run `mix test --cover` and ensure coverage is above the threshold.
- **IMPORTANT**: When you complete a task run `mix credo --strict` to check for code quality issues and fix them

### Security guidelines

**ALWAYS** follow these security guidelines:

- **IMPORTANT**: When you add or update a dependency run `mix deps.audit` and `mix hex.audit` to check for security issues
- **IMPORTANT**: When you add or update a dependency run `mix hex.outdated` to check for outdated dependencies
- **IMPORTANT**: When you complete a task run `mix sobelow --config` to check for security issues and fix any issue
```

Pay special attention to the Quality guidelines and Security guidelines. These are important and are emphasized in other configuration files.

##### CLAUDE.md

By default Claude Code does not read the AGENTS.md file. Instead it looks for a file named CLAUDE.md. Since I did not want to duplicate the AGENTS.md file content, I simply created a CLAUDE.md file that points to the AGENTS.md file.

```markdown
@AGENTS.md

## Development Rules (MANDATORY)

Before writing or editing ANY file in lib/, test/, or assets/, you MUST invoke the `stride-development-guidelines` skill. This is not optional. Do not write code without first invoking this skill.
```

I think of this file as a connector. It is making Claude Code aware of everything that is in the AGENTS.md file and it is also making it mandatory that Claude Code use the custom skill that I maintain for the project.

##### stride-development-guidelines skill


````markdown {linenos=inline}
---
name: stride-development-guidelines
description: Use when writing ANY code in the Stride project (this Phoenix/Elixir kanban application). Invoke BEFORE implementing features, fixing bugs, or making UI changes. Invoke BEFORE marking any development task as complete.
---

# Stride Development Guidelines

This skill applies to ALL code changes in this codebase. No exceptions.

Standards for quality, security, UI/UX, and dark mode are defined in AGENTS.md.
This skill enforces them. Your job is not to re-read the standards — it is to EXECUTE the checks.

---

## GATE 1: Before Writing Code

STOP. Before you write or edit any file in `lib/`, `test/`, or `assets/`, state out loud which of these apply to your change:

- Modifying UI (`.heex`, `core_components`, CSS) → Dark mode verification REQUIRED
- Adding new functions → Unit tests REQUIRED
- Modifying existing code → Existing tests must pass REQUIRED
- Adding/updating dependencies → Security audit REQUIRED
- Editing a module over 400 lines → Check line count, propose split if over 500

IF none apply, state "No special requirements for this change" and proceed.

You MUST NOT skip this step. Silently proceeding without stating applicability is a violation.

---

## GATE 2: After Writing Code

STOP. Run these commands and show the output. Do NOT claim they pass without running them.

1. `mix test` — all tests must pass
2. `mix credo --strict` — no issues

IF you wrote new functions, you MUST have written tests for them before reaching this gate.

IF you modified UI, you MUST have verified dark mode before reaching this gate (see Trigger Rules below).

---

## GATE 3: Before Marking Complete

STOP. Run `mix precommit` and show the output. This runs all quality and security checks together.

IF anything fails, fix it and re-run. Do NOT mark complete until `mix precommit` passes with output shown.

---

## Trigger Rules

These are IF/THEN rules. When you encounter the trigger condition, you MUST take the specified action.

**IF you are about to write a hardcoded color in a template:**
→ STOP. Use the theme-aware equivalent from the Dark Mode Color Map below. Never use `text-gray-*`, `bg-white`, `bg-gray-*`, or `border-gray-*` in templates.

**IF you are creating a new function:**
→ You MUST write a unit test for it. No exceptions. Run the test and show it passes.

**IF a module you are editing is over 400 lines:**
→ STOP. Count the lines. If over 500, propose a refactoring split before adding more code. Follow the module design patterns in AGENTS.md.

**IF you are adding or modifying any UI element:**
→ Check `core_components.ex` FIRST for existing components (`<.input>`, `<.button>`, `<.form>`).
→ Use existing components. Do NOT create custom alternatives unless specifically requested.
→ Verify the change works in BOTH light and dark modes.

**IF you are modifying a `.heex` file, CSS file, or `core_components.ex`:**
→ You MUST verify dark mode. Test in both light and dark modes before proceeding.
→ Use browser evaluation or visual inspection to confirm contrast in both themes.

**IF you are adding or updating a dependency:**
→ Run `mix deps.audit`, `mix hex.audit`, and `mix hex.outdated`. Show the output.

**IF you are about to say "done", "complete", or "finished":**
→ STOP. Go to GATE 3. Run `mix precommit`. Show the output. Only then say complete.

---

## FORBIDDEN Actions

These are hard failures. If you catch yourself doing any of these, STOP and correct immediately.

- FORBIDDEN: Saying "tests should pass" or "credo should be clean" without running them
- FORBIDDEN: Marking a task complete without showing passing output from `mix precommit`
- FORBIDDEN: Adding UI elements without checking `core_components.ex` first
- FORBIDDEN: Skipping dark mode verification on any UI change
- FORBIDDEN: Writing new functions without unit tests
- FORBIDDEN: Putting Ecto queries directly in LiveViews (use context modules)
- FORBIDDEN: Adding text visible in the UI without providing translations

---

## Red Flags — STOP If You Think Any of These

| Thought | Reality |
|---------|---------|
| "It's just a small change" | Small changes break dark mode constantly. Verify. |
| "Tests probably still pass" | Run them. "Probably" is not evidence. |
| "Credo is just style" | Credo catches real bugs and complexity issues. |
| "Security checks are overkill" | One missed vulnerability = production incident. |
| "I'll check dark mode later" | You won't. Check now. |
| "The module isn't that big" | Count the lines. Over 500 = split it. |
| "I already know this passes" | Show the output. Knowledge without proof is assumption. |

---

## Dark Mode Color Map (Reference)

Use this table when writing or reviewing template colors.

| Never Use          | Always Use Instead              |
| ------------------ | ------------------------------- |
| `text-gray-900`    | `text-base-content`             |
| `text-gray-600`    | `text-base-content opacity-70`  |
| `text-gray-500`    | `text-base-content opacity-60`  |
| `bg-white`         | `bg-base-100`                   |
| `bg-gray-50`       | `bg-base-200`                   |
| `border-gray-200`  | `border-base-300`               |

### Dark Mode Element Fixes

| Element                | Fix                                                                            |
| ---------------------- | ------------------------------------------------------------------------------ |
| Labels invisible       | `text-base-content` with full opacity                                          |
| Inputs invisible       | `bg-base-100` background, `text-base-content` text, `border-base-300` border   |
| Low contrast buttons   | `btn-primary` or `var(--color-primary)` background                             |
| Low contrast links     | `var(--color-primary)` color                                                   |
| White modal background | `bg-base-100` instead of `bg-white`                                            |
| Modal backdrop         | `bg-base-200/90` for proper overlay                                            |

### Dark Mode Contrast Targets

| Mode | Text | Background |
|------|------|------------|
| Light | Dark text (oklch ~0.21) | Light backgrounds (oklch ~0.98) |
| Dark | Light text (oklch ~0.97) | Dark backgrounds (oklch ~0.30) |

---

## Workflow Summary

```text
BEFORE WRITING CODE → GATE 1 (state what applies)
    ↓
WRITE CODE (follow trigger rules as you go)
    ↓
AFTER WRITING CODE → GATE 2 (mix test + mix credo --strict, show output)
    ↓
BEFORE MARKING COMPLETE → GATE 3 (mix precommit, show output)
```

`mix precommit` runs tests, coverage, credo, and sobelow together. Use it at GATE 3.
````

There are a lot of details here that you can read. The important thing I want to leave you with is a couple of key items in the structure.

* The top level guideline starting on line 6 makes it mandatory to use this skill when writing code. It also points Claude to the AGENTS.md file to get specific requirements regarding quality, security, UI/UX, and dark mode.

* On line 15, 31, and 44 I define very specific GATES that Claude must follow. These have become a part of my workflow that is defined later in this file.

* Starting on line 52 I define some very specific rules for Claude Code. Here is an example of one.

```markdown
**IF you are creating a new function:**
→ You MUST write a unit test for it. No exceptions. Run the test and show it passes.
```

* Starting on line 82 I have a list of FORBIDDEN actions. This is a list of things that Claude Code has done in the past that I want to prevent it from doing again.

* The final thing I want to bring to your attention starts on line 143. This is where I define the workflow that Claude Code must follow. Essentially, this is where I am telling Claude when to invoke the GATES that I defined earlier.

##### .stride.md

Stride is the tool I use to deliver tasks to my agent and is a critical part of my workflow. With Stride you have the option to define [Hooks](https://github.com/cheezy/kanban/blob/main/docs/AGENT-HOOK-EXECUTION-GUIDE.md) - commands that you want executed at various points in the workflow. I have two sets of hooks - one for when I am working on a project solo and one for when I am working on a project with a team. Here are the hooks I have defined for working with a team.

````markdown
## before_doing

```bash
echo "Starting task $TASK_IDENTIFIER: $TASK_TITLE"
git checkout main
git pull origin main
git checkout -b feature/$TASK_IDENTIFIER
mix deps.get
mix ecto.migrate
```

## after_doing

```bash
# echo "Running quality checks for $TASK_IDENTIFIER"
mix test --cover
mix format --check-formatted
mix credo --strict
mix sobelow --config .sobelow_config.exs
git commit -a -m "Completed task $TASK_IDENTIFIER: $TASK_TITLE"
```

## before_review

```bash
echo "Rebasing code for $TASK_IDENTIFIER"
git fetch origin
git rebase origin/main
mix test
```

## after_review

```bash
echo "Finished $TASK_IDENTIFIER"
git fetch origin
git rebase origin/main
mix test
git push origin HEAD:main
git checkout main
git branch -d feature/$TASK_IDENTIFIER
```
````
