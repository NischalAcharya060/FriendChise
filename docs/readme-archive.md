---

title: README Archive

description: Full historical README snapshot from commit ec0a2b3

order: 18.5

---

## Franchise System

A parent org can spawn franchisee orgs using a one-time invite token flow:

1. Franchisor generates a token via the Franchisee page — stores a `FranchiseToken` with `invitedEmail` and `expiresAt`.
2. The invitee visits `/orgs/new` and submits the token (via `joinFranchise` server action).
3. On join, all roles, tasks, and timetable settings are cloned from the parent into the new child org (`lib/services/franchise.ts`).
4. The joining user is assigned as the franchisee org's Owner.
5. The parent org owner can view all child orgs and pending tokens, extend/revoke tokens, and remove franchisees.

## UI Notes

- **Org color accents** — both the hub page (`/`) org cards and the org overview page (`/orgs/[orgId]`) derive a deterministic accent color from the org name via a seeded palette (`orgColor(name)` hashes the character codes mod 9). The hub card uses the color for the initials badge background and a top color bar; the overview page renders a `h-1.5` color bar at the top of the card. No extra DB field is required.
- **Sidebar architecture** — Three context layers work together:
  - `MobileSidebarContext` — boolean open/close state for the global app sidebar overlay on mobile.
  - `AppSidebar` — desktop hover-expand strip (`w-12` → `w-52`); mobile fixed overlay. Uses `SidebarNavItem variant="app"`.
