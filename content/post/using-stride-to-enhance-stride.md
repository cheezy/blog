---
date: '2026-01-14T10:24:27-05:00'
draft: false
title: 'Using Stride and Claude Code to Enhance Stride'
tags: ["AI", "Agile", "Continuous Delivery"]
---

In this post I will be using Stride and Claude Code to add a _Resources_ section to the Stride UI. Through a series of videos you will see me go through the entire lifecycle of adding this feature to Stride.

## Brainstorming with Claude

I start with a concept. I want to add a new section to Stride where users can go to find answers to questions about Stride. I hope to include a lot of images and videos. The video below shows the output of a Brainstorming session I had with Claude. The session lasted about 5 minutes. I would expect a Product Owner and Developer to pair on this activity in a team setting.

I spent another 15 minutes reviewing the output after I finished with Claude. The goal at this time is not to create a perfect plan. Instead I think that having the plan be 80% right is perfect. We will have several opportunities to refine the plan and to make small adjustments as we go.

{{< youtube VQ6Zj7qNgwY >}}

## Creating the Backlog

Now that we have a plan we need to break this down into Tasks. In this video I ask Claude to do just that. Once the Tasks are created Claude will use one of the Stride Skills to upload the Tasks to Stride. What you do not see is that Stride causes Claude to add a lot of details to each [Task](https://cheezyworld.ca/post/what-is-a-task/). The Task includes things like testing approaches, dependencies, what, why, how, risks, security considerations, etc. This is very useful when the Agent gets around to implementing the Task which is frequently not immediately after the brainstorming. This is a simple step and it took less than 2 minutes.

{{< youtube RW98r1CQMXc >}}

After the Tasks were in Stride I spent another 15 minutes reviewing the tasks and making sure I was happy with how things were broken out. I also ensured all of the dependencies were properly identified. Everything seemed okay so I moved the Tasks to the _Ready_ column on the board so they could be picked up by the Agent.

## Implementing the Change

Now that we have a list of Tasks in the _Ready_ column on the board we can ask Claude to implement them. Claude not only writes the code, but it also tests everything, performs quality checks like static code analysis, and runs security checks. All of these are specified in the [hooks](https://github.com/cheezy/kanban/blob/main/docs/AGENT-HOOK-EXECUTION-GUIDE.md) definition in the Stride configuration so you can tailor it to the needs of your team. A developer would be performing this step. It took a little under 47 minutes for Claude to work through all of the Tasks. If I had multiple developers working on this Backlog it would have taken less time. Stride makes it easy for multiple developers / Agents to work on the same Backlog. It includes intelligence during task assignment to ensure the Agents do not conflict with each other - even down to the individual file level.

{{< youtube Pdv5l6e0Uw4 >}}

## Looking at the Results

This short video walks through some of the updates made to Stride. I wanted you to see what was added. This feature is now live in production so you can try it out. I plan to enhance it (with Claude and Stride) over the coming days.

{{< youtube OymrWVivDP0 >}}

I will be going through the details of this change and asking Claude to make small changes. As I said earlier, I was shooting for 80% accuracy with the requirements and now that I have working software I can easily make small changes to accomplish the remaining 20%.

## What happened?

This is an example of how Claude can work with Stride to implement a feature. It took a total of 84 minutes to go from concept to live feature. I think this is a great example of how AI can be used to enhance the development process.

| Activity | Duration |
|:--------:|:--------:|
| Brainstorming with Claude | 5 Minutes |
| Reviewing the Brainstorming Output | 15 Minutes |
| Creating the Backlog | 2 Minutes |
| Reviewing the Backlog | 15 Minutes |
| Implementing the Change | 47 Minutes |

- **Total time spent on requirements: 37 Minutes**
- **Total time spent on implementation: 47 Minutes**

It also points to a few things that I have blogged about before:

1. It will not be easy to create enough requirements to keep a lot of developers busy. The solution to this is to rapidly create requirements and get them mostly correct. Once the backlog is implemented a Product Owner can go through the software and make the tweaks necessary to get it ready for release.
2. We no longer need large teams with many developers. Two developers and a Product Owner can implement a lot of changes in a short amount of time due to the power of AI.
