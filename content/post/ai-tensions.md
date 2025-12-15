---
date: '2025-12-15T06:38:22-05:00'
draft: false
title: 'Tensions with AI'
tags: ["AI", "Agile", "Continuous Delivery"]
---

## Bringing AI into your organization

I have now worked with multiple teams that have introduced an AI driven development into their development workflow and I have seen a pattern emerge. When AI, and more specifically Vibe Coding, is introduced into a traditional software development organization that are following an Agile process there are three tensions that quickly arise. All three of these tensions are due to the rapid pace of development.

### The Testing Tension

The first tension I will discuss is testing. If you have testers at the end of your process verifying the accuracy of the changes made by developers (or AI in this case) then be assured that they will be unable to keep up. It’s not even close. Tasks will be developed in minutes instead of days and they will rapidly queue up waiting for testing.

Furthermore, once you have your model working well with your code you will be changing from a current place where developers sort-of write a few unit tests to where AI will write comprehensive tests for all functionality. AI will even open a browser and test behaviours from a user perspective. I have seen multiple teams go through this transition and after a while the testers find incredibly few defects.

In my opinion, testing will ultimately shift from these human testers to AI. I am sure you can think of how this tension might work itself out.

### The Development Tension

A more interesting tension is in development. If you have multiple developers working on the same codebase you will have greater code conflicts due to the rapid pace of development. The agents make the changes but also tend to improve the code by refactoring. This is desired but it also increases the pace of change of the code. This makes code merges more complex.

A second development issue that arrises is code reviews. If you have a PR process where developers review the changing code then it will also become a bottleneck. You will quickly find that you are spending much more time reviewing the code than the agent spent writing it.

Over time this will become less of a problem. In the months I've been working with AI to build applications I have seen it dramatically improve. This will continue to a point where we will be able to rely on AI to write quality code that needs little to no review. Even so, most organizations will still want developers to look at the changes.

### The Requirements Tension

The traditional requirements process where a product owner works with stakeholders to understand what changes to make and then turns those into user stories that are brought to a team to refine and eventually placed on a kanban or sprint board will quickly fall apart once AI driven developemnt is introduced.

On more than one occasion I have seen developers blast through an entire Sprints worth of work in a couple of days. Not having enough refined stories quickly brings development to a halt. Throwing more people at the requirements process does not solve this problem.

Another tension that exists in requirements is that the form and details captured in a traditional Agile story is not modeled after what is best for AI. Instead, they are structured to facilitate human communication and collaboration. If we are turning our development over to AI we need to rethink the form and details of our requirements.

## Is there a solution to these tensions?

So far this post might feel like doom and gloom. With all of these challenges why would an organization want to use AI in their development process? Instead of doom I want you to feel a sense of optimism and see this all as an opportunity to grow our way forward. By throwing off the constrants of traditional processes many of us are seeing an amazing shift in our development efforts. We are able to deliver higher quality more rapidly that we ever thought possible.

In a more enterprise setting these tensions are going to be even more pronounced. The tools that are available now to help us overcome some of these tensions will be unacceptable to most corporations. The good news is that along with this new era of software development will come new tools and processes to help us overcome these tensions.

In a few weeks I will detail one such tool that will help with some of the tensions outlined in this post. Stay tuned.