- **PageSidebarContext** — slot-based system for page-level sidebars. `layout.tsx` calls `<RegisterPageSidebar>` to mount a persistent shell; pages call `<RegisterPageSidebarSubContent>` to swap only the inner filters/actions without unmounting the shell (eliminates sidebar flicker on navigation). Open/closed state persisted in `localStorage`.
- **Shell + sub-content pattern** — Tasks and Members each have a `*-sidebar-shell.tsx` (client, registered in `layout.tsx`) that renders the panel title, nav tabs, and a `usePageSidebarSubContent()` slot. The per-page sidebar content (`*-sidebar-content.tsx`) is registered via `RegisterPageSidebarSubContent` in `page.tsx` and fills that slot.
- **ActionSidebar for member actions** — "Invite Member" and "Add Bot" in the members sidebar open an `ActionSidebarSlot` panel on desktop (button highlights blue while active) and a `Dialog` popup on mobile. The dialog is mounted in the same component tree as the button so it is not unmounted when the mobile sidebar overlay closes.
- **Unified height system** — `h-12` (48px) is used consistently across: navbar inner row, toolbar, sidebar nav items, page sidebar title rows, and open/close buttons. This ensures every horizontal element lines up on a shared baseline.
- **Sidebar nav** — Active state uses prefix matching; Overview uses exact matching. The nav contains: Overview, Timetable, Tasks, Tools, Members.
- **Colors required** — Both `Role.color` and `Task.color` are non-nullable in the schema and enforced by Zod validators (`/^#[0-9a-fA-F]{6}$/`). Create and edit forms render a native `<input type="color">` with a hex label. The color is submitted as a hidden `<input name="color">` so it flows through `FormData`.
- **Task form color picker** — Lazy `useState(() => dv?.color ?? randomHex())` initializer prevents React purity errors on random defaults.
- **Member pages** — Split into view (`[memberId]/page.tsx`) and edit (`[memberId]/edit/page.tsx`) routes. Both share `MemberForm`. The toolbar on the detail page provides Edit and an Actions ▼ dropdown (Restrict / Unrestrict / Delete with confirm dialogs).
- **Role picker** — Searchable text input with a dropdown. Selecting a role auto-adds it; no `+` button. The owner role is never shown in the picker (filtered in the edit page query and enforced in the service layer).
- **Owner role guard** — Three layers: (1) DB query filters it from `allRoles` on the edit page, (2) `updateMembership` rejects any `roleId` whose key is `"owner"`, (3) the new-member query uses `NOT: { key: "owner" }`.
- **Clicking tasks in timetable** — In Calendar view the task title inside each block is a `<Link>` to the task detail page. In Simple (table) view the task name cell is a `<Link>`; clicking elsewhere in the row still opens the edit popup.
- **Timetable simple view** — Replaced the `<table>` layout with flex rows. Each row has a colored accent bar (`w-1 self-stretch rounded-full`, color from `inst.taskColor`), a monospace time column, the task name (linked, truncated, line-through when done/skipped), assignee initials chips (max 3 + "+N" overflow, hidden on mobile), a compact duration label (`formatDuration` — e.g. `"45m"`, `"1h 30m"`), and a status badge pill. A small status dot replaces the badge on mobile (`sm:hidden`). The edit button fades out on hover focus for desktop.
- **Mobile page sidebar X close button** — The mobile overlay for the page sidebar (`PageSidebarSlot`) includes an `absolute` positioned X button (top-right corner) to close the panel. It is positioned in the outer `fixed` container (not the scrollable inner div) so it stays visible while the user scrolls the sidebar content.
- **Form validation** — server-action errors rendered inline with `aria-invalid`/`aria-describedby` plus a Sonner toast summary.
- **Timetable** — Calendar and Simple mode toggle, week navigation via `?week=` and `?mode=` params. Calendar view uses absolute positioning for task blocks; overlapping tasks get side-by-side columns. Status colours: gray = TODO, amber = IN_PROGRESS, green = DONE, red = SKIPPED.
- **Fixed toolbar / scroll containment** — `h-dvh` on `SidebarProvider` + `overflow-hidden` on `SidebarInset` keep the body from scrolling so toolbars can stay visually fixed. The `<main>` element is the actual scroll container. Child pages that need a pinned toolbar use `flex flex-col h-full` on their root, a static `<Toolbar>` at the top, and a `flex-1 overflow-auto` div below it for the scrollable list. Negative horizontal margins on the scrollable div cancel `<main>`'s padding so the list extends edge-to-edge.
- **Template editor** — Two view modes (Calendar / Simple) toggled via a segmented control and persisted in `localStorage`. **Calendar** mode shows a drag-and-drop time grid; tasks are dragged from a sidebar panel (desktop) or a bottom sheet (mobile); adaptive column count based on container width via `ResizeObserver`. **Simple** mode shows a day-by-day table sorted by start time; clicking a row opens an inline popup to adjust time and assignees. Both modes share day/week navigation and +/− cycle-length controls.
- **Roster tool** — A scrollable week-by-week shift assignment grid. Days (Mon–Sun) are rows; each week column represents one calendar week identified by its Monday `weekStart` date. Clicking a cell opens a dialog to assign org members and optional shift start/end times. Day columns carry a configurable `recommendedSize` badge and optional open/close time range. Week navigation shifts the visible window by one week.
- **Roster templates** — Reusable multi-week staffing patterns. A template has a `cycleWeeks` (1–12); the editor shows a 7-row × cycleWeeks-column grid. Clicking a cell opens an `ActionSidebar` panel to assign members and shift times. The +/− stepper adds/removes week columns — removing a column is blocked when entries exist in the last week. Applying a template (via the Apply Template panel on the live roster page) stamps the pattern starting from a selected Monday, repeating it `N` times; a conflict check prevents overwriting existing entries unless the force checkbox is ticked.
- **Template list management** — MANAGE_TASKS holders see a ··· dropdown on each template (card and list view) with Rename (inline Dialog), Duplicate ("Copy of …" with collision suffix), and Delete (AlertDialog confirmation). Mutations call `revalidatePath` so the list refreshes without a full reload.
- **Task descriptions** — Task descriptions are stored as GFM markdown and rendered via `react-markdown` + `remark-gfm` on the task detail page. The task list (card and table views) strips markdown via a lightweight `stripMd()` helper for plain-text previews.
- **Task table** — `TaskTable` client component: search, sort (name/duration/people), role filter, row `···` menu (Edit / Duplicate / Delete with confirm). Clicking the row navigates to the task detail page (keyboard accessible — `role="button"` + `tabIndex=0`). In "All" and "Shared" modes each task row shows an ownership badge: **Mine** (org owns it), **Franchise** (inherited from parent), or **Available** (franchise global, not yet added).
- **Roles page** — System roles show a `system` badge and cannot be deleted; Owner also cannot be edited. "+ Create Role" in the page sidebar opens an `ActionSidebar` panel with the full role form (name, color, permissions, task eligibility). The row `···` menu's "Edit" item opens the same form pre-filled in the action sidebar — no standalone `/new` or `/[roleId]/edit` pages. On success the panel closes and `router.refresh()` updates the table in place.
- **Role security** — `createRole` and `updateRole` validate `taskIds` against tasks scoped to `orgId` inside a transaction. Cross-tenant IDs abort the transaction with an `INVALID` error.

## Timetable

### Permission gating

