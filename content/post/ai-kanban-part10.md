---
date: '2025-11-08T18:36:42-05:00'
draft: true
title: 'Building a LiveView app using AI - Part 10'
tags: ["AI", "Elixir", "Phoenix", "LiveView"]
---

## Adding Drag and Drop

We asked Claude to finish phase six which was adding drag and drop functionality to the board. Claude did this quickly but when I tested it I found that it was more complex that expected. Claude got a few things wrong. First of all let's watch the video of phase six.

{{< youtube aM6Rt3fuC9Q >}}

## Always test everything

At the end of the video it seems like everything was okay. One might be tempted to commit the code and move on. I think a very important step is to test everything that AI creates. Occasionally AI will make a mistake and it is important to catch it right away while it still has the entire context available.

### First defect

I started using the drag and drop functionality and I quickly discovered the first issue. If I drag a task to another position in the same column it works fine. If I drag a task to another column and place it at the end of the column it works fine. However, if I drag a task to another column and place it above an existing task I get a database unique constraint error. The violation had to do with this constraint:

```elixir
unique_constraint([:column_id, :position])
```

I wondered why the tests didn't catch this. When I looked at the tests I realized that the drag and drop tests always dragged to an empty column. I decided to take a test first approach to solve this problem. I asked claude to add a test where it dragged a task to another column and placed it above an existing task. It did this and the tests right away received the same error that I was getting.

This was all it took. Claude went about figuring out why the test was failing and discovered the error. After five minutes Claude had fixed this issue.

### Second defect(?)

After the last fix I tested the remainder of the drag and drop functionality and everything looked good. I decided to test how drag and drop would react when one attempted to violate a WIP limit. I dragged a task to a column that was at its WIP limit and the task was not allowed to be dragged there. The column was also highlighted red and an exclamation point icon was placed at the top of the column. I that that was a little strange as it was in a state where the WIP limit was not violated and yet the column was highlighted red. I dragged another task away from the column making it even lower than the WIP limit and the highlighting remained.

I had to think about how I wanted to to behave. The system is designed so it will not allow you to exceed a WIP limit but I still wanted it to provide some sort of indicator that a violation of the WIP limit was attempted. I asked Claude to change the highlighting strategy to only highlight the column for 3 seconds when there was an attempt to exceed the WIP limit. Claude did this and the highlighting was much more appropriate.
