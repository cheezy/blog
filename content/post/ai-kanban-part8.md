---
date: '2025-11-02T18:35:14-05:00'
draft: false
title: 'Building a LiveView app using AI - Part 8'
tags: ["AI", "Elixir", "Phoenix", "LiveView"]
---

## Adding tasks

Before getting started adding tasks to our Kanban Board I decided to do a little maintenance. A couple of the dependencies had updates so I decided to go ahead and update the project. Also, the latest version of Elixir finally reached 1.19.2. To me that signals that the 1.19 versions are stable enough to update so I did. I'll have a separate blog post of what I had to do to update the application as well as update my deployment scripts and Dockerfile.

## Adding Tasks to the Kanban Board

The next two videos will seem very familiar. They mimic the activity we did in order to add columns - but this time we are adding tasks. There was very little interaction from me and I do not have much to say about them other than Claude is really cranking on the functionality.

Here's the video for adding the backend (database table, schema, context, tests)

{{< youtube l9kVy8MDE9I >}}

Here's the video for building the UI to suppor the creation of tasks as well as placing tasks on the board

{{< youtube mr1LWEKv03c >}}

### What's next?

We have completed the first five phases of our plan. Phase six is focused on adding drag-and-drop functionality to the board to allow us to move tasks between columns. After we complete this next phase we will be doing a deep dive into the UI that has been created so far. Stay tuned!

[Continue on to part nine](/post/ai-kanban-part9)
