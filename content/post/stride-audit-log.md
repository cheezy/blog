---
date: '2026-10-06T19:27:00-04:00'
draft: false
title: 'A Permanent Record of Who Did What'
tags: ["AI", "Continuous Delivery", "Stride"]
---

When something unexpected happens on a Stride instance, such as a run of failed sign-ins, an API token nobody remembers creating, or someone trying to reach a page they shouldn't, the first question is always the same: *what happened, and when?* Until now, Stride noted these events in its server logs, which come and go and which administrators can't search from Stride. Now it keeps them.

Stride has a **permanent, append-only audit log** of important security events. Entries are only ever added. Once an event is recorded it can't be edited, and recent entries can't be deleted. Site administrators can search the log, filter it and export it.

## Stride now remembers security events

Stride records an entry every time one of these happens:

- someone fails to sign in;
- someone asks for a password reset;
- someone opens a page that needs a recent password confirmation, such as account settings;
- someone is turned away from a page they aren't allowed to see;
- an API token is created or revoked;
- a request arrives with a missing, unknown, revoked or expired API token;
- a completed task's notes look like they contain a credential;
- someone exports the audit log itself.

Each entry records **when** it happened, **what** happened, **who** did it (when Stride knows), **where** the request came from, and any useful details, such as which token or board was involved.

A few things are always true of what gets stored:

- **No secrets.** Passwords, tokens and other secrets are never written into the log. If a detail looks sensitive, Stride leaves it out before the entry is saved. A security record shouldn't become a security risk itself.
- **No runaway entries.** Very long details are cut to a sensible length, so one oversized value can't swamp the log.
- **Nothing gets in your way.** If Stride can't save an entry for some reason, whatever you were doing carries on as normal.
- **Nothing is lost when people leave.** Deleting a user doesn't delete their history. Their events stay in the log, shown as *User #N (deleted)*, so the record still says which account did what.
- **Server logs keep working.** Every event still goes to Stride's server logs and monitoring as well, so any alerts you already have keep firing.

## Looking things up

Site administrators get a new **Audit Log** page, linked from the top navigation.

![The audit log viewer, showing an export, a flagged credential, a revoked token, a denied admin page, a password confirmation, a rejected API token and failed sign-ins, newest first](/img/audit-log-viewer.png)

Events are listed newest first, 50 at a time. **Older events** takes you further back, and **Newest** brings you back to the top. Every time is shown in UTC, so entries line up however your team is spread across time zones. When no signed-in person caused an event, such as a request with no API token, the Actor column says *None*.

You can narrow the list four ways, and combine them:

- **Action:** only one kind of event, such as failed sign-ins or revoked tokens.
- **Actor email:** everything involving one person's email address. That includes what they did, and failed sign-ins or password resets aimed at their account. Capitalisation doesn't matter.
- **From** and **To:** only events within a date range. Both ends are whole days in UTC, and both are included.

For example, filter to failed sign-ins for today and a pattern jumps out: four attempts in about a minute from one address, against three different accounts.

![The audit log filtered to failed sign-ins on one day](/img/audit-log-filtered.png)

The list updates as you change a filter. **Clear filters** puts everything back. The filters are part of the page's address, so you can bookmark a view or send another administrator a link to exactly the events you're looking at. A filter value that doesn't make sense, such as a mistyped date in a shared link, is simply ignored rather than breaking the page.

## Taking it with you

**Export CSV** and **Export JSON** download the events you're looking at. An export uses the same filters as the page, so "every failed sign-in last week" is a filter and one click. Exports stream straight from the database in batches, so even a very large log can be downloaded in full.

- **CSV** opens in any spreadsheet. Stride makes sure no cell can be read as a spreadsheet formula, so an export is safe to open even if someone typed something malicious into a field that ends up in the log.
- **JSON** is ready for scripts, security tools and anything else that reads structured data.

Exporting is recorded too. The log shows which administrator exported it, in which format and with which filters, so you can see who has taken a copy. The entry is written before the download starts, so even an abandoned download leaves a record.

## Only administrators, and nobody can rewrite history

The audit log is visible only to site administrators. Anyone else who tries to open the page or download an export is sent away, and the attempt is itself recorded.

The log is **append-only**. Once an entry is saved:

- **It can't be edited.** The database itself refuses any change to a stored entry, so this isn't just a promise the app makes. The only exception is when a user is deleted: the event's link to their account is cleared, and the event itself is kept.
- **It can't be deleted or wiped while it's recent.** The database refuses deletes, and it refuses requests to empty the log in one go.
- **History has a 90-day floor.** Old entries can only be removed through a single retention step, and that step refuses to touch anything less than 90 days old. The database enforces the floor, not the app. Nothing removes old entries today; retention settings will build on this later.

Where the database allows it, Stride goes one step further. The log is handed to a separate, locked-away database owner, and Stride's own connection can only add entries and read them. In that setup, even a compromised Stride couldn't switch the protection off or quietly remove the evidence.

**If you run your own Stride,** that last step is yours to take. It needs a database administrator's credentials, which Stride deliberately never stores, so it's a one-time command you run yourself after upgrading:

- **Upgrades never fail because of it.** If Stride doesn't have the rights it needs during an upgrade, the upgrade carries on with the protection described above.
- **You'll know where you stand.** A status check reports whether your log is fully locked down and, if not, why. Stride also writes a warning to its startup log until it is.
- **Some hosts can't fully lock it down.** Some managed database services don't hand out the full administrator rights the last step needs. On those, the log still rejects edits, deletes and wipes through Stride, and the 90-day floor still holds, but a compromised Stride could undo that protection. The startup warning stays as a reminder.

The [database roles guide](../audit-log-database-roles.md) walks through every step.

## Why it matters

- **Answer "what happened?" in minutes.** Look up a suspicious sign-in pattern, an unexpected token or a denied request without asking anyone to dig through server logs.
- **Hand evidence to the people who need it.** Security reviews, compliance checks and incident reports want a record they can keep. Filter, export and attach it.
- **Trust the record.** A log that could be quietly edited proves nothing. This one only grows, and recent history can't be removed.

The audit log is in Stride now. If you're a site administrator, you'll find **Audit Log** in the admin menu.
