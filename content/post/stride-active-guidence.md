---
date: '2026-01-09T10:41:00-05:00'
draft: false
title: 'Stride Active Guidence'
tags: ["AI", "Agile", "Continuous Delivery"]
---

## Stride Now Supports Four AI Assistants with Always-Active Guidance

What a day. Earlier today I rolled out [Claude Code Skills for Stride](https://www.stridelikeaboss.com/blog/stride-has-skills). A couple of hours later I'm excited to announce that Stride now supports four popular AI coding assistants beyond Claude Code, with always-active instruction files that help developers avoid common mistakes and follow best practices when working with the Stride API.

## The Challenge: Supporting Multiple AI Assistants

I know that not all developers use Claude Code. Many companies are invested in tools like Copilot, Windsurf, etc. Developers in these companies should not feel left out when it comes to Stride. Because of that need, I have just added enhanced instructions for [GitHub Copilot](https://github.com/features/copilot), [Cursor](https://www.cursor.com/), [Windsurf Cascade](https://www.windsurfrules.com/), and [Continue.dev](https://continue.dev/). These assistants are excellent tools, but they needed help understanding Stride's workflow requirements, especially around:

- Hook execution at four lifecycle points
- Proper task creation with complex nested structures
- Field validation rules (verification_steps as objects, not strings)
- The critical rule about NOT specifying identifiers when creating tasks
- When to execute hooks (especially the after_doing hook BEFORE calling completion)

## The Solution: Format-Specific Instructions

Rather than forcing developers to memorize API requirements, we created format-specific instruction files that each AI assistant can download and use to guide their interactions with Stride. More detailed installation instructions can be found [here](https://github.com/cheezy/kanban/blob/main/docs/MULTI-AGENT-INSTRUCTIONS.md).

### GitHub Copilot
**File:** `.github/copilot-instructions.md`
**Size:** ~9KB (~250 lines)
**Optimized for:** Repository-scoped AI assistance

Copilot has the strictest token limits (~4000 tokens), so its instructions focus on the top 5 critical mistakes and essential code patterns.

```bash
curl -o .github/copilot-instructions.md \
  https://raw.githubusercontent.com/cheezy/kanban/refs/heads/main/docs/multi-agent-instructions/copilot-instructions.md
```

### Cursor
**File:** `.cursorrules`
**Size:** ~15KB (~400 lines)
**Optimized for:** Project-scoped chat and code generation

With double the token budget (~8000 tokens), Cursor's instructions include more detailed examples, comprehensive mistake catalogs, and hook execution details.

```bash
curl -o .cursorrules \
  https://raw.githubusercontent.com/cheezy/kanban/refs/heads/main/docs/multi-agent-instructions/cursorrules.txt
```

### Windsurf Cascade
**File:** `.windsurfrules`
**Size:** ~15KB (~400 lines)
**Optimized for:** Hierarchical rules across multiple projects

Windsurf's cascading rules system allows placing `.windsurfrules` in a parent directory to affect all child projects—perfect for teams working on multiple Stride-integrated codebases.

```bash
curl -o .windsurfrules \
  https://raw.githubusercontent.com/cheezy/kanban/refs/heads/main/docs/multi-agent-instructions/windsurfrules.txt
```

### Continue.dev
**File:** `.continue/config.json`
**Size:** ~4KB (~100 lines)
**Optimized for:** JSON configuration with custom context providers

Continue.dev's JSON format supports custom context providers (pointing to external documentation) and custom slash commands for common Stride workflows.

```bash
mkdir -p .continue
curl -o .continue/config.json \
  https://raw.githubusercontent.com/cheezy/kanban/refs/heads/main/docs/multi-agent-instructions/continue-config.json
```

## What's Covered in Every Format

Despite different formats and token limits, all four instruction files cover the same essential topics:

### 1. Hook Execution Mandate
All four hooks (before_doing, after_doing, before_review, after_review) and their blocking vs. non-blocking behavior. Most critically: **execute after_doing BEFORE calling the complete endpoint**.

### 2. Top 5 Critical Mistakes
- Don't specify identifiers when creating tasks (system auto-generates G1, W47, D12, etc.)
- verification_steps must be array of objects, not strings
- testing_strategy fields (unit_tests, integration_tests, manual_tests) must be arrays
- type must be exactly "work", "defect", or "goal" as strings
- Execute after_doing hook before calling completion endpoint

### 3. Essential Field Requirements
- key_files prevents merge conflicts
- dependencies control execution order
- testing_strategy must have arrays for all test types
- verification_steps as objects with step_type, step_text, expected_result

### 4. Code Patterns
Complete examples for:
- Claiming a task with hook execution
- Completing a task with proper validation
- Creating tasks with all required fields
- Creating goals with nested tasks
- Batch creation of multiple goals

### 5. Documentation Links
Direct links to:
- Onboarding endpoint
- Task Writing Guide
- API Reference
- Hook Execution Guide

## How It Works: Two-Tier Architecture

Stride now uses a complementary two-tier approach:

### Claude Code Skills (Contextual Workflow Enforcement)
- **When active:** Only when claiming, completing, or creating tasks
- **Content size:** 1000+ lines per skill
- **Distribution:** Embedded in onboarding endpoint
- **Purpose:** Blocking validation and comprehensive workflow enforcement

### Multi-Agent Instructions (Always-Active Guidance)
- **When active:** During all AI assistant interactions
- **Content size:** 200-400 lines per format
- **Distribution:** Downloadable files from GitHub
- **Purpose:** Workflow guidance and critical mistake prevention

This separation provides several benefits:

1. **Specialized for each assistant** - Each format optimized for its platform
2. **Token-efficient** - Agents download only what they need
3. **Better caching** - Separate files cached independently
4. **Easy updates** - Update individual formats without changing endpoint
5. **Consistent distribution** - All formats served from same GitHub docs directory

## The Performance Impact

By moving multi-agent instruction content from embedded JSON to downloadable files, we achieved:

- **40% endpoint size reduction** (132KB → 79KB)
- **On-demand loading** - Agents download only their format
- **Better caching** - Browser/agent can cache instruction files separately
- **Faster onboarding** - Smaller initial payload for all agents

## Getting Started

### Automatic Installation (Recommended)

When AI agents fetch the onboarding endpoint at `https://www.stridelikeaboss.com/api/agent/onboarding`, they'll see the `multi_agent_instructions` section with download URLs and installation commands for their format. Smart agents can automatically download and install the appropriate file.

### Manual Installation

Developers can manually install instruction files using the curl commands shown above. On Windows, use PowerShell:

```powershell
# GitHub Copilot
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/cheezy/kanban/refs/heads/main/docs/multi-agent-instructions/copilot-instructions.md" -OutFile .github/copilot-instructions.md

# Cursor
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/cheezy/kanban/refs/heads/main/docs/multi-agent-instructions/cursorrules.txt" -OutFile .cursorrules

# And so on for other formats...
```

## Real-World Impact

Early testing shows dramatic improvements:

- **Fewer API rejections** - Agents rarely make the "top 5 mistakes" anymore
- **Faster task creation** - No trial-and-error with field formats
- **Proper hook execution** - Agents consistently execute after_doing before completion
- **Better code patterns** - Agents follow established patterns from instruction examples

## Learn More

- **Full Documentation:** [Multi-Agent Instructions Guide](https://github.com/cheezy/kanban/blob/main/docs/MULTI-AGENT-INSTRUCTIONS.md)
- **Task Writing Guide:** [How to Write Effective Tasks](https://github.com/cheezy/kanban/blob/main/docs/TASK-WRITING-GUIDE.md)
- **API Reference:** [Complete API Documentation](https://github.com/cheezy/kanban/blob/main/docs/api/README.md)
- **Onboarding Endpoint:** [https://www.stridelikeaboss.com/api/agent/onboarding](https://www.stridelikeaboss.com/api/agent/onboarding)

## Try It Today

If you're using GitHub Copilot, Cursor, Windsurf Cascade, or Continue.dev with Stride, download the appropriate instruction file and experience the difference. Your AI assistant will immediately understand Stride's workflow requirements and help you avoid common mistakes.
