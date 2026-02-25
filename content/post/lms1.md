---
date: '2026-02-25T11:22:00-05:00'
draft: false
title: 'Building the Learning Management System - Initial Requirements'
tags: ["AI", "Continuous Delivery"]
---

In this post, we start to show how the process we outlined in the post [The New Team](/post/the-new-team/) works for a real application. If you haven't read the initial post, I recommend you do so before reading this one.

## Creating the Requirements

This step is performed by the Product Owner and the Developers. Both are involved because knowledge of the business requirements as well as the technical details of the application is needed in order to create a complete set of requirements.

In this simulation, the team used Claude Code with the [Superpowers Brainstorming Skill](https://github.com/obra/superpowers) installed. This skill helps teams think about the task at hand by prompting them with a series of questions and then using the answers to create a set of requirements. Here is the initial prompt provided to Claude Code:

> I want to build a Learning Management System. The system should allow companies to register and then add their employees. Companies should be able to create training for their employees. The train could include text, images, and videos to make professional looking courses. Companies should be able to enroll their employees in a particular course and the employee will receive an email notifying them of this enrollment. Employees should have their own landing page where they can see the courses the have completed, courses that are in progress, as well as courses that they have not started yet. Please help me brainstore the details of this application.

The video below is long. I chose not to shorten or speed it up, as I wanted you to see all of the details and interactions that go into building out the requirements. In a team setting, the team members will be reading and discussing the questions to ensure they come up with the correct set of requirements. You can see the entire interaction here:

{{< youtube b0P69sf4A8c >}}

After the requirements document is created, the PO and developers would review it for accuracy. If there are any changes required, the team would simply ask Claude to update the document. Remember, the goal here is not to capture every single detail. Target 80% accuracy and completeness and we can fill in the remaining details later.
