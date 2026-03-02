---
date: '2026-03-01T12:15:00-05:00'
draft: false
title: 'Building the Learning Management System - First Coding Session'
tags: ["AI", "Continuous Delivery"]
---

This post is a continuation of the implementation of the Learning Management System application demonstrating my concept for the new team structure and process in the age of AI-driven development. 

In the first post of the implementation series, we [created a requirements document](/post/lms1/) with the whole team and Claude Code. In the second post, the whole team, using Claude Code, [created a backlog of tasks from that requirements document](/post/lms2/) and uploaded it to [Stride](https://stridelikeaboss.com). The entire process and team structure is outlined in the post titled "[The New Team](/post/the-new-team/)." If you haven't read the initial post, I recommend you do so before reading this one and follow along with the implementation via the links at the bottom of that post.

### Implementing the Backlog

This step in the process is conducted by the one or two developers that are the developers for the product. The role of the developer is to simply monitor their Agent and only step in if the Agent needs to ask for permission to do something, or if the Agent needs clarification.

Following our process, the developer does not type prompts into the Agent in order to implement the Task from the backlog. Due to the way we built our backlog, each Task contains all of the details necessary to implement the Task. The developer is simply asking their Agent to claim the next Task from [Stride](https://stridelikeaboss.com).

### Looking at the Details

In the video below, I tried to draw attention to all of the [configuration I have in place](https://cheezyworld.ca/post/my_dev_environment/) to direct how the Agent writes and tests the code. Agents are very much like a fast car without a steering wheel and brakes. It is up to the developers to configure the behaviour of the Agent to ensure their standards are met. This configuration should provide best practices for the language you are using, any major framework you are using, quality and testing standards, and anything else that is important to you.

In the video, you will not only see the configuration but you will also see the Agent run the [Stride Hooks](https://github.com/cheezy/kanban/blob/main/docs/AGENT-HOOK-EXECUTION-GUIDE.md). The hooks are a set of commands that the Agent must complete successfully at different points in the workflow in order to move to the next step. There are four hooks that must be defined. They are before and after the _doing_ step and before and after the _review_ step. Typical hooks include checking out the latest code, running tests, running static code analysis, running security scans, running linters, and of course committing the code and pushing it to the repository.

All of these things together are what make this process so effective. The Agent is not just writing code, it is also writing and running tests, and all other things necessary to ensure the quality of the application being built.

{{< youtube EED6iNdp8nE >}}
