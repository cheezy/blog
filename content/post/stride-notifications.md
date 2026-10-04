---
date: '2026-10-03T14:13:00-04:00'
draft: fakse
title: 'Stride Now Tells You When It Needs You'
tags: ["AI", "Continuous Delivery", "Stride"]
---

AI agents don't keep office hours. They finish work at 2 a.m., on Sunday afternoons, and in the middle of your lunch meeting. Until now, Stride kept quiet about all of it: if an agent finished something that needed your review, it sat in the review queue until you happened to open it. A stalled claim, a finished goal, a delivery date slipping out of reach. All of it waited for you to come and look.

That changes today. Stride now tells you when something needs your attention, in the app and by email, and lets you decide exactly what reaches you and how.

## A bell that counts what's waiting

Every page now has a bell in the top bar. When something new arrives, a small orange badge shows how many notifications you haven't read yet.

![The Stride top bar with the New board, New Target and Archived targets buttons, and a bell icon at the far right with an orange badge showing 6 unread notifications](/img/notifications-bell-header.png)

The count updates live. You don't need to refresh the page: when an agent sends something your way, the badge ticks up while you're looking at your board. Read something in another tab and the count drops everywhere at once.

## Your notification inbox

Click the bell to open your inbox. Newest notifications come first, and each one tells you what kind of thing happened, what it's about, who did it and when.

![The Notifications inbox showing a list of notifications: a review request, an after-goal hook failure with its exit code, a review result from Priya Shah with her change-request notes, a task assignment, an expired claim, an at-risk delivery target, and older read items such as a completed goal and an unclaimed task with its reason](/img/notifications-inbox-all.png)

Unread notifications have an orange dot and bold titles. A few things you can do here:

- **Open a notification** by clicking it. It takes you straight to what it's about (the review queue, the task, the goal, the delivery target or your boards) and marks it read on the way.
- **Mark as read** without opening it, using the button on each row.
- **Mark all read** to clear the lot in one go.
- **Switch to Unread** to see only what you haven't dealt with yet.

![The Notifications inbox filtered to Unread, showing only the six unread notifications, each with a Mark as read button](/img/notifications-inbox-unread.png)

The inbox shows 25 notifications at a time. If you have more, a **Load more** button at the bottom brings in the rest.

## What you'll be notified about

Stride notifies you about the moments where a person usually needs to step in:

- **Review requests.** When an agent finishes a task that needs review, everyone who can edit the board hears about it, with a link straight to the review queue.
- **Review results.** When someone approves your agent's work or asks for changes, you're told which. A change request includes the reviewer's notes, so you can see what needs fixing without opening anything.
- **Task assignments.** When someone assigns a task to you.
- **Unclaimed tasks.** When an agent gives a task back. The person running the agent and the person who created the task both hear about it, along with the agent's reason when it gave one.
- **Expired claims.** When an agent's claim on your task runs out before the work is done, so nothing sits quietly stuck.
- **Completed goals.** When a goal you created or own reaches Done.
- **After-goal hook failures.** When the script that runs after a goal finishes fails on the agent's machine, with its exit code and how long it ran. You hear about a run of failures once, not on every retry.
- **Board access changes.** When you're added to a board, removed from one, or your access level changes. If the change also switched off API tokens you'd created for that board, the notification tells you how many.
- **Delivery target status.** When a delivery target you own becomes at risk or misses its date. You're told once when the status changes, not every hour after.

Stride doesn't notify you about things you did yourself. Assigning a task to yourself, reviewing your own agent's work or changing your own access won't land in your inbox.

## Email, when you want it

Most notifications also arrive by email, so you hear about urgent things even when Stride isn't open. Each email says what happened and has a button that takes you straight to it.

![A "Review requested" email for "W36: Add archive action to task card menu" on Stride Board, with a View in Stride button and a footer containing Unsubscribe from these emails and Manage notification preferences links](/img/notifications-email-review-requested.png)

