---
date: '2026-10-05T18:21:00-04:00'
draft: false
title: 'The Stride API Now Pages, Filters and Describes Itself'
tags: ["AI", "Continuous Delivery", "Stride"]
---

Most of the work on a Stride board is done by things that talk to the API: coding agents claiming and completing tasks, scripts that build reports, dashboards that keep an eye on progress. Two changes make that API much easier to build on. You can now page through and filter the task list, and Stride publishes a complete, machine-readable description of its API that tools can read for themselves.

## Part 1: What changed, and why it matters

### The task list no longer arrives all at once

Until now, asking Stride for a board's tasks returned **every task on the board in a single response**. On a small board that's fine. On a board with hundreds or thousands of tasks, it means a slow, heavy response every time, most of which the caller throws away. Any script that wanted "just the open high-priority work" had to download everything and sift through it locally.

The task list now works the way you'd expect from a modern API:

- **Pages.** Ask for up to 200 tasks at a time and follow a cursor to the next page. Paging is stable, so a task created while you're reading never makes you skip a row or see one twice; it simply appears on a later page.
- **Filters on the server.** Ask only for the tasks you care about, by status, type, priority, assignee, parent goal or column, and combine them freely. "Open, high-priority work assigned to me" is one small request.
- **Changes since a point in time.** Ask for only the tasks that changed since your last check. A dashboard or mirror can stay current by pulling a handful of rows instead of re-downloading the whole board. Moving a task between columns or reordering it counts as a change, so those updates come through too.
- **Compact rows.** If you only need to find a task rather than read it, ask for a slim summary of each one instead of the full record.

The result is faster responses, far less data over the wire, and integrations that keep working as boards grow. For coding agents, smaller responses also mean less of the model's context spent reading tasks it will never touch.

### Nothing breaks

All of this is **opt-in**. A request that doesn't use any of the new options gets exactly the response it always has: same tasks, same order, same shape. Existing scripts, agents and integrations keep working without a single change. You adopt paging and filters when you're ready, one request at a time.

Invalid input is now caught clearly, too. Send a status that doesn't exist, or a page size that's out of range, and you get a plain `400` naming the parameter that was wrong and the values it accepts, rather than a silently ignored option.

### A description of the API that tools can read

Stride's API has always had friendly documentation for people to read. It now also publishes an **OpenAPI 3.1 description**: a single document listing every endpoint, the parameters each one takes, what it returns and which ones need a token. It lives at `/api/openapi.json` on every Stride server, and it's public, so a new client can discover how to authenticate before it has a token.

That one document unlocks a whole ecosystem of existing tools:

- **Generated clients.** Produce a typed client for TypeScript, Python, Go, Java or dozens of other languages, instead of hand-writing HTTP calls.
- **API explorers.** Open the API in Swagger Editor, Redocly, Scalar or any other OpenAPI viewer, and browse or try every endpoint from your browser.
- **Agent tooling.** Each operation has a stable name such as `listTasks`, `claimTask` or `completeTask` and a described request shape, which maps directly onto the tool definitions agent frameworks expect. New agents are pointed to the description automatically when they first connect to Stride.

The description **stays accurate**. Stride's test suite compares it against the API on every change, checking that no endpoint is missing, that the security requirements match, and that the documented response shapes match what the API really returns. If someone adds an endpoint without describing it, the build fails. You can rely on the document being the API, not an approximation of it.

## Part 2: Putting it to work

The examples below use the hosted service at `https://www.stridelikeaboss.com`. If you self-host Stride, use your own address instead. Every task-list request needs your board's API token in an `Authorization: Bearer` header; the OpenAPI description does not.

### Page through a board

Add `limit` to switch the task list into paged mode. Each response carries a `meta` block with a `next_cursor`. Send that back as `cursor` to get the next page, and stop when it's `null`.

```bash
curl -H "Authorization: Bearer $STRIDE_API_TOKEN" \
  "https://www.stridelikeaboss.com/api/tasks?limit=2&status=open&response_view=slim"
```

```json
{
  "data": [
    { "id": 131, "identifier": "W34", "title": "Add unarchive button and handle_event to archive page", "status": "open", "priority": "high", "type": "work", "...": "..." },
    { "id": 150, "identifier": "G1", "title": "Goal", "status": "open", "priority": "medium", "type": "goal", "...": "..." }
  ],
  "meta": { "limit": 2, "next_cursor": "MTUw" }
}
```

The next page is the same request with `&cursor=MTUw` added. A few rules worth knowing:

- `limit` is 1 to 200 and defaults to 50 once you're in paged mode.
- Keep the same filters on every page of a pass.
- Treat the cursor as opaque. Don't build or decode it yourself.
- Pages are ordered by task `id`. The unpaged response keeps its board order (column, then position).

Here is the same loop as a reusable Python generator:

```python
import os
import requests

BASE = "https://www.stridelikeaboss.com"
HEADERS = {"Authorization": f"Bearer {os.environ['STRIDE_API_TOKEN']}"}


def tasks(**filters):
    """Yield every task matching the filters, one page at a time."""
    params = {"limit": 200, **filters}
    while True:
        response = requests.get(f"{BASE}/api/tasks", headers=HEADERS, params=params)
        response.raise_for_status()
        body = response.json()
        yield from body["data"]
        if body["meta"]["next_cursor"] is None:
            return
        params["cursor"] = body["meta"]["next_cursor"]


for task in tasks(status="open", priority="high", type="work"):
    print(task["identifier"], task["title"])
```

