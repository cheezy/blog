---
date: '2026-10-14T15:20:00-04:00'
draft: false
title: "See Everything Your Board Is Doing"
tags: ["AI", "Continuous Delivery", "Stride"]
---

Your Stride board shows you where every card is right now. What it couldn't easily tell you was how the work has been *going*:
- How many tasks did the agents finish this week?
- How long does a task take from the moment an agent claims it to the moment it's done?
- How often does work pass review the first time?
- Did anything quietly fail overnight?

Stride now records all of that. Every meaningful thing that happens, such as a task claimed, a review approved, a goal's hook failing or an API call, sends a small, private **telemetry event**. You can feed those events into the dashboards, reports and alerts your team already uses, or build new ones around them.

![An example "Agent operations" dashboard built on Stride telemetry. Five headline numbers: 308 tasks completed by agents (up 18%), a 44-minute median from claim to done, 91% approved on first review, 97.6% of after_goal hooks succeeding, and a 1.8% API error rate. Below them: a line chart of tasks claimed and completed per day, an alerts panel, API requests by endpoint, a heatmap of when agents finish work, and a table of boards](/img/telemetry-dashboard.png)

*An example dashboard. Every panel is built from Stride events; the figures are illustrative.*

## What Stride records

Stride sends 134 different events covering almost everything that happens in it:

- **Work:** tasks created, claimed, unclaimed, moved, completed and archived, goals finishing, dependencies unblocking.
- **Review:** tasks sent for review, approved, or sent back with changes requested.
- **Agents and the API:** every API request, with how long it took and whether it failed, plus claims, completions and the time agents report spending.
- **Automation:** goal hooks succeeding or failing, notification emails sent or failing, exports, GitHub issue reports.
- **Accounts and boards:** sign-ups, sign-ins, boards created, members added and removed, API tokens created and revoked.

