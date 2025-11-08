---
date: '2025-11-08T14:04:14-05:00'
draft: false
title: 'Building a LiveView app using AI - Part 9'
tags: ["AI", "Elixir", "Phoenix", "LiveView"]
---

This post is a cleanup post. After Part 8 I spent some time testing all aspects of the application and decided to make a few small changes beofre moving to the next phase. I noticed that flash messages (the message that shows in the upper right corner) stays there until I dismiss it. I think it becomes anoying to have to do that repeatedly when adding multiple tasks so I decide to make it automatically fade away after 5 seconds. I could ask Claude to do this but thought it was a very easy task so I set about to do it myself. Here is what I came up with.

## Auto Dismiss Flash

The first think I needed to do was create a hook that could dismiss (in this case click) the flash. I created the file named `assets/js/hooks/auto-dismiss-flash.js` and this is what I came up with:

```javascript
export default {
  mounted() {
    this.timer = setTimeout(() => {
      // Simulate a click to trigger the existing phx-click handler
      // which properly clears the flash and hides the element
      this.el.click();
    }, 5000); // Wait 5 seconds before auto-dismissing
  },
  destroyed() {
    if (this.timer) {
      clearTimeout(this.timer);
    }
  },
};
```

The code is simple enough. I waits five seconds and then clicks the element. Next I needed to register the hook and I do this in my `app.js` file:

```javascript {linenos=inline hl_lines=[4, "7-9", 15]}
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import {hooks as colocatedHooks} from "phoenix-colocated/kanban"
import AutoDismissFlash from "./hooks/auto-dismiss-flash"
import topbar from "../vendor/topbar"

const MyHooks = {
  AutoDismissFlash,
}

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: {...colocatedHooks, ...MyHooks},
})
```

The final step was to modify the flash componet. In the `core_components.ex` file I modified the flash component to register my hook viw the `phx-hook` attribute:

```elixir {linenos=inline hl_lines=[8]}
  def flash(assigns) do
    assigns = assign_new(assigns, :id, fn -> "flash-#{assigns.kind}" end)

    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-hook="AutoDismissFlash"
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class="toast toast-top toast-end z-50"
      {@rest}
```

## Position of Edit Tasks

Again, while testing the task functionality I noticed that when you try to edit a task it opens up a form at the bottom of the page. If you have a lot of tasks the form can be below the bottom of the screen and you have to scroll to see it. I decided to let Claude perform this cleanup.

I asked Claude to move the add task form to a modal popup and to make things consistent I asked him to also move the form for colunns to a modal popup as well. Here's a picture of the result:

![Image of Edit Task modal](/img/kanban_edit_tasks.png)

## Adding a new task

The link to add a new task was originally placed at the bottom of the column. If you have a lot of tasks this link will scroll off of the page and will not be easy to see. I asked Tidewave to move it to a plus icon in the column header. This was an easy task for Tidewave and I'm happy with the results.

![Image of the add task icon](/img/kanban_add_task.png)

## And I have a name

My marketing manager (my wife) has decided that the application shall be named Stride. I asked Tidewave to update the home page to use the new application name. Once that was finished I asked Claude to present me with a list of possible logos. We have selected one but you'll have to wait to see it. Stay tuned!

## What's next?

With these small tweaks of the UI out of the way I think we are ready to complete the final two phases. I have also already dreamed up other features but I want to release the MVP prior to adding them.
