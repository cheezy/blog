---
date: '2026-10-08T07:26:00-04:00'
draft: false
title: "Comments That Know Who's Talking"
tags: ["AI", "Continuous Delivery", "Stride"]
---

A task's comments are where the real work gets discussed. Someone reproduces the bug, an agent explains what it changed, a reviewer raises a concern, and someone else answers it. Until now, Stride's comments were a list of notes with a date. They didn't say who wrote them, you couldn't fix a typo, and the only way to get someone's attention was to message them somewhere else.

Comments in Stride are now a proper conversation. Every comment shows who wrote it, human or agent. You can edit or delete your own comments. You can **@mention** a teammate, and they're notified in Stride and by email, with a link that takes them straight to your comment. Agents can read and post comments through the API too.

## Every comment has an author

![A task's comment thread with comments from Priya, Claude Code, Marcus, Dana and Cheezy, including mentions, an edited comment and an agent comment](/img/comments-thread.png)

Each comment shows the author's name and avatar and how long ago it was posted, such as *20h ago*. Hover over the time to see the exact date and time.

Comments written by an agent are easy to spot. The agent's name is shown as the author, with a square avatar where people have round ones, followed by the person whose API token the agent was using. In the thread above, *Claude Code via Cheezy Morgan* tells you an agent did the work and who it was working for. Agents from Claude, Cursor, Aider and Codex each get their own avatar colour.

If someone's account is later deleted, their comments stay on the task, shown with *Unknown* as the author. The conversation still makes sense.

The thread appears in both the task view and the task edit form, and it's the same thread in both places. Comments are listed oldest first, and a long thread scrolls inside its own box so the rest of the task stays in view.

## Fix it or remove it

![Editing a comment in place, with Save and Cancel buttons](/img/comments-inline-edit.png)

Mistyped something? Click **Edit** on your comment and change it right where it is. Click **Save** to keep the change or **Cancel** to leave it as it was. An edited comment is marked *edited*, and hovering over the marker shows when it was changed. The original posting time never changes, so the thread's order stays honest.

**Delete** removes a comment after you confirm.

- **You can edit your own comments.** Nobody else can, not even the board owner, so nobody can put words in your mouth.
- **You can delete your own comments.** The board owner can also delete any comment on their board, to clean up something posted in the wrong place. Stride records that in the audit log, without the comment's text.
- **You need to be on the board.** Anyone on the board can comment, including read-only members. Once someone leaves the board, they can no longer edit or delete what they wrote there.

Edit and Delete only appear when you're allowed to use them, and Stride checks again on the server every time.

## Changes appear for everyone, straight away

If several people have the same task open, they all see new comments appear, edits change and deleted comments disappear as it happens. They don't have to refresh. Your half-written comment and any edit you have open are left alone while the thread updates around them.

Posting a comment from the task edit form no longer throws away changes you haven't saved yet. Change a task's title, leave a comment about why, and your new title is still there, waiting for **Save Task**.

## Mention a teammate

![Typing @ma in the comment box lists the matching board members, Marcus Bell and Priya Raman](/img/comments-mention-autocomplete.png)

Type **@** followed by part of a name and Stride lists the matching people on the board. It matches anywhere in a person's name or email address, so *@ma* finds Marcus Bell and Priya Ra*ma*n. Choose a name and it's added to your comment. When the comment is posted, the mention shows as a highlighted chip with the person's avatar.

- **Keyboard:** Up and Down move through the list. **Enter** or **Tab** adds the highlighted person. **Escape** closes the list without closing the task.
- **Mouse:** click a name. The cursor stays in the comment box, so you can carry on typing.
- **Email addresses don't set it off.** The list only opens when **@** starts a word, so typing *dana@example.com* in a comment doesn't pop it up.
- **It finds the right people.** You can only mention people on the task's board, and disabled accounts aren't offered. Up to eight matches are shown at a time.
- **Names stay current.** A mention always shows the person's current name, so if someone changes their name, old comments show the new one.

Screen readers can use it too. They announce the list of board members and the person you've highlighted as you move through it. The highlighted person is marked with a bar as well as a colour, so you can see the highlight without relying on colour.

## Mentions reach people where they are

![The notifications inbox, with a new mention from Dana Okafor at the top](/img/comments-mention-notification.png)

When you're mentioned, it shows up in your [notifications](/post/stride-notifications/) straight away, under **Mentions**, with the task and who mentioned you. When an agent mentions you, the notification names both the agent and the person it was working for, for example *Claude Code (Cheezy Morgan)*.

Stride emails you as well:

![The mention email: You were mentioned, the task, who mentioned you, the board, and a View in Stride button](/img/comments-mention-email.png)

Mention emails are on by default. You can turn them off, along with any other notification email, on your notification preferences page or with the unsubscribe link in the email.

Neither the notification nor the email includes the comment's text. Emails get forwarded and notification lists get glanced at over shoulders, so the words stay in Stride where only the board can see them.

Stride is careful not to nag:

- **You're notified once.** Editing a comment doesn't notify the people who were already mentioned in it. Only people the edit adds are told.
- **You're never notified about yourself.** Mention yourself as a reminder if you like, and nothing is sent.
- **Only people on the board are notified.** A mention of someone who isn't on the board is left as plain text, and nobody hears about it.
- **Up to 20 people can be mentioned in one comment.** That's enough for a real conversation and stops one comment from pinging a whole company.

## Straight to the comment

![The task opened from a mention, with Dana's comment outlined in the thread](/img/comments-deep-link.png)

Clicking a mention, in Stride or in the email, opens the task and scrolls to the comment you were mentioned in. The comment is outlined so you can find it at a glance, even in a long thread. You don't have to hunt for it.

## Agents can join the conversation

Agents often have the most to say about a task. They know what they changed, what they tested and what they're unsure of. They can now read a task's comments and add their own through the API:

- `GET /api/tasks/:id/comments` returns the most recent comments, up to 200 at a time, oldest first.
- `POST /api/tasks/:id/comments` adds a comment. The `stride_add_comment` MCP tool does the same thing.

```json
{
  "content": "Retry is in place behind the checkout_retry flag. @[Priya Raman](user:66) can you confirm staging still returns 504 for a timeout?",
  "agent_name": "Claude Code"
}
```

An agent's comment works just like a person's:

- **Mentions work the same way.** Mentioned people are notified as usual.
- **The comment is credited correctly.** It's always attributed to the token's owner, and the agent's name is shown alongside, so nobody can post as someone else.
- **Task details include a comment count.** An agent can see at a glance whether there's a discussion to read before it starts work.

The [API reference](https://github.com/cheezy/kanban/blob/main/docs/api/post_tasks_id_comments.md) has the details, and the [read side](https://github.com/cheezy/kanban/blob/main/docs/api/get_tasks_id_comments.md) is documented alongside it.

## Light or dark, any language

Comments, mentions and their notifications follow your light or dark theme, and they're available in every language Stride supports.

![The comment thread in dark mode](/img/comments-thread-dark.png)

## Why it matters

- **Know who said what.** Every comment has a name on it, and agent work is clearly labelled and tied to the person who ran the agent.
- **Get the right person's attention.** A mention reaches them in Stride and in their inbox, and takes them straight to the comment.
- **Keep the decision on the task.** Questions, answers and second thoughts stay next to the work instead of being scattered across chat threads.
- **Let people and agents work in one thread.** Agents read what people wrote and answer in the same place, with the same mentions and notifications.

Better comments are in Stride now. Open any task and start talking.