Each event has a stable name, such as `kanban.api.task_completed`, and a short, documented list of what it carries. The full list is in the [telemetry reference](https://github.com/cheezy/kanban/blob/main/docs/telemetry.md). It's generated from Stride's own catalog of events, and a test fails if the two ever disagree, so the documentation is always current.

## Private by design

The most important thing about these events is what they leave out.

![One event as your tools receive it: kanban.api.task_completed, with a count of 1 and metadata of board_id 49, task_id 1842, user_id 15, time_spent_minutes 38, method PATCH and the request path. Beside it, the things an event never carries: task titles and descriptions, comments and review notes, names and email addresses, IP addresses, API tokens and secrets, and hook output](/img/telemetry-event.png)

An event carries **ids, fixed labels and numbers**: which board, which task, how long, which outcome. It never carries:
- what a task says;
- who someone is beyond their id;
- where they connected from;
- anything secret.

You can send Stride's events to a monitoring service, or keep them for years, without worrying that a card's description or a customer's email address has gone with them.

This isn't left to good intentions. Stride checks every event as it's sent and removes anything not on that event's approved list. If that ever happens, Stride sends a separate event to say so. Tests also fail if new code tries to add something that doesn't belong. The one exception is the request path on API events, which the [telemetry reference](https://github.com/cheezy/kanban/blob/main/docs/telemetry.md#privacy-rule) documents.

## What you can build with it

The events are standard Elixir telemetry, so they work with the monitoring tools Elixir teams already use, such as Prometheus and Grafana, Datadog and OpenTelemetry. Stride also keeps its own history of the most important ones. Here are some of the things teams build.

### A live operations dashboard

The dashboard at the top of this post answers the questions a team lead asks every morning:

- **Are the agents keeping up?** Claims against completions, day by day. If the lines drift apart, work is piling up in Doing.
- **How long does work take?** The time from `api.task_claimed` to `api.task_completed`, per board.
- **Is the work good?** The share of tasks approved on their first review, from `task.review_approved` and `task.review_changes_requested`.
- **What are agents asking for?** API requests broken down by endpoint. Each endpoint is recorded as its route, such as `/api/tasks/:id/complete`, never with a task's id in it, so the breakdown stays tidy.
- **When does work get done?** A heatmap of completions by hour and day helps you plan reviews around when work actually lands.

Everything is grouped by `board_id`, so one dashboard covers every board, and a filter narrows it to one.

### Reports that arrive by themselves

Not everyone wants another dashboard to check. The same events make a good weekly summary, sent wherever your leads already read.

![A weekly report email titled "Your agents this week: 270 tasks done, 2 hooks to look at". It shows 270 tasks done, a 42-minute median from claim to done, 92% first-pass approvals and 214 hours of agent time logged, a bar chart of tasks completed each day, a table of the four boards with each one's change on last week, and a note that two after_goal hooks failed on the Platform API board](/img/telemetry-weekly-report.png)

*An example weekly report built from Stride telemetry.*

Agents report how long they spent on each task, and that figure arrives with every API completion. Adding it up gives you a real measure of agent time per board, per week or per project, ready for planning or for a cost report.

### Alerts before anyone notices

Some things shouldn't wait for a weekly report. Because every event arrives the moment it happens, you can set rules that tell you straight away:

- a goal's `after_goal` hook fails, so a deploy didn't happen;
- rate-limit denials jump, which often means an agent is stuck in a retry loop;
- notification emails start failing;
- the API error rate climbs above its normal level.

![A Slack channel called #eng-alerts. A Stride Monitor app posts a warning that rate-limit denials are 4× above normal, then a critical alert that an after_goal hook failed twice in the last hour on the Platform API board for goals G58 and G61. A teammate replies that they're looking into it, and the monitor later posts that the hooks are succeeding again](/img/telemetry-slack-alert.png)

*An example alert channel fed by Stride telemetry.*

### History, kept for you

Stride stores its most important measurements for 90 days, including:
- sign-ups, sign-ins and new boards;
- API requests and errors;
- agent claims and completions;
- goal hook results;
- exports and failed notification emails.

A daily clean-up keeps the history to that window. The stored rows hold only ids and labels, under the same privacy rule as the events.

Administrators can watch these metrics live on the **Metrics** page of Stride's admin dashboard, under the **Kanban** tab. Because the history sits in Stride's own database, a reporting tool such as Grafana or Metabase can chart it too, with no extra code.

## For the people setting it up

If you run Stride yourself, connecting your own tools takes a few lines of Elixir. You pick the events you want from the [reference](https://github.com/cheezy/kanban/blob/main/docs/telemetry.md#event-reference) and attach a handler:

```elixir
:telemetry.attach_many(
  "northwind-stride-events",
  [
    [:kanban, :api, :task_completed],
    [:kanban, :goal, :after_goal_failed],
    [:kanban, :rate_limit, :denied]
  ],
  &Northwind.StrideEvents.handle_event/4,
  nil
)
```

From there, forward the events to whatever you use. The [telemetry guide](https://github.com/cheezy/kanban/blob/main/docs/telemetry.md#attaching-a-handler) covers the details, such as keeping handlers fast and converting durations.

Event names are stable: once an event has a name, it keeps it. A dashboard you build today keeps working as Stride grows.

## Why it matters

- **Know, don't guess.** "Are the agents helping?" becomes a number you can track week by week.
- **Catch problems early.** A failing deploy hook or a stuck agent shows up in your alert channel in minutes, not at the next stand-up.
- **Plan with real data.** Real claim-to-done times and logged agent hours make estimates and budgets honest.
- **Use the tools you already have.** Prometheus, Grafana, Datadog, OpenTelemetry or a plain database query: Stride fits in rather than asking you to learn something new.
- **Share it without worry.** Events carry ids and numbers, never content, so they can go to any monitoring service safely.

Telemetry is on in every Stride installation now. Start with the [telemetry reference](https://github.com/cheezy/kanban/blob/main/docs/telemetry.md) to see what's available.
