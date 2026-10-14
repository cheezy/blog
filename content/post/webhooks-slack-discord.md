---
date: '2026-10-14T13:35:00-04:00'
draft: false
title: "Your Board, Wherever Your Team Talks"
tags: ["AI", "Continuous Delivery", "Stride"]
---

A Stride board knows the moment anything happens. A card is picked up, an agent finishes a task, a reviewer approves the work. Until now, though, you only found out if you happened to have the board open. Most teams don't sit on their board all day. They live in Slack or Discord, and the board was one more tab to check.

Stride can now tell your team about it where they already are. Each board has a new **Integrations** tab, where the board's owner can send board activity to:

- a **Slack** channel;
- a **Discord** channel;
- a **webhook**, for teams who want to feed Stride into their own tools.

Setting one up takes a couple of minutes, and you choose exactly which kinds of activity each channel hears about.

## The Integrations tab

Open your board and choose **Integrations**, next to **Settings**.

![The Mobile Checkout board, with the Integrations tab next to Settings above the columns](/img/board-integrations-tab.png)

Stride opens a panel listing the board's endpoints, with a form to add a new one underneath.

![The Integrations panel: a Slack endpoint already sending task events, and the Add an endpoint form with a Kind menu, a URL box and nine events to choose from](/img/integrations-overview.png)

Each place Stride sends to is called an **endpoint**. A board can have as many as you like. One team might send everything to an engineering channel, and only finished work to a channel the whole company reads.

Only the board's owner sees this tab. Members, including those who can edit cards, don't. A board's integrations decide what gets shared outside Stride, so that choice stays with one person.

## Slack

### Get a link from Slack

Slack calls this an **incoming webhook**: a private link that posts into one channel. To make one:

