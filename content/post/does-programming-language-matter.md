---
date: '2026-01-13T10:11:02-05:00'
draft: false
title: 'Does Programming Language Matter?'
tags: ["AI", "Agile", "Continuous Delivery"]
---

## Does AI work better with some languages than others?

A lot of developers identify with the language they program in. How often do you hear "I'm a Java developer" or "I'm a Python developer"?

I've had several conversations with other developers about this topic. Some believe that certain languages are better suited for AI-assisted development than others. Others think that the choice of language has little to no impact on the outcome. I'm of the opinion that language does matter but this is just based on my personal experience that is limited to three languages (Java, TypeScript, and Elixir) in four different contexts.

### The AutoCodeBench Results

[The Hunyuan team at Tencent](https://hunyuan.tencent.com/visual) (maker of Weixin Pay) has released a benchmark called [AutoCodeBench](https://github.com/Tencent-Hunyuan/AutoCodeBenchmark?tab=readme-ov-file). In their benchmark they used 3,920 curated problems, 20 different programming languages, and evaluated over 30 LLMs. This benchmark provides some interesting insights into how different languages perform with AI-assisted development. Let's look at the results:

![AutoCodeBench Results](/img/AutoCodeBenchResult.png)

When running the same set of tests across different languages and different LLMs you can see that the results range anywhere from less than 10% accuracy to over 90% accuracy. At the time they published these results (October 2025) Claude Opus 4.1 was the top performing LLM. If we look at only those results we can see 31.2% accuracy (PHP) to 86.9% accuracy (Elixir) with those languages scoring an upper bound of 53.8% and 97.5%. Let's see how some of the most popular corporate programming languages scored:

| Language | Accuracy | Upper Bound |
|:--------:|:--------:|:-----------:|
| Java | 56.4% | 80.9% |
| JavaScript | 42.9% | 60.9% |
| TypeScript | 47.7% | 61.3% |
| C# | 78.4% | 88.4% |
| Python | 42.3% | 65.3% |
| Ruby | 61.0% | 81.0% |

That is a huge spread. The difference between the highest and lowest scoring languages is 55.7%. I think there are reason why we see such a huge spread and I'll get into that later. But first, let's see what the world's largest technical professional organization has to say on this topic.

### The view of IEEE

In late September [IEEE](https://www.ieee.org) published a [paper](https://developers.slashdot.org/story/25/09/28/1823244/will-ai-mean-bring-an-end-to-top-programming-language-rankings) on [./Slashdot](https://developers.slashdot.org) of all places. In that paper they pose a very interesting question:

> Could we get our AIs to go straight from prompt to an intermediate language that could be fed into the interpreter or compiler of our choice? Do we need high-level languages at all in that future?

This is an interesting thought. If developers are using agents to write over 90% of the code then does it really matter what language it is written in? Does it matter which language it is ultimately compiled to? Should the LLM select the runtime based on the characteristics needed by the application or component? They go on to say:

>Will there be a Top Programming Language in 2026? Right now, programming is going through the biggest transformation since compilers broke onto the scene in the early 1950s. Even if the predictions that much of AI is a bubble about to burst come true, the thing about tech bubbles is that there's always some residual technology that survives. It's likely that using LLMs to write and assist with code is something that's going to stick. So we're going to be spending the next 12 months figuring out what popularity means in this new age, and what metrics might be useful to measure.

### The corporate perspective

Historically corporations have chosen languages based on factors like available developers, internal knowledge and experience, and the need to integrate with existing systems. In the age of AI, these factors may become less important as agents can write code in many languages and we have clearly seen that they are more accurate in some languages than others.

If a company has chosen Java as their primary language would it be bad if an LLM chose another JVM based language like Kotlin for a specific component? In service oriented architectures that use basic JSON with RestFul APIs is it a bad thing if an LLM writes the code in a language where it is more accurate and where there are other characteristics that make it a better choice - like scalability and performance?

These type of questions have not been asked in the past due to the cost of training developers on a new platform. But if AI is writing all of the code is there a cost to switching languages? Is that cost worth the tradeoffs that we might see by selecting the language that works best with the LLM?

### My Cheezy view

I have given a lot of thought to why I think some languages are more accurate than others and I believe it comes down to a few factors:

- Complexity or simplicity of the language

  A simple example of this is comparing Object Oriented languages to Functional languages. OO languages have state that is spread across multiple objects and can be changed a numerous points in the code. Functional languages typically have imutable data with many small functions that have no side effects. It is easy for me to understand how an LLM might do better with a functional language than an object oriented language.

- Number of frameworks and libraries available
  
  I am going to go the opposite way than what you might think here. I think that the more frameworks and libraries a language has translate into more complexity. For example, if there are 10 different ways to build a basic web application due to 10 completely different frameworks then the LLM has more work to do to be great in each of those frameworks. Frameworks that have been around for a long time tend to have many ways of implementing a specific feature and depending on the codebase it brings with it even more complexity.

- Availability of documentation

  It is no secret that access to documentation helps LLMs understand how to implement specific features and patterns. I think that the quality of the documentation and the ability to find it make a big difference in how well an LLM can work with a language. Having to put a lot of links in your [AGENTS.md](https://agents.md) file is far from ideal. Languages that have centralized all documentation in a well-known site and even provide [MCPs](https://modelcontextprotocol.io/docs/getting-started/intro) that know how to locate and deliver the document the Agen needs are a huge benefit.

- Community support and activity

  There are some languages where the community has spent a considerable amount of time over many months making their language and tools work better with AI. Other languages are very late to the game and are playing catch-up. I believe this is clearly the reason the Elixir programming language does so well in Benchmarks.

### Summary

I think many of the reasons specific programming languages were selected in the past no long hold the same level of importance. It is not a huge issue right now but over time I see developers / companies making programming language selections based on how well the language works with AI. How soon will this happen? Maybe this year!