When there's more to say, the email says it. A change request, for example, carries the reviewer's name and their notes:

![A "Your task was reviewed" email showing the task, "By Priya Shah", the board, "Changes requested" and the reviewer's two-line notes, with a View in Stride button](/img/notifications-email-changes-requested.png)

Every email ends with two links: one to stop that kind of email with a single click, and one to manage all your notification preferences.

## A weekly summary in your inbox

Not everyone wants to log in to see how the week went. Every Monday, Stride emails you a short digest of the previous week:

- how many tasks were finished and goals completed
- how many tasks are waiting for review
- a table of your boards with what's to do, in progress, in review and done this week
- the reviews that have been waiting longest, with a button to open the review queue

![A "Your weekly digest" email summarising the week of 2026-09-28 to 2026-10-04: 17 tasks done, 2 goals completed and 3 waiting for review, a table of three boards with To Do, Doing, Review and Done counts, the three oldest pending reviews with how long each has waited, and an Open the review queue button](/img/notifications-email-weekly-digest.png)

Quiet weeks stay quiet: if nothing was finished and nothing is waiting for review, you won't get an email.

## Choose what reaches you

Head to **Settings → Notifications** to decide how each kind of notification reaches you. Every type has its own **In-app** and **Email** switches, so you can, for example, see review results in the app but only get emails for review requests.

![The Settings page with Profile, Password and Notifications in the section menu and Notifications selected. The Notification preferences section lists Reviews, Tasks and agents, and Goals and targets, each with In-app and Email checkboxes per notification type](/img/notifications-preferences.png)

Changes save as soon as you tick or untick a box; there's no Save button to forget. Notifications are grouped so they're easy to find, and the weekly digest has its own switch at the bottom.

![The lower half of the notification preferences page showing the Board access, Comments and mentions, and Weekly digest groups, with a checkbox to email a weekly summary of activity on your boards](/img/notifications-preferences-more.png)

A few defaults to know about: completed goals and comments start with email off, since they're good news rather than calls to action. Everything else starts on. Turn both switches off for a type and you won't hear about it at all. The **Comments and mentions** settings are there ahead of time, so they'll already be set the way you like when comment notifications start arriving.

## Unsubscribe in one click

Every email's unsubscribe link opens a short confirmation page that tells you exactly which emails you'll stop getting. It works even if you're not logged in, and it only turns off that one kind of email. Your in-app notifications carry on as before.

![The unsubscribe confirmation page asking "Unsubscribe from these emails?" and explaining that you will stop receiving emails about the Weekly digest and that in-app notifications are not affected, with an Unsubscribe button](/img/notifications-unsubscribe.png)

Stride emails also support the unsubscribe button that many mail apps show next to the sender, so you can turn emails off without leaving your inbox at all. You can turn any of them back on later in your notification settings.

## On your phone

Notifications work on small screens too. The bell sits next to the menu button in the top bar, the inbox stacks neatly, and the settings page puts each checkbox where your thumb can reach it.

<p>
  <img src="/img/notifications-inbox-mobile.png" alt="The notifications inbox on a phone, with the menu button and the bell with a badge of 6 in the top bar, the All and Unread filters, a Mark all read button, and full-width notification rows with a Mark as read button below each one's text" width="300">
  <img src="/img/notifications-preferences-mobile.png" alt="The notification preferences page on a phone, with Profile, Password and Notifications in a row at the top and the Reviews group below, each notification type showing its In-app and Email checkboxes underneath its description" width="300">
</p>

## In your language

Everything here (the inbox, the settings, every email and the weekly digest) is available in all the languages Stride supports: English, German, Spanish, French, Japanese, Portuguese and Chinese.

## The upshot

The biggest delay in working with agents was never the agents. It was the gap between an agent finishing and a person noticing. Stride now closes that gap: you hear about the work that needs you when it needs you, in the place you prefer, and you stay in control of how much you hear.

Try it from the bell in the top bar, or set your preferences under **Settings → Notifications**.
