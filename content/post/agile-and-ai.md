---
date: '2025-10-29T15:28:45-04:00'
draft: false
title: 'Is Agile compatible with AI?'
tags: ["AI", "Agile", "Software Development"]
---

I have made my living as an Agile coach since 2003. I have worked as a coach for clients around the world, taught many courses in various topics, and spoken at too many conferences to count. I have dedicated more than a third of my life to these concepts and truly believe they have been the best way to deliver software.

Agile has gone through many changes over my career. A few of the major ones that I feel have had the most impact are the introduction of Lean Startup, practices like BDD and Acceptance Test Driven Development, and my favourite which is Continuous Delivery. Most of these changes have come from within the Agile community and have pushed us forward in our understanding of how to deliver more value quicker. I have stayed current and in some cases have been on the forefront for many of these changes.

## Here comes AI

There is a major change coming to the software development field and in my opinion its impact will be larger than any of the previous changes I have experienced. This change is not coming from the Agile community but instead it is coming from the Tech community. It will undoubtedly change so much of what we do and how we do it.

I have studied AI over the past year and have spent a significant amount of time working hands-on with the tools over the past six months. I have worked with several LLMs in several languages and have developed a few applications. In the past two months I have seen dramatic improvements in these tools. What I am seeing is shocking to me. Already AI has the possibility to completely rewrite the way we build software and it will only improve over time.

This has caused me to do a lot of soul searching. Will the processes and practices that I have used so successfully for a few decades work with this new paradigm? Is Agile compatible with AI or do we need to look for something different?

## Agile Processes are not compatible with AI

I have come to the conclusion that the Agile processes I am familiar with when applied to a development team fully utilizing AI will quickly become a liability. Let me explain.

By Agile processes I am refering to the forms of Agile were a Product Owner maintains a backlog of tasks to complete and they are delivered to a team in value order. The teams works the tasks to completion. The team will have a dialy meeting usually called a stand-up and they will have meetings to do planning, elaborate the tasks, and review the progress. Scrum is an example of this type of Agile but most teams using Kanban follow a simular pattern.

In the world of AI this approach quickly becomes a drag on progress. In this new world a developer will finish more in an hour or two than what would have taken them a week with a much higher quality output and more automated tests. It becomes impossible for a Product Owner to build out a backlog fast enough. At this new pace a once-a-day meeting (stand-up) seems hardly adequate. Elaboration of the tasks needs to happen in real time in collaboration with a LLM. Reviews of work needs to happen on an hour by hour basis and not every two weeks.

### The traditional team structure also makes no sense with AI

I do not see the need of having somebody on the team with the role of tester. AI builds and maintains a thorough set of unit tests that test every aspect of the application and also completes integration type tests with each tiny increment. Other concerns (i.e. security, accessibility, etc.) can be added to your agents file making the LLM responsible for ensuring compliance as it makes changes. I honestly cannot figure out what a tester on this team would actually do.

With the team eliminating the majority of the meetings (ceremonies) associated with Agile processes I do not see the need for a Scrum Master. There is literally nothing for them to do.

Do we need a designer? I can tell you from experience that it is possible to point an LLM at a design system like Figma and it can retrieve the designs. Better yet, you can point it to an existing application, tell it to imitate the design and it can do it. I see designers taking more of a global role within an organization by setting design standards and AI taking those standards and imitating them.

A product owner is needed but it is essential that it be a person that is an expert in the domain (does not need to consult outside of the team) and has fully authority (does not need to reach out to other stakeholders) to make decisions. This person will need to sit with the developers and review the changes every few minutes to make decisions about the next steps and course correct as needed.

Finally, I do not think we need as many developers on the team. Two to three developers will be able to deliver many times more tasks than six to eight developers have been able to do in the past. The developers are there simply to guide the LLM, review and accept the changes as they appear, and continue to refine AI's approach as the project matures.

## What about the Agile Values?

I have had conversations with people who have stated that the Agile Values still apply. This might be true but they do not apply in the same way as they have in the past. Let's take a look:

### Individuals and interactions over process and tools

Valuing individuals and interactions made a lot of sense, especially when your team size was 8, 10, or 12 people. Collaborating and working together is essential in a traditional Agile team. But when your team size drops to three or four people and they must be in an ongoing conversation all day in order to ensure they are delivering the correct thing you might think it becomes even more important. The fact is that the tools are what is driving the new pace and a lot of the interaction is with the tools. The tools become elevated and the developers become simply a conduit through which the product owner interacts with the tools.

### Working software over comprehensive documentation

When working with AI it is totally possible to have both. There is no need to include this value statement.

### Customer collaboration over contract negotiation

It is always important to get feedback from customers but how should one go about doing this? The best way to do this for a long time has been to orchastrate your application and to learn how your users use the system. Lean Startup and Continuous Delivery combined with product experimentation has yielded the best products. I do not see this changing. I think this will coninue with AI. To state it clearly, there is no contract negotiation and customer collaboration comes from learning how they use the system instead of direct collaboration.

### Responding to change over following a plan

I think this one still applies. Course correction as we learn is still important. Following a plan has been an anti-pattern for a long time and I think it will continue except for environments where there are strict regulatory requirements.

## So what will work?

I have been looking at a lot of the lighter weight processes out there to see if any of them come close to what I envision as working with AI. I looked at [FaST](https://www.fastagile.io) and think it is too heavy although it could possibly be adapted. I looked at [Programmer Anarchy](https://martinjeeblog.com/2012/11/20/what-is-programmer-anarchy-and-does-it-have-a-future/) and think it comes closer but I do think the daily checkin with the product owner is an artifact of the slower pace of the past.

I am currently working through an idea of a three person team - one product owner and two developers. The product owner is describing the next steps and the developers are working with the LLMs to implement them. Commits and deployments to a review environment are happening ever 10 to 20 minutes. The product owner is reviewing those changes and if there is a fundamental change they are talking to the developers to make those changes. If the desired change is a simple UI change then the produce owner will use a UI based AI tool like [Tidewave](https://tidewave.ai) to make those changes. Once the product owner is happy with what they see in the review environment they ask their LLM to move those changes to production. They should work with AI to manage the feature toggles in production thereby coordinating software releases. This is a very light weight collaborative conversation to code process.

## Conclusion

I think the goal of achieving what we have learned through more than twenty-five years of Agile is very desirable. At the same time, I am convinced that Agile is not the way to get us there in the future. I'll keep posting more here as I continue this journey and learn more.
