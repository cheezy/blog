---
date: '2026-10-09T06:51:00-04:00'
draft: false
title: "Busy Boards, Made Manageable"
tags: ["AI", "Continuous Delivery", "Stride"]
---

A Stride board with a dozen cards is easy to read at a glance. A board with a hundred is not. Until now, finding something meant scanning every column by eye. There was no way to say "these are all the Android bugs", and no single place to see everything assigned to you. Tidying up after a planning session meant dragging cards one at a time.

This release adds six things to help with that:

- **labels**, to group cards by theme;
- **search and filters** on the board;
- a **My Work** page that lists everything assigned to you;
- **bulk actions**, to change many cards at once;
- **keyboard shortcuts**;
- **labels in the API**, so agents can use them too.

## Labels

Labels are short coloured tags you put on cards, such as *iOS*, *Payments* or *Tech debt*. They show up as chips on each card, so the board shows you at a glance what kind of work is where.

![The Mobile Checkout board with coloured label chips such as iOS, Payments, Android, Support and Performance on each card](/img/board-labels.png)

A card shows up to three labels. If it has more, a small **+1** (or +2, and so on) shows how many are hidden, so cards stay compact however many labels they carry.

### Setting up your labels

Each board has its own set of labels. Open the board's **Settings** tab and scroll down to **Labels**.

![The Labels section of board settings, listing eight labels with Edit and Delete buttons, and a form to add a new label called Design review in pink](/img/labels-settings.png)

Type a name, pick one of nine colours, and click **Add label**. You can rename a label, change its colour or delete it at any time, and every change saves straight away. A few rules keep the list tidy:

- **Names are unique on a board, whatever the capitals.** You can't have both *iOS* and *IOS*.
- **Names are up to 40 characters.**
- **Deleting a label never deletes a card.** The label simply disappears from the cards that had it.

The nine colours were chosen to be readable in both light and dark mode, and each chip has a visible border, so a label never fades into the card behind it.

Anyone on the board can see the labels. Only the board owner and members who can edit get the edit controls.

### Labelling a card

The task form now has a **Labels** row. Tick the labels that apply and save.

![The task form, showing Priority, Status and Assigned To, and a Labels row of checkboxes with Payments and Support ticked](/img/task-form-labels.png)

The picker only offers the current board's labels, so you can't attach another board's labels by mistake. If someone deletes a label while you have the form open, Stride saves your other changes and tells you that label was dropped.

## Search and filters

Every board now has a search box and four filters above the columns: **type**, **priority**, **assignee** and **label**.

- **Search** matches card titles and IDs, so typing `D2` or `apple pay` both work, and capitals don't matter.
- **Assignee** includes an **Unassigned** option, for finding work nobody has picked up yet.
- **Filters combine.** Choose *High* and *Payments* and you see only cards that are both.

Here is the Mobile Checkout board narrowed to high-priority payment work:

![The board filtered to High priority and the Payments label: Backlog shows 1 of 6 cards, Ready shows 2 of 4, Doing shows 1 of 3, and an empty column says no cards match](/img/board-filtered.png)

Each column header shows how many cards match out of how many there are, such as **2 of 4**. A column with no matches says so, rather than looking broken. Click **Clear filters** to see everything again.

If a goal's subtask matches, the goal stays on the board too, so you never see a subtask without the goal it belongs to.

While a filter is on, you can't drag cards to reorder them, and the board shows a note saying so. A drag on a partial view could put a card somewhere you didn't expect among the cards you can't see.

### Share exactly what you see

Your search and filters are saved in the page address:

```text
/boards/49?priority=high&label=50
```

Copy the address into chat and your teammate opens the board already filtered the same way. Bookmark it, and you have a saved view for your Monday triage. If a link mentions a label that has since been deleted, or a value Stride doesn't recognise, Stride ignores that part and shows the rest.

Everyone who can see a board can filter it, including members with view-only access and visitors to a public board.

## My Work

**My Work** is a new item in the side navigation. It lists every open task assigned to you, across all the boards you belong to, in one place.

![The My Work page, with Customer Accounts and Mobile Checkout groups, each listing the tasks assigned to you with their ID, title, labels and priority](/img/my-work.png)

