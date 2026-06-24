# Contributing to FriendChise

Thanks for helping improve FriendChise.

If this project helps you, please star the repo, follow my work, and share it.

## 1. Start with an issue

Open a GitHub issue before a PR if the change is larger than a small bug fix. That keeps the work focused and avoids duplicate effort.

If you are looking for ideas, see [Ideas for Contributing](https://friendchise.app/doc/contributing/ideas-for-contribution).

## 2. Follow the exact setup steps

If you want the shorter overview, see [Quick Start](https://friendchise.app/doc/development/quick-start). If you are new, follow the steps below exactly; that guide shows the exact local path, including Docker commands for macOS/Linux and Windows.

### 2.1 Fork and clone the repo

```bash
git clone https://github.com/<your-username>/FriendChise.git
cd FriendChise
```

If you already have the repo open, just use the folder you already cloned.

### 2.2 Start a local Postgres database

Use Docker if you want the quickest setup. The same Postgres container image works on macOS, Linux, and Windows through Docker Desktop:

```bash
docker run --name friendchise-postgres \
	-e POSTGRES_USER=postgres \
	-e POSTGRES_PASSWORD=postgres \
	-e POSTGRES_DB=friendchise \
	-p 5432:5432 \
	-d postgres:16
```

If you are on Windows PowerShell or Windows Terminal, use this version:

```powershell
docker run --name friendchise-postgres `
  -e POSTGRES_USER=postgres `
  -e POSTGRES_PASSWORD=postgres `
  -e POSTGRES_DB=friendchise `
  -p 5432:5432 `
  -d postgres:16
```

If you already have Postgres installed locally, use that instead. The important part is that `DATABASE_URL` points to your local database, not Supabase.

### 2.3 Create `.env.local`

Create `.env.local` in the repo root with these values:

```env
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/friendchise
AUTH_SECRET=your-generated-secret-here
AUTH_URL=http://localhost:3000
```

If you do not have an auth secret yet, generate one:

```bash
npx auth secret
```

If you are working against a shared Supabase-backed dev environment, keep the same env vars in `.env.local` and provision that database separately. If you need namespaced seed data, also set `SEED_NAMESPACE`.

### 2.4 Install, migrate, generate, and seed

Run these commands in order:

```bash
pnpm install
pnpm prisma migrate dev
pnpm prisma generate
pnpm seed
```

If you already restored a snapshot that contains data, `pnpm seed` is still safe to run and will namespace the seed data for your local environment.

If the schema is out of sync, rerun `pnpm prisma migrate dev`.

### 2.5 Start the app

```bash
pnpm dev
```

Then open [localhost:3000/signin](http://localhost:3000/signin) and use either:

- the seeded dev user picker
- the demo button for an isolated demo org

No app password is required. The data you edit goes into your local Postgres database only.

## 3. Working rules

- Keep `.env.local` private. Never commit it.
- Keep production secrets out of the repo.
- Do not point seed commands at production data.
- Use `SEED_NAMESPACE=random` for disposable local runs.
- Use `pnpm seed:clean` if you need to remove only your namespaced seed data.
- Keep the Supabase storage vars set before running the app locally if you need logos, images, or uploads.
- If you change Prisma models, create a migration with `pnpm prisma migrate dev --name <migration-name>`.

## 4. Testing

- `pnpm test` runs the Vitest suite.
- `pnpm test:integration` runs integration tests.
- `pnpm test:e2e` runs Playwright.
- `pnpm lint` runs ESLint.
- `pnpm exec tsc --noEmit` runs a typecheck.

E2E and integration tests depend on seeded data, so keep new test data namespaced or disposable.

## 5. Pull requests

- Keep PRs focused on one change when possible.
- Include tests for behavior changes.
- Update docs when setup or contributor flow changes.
- Avoid unrelated refactors in the same PR.
