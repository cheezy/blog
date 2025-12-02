---
date: '2025-11-21T07:05:12-05:00'
draft: false
title: 'Building a LiveView app using AI - Part 13'
tags: ["AI", "Elixir", "Phoenix", "LiveView"]
---

## Setting permissions for users

Currently every user can do everything in the application. A read only user can delete a board or make any type of change they want. Let's fix that.

### Focus on Owners first

First I want to focus on ensuring the board owner can do board-level actions and other users cannot. Let me start by listing out the things that only owners can do:

* Edit and delete their boards
* Add new columns to a board
* Edit or delete columns from their boards
* Reorder columns (including drag-and-drop)

I think this is a good list. Let's ask TideWave to make these changes.

{{< youtube OBvUmz7zBYo >}}

## Restricting Read Only users

I think users that have Modify permissions should be able to do everything that is currently not restricted for owners. But read only users should not be able to make changes. Let's list out what restrictions we need to add:

* They should not be able to delete tasks
* They should not be able to edit tasks but the should be able to view the details
* They should not be able to add comments.
* They should not be able to move tasks (drag-and-drop)

The second and third bullets are going to be a little more complex. The forms are they for edit mode and they will need to undergo some significant changes to also allow a read-only mode.

That's all I can think of for now so it on over to TideWave to implement.

{{< youtube gYa86y0UrBU >}}

After I completed the video there were a couple of things I decided to change.

### Just a few changes

1. You probably saw in the video that the read only view of tasks initially closed after it opened. This was a defect that was introduced in the session. It was easily resolved.

2. I wasn't happy with having to click the eye icon to view a task in read only mode. I asked my agent to remove the eye icon and update the view so that clicking on a task opened the modal popup. I like this much better.

3. When you go to the edit board page there was no way to go back to the boards. TideWave was easily able to add a back button to the top of the page.

4. When viewing a task one might decide they want to make a change. I asked TideWave to add an edit link on the top of the read only view to load the edit view for that task. Of course this link is not visible for read only users.

[Continue on to part fourteen](/post/ai-kanban-part14)
