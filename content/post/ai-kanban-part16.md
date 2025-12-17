---
date: '2025-12-17T08:23:02-05:00'
draft: false
title: 'Building a LiveView app using AI - Part 16'
tags: ["AI", "Elixir", "Phoenix", "LiveView"]
---

## A million small things - on to Version 1.0

This is the final post in this series. There were many things that needed to be done that were not on the original plan so I worked with my trusty AI tools to complete them. This post simply lists them and provides a some details where I thought it was interesting.

Do not worry about this being the end of the series. See the What's Next section at the bottom of this post to see where this is all going. What's next is very exciting and I hope you stay with me on this.

### The List

- Updated the text when adding a user to a board from "Add with Modify Access" to "Add with Edit Access" and the Board Card for users from "Can Modify" to "Can Edit".

- Added translations for the following languages:

  ![Language Selector](/img/language_selector.png)

  I am unsure if the translations are correct but there is a way for you to submit corrections and I will turn them around quickly. See below for how to do that. I also updated my `AGENTS.md` file to have it provide all translations for changes in the future.

- Added the [Error Tracker](https://hex.pm/packages/error_tracker) hex package to make it easy to see errors that occurr in production and have a way to understand what has been resolved and what hasn't.

- Updated the column edit/delete links so they only show when you hover over the column header. This is simular behaviour to tasks and I think it improved the user experience.

- Updated to add a Task History when a task priority changes.

- Updated to add a Task History when a person is assigned to an existing task or when the person assigned changes.

- Updated to use the users name instead of their email in Task History.

- Added a form to the About page for users to easily submit issues they find with the system. This form creates issues in the github issues tracker. Also added a link so users can go see what issues are currently open.

- Created my production environment, pipeline updates, and Dockerfile. Production is live.

- Updated password edit fields so they have an eye icon to show/hide the password.

  ![Password fields](/img/password_field.png)

- Added a page to describe my company - purly marketing on my part. You can access it from the About page.

- Added a green highlight to tasks that belong to the signed in user. This makes it easy to see the tasks that are assigned to you.

  ![Task Highlight](/img/green_task_highlight.png)

- Added a yellow highlight to tasks that are not currently assigned to a user. This makes it easy to see tasks that are not assigned.

  ![Task Highlight](/img/yellow_task_highlight.png)

- Added telemetry to capture events like users registering, boards and tasks being created, etc. This information will show up in reports and make it easy for me to understand how users are using the system.

- Used TideWave to address all Accessibility issues.

- Added an Acceptance Criteria field to Tasks.

- Updated the Project README to not only show what is currently in the system but to also list what is planned.

- Updated system to automatically show updates across all users on a board. When one user moves or updates a task, all users see the change.

- Added a CHANGELOG.md file to the project. Also added a ChangeLog page to the application that can be viewed from the About page. Please keep an eye here as there are a lot of updates coming.

- Added "forgot password" functionality to the application.

### Version 1.0

We are live. We named the application Stride and have the URL <https://StrideLikeABoss.com>. Please check out the application and let me know if you find any issues. There wil be a lot of updates to the application over the coming weeks.

## What's next?

I started this project over three months ago with the goal to really understand AI and Vibe Coding. I have learned a lot and have passed what I have learned on to my clients. The potential is mind-blowing but there are issues that arrise when you try to scale this to a team. One of the issues is that it becomes difficult to maintain a backlog of work that can stay ahead of the agents. They are able to work too fast. Another issue is that the way we typically document tasks (user stories) is not really ideal for AI. I have been experimenting a lot on these two issues and over time I will evolve Stride to address them.  Stay tuned!
