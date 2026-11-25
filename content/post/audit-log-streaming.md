---
date: '2026-11-15T09:57:00-04:00'
draft: false
title: "Send Your Audit Log to Your Security Tools"
description: "Stride streams your Organization's audit log to Splunk, Datadog or any HTTPS endpoint, and adds signed exports for your auditors."
tags: ["AI", "Continuous Delivery", "Stride"]
---

*Audit log streaming and signed exports are part of the Organization plan.*

Your security team doesn't want to log in to every tool your company uses to see what happened in it. They want every tool's security events in one place: Splunk, Datadog or the system your security operations centre already watches. There they can search them, alert on them and keep them as long as your policies say.

Until now, getting [Stride](https://StrideLikeABoss.com)'s events there meant exporting the [Organization audit log](/post/organizations/) by hand. Today Stride does it for you. **Audit log streaming** sends your Organization's audit log to Splunk, Datadog or any HTTPS endpoint, as it happens. **Signed exports** let an auditor check that an exported file really came from Stride and hasn't been changed since.

## Streaming, from the Organization console

Org-admins find streaming under **Organization**, then **Audit streaming**, or with the **Streaming** button on the Organization audit log. Each place you send events to is a **destination**, and an Organization can have up to three.

![The Destinations list: Security Splunk, a Splunk destination marked Healthy and up to date; Datadog (EU), a Datadog destination marked Healthy with a notice that 312 events will never reach it; and SOC ingest webhook, an HTTPS endpoint marked Needs attention, rejected by the destination, with 6 events waiting. Each row shows its host and the last 4 characters of its credential, when it last delivered, how far behind it is, and Pause, Edit, Send test event and Delete buttons](/img/audit-streaming-destinations.png)

The list answers the questions your security team will ask first. Is each destination working, when did it last deliver, and is it keeping up? **Behind by** says "Up to date", or how many events are waiting and how old the oldest one is. Each destination also has **Pause**, **Edit**, **Send test event** and **Delete**.

New events reach your tool within about a minute, in the order they happened.

## Adding a destination

Choose **Add destination** and pick its **Type**: **Splunk**, **Datadog** or an **HTTPS endpoint**. Each type asks only for what that tool needs.

![The Add destination form with Splunk chosen as the Type and Splunk Cloud (SOC) as the Name. Under Connection: the HEC URL https://http-inputs-lakeside.splunkcloud.com/services/collector/event, a hidden HEC token, a reminder to turn off indexer acknowledgement on the token, stride_audit as the Index and stride:audit as the Source type](/img/audit-streaming-add-splunk.png)

- **Splunk** takes your HTTP Event Collector URL and token, and optionally an index and source type. If you paste your Splunk Cloud web address by mistake, Stride warns you that the collector address is the one that starts with `http-inputs`.
- **Datadog** takes your site, such as `datadoghq.com` or `datadoghq.eu`, and an API key. Stride works out the address to send to. You can add a service name and tags, so your events land where your Datadog dashboards already look.
- **An HTTPS endpoint** takes a URL, a format (one JSON batch per request, or one event per line), and an optional header for your endpoint's own authentication. Use it for Sumo Logic, Google Security Operations or a receiver of your own. Stride signs every delivery and gives you a **signing secret**, once, so your endpoint can check that each batch really came from your Stride.

Tokens, API keys, URLs and header values are never shown again once you save them. Everywhere in Stride, a destination is shown only by its host and the last 4 characters of its credential. To change a secret, type a new one. Leave the box empty to keep the one you have.

### Where to start, and what to send

A new destination can start with new events only, or catch up on events already in the audit log: **The last 24 hours**, **The last 7 days** or **Everything in the audit log**. Datadog doesn't accept events more than 18 hours old, so a Datadog destination can catch up on **The last 17 hours** at most.

![The Start from card with The last 24 hours chosen under Send events from, and a notice that this sends past events from the audit log and every org-admin of the Organization will be told. Below it, the What is sent card with Include email and IP addresses ticked, and the start of Leave out these actions, which notes that changes to audit streaming are always sent and can't be left out](/img/audit-streaming-start-from.png)

Under **What is sent**, you decide how much of each event leaves Stride:

- **Include email and IP addresses** is on unless you turn it off. Turned off, each event is sent without the email address and IP address of the person who acted, and without any email or IP address in its details. Your tool still gets their Stride user id, so you can still follow one person's actions without sending their personal data.
- **Leave out these actions** lets you skip events your tool doesn't need, such as password reset requests. Changes to audit streaming itself are always sent, so your security tool always sees a destination being added, changed, paused or deleted.

When you save, Stride sends a **test event** and shows the result straight away: "Test event delivered", or what went wrong, such as "Could not connect" or "The destination refused the credentials". You can send another one any time with **Send test event**.

## Seeing that it works

Open a destination to see its status, its settings and its **Recent attempts**: the last 50 deliveries, newest first, with how many events each held, its size and what your tool answered.

![The Security Splunk destination page, marked Healthy. Status: last delivered 3 minutes ago, up to date. Settings: the host http-inputs-lakeside.splunkcloud.com, the credential ending 8f2c, the index stride_audit, the source type stride:audit, email and IP addresses included, and no excluded actions](/img/audit-streaming-destination-healthy.png)

![Recent attempts for the Splunk destination: seven deliveries of 1 to 27 events, each answered with HTTP 200 and marked Delivered, and an earlier one answered with HTTP 503 and marked Will retry](/img/audit-streaming-recent-attempts.png)

Short outages fix themselves. If your tool is slow or briefly down, Stride waits and tries again, waiting longer each time, and the destination shows **Retrying**. Once it has kept failing for 30 minutes, it becomes **Failing**. Events wait in the audit log in the meantime, so nothing is lost while your tool is down.

## When something needs you

Sometimes retrying won't help. If your tool keeps rejecting the same batch, perhaps because a parser on the receiving end changed, Stride stops after three tries and marks the destination **Needs attention**. It never skips events without telling you. The destination page says what happened and gives you two choices.

![The SOC ingest webhook destination page, marked Needs attention. Status: the destination rejected the same batch on every try, and Stride never skips a batch on its own, so fix the cause at the destination and choose Retry now, or skip the batch. It last delivered 1 day ago and has 6 events waiting. The Rejected batch card shows the answer, Rejected by the destination (HTTP 422), the batch's 6 events and the times of its first and last event, with Retry now and Skip this batch buttons](/img/audit-streaming-needs-attention.png)

- **Retry now** sends the same batch again once you've fixed the problem at your end.
- **Skip this batch** gives up on that one batch and carries on with the next. The skipped events stay in Stride's audit log and in its exports, and the skip is recorded as an audit event that every destination receives, so your security tool knows events were skipped.

If your tool refuses the token or API key, Stride shows it as **Failing** with the reason in plain words. Fix the credential, and the next delivery recovers on its own.

### Gaps

Some events can't be delivered at all. Your Organization's [audit retention](/post/organizations) may delete events before a destination that was down has received them. Or a Datadog destination may have been failing for so long that its events became too old for Datadog to accept. Stride records each run of events like this as a **gap**: how many events, why, and when they happened.

![The Gaps card on the Datadog destination: 312 events lost, too old for Datadog, from 2026-11-11 14:23:39 to 2026-11-12 08:50:19 UTC, with a Dismiss button](/img/audit-streaming-gap.png)

The events are still in the audit log. Export that time range from the Organization audit log, load it into your tool, then **Dismiss** the gap. A gap is also recorded in the audit log itself, so your security tool hears about it too.

## Every org-admin is told

Sending security events outside Stride is a big decision, so streaming doesn't happen quietly. Every org-admin of your Organization gets an email, in the language they use Stride in, when:

- a destination is created (the subject says if it's catching up on past events), paused, resumed or deleted, or its connection or what it sends changes
- a destination starts failing, and when it recovers
- a gap opens

![The email Stride sends when a destination fails: Audit streaming destination is failing: SOC ingest webhook. Stride marked the destination as Failing because it rejected the same batch 3 times, and nothing more is sent until an org-admin chooses Retry now or Skip this batch. A table names the destination, its type, its host, the credential ending 8zK1 and that Stride recorded this, with an Open the destination button and a note that every org-admin receives this security notice, whatever their notification settings](/img/audit-streaming-failing-email.png)

The org-admin who made a change gets the email too, so a change made by one of you is seen by all of you. These are security notices, so they're sent whatever your notification settings are. They never contain a destination's URL, token, API key or signing secret.

## Signed exports for your auditors

Streaming covers your security tools. Auditors have a different question: when someone hands them an exported audit log, how do they know it's what Stride recorded?

The Organization audit log now has **Export signed (.zip)** beside **Export CSV** and **Export JSON**. It exports the events that match your current filters, just like the other exports, and adds a signed **manifest** describing the export. The manifest records which Stride made it, for which Organization, who made it and when, the filters used, how many events it holds, and a fingerprint of the file itself.

![The top of the Organization audit log: Export CSV, Export JSON, Streaming and Export signed (.zip) buttons, then the Signing key panel, which asks you to record the key's fingerprint somewhere outside Stride, and shows the Key ID, the SHA-256 fingerprint, and links to the public key set and to this key as PEM](/img/audit-signed-export-key.png)

The zip holds four files: the events file (byte for byte what an unsigned export of the same events holds), the manifest, its signature, and a `README.txt` with the three commands an auditor runs to check it with OpenSSL. If the signature checks out, the auditor knows that your Stride made exactly this file, for the Organization and filters the manifest names, and that nobody has changed a byte since. That's true whoever handed it over.

The **Signing key** panel shows the key your Stride signs with. Record its fingerprint somewhere outside Stride when you first set things up, and give it to your auditors. That fingerprint is how they know the key that verifies an export really belongs to your Stride.

## Built to be careful

- **Only org-admins.** Only your Organization's org-admins can see or change its destinations. Stride's own site admins can't see them.
- **Secrets stay secret.** Credentials are never shown again, never put in an email and never shown in an error. Errors name what went wrong, never what your tool sent back.
- **Encrypted connections only.** Stride sends only over HTTPS, checks every certificate, and has no setting that skips the check.
- **Nothing lost quietly.** Batches are never skipped without a person choosing to, and events that can't be delivered show up as gaps you can fill from an export.
- **Everyone knows.** Changes to streaming and every failure are in the audit log, and every org-admin is emailed about them.

## Why it matters

- **One place for security events.** Stride's events sit beside the rest of your company's, in the tool your security team already watches.
- **Within about a minute.** Alerts and investigations work from current events, not last week's export.
- **Your choice of tool.** Splunk and Datadog are built in, and any HTTPS endpoint works for the rest.
- **You control what leaves.** Leave out email and IP addresses, or whole kinds of events.
- **Exports auditors can trust.** A signed export proves where it came from and that nothing in it has changed.

Audit log streaming and signed exports come with the Organization plan. The [audit log streaming reference](https://github.com/cheezy/kanban/blob/main/docs/audit-log-streaming.md) has every setting, limit and error, and the [signed exports reference](https://github.com/cheezy/kanban/blob/main/docs/audit-log-signed-exports.md) walks auditors through checking an export step by step.