- **Grouped by board, most urgent first.** Within each board, critical tasks come first, then high, medium and low.
- **Only work that's still to do.** Completed and archived tasks are left out.
- **Labels come along.** Each row shows the task's labels as they are on its own board. In the example, *Support* is red on one board and orange on the other.
- **One click to the task.** Each row opens the task on its board. If you can only view that board, Stride opens the board with a search for the task instead.

My Work only ever shows boards you are a member of. If someone removes you from a board, its tasks leave your list too.

## Bulk actions

Triage and planning often mean the same change to many cards: move these five to Ready, give those three to Priya, label all of these *Support*. Now you can do that in one step.

Click **Select** at the top of the board. A checkbox appears on every card, and an action bar appears above the columns.

![Selection mode: three cards are ticked, and the action bar shows 3 selected, with Move, Assign, Add label, Remove label and Archive actions, and Priya Raman chosen in the Assign menu](/img/bulk-select.png)

Tick cards one by one, or use **Select all** at the top of a column. Then choose one action:

- **Move** the cards to another column.
- **Assign** them to a board member, or unassign them.
- **Add a label** to all of them, or **remove a label** from all of them.
- **Archive** them. Stride asks you to confirm first, and archived cards are recorded exactly as if you had archived each one by hand.

A few safeguards make bulk changes safe to use:

- **All or nothing.** If any part of an action fails, nothing changes. For example, a move that would push a column past its WIP limit is refused with a message, and no cards are moved.
- **Goals are handled carefully.** Move, assign and archive skip goals, because those actions would also affect the goal's subtasks. Stride tells you how many it skipped. Labels can be added to goals and removed from them as normal.
- **Only sensible choices.** You can only assign to members of the board, and only use the board's own labels.
- **Everyone stays in sync.** Anyone else looking at the board sees the change at the same moment.

Bulk actions are only for people who can edit the board. Members with view-only access don't see the checkboxes or the action bar, and Stride refuses the action even if someone tries to send it by other means.

Press **Esc** to untick everything and start again. Click **Done selecting** when you've finished.

## Keyboard shortcuts

People who spend all day on the board can now keep their hands on the keyboard:

![The Keyboard shortcuts overlay: / focuses the search box, ? shows or hides the list, Esc closes the list or clears the selected tasks](/img/keyboard-shortcuts.png)

- **/** jumps to the search box.
- **?** opens a list of the shortcuts.
- **Esc** closes that list, or clears your selected cards.

The small **/** and **?** keys beside the search box are there as a reminder. The shortcuts stay out of your way: they don't fire while you're typing in a text box or a menu, while you hold Ctrl, Cmd or Alt, or while another dialog is open. So typing a question mark in a comment, or using your browser's own shortcuts, works exactly as before.

## Labels for agents

Agents plan and triage work through Stride's API, and they now see the same labels people do.

- **Every task in the API now includes its labels**, each with a name and a colour.
- **Agents can set labels by name** when they create a task, create a batch of goals, or update a task:

  ```json
  { "task": { "labels": ["Payments", "Support"] } }
  ```

  On an update, the list replaces the task's labels, an empty list removes them all, and leaving the field out changes nothing.
- **A label name the board doesn't have is refused** with an error naming it, and nothing is saved, so a typo never half-applies.
- **Agents can list tasks with a given label** using `GET /api/tasks?label=Payments`, and the MCP tool takes the same `label` option. The result matches what the board's label filter shows for the same label.

Labels are created and managed in board settings, not through the API, so the label list stays under the team's control.

## Why it matters

- **Find any card in seconds.** Search and filters replace scanning columns by eye, and the counts tell you at once how much of the board is in view.
- **See the shape of the work.** Labels show where the payment work, the accessibility work or the customer bugs are, without opening a single card.
- **Talk about the same view.** A filtered board is just a link, so "look at the high-priority Android bugs" becomes a link instead of instructions.
- **Know what to do next.** My Work gathers your tasks from every board into one list, sorted by urgency, so nothing assigned to you hides on a board you rarely open.
- **Spend planning time on decisions, not clicks.** Bulk actions change many cards in one step, and the all-or-nothing rule means a half-finished change never leaves the board in a muddle.
- **Agents and people share one vocabulary.** The same labels appear on the board, in the API and in the MCP tools, so an agent can pick up "all the *Support* cards" exactly as a person would.

All of this is on every board now. Open a board and press **?** to get started.
