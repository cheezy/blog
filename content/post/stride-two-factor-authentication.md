---
date: '2026-10-08T16:57:00-04:00'
draft: false
title: "A Stolen Password Is No Longer Enough"
tags: ["AI", "Continuous Delivery", "Stride"]
---

Until now, your Stride account was exactly as safe as your password. If your password leaked in someone else's data breach, if you reused it somewhere, or if you typed it into a convincing fake sign-in page, whoever had it could sign in as you. They could see your boards, change your tasks and create API tokens.

Stride now supports **two-factor authentication**. Once you turn it on, signing in takes two things: your password, and a six-digit code from an authenticator app on your phone. Someone who has only your password gets no further than the second step.

## Turning it on

Open **Settings** and choose the **Two-factor** tab.

![The Two-factor tab in Settings, showing that two-factor authentication is off, with a Set up two-factor authentication button](/img/two-factor-settings-off.png)

Click **Set up two-factor authentication**. Stride shows a QR code and the same key written out as text.

![Setting up two-factor: a QR code, the key written out in groups of four, and a box for the 6-digit code](/img/two-factor-setup-qr.png)

1. **Scan the QR code** with an authenticator app such as 1Password, Google Authenticator or Authy. If you can't scan it, type the key into the app by hand.
2. **Enter the six-digit code** the app shows, and click **Verify and turn on**.

Two-factor only turns on once Stride has seen a correct code. So you can't switch it on by accident, and you can't switch it on with an app that was set up wrong. Change your mind halfway through? Click **Cancel** and nothing changes.

Two-factor settings need a recent sign-in. If you signed in more than ten minutes ago, Stride asks for your password again before showing the page. Someone who walks up to a computer you left signed in can't quietly turn two-factor on or off.

## Your recovery codes

As soon as two-factor is on, Stride shows you ten **recovery codes**.

![Ten recovery codes shown once after turning two-factor on, with an I have saved these codes button](/img/two-factor-recovery-codes.png)

Recovery codes are your way back in if you lose your phone. Each one works once, in place of a six-digit code. **They're shown only this once.** Save them before you click **I have saved these codes**. A password manager is a good place for them, or print them and keep the paper somewhere safe.

The codes are easy to read and to type. They leave out characters that are easy to confuse, such as *1*, *l*, *i* and *o*. Stride doesn't care whether you type the dash, or whether you use capital letters.

Once you're set up, the Two-factor tab offers two things:

![The Two-factor tab with two-factor on: generate new recovery codes, or turn two-factor off](/img/two-factor-settings-on.png)

- **New recovery codes.** Enter a code from your authenticator app and click **Generate new codes**. You get a fresh set of ten, and your old codes stop working straight away. Do this if you've used a few of them, or if you think someone else has seen them.
- **Turn off two-factor.** Enter a code from your authenticator app, or one of your recovery codes if you no longer have the app, and click **Turn off two-factor**.

## Signing in

Sign in with your email and password as usual. If two-factor is on, Stride then asks for your code before it lets you in.

![The two-factor sign-in step: Enter the 6-digit code from your authenticator app](/img/two-factor-challenge.png)

Open your authenticator app, type the code shown for Stride, and click **Verify**. That's all. If you ticked **Keep me signed in on this device**, Stride remembers that too. If you were on your way to a particular page when Stride asked you to sign in, you'll land on that page.

If you don't have your phone, click **Use a recovery code instead** and enter one of the codes you saved.

![The recovery code version of the sign-in step](/img/two-factor-challenge-recovery.png)

Stride tells you when you've used one, so you know your supply is shrinking:

![After signing in with a recovery code: Welcome back! You signed in with a recovery code, which can't be used again. Create new recovery codes in Settings → Two-factor.](/img/two-factor-recovery-sign-in.png)

If a code is mistyped, or has just expired, Stride says so and lets you try again:

![That code is not valid. Check it and try again.](/img/two-factor-challenge-invalid.png)

## A nudge to get started

Two-factor is your choice, and it's off until you turn it on. To help people find it, Stride shows a short reminder after you sign in with a password if two-factor isn't on yet.

![A reminder above the boards list: Protect your account with two-factor authentication, with Set up two-factor authentication, Not now and Read the setup guide](/img/two-factor-reminder.png)

- **Set up two-factor authentication** takes you straight to the Two-factor tab.
- **Read the setup guide** opens a step-by-step guide in Resources, including what to do when you get a new phone or a code is refused.
- **Not now** hides the reminder for ten days on every device you use.

The reminder only appears right after you sign in, and it's gone when you move to another page. It never gets in the way of your work.

## What makes it safe

A second step is only as strong as the way it's built. Here's what Stride does behind the scenes:

- **Your password is checked first.** Stride only asks for a code after the password is right. Someone guessing passwords can't use the sign-in page to find out who has two-factor turned on.
- **A correct password alone isn't a session.** Until the code is accepted, you aren't signed in to anything. The half-finished sign-in expires after five minutes, and then you start again from your password.
- **Each code works once.** A code from your app is accepted for about a minute and a half, to allow for a clock that's a little out. Within that time, a code that has already been used is refused. A code someone watched you type is no use to them afterwards.
- **Guessing is slow and pointless.** A six-digit code has a million possibilities. Stride allows only a handful of attempts per account every few minutes, and limits wrong codes from a single network across all accounts. It also caps wrong codes per account over a whole day. Reach a limit while signing in and you're sent back to the start, password and all.
- **Your key is encrypted.** The key behind your codes is stored encrypted with AES-256-GCM, using a key the server keeps separately from the database. A copy of the database alone doesn't reveal it.
- **Recovery codes are never stored.** Stride keeps only a keyed fingerprint of each one, enough to check a code you type but not to recover it. Once a code is used, it's removed.
- **Every step leaves a record.** Turning two-factor on or off, generating new recovery codes, signing in with two-factor, using a recovery code and entering a wrong code are all written to Stride's audit log, where site administrators can review them. Codes, keys and recovery codes themselves are never written down.

## Things to know

- **Agents aren't affected.** API tokens keep working exactly as before, so your agents, scripts and MCP connections don't need anything new. Two-factor protects the browser sign-in. Treat API tokens like passwords, and revoke one if it might have leaked.
- **Turning it on doesn't sign out your other devices.** Two-factor applies to every sign-in from then on. If you think someone already got into your account, change your password too. That signs out every other device.
- **Keep your recovery codes safe.** Stride deliberately can't turn off two-factor for you, and neither can a site administrator, without one of your codes. That's what stops someone talking their way into your account. It also means that if you lose your phone *and* your recovery codes, you can't get back in.
- **Moving to a new phone?** Many authenticator apps, such as 1Password, move your codes to the new phone for you, and then there's nothing to do. Otherwise, while you still have the old phone, turn two-factor off with a code from it, then set it up again on the new one. The setup guide in Resources walks through it.

Two-factor follows your light or dark theme like the rest of Stride, and it's available in every language Stride supports.

![The Two-factor tab in dark mode](/img/two-factor-settings-on-dark.png)

## Why it matters

- **A leaked password stops being an emergency.** Breaches, reused passwords and phishing pages all hand over a password. None of them hands over your phone.
- **Your boards stay yours.** Your account can see and change your team's work and create API tokens for agents. A second step keeps all of that behind something only you have.
- **It takes seconds.** Setting it up takes about a minute, and each sign-in adds one six-digit code.

Two-factor authentication is in Stride now. Open **Settings → Two-factor** to turn it on.
