---
date: '2026-02-23T09:56:00-05:00'
draft: false
title: 'The New Team'
tags: ["AI", "Agile", "Continuous Delivery"]
---

Traditional Agile development teams composed of a Product Owner (PO), a Scrum Master (SM), several Developers, and one or two Testers is incompatible with AI driven development. The old team structure was built around the assumptions that things happen at a human developer pace and achieve human developer quality. We built all of our processes around this human pace - everything from POs working with stakeholders to define and elaborate user stories to SMs facilitating Sprint Planning and Daily Standups and even our approach to testing.

When an AI driven development process is fully adopted we see significant constraints in each area of the team. This is a result of AI producing code at a much faster pace and higher quality than human developers. When this is applied to the traditional team structure described above we quickly reach a point where the system is idle most of the time. When we find ourselves in the place where we have two choices:

1. We can accept these constraints and continue to have our teams work at a human pace
2. We can restructure our teams and the processes they follow to take advantage of the speed and quality of AI

This post is about the second option. I will present my vision for the new team structure and the processes to be followed. To make it real, I will be building a new application from scratch describing how the new team structure and process would work to deliver this application.

## What are the constraints?

Before I go into detail to describe the new team structure and team process I want to describe the constraints that we are facing and that are driving this change.

- The traditional PO / stakeholder requirements gathering and elaboration process is too slow for AI driven development. If continued, the developers will quickly run out of work to do and will be idle.
- The traditional team that has four or five developers will run into significant constraints around source code management, collaboration with the PO to understand requirements, and understanding the changes being made to the application. As a result this will create a lot of _busy work_ for the developers and will create plenty of idle time.
- The traditional tester role will not be able to keep up with the pace of AI driven development. The option will be to either add a very large number of testers to the team or have the developers slow their pace down to match the testers.

While I know that the goal of any team is not to achieve full utilization, when we view things from a Lean perspective we should try to identify the wait queues (idle time) and eliminate them in order to achieve flow.

## The Optimized Team Structure

The ideal team structure to fully take advantage of AI driven development is one Product Owner and one or two Developers. Let's look at these roles and explain what the will be doing during the development process.

### The Product Owner

The Product Owner is the person who has the vision for the application and is responsible for what is delivered. They will work very closely with the developers in tight feedback loops that last no more than a few hours.

Due to the need to create a lot of requirements and also the need to review and make slight modifications to what AI produces, they will be very busy and will not have a lot of time to have meetings with outside stakeholders. As a result, the organization needs to empower these POs to make decisions without having extensive consultation outside of the team.

Due to the ease and speed of making changes to the application, these POs should focused on experimentation and learning instead of a long list of hard requirements. They should measure success by achieving the desired outcomes instead of a roadmap that is based on assumptions that may or may not be true.

If the team is not focused on customer facing software then the PO might need to have technical knowledge, and in some cases where the software resides in a complex system that is integrated with many other systems, the PO might need to have a deep understanding of the entire system and possibly have the role of an technical lead or a technical business analysis.

### The Developers

Developers will not be writing code. Instead they will be using an AI Agent like Claude Code to product the code and tests. In order to make this successful, the developers will need to fully understand the agents they are using, understand how to place quality/testing constraints and specific workflow instructions.

They will be spending a significant amount of their time working with the PO and AI to create and maintain the task backlog before development and to work with the PO to make fine tune adjustments after the initial development.

## The Optimized Process

The simplified version of this process is a loop that takes anywhere from a half day to a full day. Inside of that loop the PO and Devs will:

1. Meet to create a backlog of tasks to be performed. This is achieved by the PO, Devs, and AI brainstorming the next change (goal), creating a requirements document for that goal, quickly reviewing that document and making any last minute adjustments, and finally having AI break that document down into tasks that can be later consumed by AI. This entire process should take anywhere from 15 minutes for a small feature to upwards of an hour for something larger.  The goal during this session is not to document a huge step with extreme details. Instead, I believe we need to take small steps and shoot for 80% completeness and accuracy at this stage.
2. Developers work with their Agents to complete the tasks that were created in the previous session. This is the most boring part of the process as the Agents will be doing the majority of the work here. Because of this, it is important that the developer has setup their environment so the Agent has a process to follow and will achieve both the code quality and application quality standards of the team. Beyond this, the developer is simply there to step in if there is a problem encountered like a code merge conflict. A single Agent can typically work through a backlog of 15 to 30 tasks in a matter of an hour or two.
3. Once the tasks that were created in the first step are implemented, the team should get back together to review the changes. I suggest the PO have their Agent open during this review so they have the ability to make adjustments to the application in real time. This is where the remainder of the details can be filled in and the PO can ensure that this new feature is ready for end user consumption. In an ideal world, the code is pushed to production at the end of this session.

### External Concerns

There are often other concerns outside of the development team that feed into the requirements. For example, there might be legal, language translations, design, and other extermal groups that need to be considered when creating the requirements. If these groups are not also optimized around the new AI pace then we will be facing the same issues and constraints mentioned above. For example, if a development team needs to wait days for a legal decision around verbage or wait days for a translation to be available, we have the same problems we had before.

These external groups will also need to move toward utilizing AI in order to deliver their requirements in a timely manner. For example, the translation team needs to build an agent that can be utilized by the development team to provide translations on demand. Legal teams need to build their own LLMs that contain the specialized knowledge necessary to ensure legal compliance. Design organizations need to be using design systems that provide MCP access and/or should build out Agent Skills and Sub-Agents the teams can use to ensure compliance with the corporate design standards.

### Dependencies Between Teams

What do we do when we need multiple teams to complete work in order to release a single feature? AI is extremely good at adding and removing feature toggles and I believe it is the easiest way to coordinate the release of changes across multiple teams. There are a couple of things that will make this approach successful.

1. Areas of the organization that will take longer to implement the change should start making the changes first. Areas that have historically been able to make changes more rapidly might want to wait until the longer-running changes are complete before even starting to make their changes.
2. The feature toggles need to be removed as soon as possible once all of the changes are released.

## The New Application

In order to demonstrate how this will work in practice, I will be building a new application from scratch. This application will be a simple Learning Management System. I will be creating a post about each step of the process along with descriptions of what each role is doing during that development. 

**Please come back here for updates as the application is built over the next few days and the table below links to those additional posts.**

| Post | Duration | Involved Roles |
|:--------:|:--------:|:-----------:|
| Initial Design Session | 30 Min | PO and Devs |
| Initial Development | 3 Hours | Devs |
| Review and Refinement Session | 1 hour | PO and Devs |
| Next Planning Session | 30 Min | PO and Devs |
| Next Development | 3 Hours | Devs |


