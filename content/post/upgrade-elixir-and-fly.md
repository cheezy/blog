---
date: '2025-11-07T15:41:11-05:00'
draft: false
title: 'Upgrade Elixir and Fly.io to use Elixir 1.19'
tags: ["Elixir", "Fly.io", "Pipeline"]
---

Elixir finally reached version 1.19.2 so I feel the 1.19 is stable enough to give it a try. This short blog post is about my process to update Elixir and to also update my Fly.io deployment to the latest version of elixir and OTP.

## Update the application

To begin with I needed to get the latest elixir and otp version. That was easy with `asdf` and so I installed `elixir 1.19.2-otp-28` and `erlang 28.1.1`. These are the latest versions at the time of this writing. To ensure I always use these version I updated my `.tool-versions` file in the root of my project:

```bash
elixir 1.19.2-otp-28
erlang 28.1.1
```

I also updated my `mix.exs` file to use the latest version of elixir:

```elixir {linenos=inline hl_lines=[2]}
version: "1.1.0",
elixir: "~> 1.19",
elixirc_paths: elixirc_paths(Mix.env()),
```

With these two changes I was able to run the application with the latest version of elixir and erlang otp. It was easy and seamless. Now on to getting my pipeline and deployment infrastructure updated.

## Pipeline and deployment

My application runs on [Fly.io](https://fly.io). It is a simple platform that gives me everything I need. I use GitHub Actions for my CI/CD pipeline. Here are the changes I had to make to get everything working with the latest Elixir.

First of al I made this simple change to my GitHub Actionspipeline script:

```bash
matrix:
  otp: ['28.1.1']       # Define the OTP version [required]
  elixir: ['1.19.2']    # Define the elixir version [required]
```

I also had to make some changes to my `Dockerfile`. First of all I simply updated the version of elixir and erlang specified which also caused me to update the version of debian:

```dockerfile
ARG ELIXIR_VERSION=1.19.2
ARG OTP_VERSION=28.1.1
ARG DEBIAN_VERSION=trixie-20251103-slim
```

When I pushed this code the pipeline failed complaining about a missing package: `Unable to locate package libncurses5`. After a little research I learned that this is an older version of the library and newer version of debian no long use that. I had to make one additional change to my Dockerfile:

```dockerfile {linenos=inline}
RUN apt-get update \
  && apt-get install -y --no-install-recommends libstdc++6 openssl libncurses6 locales ca-certificates \
  && rm -rf /var/lib/apt/lists/*
```

Notice on line 2 that I updated the library to use `libncurses6`. With this change everything worked and the pipeline passed.
