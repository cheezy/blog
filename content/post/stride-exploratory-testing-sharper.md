---
date: '2026-10-06T06:22:00-04:00'
draft: false
title: 'Exploratory Testing Gets Sharper, Safer and Quicker'
tags: ["AI", "Continuous Delivery", "Stride"]
---

The Stride exploratory-testing plugin teaches a coding agent to test software the way a good human tester does: give it a mission, let it probe the running app, judge what it sees, and come back with bugs, questions and an honest account of what it didn't get to. The latest version is the result of a close look at how the plugin actually behaved in real use. This post covers what changed, what that means for you, and how to use the plugin inside the Stride workflow or on its own.

## What changed

### Severity labels you can rely on

Every bug the explorer reports gets a severity: **Critical, High, Moderate or Minor**. When we reviewed real sessions, most bugs didn't use those four words. We saw "Major", "important", "medium" and even whole sentences. The rules for choosing a severity lived in a separate skill the explorer was told to read but almost never did.

Those rules now travel inside the explorer itself as a compact reference card: the four levels and what qualifies for each, how to break a tie, how to rate a bug whose impact isn't known yet, and when a session should stop. The explorer no longer depends on loading anything else to label a bug correctly.

This matters most inside Stride, which treats a **Critical** bug as a reason to stop and fix before completing a task. A bug labelled "Major" instead of "Critical" used to slip past that check.

### Findings you can trust

Each session's findings now follow a published, versioned format, so anything reading them knows exactly what to expect:

- **Every bug says how often it reproduced.** "3/3" means the explorer triggered it three times out of three from a clean start. A bug seen once is marked as not yet reproduced, never as "1/1". A severity that's still a best guess is marked **provisional**.
- **Every session says how it ended and what that means.** Did the charter run out of things to find, did the probe budget run out first, or was the session blocked? Each ending maps to one clear status, so "stopped early" always means the same thing.
- **Known issues stay out of the bug list.** Hand the explorer a list of bugs you already know about, and matches go in a separate list instead of being reported as new.

### An explorer that only claims what it can see

The explorer used to be able to fetch web pages through a tool that returns a processed summary of the page, hiding the status code and headers a tester needs. It now observes HTTP directly with `curl`, seeing the raw response.

It also no longer pretends to judge things it can't see. It has no browser, so it can't see layout, colour or contrast. A charter that depends on those now ends with an honest "no way to observe this" result instead of a guess drawn from HTML or CSS source. Inside Stride, that manual test goes back to a human rather than being counted as done.

### A stricter safety boundary

The explorer exercises a live application, so its limits now need explicit permission rather than relying on careful wording:

- **It needs explicit permission.** Every session must say, in a fixed form, that the target is authorized and not production, and list exactly which hosts the explorer may reach. If either line is missing, unclear or repeated, the explorer does nothing. Zero probes, no exceptions.
- **It only goes where it's allowed.** Hosts are matched exactly against that list. It never follows a redirect to a host that isn't listed.
- **It cleans up after itself.** Every file and process it starts is tracked and removed on every exit path, including when something goes wrong.
- **It handles credentials narrowly.** It reads a credentials file only for the specific value it was told to use.
- **Disruptive techniques stay inside the app.** Ideas like interrupting work mid-flight or starving the app of resources are limited to what you can do through the app itself, never by killing processes or cutting the machine's network.

### Quicker sessions

- **Findings go to a file, not the conversation.** When a caller provides a report path, the explorer writes its full findings there and returns a short summary: how the session ended, the counts, and one line per bug. Your conversation no longer fills up with tens of kilobytes of findings.
- **Re-checking a fix is quick.** A new verify mode takes one bug's minimal reproduction and checks whether it still happens, in one or two probes instead of a full session. "Couldn't verify" is never treated as a pass.
- **Turning bugs into tests can run unattended.** The `/harden` command drafts a regression test for each confirmed bug. When it's given the findings and the name of your test framework, it never stops to ask a question, so an automated workflow can run it.
- **The explorer reads less.** It finds what it needs with a search and reads only that part of a file, and it never re-reads something it has already read.

### Less overhead in every session

The plugin's descriptions are loaded into every session where it's installed, whether or not you test anything. They're now about a quarter smaller, with every trigger kept. Reference material the explorer never uses has moved out of the skills into linked documents, where people can still read it.

## What you get from it

We compared three explorer sessions on the new version with nineteen from before the change:

- **The main conversation receives about 0.5 KB per session instead of about 37 KB.** The full findings, about 14 KB, sit in a file you can open when you want them.
- **Sessions finished in a median of about 4½ minutes instead of 9.** Part of that comes from the type of charter and a newer model, so we don't credit all of it to the plugin.
- **Stride's instructions to the explorer shrank from about 6.8 KB to 1.1 KB.** Stride now fills in a fixed template instead of writing a request by hand.
- **Inside Stride, independent read-only sessions now run side by side.** All three of the measured sessions had finished within about 5 minutes of starting.

We want to be straight about what didn't improve. **Total tokens used inside each explorer session went up,** from a median of about 1.1 million to about 1.5 million. The explorer's instructions grew to carry the reference card, the safety rules and verify mode, and every request pays for those. Most of what you notice in practice is the conversation staying small, but the total work inside a session cost more. Three sessions is a small sample, so we're treating the severity-label improvement as encouraging rather than proven.

## How the plugin works

The plugin is built on a simple idea: **Tested = Checked + Explored.** Automated tests *check* what you already expect. Exploration *discovers* what you didn't think to check. The plugin gives the agent a tester's toolkit for the second half:

- **Charters** give each session a mission: *Explore \<target\> with \<resources\> to discover \<information\>*.
- **Heuristics** supply concrete test ideas when you're stuck: cheat sheets, a catalog of things to vary, and themed "tours" of the product.
- **Oracles** decide whether a result is actually wrong, not just surprising.
- **Bug advocacy** turns a confirmed defect into a report someone will act on: reproduce it, narrow it down, find its worst consequence, and rate its severity.
- **Sessions** keep the work disciplined: a time box, a running session sheet, a parking lot for things that come up along the way, and a debrief at the end.

### Inside the Stride workflow

If you use Stride with the exploratory-testing plugin installed, it joins your task workflow automatically. You don't run any commands.

1. **At the start of a session,** the agent asks you one question: is there an app it's allowed to test that isn't production, how does it reach it, and where are the test accounts? Point to them; don't paste credentials. Answer once and that's it for the session. If you don't answer, or the answer is anything short of a clear yes, exploratory testing is simply skipped.
2. **When a task lists manual tests,** the agent turns them into a small number of charters, highest risk first, and runs an explorer session for each, side by side when they only observe. Any manual test it can't cover goes back to a human, and the completion record says so.
3. **When a session finds a Critical bug in code the task just wrote,** the agent fixes it and re-checks with verify mode before completing. A Critical that couldn't be reproduced is recorded as advisory rather than blocking the task. A bug in code the task didn't touch becomes a follow-up task instead of holding up this one.
4. **When there are confirmed bugs,** the agent can run `/harden` to draft regression tests from them. Drafts are staged in `.exploratory/checks/`, never dropped straight into your test suite, so a test for a bug that isn't fixed yet can't break your build.

If the plugin isn't installed, or no app is available, the workflow continues exactly as before. Exploratory testing never blocks a task from completing.

### On its own

The plugin works just as well without Stride, through its commands:

- **`/charter <target>`** turns a feature, a requirement or a worry into a ranked list of charters. **`/nightmare-headline <feature>`** gets there by asking what the worst possible news story about the feature would be.
- **`/recon <feature>`** does a quick survey of something unfamiliar: what it does, what questions to ask, and where to aim.
- **`/explore <target>`** runs a full session: it builds charters, sends the explorer out under the safety boundary, and brings everything back as one debrief with a ranked bug list, saved in `.exploratory/sessions/`.
- **`/pair <target>`** flips the roles. You drive the app; the agent suggests the next thing to try, judges what you report, keeps your notes, and points out what you haven't touched yet.
- **`/debrief`** turns notes and findings into a report for stakeholders: what was explored, what was found, and what's still unknown.
- **`/harden`** drafts a regression test for each confirmed bug, using the test framework your project already has.

A typical first session looks like this:

```
/charter the CSV receipt import --risk multi-tenant data leakage
/explore the CSV receipt import --timebox 90
/debrief
```

The plugin makes no network calls of its own and needs no accounts or keys. The explorer only touches the app you name, and only after you've confirmed it's authorized and isn't production. Add `.exploratory/` to your `.gitignore`; that's where sessions, notes and drafted tests are kept.

## Getting it

It is available from the Stride marketplace. In Claude Code, run:

```
/plugin marketplace add cheezy/stride-marketplace
/plugin install stride-exploratory-testing@stride-marketplace
```

If you already have it installed, run `/plugin marketplace update stride-marketplace` and then `/plugin update stride-exploratory-testing@stride-marketplace`. To get the Stride workflow changes that go with it (side-by-side sessions, verify-mode re-checks and the fixed request template), update the Stride plugin to 1.84.0 or later as well.