| Feature                                               | Required permission |
| ----------------------------------------------------- | ------------------- |
| View timetable                                        | `VIEW_TIMETABLE`    |
| Drag entries, add from task sidebar, Actions dropdown | `MANAGE_TIMETABLE`  |
| Update a task's status via `···` popup                | any org member      |
| Full edit (time, assignees, delete) via `···` popup   | `MANAGE_TIMETABLE`  |

### Role filter

A **Filter** dropdown in the toolbar lets users narrow the timetable to tasks whose `TaskEligibility` includes a selected role. The filter is stored in the URL (`?roleId=`) so it persists across week navigation.

### Skip display

Any `TODO` entry whose local date is before today (org timezone) is displayed as `SKIPPED` in both Calendar and Simple views without mutating the database.

### `···` popup (CalendarEditPopup)

Every timetable block has a `···` menu button. Clicking it opens a Dialog:

- **All members** — can update the task's status.
- **MANAGE_TIMETABLE holders** — additionally see a time input, an assignee list, and a Delete button.

### UTC storage model

Live `TimetableEntry` rows are stored in UTC (`date` = UTC midnight, `startTimeMin`/`endTimeMin` = UTC minutes from that midnight). The server page converts to the org's local timezone before passing instances to the client. Template entries remain in local wall-clock minutes and are converted on `applyTemplate`.

`endTimeMin` is capped at 1440 (= 24:00 midnight) to support 24/7 schedules.

## Seed Data

### Dev seed (`pnpm seed` / `pnpm seed:dev`)

Creates 3 sample organizations each with realistic data:

| Org            | Owner  | Members                       | Custom roles                  | Tasks |
| -------------- | ------ | ----------------------------- | ----------------------------- | ----- |
| Donut Shop A   | Ivan   | Jordan, Casey, Riley, Alex    | Fryer Operator, Counter Staff | 6     |
| Coffee House B | Ivan   | Riley, Morgan, Jordan, Taylor | Head Barista, Kitchen Hand    | 6     |
| Bakery C       | Jordan | Casey, Riley, Morgan, Sam     | Head Baker, Pastry Chef       | 6     |

All orgs also have Owner and Default Member system roles. Members can hold multiple roles. Each org has a timetable template and ~14 historical timetable entries plus today and tomorrow entries.

Users: Ivan, Jordan, Casey, Riley, Morgan, Alex, Taylor, Sam.

### Walker's Doughnuts one-off seed

`scripts/seed-walkers-doughnuts.ts` is a standalone seed for the Walker's Doughnuts org (60 tasks — frappes, hot drinks, food prep, cleaning). Task descriptions are written in GFM markdown (ingredients, method steps, notes).

```bash
# First run — creates the org from scratch
npx tsx scripts/seed-walkers-doughnuts.ts

# Re-run (safe) — upserts roles/permissions/membership and replaces all tasks
npx tsx scripts/seed-walkers-doughnuts.ts

# Full reset — deletes the org and all related data, then recreates from scratch
npx tsx scripts/seed-walkers-doughnuts.ts --reset
```

The script reads `DATABASE_URL` from `.env` (then `.env.local` override). The owner email defaults to `E2E_TEST_USER_EMAIL` or `ivan@example.test`.

## Testing

```bash
# Unit tests (Vitest)
pnpm test
pnpm test:watch
pnpm test:coverage

# Scoped unit test runs
pnpm test:services
pnpm test:validators
pnpm test:actions
pnpm test:api

# Integration tests (Vitest — hits the real dev database; reseeds before each run)
pnpm test:integration

# E2E tests (Playwright — requires a running dev server and seeded DB)
pnpm test:e2e
```

Integration tests live in `__tests__/integration/` and run sequentially against the live dev database (`DATABASE_URL`). They require `INTEGRATION_TEST_USER_EMAIL` (or fall back to the seed user). The global setup reseeds the dev database before each run to guarantee a clean baseline.

| Test file                                                      | Service covered        | Tests |
| -------------------------------------------------------------- | ---------------------- | ----- |
| `__tests__/integration/lib/services/orgs.test.ts`              | `orgs.ts`              | 2     |
| `__tests__/integration/lib/services/memberships.test.ts`       | `memberships.ts`       | 6     |
| `__tests__/integration/lib/services/roles.test.ts`             | `roles.ts`             | 7     |
| `__tests__/integration/lib/services/tasks.test.ts`             | `tasks.ts`             | 8     |
| `__tests__/integration/lib/services/timetable-entries.test.ts` | `timetable-entries.ts` | 14    |
| `__tests__/integration/lib/services/assignees.test.ts`         | `assignees.ts`         | 8     |
| `__tests__/integration/lib/services/templates.test.ts`         | `templates.ts`         | 18    |
| `__tests__/integration/lib/services/invites.test.ts`           | `invites.ts`           | 11    |
| `__tests__/integration/lib/services/bots.test.ts`              | `bots.ts`              | 13    |
| `__tests__/integration/lib/services/audit-log.test.ts`         | `audit-log.ts`         | 6     |