1. Go to [api.slack.com/apps](https://api.slack.com/apps) and choose **Create New App**, then **From scratch**.
2. Call it "Stride", pick your workspace and choose **Create App**.
3. Open **Incoming Webhooks** and turn it on.
4. Choose **Add New Webhook to Workspace**, pick the channel, and choose **Allow**. Some workspaces need an admin to approve the app first.
5. Copy the link Slack gives you. It starts with `https://hooks.slack.com/services/`.

### Add it to your board

Back on the Integrations tab, set **Kind** to **Slack**, paste the link, and tick the activity you want the channel to hear about.

![The Add an endpoint form with Kind set to Slack, a Slack webhook link pasted in, and task.claimed, task.moved_to_review, task.reviewed and task.completed ticked](/img/add-slack-endpoint.png)

Choose **Add endpoint**, and you're done.

Treat that Slack link like a password: anyone who has it can post in your channel. Stride stores it encrypted and never shows it in full again. If you come back to edit the endpoint later, you see only the start of the address.

### What your channel sees

From then on, every time something you ticked happens on the board, a short message appears in the channel.

![A Slack channel called #mobile-checkout. Between messages from teammates, Stride posts that W11 Show a clear message when a card is declined was claimed, moved to review, reviewed and completed, and that D3 Keyboard covers the postcode field on small iPhones was claimed. Each message names the board, the column and the event](/img/slack-message.png)

*An illustration of a Slack channel, showing the messages Stride sends.*

Each message tells you:

- **which card**, by its ID and title, linked straight to the card in Stride;
- **what happened** to it, such as *claimed*, *moved* or *completed*;
- **which column** it's in now, and **which board**, with a link to the board.

The messages are deliberately short. They tell you something happened and take you to the card in one click, without filling the channel with detail.

## Discord

### Get a link from Discord

Discord calls this a **channel webhook**. You need the **Manage Webhooks** permission on the server.

1. Open **Server Settings**, then **Integrations**.
2. Choose **Webhooks**, then **New Webhook**.
3. Name it "Stride" and pick the channel.
4. Choose **Copy Webhook URL**.

### Add the Discord link to your board

On the Integrations tab, set **Kind** to **Discord**, paste the link and tick your events.

![The Add an endpoint form with Kind set to Discord, a Discord webhook link pasted in, and task.created, task.moved, task.completed and task.reviewed ticked](/img/add-discord-endpoint.png)

Stride accepts only a real Discord webhook link here. If you paste the wrong thing, such as a link to a channel or a server invite, it tells you, rather than leaving you with an endpoint that will never post.

### What your Discord channel sees

Discord messages show as a small card, with the task as a clickable title and the event, column and board laid out underneath.

![A Discord channel called #stride-updates where Stride posts a card for each event: W15 Saved cards list for returning customers was created in Backlog, W10 Prefetch shipping rates while the cart loads was moved to Doing, and W11 Show a clear message when a card is declined was reviewed](/img/discord-message.png)

*An illustration of a Discord channel, showing the messages Stride sends.*

## A safe channel, whatever the card says

Card titles are written by people and, more and more, by AI agents. Stride makes sure a title can never misbehave in your channel. A card called *@everyone the release is broken* shows up as exactly that text: it doesn't ping the whole server. In Slack, `<!channel>` in a title doesn't notify the channel, and a title can't sneak in a link that looks like something else. Very long titles are shortened, so one card can't take over the conversation.

## Webhooks, for your own tools

If your team has developers, a **webhook** endpoint sends the same activity to a web address of your choosing. It's how you connect Stride to an internal dashboard, a reporting tool, an automation service such as Zapier, or anything else that can receive a web request.

Leave **Kind** as **Generic webhook**, enter the address, tick your events and choose **Add endpoint**. Stride then shows you a **signing secret**.

![After adding a webhook endpoint for hooks.zapier.com, Stride shows its signing secret once, with a Copy button and a reminder that you won't see it again. The secret is blurred here](/img/webhook-signing-secret.png)

Hand the secret to whoever builds the receiving side. It lets their tool check that each message really came from your board and wasn't faked or replayed. **You see it only this once.** If it's lost, or you think someone else has seen it, choose **Rotate secret** to get a new one. The old one stops working at once.

Stride also checks the address before it sends anything. It refuses an address that points into a private network, so a webhook can't be used to reach systems that were never meant to be reachable from the outside.

## Choosing what to hear about

Every endpoint gets only the activity you ticked for it. There are nine kinds, each with a short name on the form:

| Tick this | To hear when |
|---|---|
| `task.created` | a card or goal is added, by a person or an agent |
| `task.updated` | a card's details or status change |
| `task.moved` | a card moves to another column |
| `task.claimed` | an agent picks up a card to work on |
| `task.unclaimed` | an agent lets go of a card |
| `task.moved_to_review` | an agent finishes a card and it's waiting for review |
| `task.reviewed` | someone approves a card or asks for changes |
| `task.completed` | a card is done |
| `task.deleted` | a card is deleted |

A few suggestions:

- **A busy team channel:** `task.claimed`, `task.moved_to_review` and `task.completed` tell people what's being worked on and what's finished, without the noise of every small edit.
- **A reviewers' channel:** just `task.moved_to_review`, so the people who approve work know the moment something is waiting for them.
- **A company-wide channel:** just `task.completed`, as a running list of what got done.
- **A reporting tool:** everything, so it has the whole picture.

Stride only speaks up when something actually changed. Opening a card and saving it without changing anything sends nothing. Neither does adding a label, or the cards below a deleted card moving up to fill the gap. If you move twenty cards at once, each one gets its own message, so nothing is lumped together or lost.

## Keeping an eye on things

Once you've added endpoints, they're listed on the Integrations tab with what each one listens for.

![The Integrations panel listing three endpoints, a Slack one, a Discord one and a generic webhook to hooks.zapier.com, each with the events it receives and Edit, Disable, Send test, Deliveries and Delete buttons. The webhook also has Rotate secret](/img/endpoints-list.png)

Each endpoint has a few actions:

- **Send test** posts a test message, "Stride test message for board Mobile Checkout", so you can check everything is connected before real activity arrives.
- **Deliveries** shows the last 20 messages Stride tried to send, whether each one arrived, and when.
- **Edit** changes which activity the endpoint hears about, or swaps in a new link.
- **Disable** pauses the endpoint without losing its settings, and **Enable** turns it back on. Nothing is saved up while it's paused, so you won't get a flood of old messages when you turn it back on.
- **Delete** removes it for good.

### When something goes wrong

Choose **Deliveries** to see what Stride has sent to an endpoint recently, whether it arrived, and when.

![The recent deliveries for the Slack endpoint: a task.moved message two hours ago and a test message the day before, both Succeeded on the first attempt with a 200 response](/img/deliveries.png)

Slack, Discord and your own tools all have bad moments. If a message can't get through, Stride doesn't give up. It tries again, waiting a little longer each time, for about an hour. Each attempt appears in the deliveries list with its attempt number and the error, so you can see exactly what happened.

Some problems won't fix themselves, such as a Slack channel that was archived or a Discord webhook someone deleted. Then Stride stops after the first try instead of retrying for an hour, and records why. To fix it, make a new link in Slack or Discord and paste it in with **Edit**.

To change an endpoint's link, choose **Edit** and paste the new one. Leave it blank to keep the old one.

![Editing the Discord endpoint: the URL box shows only the current host, discord.com, with a note to leave it blank to keep the current link, and the ticked events can be changed](/img/edit-endpoint.png)

## Why it matters

- **Stop checking the board.** The board comes to you, in the channel you already have open.
- **See your agents at work.** When an agent claims a card, finishes it or sends it for review, your team sees it as it happens, alongside everything else they're talking about.
- **Faster reviews.** A message the moment work is waiting means reviewers no longer find it hours later.
- **Each channel hears only what it needs.** Engineers can follow every move while the rest of the company sees only what's finished, from the same board.
- **Safe by default.** Links and secrets are stored encrypted and shown once. Card titles can't ping a channel, and webhooks can't be pointed at your private network.
- **Connect anything.** A webhook turns your board's activity into something your own tools can use.

Open a board you own and choose **Integrations** to get started.
