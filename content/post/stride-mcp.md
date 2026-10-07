---
date: '2026-10-07T06:50:00-04:00'
draft: false
title: 'Stride Now Speaks MCP'
tags: ["AI", "Continuous Delivery", "Stride"]
---

Coding agents are Stride's busiest users. They find the next task, claim it, do the work, run your quality checks and hand it back for review. Until now they did all of that by building HTTP requests by hand: shell commands with headers, JSON bodies and careful quoting, assembled fresh every time.

Stride now has a **Model Context Protocol (MCP) server**. MCP is the open standard that AI tools such as Claude Code use to discover and call external tools. Point an MCP client at Stride and your agent sees a small set of named, documented tools with defined inputs. It no longer has to remember an API. The agent asks for what it needs, and Stride checks the request before acting on it.

## What you get

The server offers six tools:

| Tool | What it does |
|---|---|
| `stride_next_task` | Shows the next task ready to work on, without claiming it |
| `stride_claim_task` | Claims a specific task, or the next available one |
| `stride_complete_task` | Hands a finished task back, with its hook results and review |
| `stride_get_task` | Reads one task |
| `stride_list_tasks` | Lists the board's tasks one page at a time, with filters |
| `stride_add_comment` | Adds a comment to a task |

Each tool describes itself, and every input has a defined type and allowed values. An MCP client reads those definitions when it connects, so the agent knows what's available and what each tool expects before it calls anything.

A few things make it more than a thin wrapper:

- **Same rules as the API.** Claiming and completing a task over MCP runs through exactly the same code as the REST API. Every check still applies, including the completion check that refuses a hand-back missing its review or hook results. MCP is not a side door.
- **Mistakes are explained.** Send a value a tool doesn't accept and the answer names the argument and the values it accepts:

  ```
  arguments.status must be one of open, in_progress, completed, blocked
  ```

  When Stride refuses an action, such as a task that isn't claimable or a hand-back that fails validation, the agent gets the same explanation the REST API would give, plus a short error code it can act on and the status the API would have returned.
- **Lists stay small.** `stride_list_tasks` returns one page at a time, with a short summary of each task by default. Asking for whole tasks is an option, and even then a page is capped at about 100 KB. A busy board never floods an agent's context. Follow the cursor to get the next page; together the pages hold every task exactly once.
- **Comments, from the agent.** `stride_add_comment` lets an agent leave a note on a task: what it found, why it stopped, a question for a human. It needs edit access to the board, so read-only members can't comment through MCP.
- **Your token, your board.** The server uses the API token you already have. Every tool acts as that token's user on that token's board, and nothing else is reachable. Requests with a bad token count toward the same rate limit as the API.

## The tradeoffs

We made a few deliberate choices you should know about.

- **Hooks still run on your machine.** Claiming a task returns the `before_doing` hook, and completing one returns the rest, exactly as the REST API does. Stride never runs your hooks for you; your tests and checks run where your code is.
- **The Stride plugin's automation doesn't watch MCP calls yet.** Today the Stride plugin for Claude Code runs your hooks automatically, and captures the task's file changes, by watching the API calls it makes from the shell. It doesn't see MCP tool calls. If your agent works through the full claim-to-complete cycle over MCP, it has to run the returned hooks itself. For hands-off task work, keep using the plugin's workflow for now. For everything else, MCP is the easier way in.
- **Simple and stateless.** Each request is a single HTTP request with a single JSON answer. There's no long-lived connection and no session to keep alive, which makes the server dependable behind proxies and load balancers. The flip side is that Stride doesn't push changes to you. An agent asks when it wants to know.
- **One board per token.** A token belongs to one board, so an agent working across several boards needs one connection per board for now. Workspace-wide tokens are on the roadmap.

## Getting started

Create an API token for your board in Stride, keep it in an environment variable, and add the server to Claude Code:

```bash
export STRIDE_API_TOKEN="<your API token>"

claude mcp add --transport http stride https://www.stridelikeaboss.com/api/mcp \
  --header "Authorization: Bearer ${STRIDE_API_TOKEN}"
```

To share the setup with your team, add it to the project's `.mcp.json` instead. Claude Code fills the token in from each person's environment, so the file holds no secret and is safe to commit:

```json
{
  "mcpServers": {
    "stride": {
      "type": "http",
      "url": "https://www.stridelikeaboss.com/api/mcp",
      "headers": {
        "Authorization": "Bearer ${STRIDE_API_TOKEN}"
      }
    }
  }
}
```

Run `/mcp` in Claude Code to confirm that Stride is connected with six tools. If you run your own Stride, use your own address in place of the hosted one.

## Putting it to work

Once Stride is connected, you can talk to your board in plain language and let the agent pick the tool:

- *"What's the next Stride task, and what does it involve?"*
- *"List the open high-priority defects on the board."*
- *"Show me everything in goal G12 that's still blocked."*
- *"Add a comment to W14 explaining why the migration needs a maintenance window."*

Some patterns we find useful:

- **Triage before you claim.** Ask for the next task, read it, and decide whether to take it on, all in one conversation and without touching the task's state.
- **Find first, then read.** List with the short summaries, then fetch the one task you care about in full. Your agent's context goes on the work, not on tasks it will never touch.
- **Leave a trail.** Have your agent comment when it pauses, hands work back or hits something a human should decide. The note stays with the task, where your reviewers will see it.
- **Build your own agents.** MCP isn't tied to one tool. Any MCP-capable client or agent framework can connect, and so can a plain HTTP request:

  ```bash
  curl -sS -X POST https://www.stridelikeaboss.com/api/mcp \
    -H "Authorization: Bearer $STRIDE_API_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","id":1,"method":"tools/call",
         "params":{"name":"stride_list_tasks","arguments":{"status":"open","limit":2}}}'
  ```

  The answer holds one page of short summaries and a cursor for the next page.
- **Handle refusals by code, not by text.** When a tool reports an error, branch on its error code, such as `not_found`, `task_not_claimable` or `completion_validation_failed`, rather than parsing the message.

The full reference, including every tool's arguments, the error codes and the paging rules, is in the [MCP documentation](../MCP.md).

## One step on a longer road

We're building Stride to be the best place for people and AI agents to work together: people plan, review and decide; agents claim, build and hand back; and everyone works from the same board. That only works if agents can reach Stride as naturally as people can.

The MCP server is one step on that road. It builds on the recent work that lets the API page and filter large boards and publish a complete description of itself. It sits alongside the steady work on the Stride plugins that makes agents more accurate, faster and cheaper to run. Still to come are outbound webhooks, Slack and GitHub integrations, and workspace-wide API tokens, each one another way for the tools your team already uses to meet Stride where the work happens.

Connect your agent, ask it what's next, and tell us what you'd like it to do from here.
