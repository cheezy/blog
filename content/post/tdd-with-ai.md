---
title:       "TDD With AI"
subtitle:    "Is it possible?"
description: ""
date:        '2025-09-30T09:52:02-04:00'
draft:       false
author:      ""
image:       ""
tags:        ["AI", "TDD"]
categories:  ["Tech" ]
---

## I'm a TDD guy

I have been writing code using Test Driven Development for about 25 years. I am a huge believer in the benefits of this practice. I have spoken about it at conferences around the world and have taught many workshops on the subject. As I started to dig into AI the first thing I tried to do is see how it would fit into my TDD workflow. I tried numerous approaches and they all felt unnatural. I watched videos of others try to do the same and didn't feel like they were successful.

What was wrong? Why wouldn't AI work with my TDD workflow? I felt very frustrated and thought to myself "AI will not really work for Craftsmen like myself". And yet the popularity of AI continued to grow and the tools became more powerful and capable. 

## Why am I a TDD guy?

I am a TDD guy because it is the best way I know to produce code that is thoroughly tested and well factored. Throughout the years this practice has served me well. At the same time I continue to work with AI and see the benefits. My son and I have created applications in a half day that would take a week or two to write without AI. 

It was through this process (and growing) that I realized that TDD was simply a practice. It is a practice that achieves a desired outcome. The outcome - as I said earlier - is to produce code that is thoroughly tested and well factored. What if I could achieve the same outcome using AI? What if I was able to create code that was nearly identical to what I would procude using TDD?

I have spent a lot of time experimenting with different tools, different configurations, different workflows. Throughout the months I have also seen the AI development tools mature which has helped make my desired outcome easier to achieve. I now believe I can use AI to build an application while ensuring the code is fully tested and well factored. What follows is a very high-level overview of what works for me. 

## What works for me

### Make important things easy

The first thing that I believe a developer needs to do is make it very easy within their IDE to do the things that are important to them. Here is my list:

- make it easy and fast to run tests
- make it easy to get code coverage infomation when the tests run
- make it easy to run static code analysis that you configure to check for the things you think are important
- make it easy to run security analysis on both the code as well as dependencies of the application

### Educate your LLM

Once you make it easy to perform these tasks you need to let your LLM know how to run these commands. You would typically do this by adding these commands to your `AGENTS.md` file. This is a file that exists at the root of the project and your LLMs will read this to learn information about the project. Here are a few of the entries from this file in an Elixir project I am currently working on:

```markdown
### Quality guidelines  

- When you complete a task that has new functions write unit tests for the new function
- When you complete a task that updates code make sure all existing unit tests pass and write new tests if needed
- Each time you write or update a unit tests run them with `mix test` and ensure they pass
- When you complete a task run `mix test --cover` and ensure coverage is above the threshold.
- When you complete a task run `mix credo --strict` to check for code quality issues and fix them

### Security guidelines

- When you add or update a dependency run `mix deps.audit` and `mix hex.audit` to check for security issues
- When you add or update a dependency run `mix hex.outdated` to check for outdated dependencies
- when you complete a task run `mix sobelow --config` to check for security issues and fix any issue
```

You can also add entries in this file to tell the LLM how to use some of the dependencies and even where to find documentation about your projects dependencies.

Now that we have made it easy to test, check for quality, and perform security check and we have shown our LLM how to do this it is time to move to a workflow that works given this setup.

### Workflow

Now that we have our environment setup and our LLM understanding what is important to us, we can start to write code. I like to start by asking the LLM to write a PLAN for the next task. I explain what the task is, tell it to divide the task into small steps, and then ask it to write the plan to a file that we can use to track progress. I also remind it to follow the guidelines I have in my AGENTS.md file (although it should already know this). If the plan seems too complicated I ask the LLM to rewrite all or portions of the plan breaking it into smaller steps.

Next I work with the LLM to execute the plan. I simply ask the LLM to perform the next step. This usually takes a few minutes and once it is finished I am able to review the code it has created. There is no need for me to run the tests as the LLM has already done that for me. There is no need for me to run the static code analysis as the LLM has already done that for me. There is no need to perform security analysis as the LLM has already done that for me. I just take a quick look at the product code. If there is something that I think needs improvement I have the choice to do it myself or ask the LLM to do it. When I am content with the step I commit the code.

## Conclusion

This is the process I follow when I am writing code using my LLM. I am not doing TDD but I am achieving the same outcome I would expect had I been doing TDD. And I am producing in an hour what it would take me all day to produce. Am I still a believer in TDD? Yes. Will I still do TDD? Yes. But due to the productivity boost, I spend most of my time these days writing code using AI.
