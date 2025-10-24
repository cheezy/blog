---
date: '2025-10-18T15:13:21-04:00'
draft: false
title: 'Building a LiveView app using AI - Part 5'
tags: ["AI", "Elixir", "Phoenix", "LiveView"]
---

## Follow up for the French Translations

After the last recording I started manually looking at the translatons. I quickly noticed that the authentication pages were not translated. This is why I take very small steps and verify after each one. LLMs cannot read your mind and they do not always do what you think they should. Small steps allow us to make adjustments or revert when it does the wrong thing. I asked Claude to translate the authentication pages and it did.

I also noticed that the language selector was not working on the authentication pages. I asked Claude to investigate and it reported that the main page is a phoenix page that has a phoenix controller but the authentication page was a liveview so the original fix didn't work. I asked Claude to fix that issue and it did.

## There is someting not quite right about the design

There is one thing about the design that bother me. It is not the actual design but instead it is the way that Claude decided to implement the design. Claude placed all of the tailwind css directly in the template files. This made reading the templates difficult. I would typically create classes in the `app.css` file and then use them in the templates. I asked **Tidewave** to do this.

Why did I ask Tidewave and not Claude? In my opinion, Tidewave has more insight into how some things should work in Phoenix / LiveView than Claude. When I asked Tidewave to do this it informed me that starting with Tailwind 4 the `@apply` directive is no longer supported. Instead, Tidewave suggested creating function components and hiding the tailwind details there. This ended up being a better solution. Here is an example of a portion of a template before and after this change.

Before:

```html
<h1 class="text-4xl sm:text-5xl lg:text-6xl font-bold text-gray-900 leading-tight">
  {gettext("Organize Your Work")}
  <span class="block text-transparent bg-clip-text bg-gradient-to-r from-blue-600 to-blue-800">
    {gettext("With Kanban Boards")}
  </span>
</h1>
```

After:

```html
<.hero_title>
  {gettext("Organize Your Work")}
  <.hero_title_gradient>
    {gettext("With Kanban Boards")}
  </.hero_title_gradient>
</.hero_title>
```

This is a huge improvement. I know feel like I can understand the changes to the template better and can also make my own changes.

## Deployment pipeline

Oh - and I added a deployment pipeline to deploy all code to an environment I call _review_ each time I push to main. I'll share the url so you can go check it out when I have a little more of the application in place.

## On to the next step

Looking at the remaining plan there is something that bothers me. Phase 3 is `Database Schema & Context Setup`. This is creating the schema and context for the entirity of the application. The next four Phases are focused on creating the UI. I know this is what I asked Claude to do when I was making the plan but now that I think about it I am having doubts. I am not comfortable with this approach because we are making a lot of assumptions up front. This is not the way I would implement the changes if I were doing the coding. I like to work in small vertical slices with a running app each step.

### A change of plans

I asked Claude to restructure the plan so we are incrementally creating the schema and context along with the LiveView. This is the updated Phase 3:

```markdown
#### Phase 3: Board Management (Schema, Context & UI)

- [ ] **Generate Board schema and migration**
  - [ ] Create migration: `mix ecto.gen.migration create_boards`
  - [ ] Define `boards` table with fields: name (string), description (text), user_id (references :users)
  - [ ] Add foreign key constraint with `on_delete: :delete_all`
  - [ ] Add index on user_id
  - [ ] Run migration: `mix ecto.migrate`
- [ ] **Create Board schema**
  - [ ] Create `lib/kanban/boards/board.ex` with Ecto schema
  - [ ] Define fields: `:name`, `:description`
  - [ ] Add `belongs_to :user, Kanban.Accounts.User`
  - [ ] Create changeset function with validations
- [ ] **Create Boards context**
  - [ ] Create `lib/kanban/boards.ex` context with:
    - [ ] `list_boards(user)` - list all boards for a user
    - [ ] `get_board!(id, user)` - get board with authorization check
    - [ ] `create_board(user, attrs)` - create board for user
    - [ ] `update_board(board, attrs)` - update board
    - [ ] `delete_board(board)` - delete board
- [ ] **Write Board context tests**
  - [ ] Create `test/kanban/boards_test.exs`:
    - [ ] Test all CRUD operations
    - [ ] Test user scoping (users can't access other users' boards)
    - [ ] Test validations
- [ ] **Create board list LiveView**
  - [ ] Create `lib/kanban_web/live/board_live/index.ex`
  - [ ] Implement `mount/3` to load user's boards
  - [ ] Use streams for board collection
  - [ ] Create template with board cards
  - [ ] Add "New Board" button
  - [ ] Add edit/delete actions for each board
- [ ] **Create board show LiveView**
  - [ ] Create `lib/kanban_web/live/board_live/show.ex`
  - [ ] Load board with authorization check
  - [ ] Display board name and description
  - [ ] Prepare structure for columns (empty state for now)
- [ ] **Create board form component**
  - [ ] Create `lib/kanban_web/live/board_live/form_component.ex`
  - [ ] Build form for creating/editing boards
  - [ ] Add validation and error display
  - [ ] Handle form submission
- [ ] **Add routes**
  - [ ] Add routes in `lib/kanban_web/router.ex` under authenticated scope
  - [ ] `live "/boards", BoardLive.Index, :index`
  - [ ] `live "/boards/new", BoardLive.Index, :new`
  - [ ] `live "/boards/:id/edit", BoardLive.Index, :edit`
  - [ ] `live "/boards/:id", BoardLive.Show, :show`
- [ ] **Write Board LiveView tests**
  - [ ] Create `test/kanban_web/live/board_live_test.exs`
  - [ ] Test board list rendering
  - [ ] Test creating new board
  - [ ] Test editing board
  - [ ] Test deleting board
  - [ ] Test authorization (can't access other users' boards)
- [ ] **Quality Checks (Phase 3)**:
  - [ ] Run `mix test` and ensure all tests pass
  - [ ] Run `mix test --cover` and verify coverage meets threshold
  - [ ] Run `mix credo --strict` and fix any issues
  - [ ] Run `mix sobelow --config` and fix any security issues
```

I am happy with this. These are small steps that are verifiable. This is in line with the small steps I would be taking.

## Let's start to implement phase 3

This video is short and sweet. We ask Claude to start on phase 3 and claude creates the database table for the boards, the schema to represent the data in the table, and the context to perform the CRUD actions. Finally it tests everything to make sure it all works.

{{< youtube DSSFUCyfBrU >}}
