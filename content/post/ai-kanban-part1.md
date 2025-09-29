---
date: '2025-09-28T09:52:02-04:00'
draft: false
title: 'Building a LiveView app using AI - Part 1'
tags: ["AI", "Elixir", "Phoenix", "LiveView"]
---

## Getting Started

This is the first post in a series in which I will be building a Kanban board application with [Phoenix](https://www.phoenixframework.org) and [LiveView](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html). What is different this about this series is that I will use AI to write the code and tests as well as come up with the design of the application.  I will be using a set of tools and workflow that I have worked out over the past several months to truly take advantage of the benefits of AI while producing quality code and a fully tested application.

This first post in the series lays down the foundation of what tools I will be using and what things I add to my application in order to make my LLM more effective.

## My Setup

I want to start by giving a very brief overview of the tools I am using in case anybody wants to try to duplicate what they see here.

### Windsurf

I am using [Windsurf](https://windsurf.com) for my IDE. It has excellent support for Phoenix and LiveView while also being built with AI in mind. It is a fork of the VS Code editor so all plugins and snippets that work with VS Code will also work in Windsurf. These are the plugins that I have installed for this series:

- Phoenix Framework
- Credo (Elixir Linter)
- Lexical (Elixir Language Server) - followed [these](https://github.com/elixir-lang/expert/blob/main/pages/installation.md)  instructions.
- GitHub Actions
- Markdownlint
- Claude Code for VS Code

### Claude Code

I am using [Claude Code](https://claude.com/product/claude-code) as my AI agent. This agent combined with a few mcps (discussed next), directions in my AGENTS.md file (discussed later) and the workflow I will demonstrate throughout this series give me the best outcome I have eperienced to date.

### MCP Servers

MCP Servers work with LLMs by providing tool, data, or function specific information. Adding the right ones can greatly improve the LLM's ability to perform tasks. I will walk you through the process to install them later in this post as I get my project setup but here is the list:

- [tidewave](https://tidewave.ai) mcp server
- [hexdoc](https://hexdocs.pm/hexdocs_mcp/readme.html) mcp server
- [filesystem](https://github.com/modelcontextprotocol/servers/tree/main/src/filesystem) mcp server
- [github](https://github.com/github/github-mcp-server) mcp server
- [sequential-thinking](https://github.com/modelcontextprotocol/servers/tree/main/src/sequentialthinking) mcp server
- [knowledge-graph](https://github.com/shaneholloman/mcp-knowledge-graph) mcp server
- [postgres](https://www.pulsemcp.com/servers/modelcontextprotocol-postgres) mcp server

## Setting up the Project

So I generated my application using `mix phx.new kanban` and then ran `mix setup` to create the database and build the assets. I can now run the applicaion and see a beautiful (not really) site.

![Image of newly generated phoenix application](/img/new_phoenix_app.png)

Before I begin development there are still a few things I need to do.

### Setup for Quality and Security

It is important to be able to verify the quality of the application at any given moment. To this end I setup some things that help Claude maintain this quality. These are related to testing, code quality, and security.

#### Testing

If I run the tests that were created during the initial project generation with the `--cover` flag I get the following results:

```shell
Running ExUnit with seed: 335709, max_cases: 16

.....
Finished in 0.06 seconds (0.02s async, 0.04s sync)
5 tests, 0 failures

Generating cover results ...

Percentage | Module
-----------|--------------------------
     0.00% | KanbanWeb.PageHTML
    18.42% | KanbanWeb.CoreComponents
    25.00% | Kanban.DataCase
    50.00% | Kanban.Repo
    50.00% | KanbanWeb.ErrorHTML
    75.00% | KanbanWeb.Layouts
    75.00% | KanbanWeb.Router
    80.00% | Kanban.Application
    80.00% | KanbanWeb.Telemetry
   100.00% | Kanban
   100.00% | Kanban.Mailer
   100.00% | KanbanWeb
   100.00% | KanbanWeb.ConnCase
   100.00% | KanbanWeb.Endpoint
   100.00% | KanbanWeb.ErrorJSON
   100.00% | KanbanWeb.Gettext
   100.00% | KanbanWeb.PageController
-----------|--------------------------
    37.99% | Total

Coverage test failed, threshold not met:

    Coverage:   37.99%
    Threshold:  90.00%
```

There is a lot of generated code here that I really do not want to be included in my test coverage as I have no intention of ever changing it. I do this by adding the following code to the `project` function in `mix.exs`:

```elixir {linenos=inline hl_lines=[12]}
  def project do
    [
      app: :kanban,
      version: "0.1.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      compilers: [:phoenix_live_view] ++ Mix.compilers(),
      listeners: [Phoenix.CodeReloader],
      test_coverage: test_coverage()
    ]
  end
```

and then I add this function at the bottom of the file below the `deps` function:

```elixir {linenos=inline}
defp test_coverage do
  [
    ignore_modules: [
      Kanban.Application,
      Kanban.DataCase,
      Kanban.Repo,
      KanbanWeb.ConnCase,
      KanbanWeb.CoreComponents,
      KanbanWeb.ErrorHTML,
      KanbanWeb.ErrorJSON,
      KanbanWeb.Layouts,
      KanbanWeb.PageHTML,
      KanbanWeb.Router,
      KanbanWeb.Telemetry,
    ]
  ]
end
```

Now my tests run clean without including generated files in my coverage report. I will be updating this new function throughout the development.

#### Code Quality

We will be using [Credo](https://hexdocs.pm/credo/overview.html) to ensure code quality. The setup is very simple. Add this line to your `mix.exs` file:

```elixir
{:credo, "~> 1.7", only: [:dev, :test], runtime: false},
```

Credo is extremely flexible and has a lot of rules you can apply. You do this by creating a file named `.credo.exs` in the root directory of your project. When I initially ran it with my standard configuration it found two issues in the generated `data_case.ex` file and another issue in the `kanban_web.ex` file. I chose to fix the one in the `kanban_web.ex` file (order of aliases) and chose to ignore the one in the `data_case.ex` since I will not be changing that generated file. Here is my configuration but you might want to adjust it to your liking:

```elixir
%{
  configs: [
    %{
      name: "default",
      strict: true,
      checks: [
        # Additional and reconfigured checks
        {Credo.Check.Design.AliasUsage,
          if_nested_deeper_than: 3,
          if_called_more_often_than: 1,
          files: %{excluded: ["test/support/data_case.ex"]}},
        {Credo.Check.Readability.AliasAs, []},
        {Credo.Check.Readability.MultiAlias, []},
        {Credo.Check.Readability.NestedFunctionCalls, []},
        {Credo.Check.Readability.SeparateAliasRequire, []},
        {Credo.Check.Readability.StrictModuleLayout, []},
        {Credo.Check.Readability.WithCustomTaggedTuple, []},
        {Credo.Check.Refactor.ABCSize, []},
        {Credo.Check.Warning.UnsafeToAtom, []},

        # Disabled checks
        {Credo.Check.Design.TagFIXME, false},
        {Credo.Check.Design.TagTODO, false},
        {Credo.Check.Readability.ModuleDoc, false},
        {Credo.Check.Refactor.LongQuoteBlocks, false},
        {Credo.Check.Refactor.Nesting, false}
      ]
    }
  ]
}
```

When I run `mix credo --strict` I get the following output:

```shell
Checking 21 source files ...

Please report incorrect results: https://github.com/rrrene/credo/issues

Analysis took 0.1 seconds (0.02s to load, 0.1s running 70 checks on 21 files)
60 mods/funs, found no issues.

Use `mix credo explain` to explain issues, `mix credo --help` for options.
```

All good. Now let's see what we need to do for security.

#### Security

Let me start by saying that what I am about to show you is in no way a comprehensive way to secure your application. What follows is my simple setup that I use during development to give me an early warning of any possible security issue. We will start by adding a few new hex packages to your dependencies in the `mix.exs` file:

```elixir
{:mix_audit, "~> 2.1", only: [:dev, :test], runtime: false},
{:sobelow, "~> 0.13", only: [:dev, :test], runtime: false}
```

`mix_audit` will scan your dependencies for security vulnerabilities while `sobelow` is a security focused static analysis tool. `sobelow` requires additional configuration. Here is mine:

```elixir
[verbose: false, private: false, skip: false, router: nil, exit: false, format: "txt", out: nil, threshold: :low, ignore: ["Config.HTTPS"], ignore_files: [], version: false]
```

With this in place we now have a few commands we can run - namely `mix deps.audit`, `mix hex.audit` and `mix sobelow --config`. When I ran the `sobelow` command it right away pointed out an issue in my router file. I fixed this by updating the `put_secure_browser_headers` plug to this:

```elixir
    plug :put_secure_browser_headers, %{"content-security-policy" => "default-src 'self'; img-src 'self' data:; style-src 'self' 'unsafe-inline'"}
```

And with that I am starting in a secure place.

## Getting Ready for AI

The changes we have made so far are changes that I would make for any project. But there are still several things we can do in order to enhance our LLMs performance.

### Updating the AGENTS.md file

The generated pheonix project includes an [AGENTS.md](https://agents.md) file. I strongly suggest taking a look at this file and understanding what is there and how it works. It provides your LLM a lot of direction on how to perform tasks and interact with different dependencies. We will be updating this file later but before we do there is another hex package that we can add that helps us get additional instructions from our dependencies. It is called `usage_rules`. The way it works is that package maintainers put a file named `usage_rules.md` in the root of their project and the tool scans all of your dependencies and gathers their instructions inserting them into a marked section of your AGENTS.md file. In fact, if you look through the AGENTS.md file added by the generation you will see some tags for usage_rules are already there. Let's start by adding the dependency:

```elixir
{:usage_rules, "~> 0.1.0"},
```

You can now execute the following command:

```shell
mix usage_rules.sync AGENTS.md --all --link-to-folder deps --inline usage_rules:all
```

Running this initially will add additional information to your agents file and I would suggest executing this command whenever you update a dependency or when you add a new dependency.

### Making our entries to AGENTS.md file

Now it is time to make some of our entries to the `AGENTS.md` file. These entries are instructions on how we want to LLM to work. First of all I add the following two lines to the top ##General guidelines section:

```markdown
- Use the HexDoc mcp server to read the documentation about project dependencies
- Use the TideWave mcp server to learn about and understand the running application
```

After the General guidelines section I add the following two sections for Quality and Security:

```markdown
### Quality guidelines  

- When you complete a task that has new functions write unit tests for the new function
- When you complete a task that updates code make sure all existing unit tests pass and write new tests if needed
- Each time you write or update a unit tests run them with `mix test` and ensure they pass
- When you complete a task run `mix test --cover` and ensure coverage is above the threshold
- When you complete a task run `mix credo --strict` to check for code quality issues and fix them

### Security guidelines

- When you add or update a dependency run `mix deps.audit` and `mix hex.audit` to check for security issues
- When you add or update a dependency run `mix hex.outdated` to check for outdated dependencies
- when you complete a task run `mix sobelow --config` to check for security issues
```

Now you can see how all of the work we have performed so far comes together. 

### Installing the MCP servers

Finally we get to use Claude Code. After starting the Claude Code plugin in Windsurf I provide my first prompt:

```shell
> please refer to the AGENTS.md file for application specific instructions.
```

This is more of a reminder as it already knew this from the AGENTS.md file. Now it is time to install the MCP servers. I ask Claude to install the mcp servers and work through all of the prompts to get them installed.

```shell
> install the HexDoc mcp server
> install the TideWave mcp server
> install the filesystem mcp server
> install the github mcp server
> install the sequential-thinking mcp server
> install the knowledge-graph mcp server
> install the postgres mcp server
```

There will be some questions asked for each mcp server installation but it is safe to go with what claude ask you to do. When you are finished restart Claude Code and run the /mcp command. You should see all of the serers listed. If you do not see one listed ask Claude Code to fix the installation.

## We are ready

What have we done so far? We have added a few dependencies to our project to make testing, code quality, and security easier to verify. We have added a dependency that will make it easier to update our AGENTS.md file going forward, we have added some of our standards to the AGENTS.md file, and finally we have installed several MCP servers. We are now ready to start building the application.
