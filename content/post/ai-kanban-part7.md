---
date: '2025-10-26T14:53:21-04:00'
draft: false
title: 'Building a LiveView app using AI - Part 7'
tags: ["AI", "Elixir", "Phoenix", "LiveView"]
---

## WIP Limits

Before we start building out the columns I asked Claude to update the plan in order to add WIP limits. I was suprised by the number of changes that were required. You can see the details here in the first video of this post.

{{< youtube qrUxEm1e1GA >}}

## Adding the columns

Now on to adding columns to our Kanban application. In the first video we ask Claude to finish all of the non-UI work which includes adding a column table to the database, create the relationship to board, create the schema to hold the data from the database, create the context to perform the basic CRUD functions, and finally create the tests for all of this.

{{< youtube uXPUp7xQtm8 >}}

## Making the Column UI

Now that we have all of the backend code necessary for our columns we can start to build the UI. I am gaining a lot of confidence in Claude so I have him build out the entire UI without asking for my approval. Since there is almost no interaction on my part, I speed up a lot of the video to make it more interesting to watch.

{{< youtube whtPkBE9rlM >}}

## Review the board

I had expected Claude to not get the board and column interaction correct or to have made some UI decisions that I did not agree with. After recording the last video I spent some time looking at the UI and testing the functionality. I have to be hones - I am pleased with everything. There are no changes I want to make to it at this time.

After we complete the next phase (which adds tasks) I will go through a full UI review on video so you can see everything created so far.

But for those of you who can't wait, here's a picture of an example board with columns:

![Image of board with columns](/img/columns.png)

[Continue on to part eight](/post/ai-kanban-part8)
