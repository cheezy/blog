---
date: '2025-11-30T15:21:44-05:00'
draft: false
title: 'Building a LiveView app using AI - Part 15'
tags: ["AI", "Elixir", "Phoenix", "LiveView"]
---

## Polish & Enhancement

It is finally time to get back and finish phase 7 of our plan. Here is what remains:

```markdown
#### Phase 7: Polish & Enhancement

- [ ] **UI/UX improvements**
  - [ ] Design beautiful board cards with Tailwind CSS
  - [ ] Add hover effects and transitions
  - [ ] Improve spacing and typography
  - [ ] Add loading states for async actions
  - [ ] Add empty states for boards without columns/tasks
- [ ] **Add notifications**
  - [ ] Use Phoenix LiveView flash messages for success/error
  - [ ] Style flash messages with Tailwind CSS
- [ ] **Add confirmation dialogs**
  - [ ] Add confirmation for board deletion
  - [ ] Add confirmation for column deletion (mention tasks will be deleted)
  - [ ] Add confirmation for task deletion
- [ ] **Error handling**
  - [ ] Add proper error messages for validation failures
  - [ ] Handle edge cases (deleting last column, etc.)
  - [ ] Add 404 pages for missing resources
- [ ] **Final Quality Checks**:
  - [ ] Run `mix test` and ensure all tests pass (510 tests, 0 failures)
  - [ ] Run `mix test --cover` and verify coverage meets threshold (94.60% coverage)
  - [ ] Run `mix credo --strict` and fix any issues (no issues found)
  - [ ] Run `mix sobelow --config` and fix any security issues (no issues found)
  - [ ] Run `mix precommit` to run all checks together (all checks passed)
```

### Starting with UI/UX improvements

We start by asking TideWave to complete the first two tasks under UI/UX improvements. Less than five minutes later we have some sparkle.

{{< youtube iooNURwm9zM >}}

### Finishing up the UI/UX improvements

Feeling confident with the first two task easily under our belt I decide to ask TideWave to take a larger step and complete all of the remaining tasks in the UI/UX improvements section.

{{< youtube SabuWMij59Q >}}

I noticed while making the video that some of the layout was not correct. There were icons that were not always visible. I made a mental note and continued with the plan.

### Taking the big leap

The first tasks in phase 7 have gone extremely well. I decided to ask TideWave to take a larger step and complete all of the remaining task from phase 7. This took nearly eight minutes but after the video I reviewed the changes and was glad that I take this step.

{{< youtube JiUQNr_-Ybc >}}

### Fixing the layout for Tasks

During the second video of part 15 I noticed that the layout of tasks was not correct. Some of the links were not fully visible. Before I say the UI/UX improvements are done I want to fix this issue.

{{< youtube GtzE8w59m_o >}}

I think the solution TideWave came up with is very elegant.

## What's next?

There are still many small tasks left to complete to get this application to a place where I can release it to the public. Stay tuned to see what remains.
