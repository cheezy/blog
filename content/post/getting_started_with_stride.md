---
date: '2026-01-05T09:03:25-05:00'
draft: false
title: 'Getting Started with Stride'
tags: ["AI", "Agile", "Continuous Delivery"]
---

## Stride - AI-Human Collaboration Platform

This post is to help you get started. Through a series of videos I will guide you through the entire process from initial setup to working with your AI Agent to build an initial backlog.

Let's start at the beginning.

## Building your first AI Optimized Board

After you've registered with the system you will want to create your first AI Optimized Board. This is an extremely simple process.

{{< youtube oHZWbYg_JnY >}}

As mentioned in the Video, there are two levels of items on a Stride board - Goals and Tasks. There are also two types of Tasks - Work and Defect. Selecting a goal will show you the list of Tasks and what column each is in.

![Goal](/img/goal.png)

Now that we have our board created let's explore the board further by adding team mambers and configuring what we see.

## Adding Users and Configuring What We See

Any user that has registered with Stride can be added to a board with either edit permissions or read-only permissions. It is a good idea to add your team early so they can collaborate with you to create an amazing backlog.

Tasks that are created by AI will have **_a lot_** of information. Much of this information is not really end-user focused but is instead there to help agents do their job more effectively. As an owner of a board you can configure what fields are displayed for teammates.

Since tasks are so detailed there is a <a href="https://github.com/cheezy/kanban/blob/main/docs/TASK-FORM-FIELD-VISIBILITY.md" target="_blank">document</a> dedicated to what is displayed and when. For now let's add a developer and configure what we can see.

{{< youtube t1A0kcms_jk >}}

## Developers Onboarding Their Agents

Stride has an API that Agents can call to learn everything they need to know to interact with the system. It also guides them through setting up with configuration necessary for their workflow. This short video walks you through the simple steps to get started.

{{< youtube hF2B0YReiHU >}}

## Configuring the Agent and Setting Up the API Token

In the previous video Stride and our Agent collaborated to create a couple of configuration files. In this video we will walk through those files and create an API token so the Agent can use the Stride API that interacts with our AI Optimized Board.

There are two items that we cover very quickly in the video that deserve a bit more explanation:

The first is the hooks in the `.stride.md` file. Here is a detailed <a href="https://github.com/cheezy/kanban/blob/main/docs/AGENT-HOOK-EXECUTION-GUIDE.md" target="_blank">document</a> that goes into more details about what they are and when they execute.

The second is the Agent Capabilities that are documented in the `.stride_auth.md` file. You will see later that this is used to match up an Agent with work it can easily do. You can read more about it <a href="https://github.com/cheezy/kanban/blob/main/docs/AGENT-CAPABILITIES.md" target="_blank">here</a>.

{{< youtube PLo4ZgB679k >}}

## Generating Our Backlog

All of the setup is complete so we are finally ready to get started generating the backlog for our Smack application. Our Agent already knows how to interact with Stride so it is simply a matter of prompting with the instructions to generate the application we want.

This process can take some time. You will want to review what is initially generated and make adjustments or additions as needed. Remember, you can always course correct and make changes later.

{{< youtube 0KZuad9I2jE >}}

It is important that we have a lot of tasks. Agents will burn through them very quickly and when you consider you will have at least one Agent (or possibly more) per developer you can start to see how quickly they will be consumed and completed.