### Filter on the server

Every filter is optional, and everything you send is combined:

| Parameter | What it matches |
|---|---|
| `status` | `open`, `in_progress`, `completed` or `blocked` |
| `type` | `work`, `defect` or `goal` |
| `priority` | `low`, `medium`, `high` or `critical` |
| `assigned_to_id` | tasks assigned to that user |
| `parent` | a goal's identifier, such as `G12`, to list its child tasks |
| `column_id` | tasks in one column |
| `updated_since` | tasks changed at or after an ISO 8601 time, such as `2026-10-01T09:00:00Z` |

For example, every task in a goal:

```bash
curl -H "Authorization: Bearer $STRIDE_API_TOKEN" \
  "https://www.stridelikeaboss.com/api/tasks?parent=G12&limit=200"
```

Add `response_view=slim` when you only need to find tasks. Each row then carries a short summary (identifier, title, type, status, priority, complexity, parent, dependencies and claim expiry) instead of the full record. Fetch the full detail of the one you want with `GET /api/tasks/:id`.

### Keep a copy in sync

`updated_since` lets a dashboard, report or mirror fetch only what changed. A few rules keep a sync from silently drifting:

1. **Use the server's clock, not yours.** Take your next starting point from the `updated_at` values Stride returns, not from the time on your machine.
2. **Overlap, then de-duplicate.** Remember the newest `updated_at` you've seen, and start the next pass a little *before* it: further back than one full pass takes, plus a margin. Some rows will come back twice. That's expected, so store tasks by `id` and overwrite.
3. **Use the full view.** Slim rows don't include `updated_at`, so a slim pass can't tell you where to start next time.
4. **Read `updated_at` as UTC.** It's sent without a time-zone suffix, and many languages treat that as local time.
5. **Reconcile now and then.** Archived and deleted tasks drop out of the results rather than appearing as changes, so run an occasional full pass and remove anything it no longer returns.

Putting those together, reusing the `tasks()` generator from above:

```python
from datetime import datetime, timedelta, timezone

OVERLAP = timedelta(minutes=10)  # longer than one full pass, plus a margin


def sync(store, watermark):
    """Pull everything changed since the last pass into `store`, keyed by id."""
    since = (watermark - OVERLAP).strftime("%Y-%m-%dT%H:%M:%SZ")
    newest = watermark
    for task in tasks(updated_since=since):
        store[task["id"]] = task  # upsert; duplicates near the boundary are expected
        updated = datetime.fromisoformat(task["updated_at"]).replace(tzinfo=timezone.utc)
        newest = max(newest, updated)
    return newest  # the watermark for the next pass
```

### Explore the API in a viewer

Point any OpenAPI 3.1 viewer at the description: Swagger Editor, Redocly, Scalar or your favourite. To try calls from the viewer, enter your token in its `bearerAuth` authorization dialog.

```bash
curl -s https://www.stridelikeaboss.com/api/openapi.json -o stride-api.json
```

Or list every operation straight from the command line:

```bash
curl -s https://www.stridelikeaboss.com/api/openapi.json \
  | jq -r '.paths | to_entries[] | .key as $path | .value | to_entries[]
           | select(.key != "parameters") | "\(.key | ascii_upcase) \($path) \(.value.operationId)"'
```

### Generate a typed client

Any OpenAPI 3.1 generator works. For TypeScript, generate the types and pair them with a small typed fetch library such as `openapi-fetch`:

```bash
npx openapi-typescript https://www.stridelikeaboss.com/api/openapi.json -o stride-api.d.ts
```

```typescript
import createClient from "openapi-fetch";
import type { paths } from "./stride-api";

const stride = createClient<paths>({
  baseUrl: "https://www.stridelikeaboss.com",
  headers: { Authorization: `Bearer ${process.env.STRIDE_API_TOKEN}` },
});

const { data, error } = await stride.GET("/api/tasks", {
  params: { query: { status: "open", priority: "high", limit: 50 } },
});
```

Your editor now knows every parameter and every field in the response, and a typo in a filter value is caught before the request is sent.

For other languages, use a full SDK generator:

```bash
npx @openapitools/openapi-generator-cli generate \
  -i https://www.stridelikeaboss.com/api/openapi.json \
  -g python -o ./stride-client
```

However you generate a client, it still needs your token on every authenticated call. Read it from your own configuration, never from the description, which deliberately contains no credentials.

### Give your agents the whole API

If you're building agent tooling, the description is a ready-made catalogue of tools. Each operation's name (`getNextTask`, `claimTask`, `completeTask` and so on), its summary and its request schema translate directly into a tool definition. Agents that connect through Stride's onboarding endpoint are pointed at the description automatically, in `api_reference.openapi_url`, so they can discover the rest of the API on their own.

### Caching and self-hosting

The description is served with `cache-control: public, max-age=3600`. It only changes when Stride is deployed, so clients and proxies can safely keep it for an hour. It uses a relative server address, so the same document works against the hosted service and against your own Stride instance: fetch it from your server and every path resolves there.

## In short

Large boards now come back in pages, filtered on the server, with only what changed since you last looked, and existing integrations don't have to change. Alongside that, Stride now describes its own API in a standard format that client generators, API explorers and agent frameworks can read, and a test keeps that description in step with the API on every change.

The full reference is in the API docs: the task list's paging, filters and sync rules in [GET /api/tasks](../api/get_tasks.md), and the description itself in [GET /api/openapi.json](../api/get_openapi_json.md).
