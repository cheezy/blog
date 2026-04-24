---
date: '2026-04-24T09:37:42-04:00'
draft: false
title: 'Context Matters'
tags: ["AI", "Continuous Delivery"]
---

At the AI Coffee Chat this past Wednesday we were having a great conversation about how to minimize the overall context that your Agent uses and what happens as the context gets full. I will not go into the details here of what the Agent context is and why it is important to not fill it up with unnecessary things. In the Chat session, I made the statement that a great way to minimize context usage is to understand the core thing you are asking your Agent to do and try to move everything else out to [SubAgents](https://code.claude.com/docs/en/sub-agents), [Hooks](https://code.claude.com/docs/en/hooks), or [Skills](https://code.claude.com/docs/en/skills).

I continued that conversation with a colleague online and he made the statement _"I am only asking Claude to write code. I really do not have a need for those things."_. This post is intended to help explain that you are not simply asking Claude to write code and it is actually very easy to move a lot of what your Agent does out of its main context.

### I'm Only Writing Code

So what is really happening when we ask an Agent to write code and what could easily be moved out of its context? What follows is a list of all of the typical things that happen while our Agent is writing code.

#### 1. Defining detailed requirements

Before the Agent begins any work it needs to figure out the details of what you are asking it to do. Quite often the human has not provided enough information and the Agent will have to add a lot of details in order to accurately complete the task. Sometimes the human asks the Agent to perform too much for one task and the Agent will want to break that task down into several smaller tasks. If you take the approach of having it figure out this information and enrich the requirements just-in-time, then that happens in your context and adds to the overall context size. If, instead, you have those requirements worked out before the Agent begins a task and have them available in a form that can easily be digested by the Agent you can do this completely outside of Context.

#### 2. Get the developer workspace ready to begin

Before an Agent starts working on a task we need to make sure the local development workspace is ready to go. If there are multiple developers working on the same codebase this often means getting the latest code from the code repository, running a command to install any updated dependencies, running any database migrations that may have been updated, and possibly running the tests to make sure everything is working prior to making any changes. This work can and should be moved out of the Agent's context.

#### 3. Explore the existing codebase

Prior to the Agent making changes it should explore the existing codebase to understand the structure of the application and how to go about making those changes. Ideally, the Agent was already informed of what files will need to change (included in the task from step 1) and it should look at those files and the related test files to have a better understanding of how the code is expected to behave. If the original task definition included any specific patterns to follow during implementation, the Agent should locate other areas in the code where that pattern has already been implemented. Finally, a detailed testing strategy should have been provided in the task definition from step 1 and the Agent should look at other existing examples of similar tests. This exploration can all be removed from context and a structured result can be returned to the implementing Agent.

#### 4. Update the code with the appropriate changes

We are finally at a place where context is used. Up to this point the task details and details about the existing codebase should have been farmed out to other SubAgents. But even in this implementation step there are still opportunities for us to minimize the usage of context. Any framework or language specific details you want the Agent to utilize should be moved out to Skills in order to not have this reside in your Agent's context.

#### 5. Quality checks

After the Agent has finished implementing the code, you will want to have several quality checks performed. These typically include running a linter, running the test suite, running static code analysis, and running security scans. If any of these fail, you will want to analyze the failure and provide those details to the implementing Agent and move back to step 4. If they all pass, you will want to continue moving through the workflow. This could easily happen in a Hook that runs outside of the Agent's context.

#### 6. Review the changes

Now that the Agent has made its changes and we have run our quality checks to make sure the code is clean and tested, it is time to make sure the Agent did everything we asked it to do. This should include ensuring all of the acceptance criteria can be mapped to code changes, any pitfalls defined earlier were avoided, any suggested patterns to follow were utilized, and ensuring the specified testing strategy was followed. This type of review could easily happen outside of the implementation context. If any of these checks fail, details of those failures should be created in a simple format and it should be sent back to the Agent and the task sent back to step 4. If the review passes, the code can be committed and the details of this review should be attached to the task being performed so it can ultimately become part of the traceability of the work if desired.

#### 7. Completing the work

Now that the work for a single task is completed, it is time to capture information about that implementation and to also ask our Agent to learn. Things that are nice to capture include data like a simple completion summary, the actual complexity of the task (to be compared with the estimated complexity from step 1), the actual files that were changed (to be compared with the estimated files to change from step 1), the duration of time to complete the task (to be compared with the estimated duration), and even what Agent and model completed the task. Capturing this information and performing any learning from comparing actual to the estimates made in step 1 should happen with the primary Agent.

#### 8. Integrating the changes

Now that everything is completed it is time to push all of the changes to a central code repository. It is common to rebase the code prior to pushing and to execute one final execution of the test suite after that rebase. This is yet another example of work that can be pushed out of the Agent's context.

### What did we just see?

The act of taking a requirement and turning it into working code is a complex process that involves many steps. Many of those steps can be moved out of the Agent's context so that the context remains focused on the actual implementation work (step 4) and learning (step 7).

### This sounds complex

Building out the SubAgents, Hooks, and Skills does take some time and a lot of effort goes into ensuring they work as expected. I have spent countless hours creating and improving these components over the past few months.

The good news is that if you are using [Stride](https://www.stridelikeaboss.com) with one of its supported Agent plugins then you already have everything mentioned above. The supported Agents are [Claude Code](https://github.com/cheezy/stride), [GitHub Copilot](https://github.com/cheezy/stride-copilot), [Google Gemini CLI](https://github.com/cheezy/stride-gemini), [OpenAI Codex](https://github.com/cheezy/stride-codex), and [OpenCode](https://github.com/cheezy/stride-opencode). If you are not using Stride and want to roll-your-own, please take a look at one of these repos and freely use it to help you get started.