CI runs on every push/PR to `master` via GitHub Actions (`.github/workflows/ci.yml`):

1. **check** job — type-check, lint, unit tests (no DB required)
2. **e2e** job (needs `check`) — spins up a Postgres 16 service container, runs migrations + dev seed, then runs Playwright against the Next.js dev server

Playwright test state is saved to `playwright/.auth/` (gitignored). The `global.setup.ts` skips reseeding when `CI=true` (already seeded by the workflow).

## Docs

The `docs/` folder contains long-form documentation that doesn't belong in this README:

| Path                                         | Description                                              |
| -------------------------------------------- | -------------------------------------------------------- |
| `docs/v1/UAT.md`                             | User Acceptance Testing checklist for the v1 feature set |
| `docs/v1/v1-smoke-test/smoke-test-{1..4}.md` | Manual smoke test reports run against production         |

## Observability

Error monitoring and performance tracking is handled by **Sentry** via `@sentry/nextjs`.

- **Error monitoring** — unhandled exceptions on server, edge, and client are captured with full stack traces and request context
- **Performance tracing** — distributed traces across server actions, API routes, and the client; `tracesSampleRate: 1` in development (lower this in production)
- **Session Replay** — video-like reproduction of user sessions leading up to an error (10% of sessions sampled; 100% on error)
- **Logs** — server-side logs forwarded to Sentry via `enableLogs: true`
- **Source maps** — uploaded at build time via `withSentryConfig`; requires `SENTRY_AUTH_TOKEN` in Vercel env vars
- **Global error boundary** — `app/global-error.tsx` catches top-level React errors and reports them before rendering the fallback UI

Sentry config files:

| File                        | Purpose                                                  |
| --------------------------- | -------------------------------------------------------- |
| `sentry.server.config.ts`   | Server-side init (tracing, logs, PII)                    |
| `sentry.edge.config.ts`     | Edge runtime init                                        |
| `instrumentation.ts`        | Next.js instrumentation hook (wires server/edge configs) |
| `instrumentation-client.ts` | Client-side init (tracing, replay, logs)                 |

Required env var for source map uploads:

```env
SENTRY_AUTH_TOKEN=   # Required whenever source maps are uploaded at build time (e.g., in CI/CD or on hosting platforms such as Vercel)
                     # Source map upload is performed by withSentryConfig during build
```

## Status

Work in progress. Fully implemented: service layer (all 10 services with 93 integration tests), REST API, auth, member management (list, view, edit, restrict, delete, convert-to-bot), task management (list, view, create, edit with color; ownership badges; card keyboard navigation), timetable view (calendar + simple, task links; simple view redesigned as flex rows with color accent bars, assignee chips, duration labels, status badge pills, and mobile status dots), timetable templates (create, rename, duplicate, delete, calendar/simple editor, cycle-length controls, apply to timetable), org settings, role management (list, create, edit, delete, task eligibility, color — all via action sidebar panels; no standalone create/edit pages), franchise management, required colors on tasks and roles, async breadcrumbs with name resolution, fixed-toolbar scroll containment on members and tasks pages, audit log (DB table + Zod-validated service layer, all significant mutations instrumented — UI pending), tasks/members/roles page sidebar redesign (shell + sub-content pattern matching timetable architecture, URL-param-driven filters, ActionSidebar panels for Invite Member + Add Bot + Create Role + Edit Role with mobile Dialog fallback), task comments (threaded comments with replies, voting, pinning, soft delete, inline edit — franchise-scoped permission model), mobile page sidebar X close button, org color accent bars (hub + overview), task filter/sort/view preferences persisted to both localStorage and cookies (server-side redirect on first load, no client round-trip), roster tool permissions corrected to MANAGE_MEMBERS.

Not yet started: schedule generation (automatic cycle-based rotation), worker "Today" checklist, completion stats, timetable/notification settings pages, real-time notification refresh, audit log UI (activity feed page).

Implemented: acceptance notification back to inviter (see `notifyInviteAccepted` in `lib/services/invites.ts`).
