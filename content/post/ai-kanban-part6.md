---
date: '2025-10-24T10:41:11-04:00'
draft: false
title: 'Building a LiveView app using AI - Part 6'
tags: ["AI", "Elixir", "Phoenix", "LiveView"]
---

## Just a small thing

Off screen I asked Claude to create the favicon based on the image it has already placed on the home page. In less than a minute I had these files:

![Image of favicons](/img/favicon.png)

Claude also added this html in the header of the `root.html.eex` file:

```html
<link rel="icon" type="image/x-icon" href={~p"/images/favicon.ico"} />
<link rel="icon" type="image/png" sizes="16x16" href={~p"/images/favicon-16x16.png"} />
<link rel="icon" type="image/png" sizes="32x32" href={~p"/images/favicon-32x32.png"} />
<link rel="icon" type="image/png" sizes="48x48" href={~p"/images/favicon-48x48.png"} />
<link rel="icon" type="image/svg+xml" href={~p"/images/favicon.svg"} />
```

This is a small change but it adds to the polish of the app.

## Are you board yet?

What remains in Phase 3 of our plan is to build out the UI for creating, editing, and viewing kanban boards. As you might expect, this is an easy task for Claude.

{{< youtube EtndvtgCdzU >}}

## Let's make a few minor adjustments

When reviewing the UI for the boards I noticed that Claude forgot to add the French translation for the pages. I also noticed that when a user logs into the system they are taken to the home page for the application instead of the page containing their boards. I asked Claude to fix these issues. Let's see how  that goes.

{{< youtube EtndvtgCdzU >}}
