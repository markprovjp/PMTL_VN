---
name: pmtl-vn-project
description: Use for any coding task in PMTL_VN. Covers the Next.js 16 + React 19 frontend, the Strapi v5 backend, shared data contracts, shadcn-style UI composition, and the project's warm Buddhist editorial design language.
---

# PMTL_VN Project Skill

Use this skill before making code changes in this repository. It replaces the old constitution-style docs.

## Stack Snapshot

- Frontend app: `fe-pmtl`
- Backend app: `BE_PMTL`
- Frontend stack: Next.js 16 App Router, React 19, TypeScript, Tailwind CSS v3, `lucide-react`, `framer-motion`, `@tanstack/react-query`
- Backend stack: Strapi v5, TypeScript, zod, Jest, Meilisearch plugin
- UI system: local source components under `fe-pmtl/components/ui`
- shadcn config: `fe-pmtl/components.json`
  - aliases use `@/`
  - `ui` alias is `@/components/ui`
  - `rsc: true`
  - global CSS is `fe-pmtl/app/globals.css`

## What To Inspect First

1. Read the target route, page, component, API helper, or Strapi feature being changed.
2. Find the nearest existing implementation for the same pattern.
3. Reuse helpers and components before adding new abstractions.
4. If the task touches UI primitives or composition, also use the installed `shadcn` skill.

## Frontend Rules

- This is a Next.js App Router codebase.
- Prefer Server Components by default.
- Add `"use client"` only when state, effects, handlers, or browser APIs are needed.
- Respect the Strapi v5 flat response shape.
- Use `documentId` as the business identifier.
- Do not write new code around `attributes` or `data.attributes`.
- Shared frontend data types live in `fe-pmtl/types/strapi.ts`.
- Shared fetch helpers live in `fe-pmtl/lib/strapi.ts`, `fe-pmtl/lib/strapi-client.ts`, and `fe-pmtl/lib/api/`.
- Search URL parsing and serialization live in `fe-pmtl/lib/search/search-params.ts`; do not hand-roll query parsing in each component.
- Recent search persistence lives in `fe-pmtl/lib/search/recent-searches.ts`; do not scatter raw localStorage keys.
- Pages belong in `fe-pmtl/app`, reusable UI in `fe-pmtl/components`, feature data access in `fe-pmtl/lib/api`.
- Reuse components before inventing new abstractions.
- When search state changes, keep `q`, `cat`, `tags`, `time`, `sort`, and `page` in the URL so back/forward navigation and share links keep working.
- Search pages should prefetch initial results on the server when possible, then enhance on the client for debounced updates and voice search.
- For search/filter pages that are not intended to rank individually, prefer `robots: noindex, follow` while keeping the base landing page indexable.
- When improving PMTL study UX, prefer deepening existing routes such as `fe-pmtl/app/niem-kinh/page.tsx` and `fe-pmtl/app/lunar-calendar/page.tsx` before adding a new top-level navigation item.
- Keep the main header compact. Prefer grouping top-level navigation into the four product pillars instead of exposing every destination as a separate desktop nav link:
  - daily practice
  - content library
  - community
  - events and organization
- Do not create new top-level navigation items unless the user explicitly asks for a new section in the header.

## Design Rules

The frontend already shows a clear visual language in `fe-pmtl/app/page.tsx`, `fe-pmtl/app/videos/page.tsx`, and `fe-pmtl/app/globals.css`.

- Keep the site warm, calm, editorial, and premium.
- Favor cream, sand, brown, and gold tokens already defined in `app/globals.css`.
- Use serif-forward headings and clean body text.
- Prefer soft borders, restrained depth, rounded surfaces, and generous spacing.
- Motion should be subtle: fade, rise, gentle scale only.
- Avoid startup colors, loud gradients, overly bright CTA colors, and generic dashboard UI.
- When the user asks for an Ant Design-like tone, shift to a more disciplined UI: reduced radii (`rounded-md`/`rounded-lg`), flatter panels, stronger borders, cleaner typography, and list-first information density instead of decorative cards.

## Overlay And Popup Rules

- Treat every popup, dropdown, sheet, menu, or modal as an overlay that must not allow background page scroll while open.
- Reuse the shared overlay lock pattern from `fe-pmtl/components/shares/SharesClient.tsx`: lock `document.body.style.overflow = 'hidden'` on open and restore it on cleanup.
- Put scrolling on an inner container, not the page root.
- Scrollable overlay bodies should use `min-h-0 overflow-y-auto overscroll-contain`, add `data-lenis-prevent`, and keep `style={{ WebkitOverflowScrolling: 'touch' }}` for mobile momentum scrolling.
- If an overlay contains a long list, prefer `ScrollArea` or an inner `overflow-y-auto` region over allowing the page behind it to move.

## shadcn Rules

This repo already has a shadcn-style setup via `fe-pmtl/components.json`.

- Use `npx shadcn@latest ...` for CLI commands because the project uses npm.
- Check existing UI primitives in `fe-pmtl/components/ui` before adding new ones.
- Use semantic tokens such as `bg-background`, `text-muted-foreground`, `border-border`, not raw ad hoc colors.
- Prefer `gap-*` over `space-*`.
- Prefer `size-*` for square dimensions.
- Use `cn()` for conditional classes.
- Keep using the local `Button`, `Card`, `Dialog`, `Badge`, `Tabs`, and other source components instead of custom styled wrappers when a primitive already exists.
- If adding or updating a shadcn component, inspect the generated files after the CLI runs and fix composition or import issues immediately.

## Backend Rules

- This is a Strapi v5 backend.
- Use `strapi.documents(...)` for normal document access.
- Avoid `entityService` in new code.
- Public reads should explicitly set published status when appropriate.
- Use explicit `fields` and `populate`; avoid broad wildcard populate.
- Validate public write inputs before business logic.
- Keep controllers thin and move reusable logic to services or utils.
- Prefer `documentId` in FE-facing routes and contracts, not numeric `id`.
- Meilisearch index settings and search document behavior must stay deterministic. Keep searchable, filterable, sortable, and displayed fields explicit.
- Search document mapping for blog posts lives in `BE_PMTL/src/search/blog-post-search.ts`. Treat it as the single source of truth for Meilisearch field shape, normalization, ranking settings, and indexable metadata.
- When changing blog search fields, update the transformer, plugin config in `BE_PMTL/config/plugins.ts`, and any frontend `attributesToRetrieve` contract in the same turn.
- Reindex operations should go through `api::blog-post.search-index`, which wraps the Meilisearch plugin services with logging and retry. Do not create ad hoc indexing code in controllers or lifecycles.
- Category or tag changes must trigger blog-post reindexing because blog search documents denormalize category/tag names and slugs.
- Operational rebuild commands are `npm run reindex:blog-post` and `npm run reindex:all`. Prefer them over manual Meilisearch console edits.
- Treat `BE_PMTL/config/plugins.ts` and backend env as the source of truth for Meilisearch credentials. If env-based config is present, do not rely on the Strapi plugin settings page as the canonical place to store credentials.
- Key split:
  - `MEILISEARCH_API_KEY` in backend: must be the Meilisearch `master` key or another admin-capable key that can create indexes and update settings
  - `MEILISEARCH_SEARCH_KEY` in frontend: search-only key for queries
  - `MEILISEARCH_MASTER_KEY` in frontend: acceptable only for local server-side debugging; never expose it to a browser client
- If the Meilisearch Docker container or data volume is recreated, generated default `search/admin` keys can change. Re-read `GET /keys` with the master key and update local frontend search key if you rely on a generated key.
- If Strapi admin shows `The provided API key is invalid` on the Meilisearch plugin page while env-based indexing works, restart Strapi first and trust the config-file credentials over the plugin form.

## Cross-Layer Rules

- Frontend and backend must agree on field names and response shape.
- If a content type or custom endpoint changes, inspect both `BE_PMTL/src/api` and `fe-pmtl/lib/api`.
- For route work, inspect the page or route handler, its API helper, and the backing Strapi controller/service together.
- Prefer one clear cache strategy per feature.
- Keep search sort/filter names aligned across `GetPostsOptions`, `app/actions/search.ts`, `fe-pmtl/lib/meilisearch.ts`, and `fe-pmtl/lib/search/search-params.ts`.
- Cache invalidation targets should be centralized. Revalidation mapping belongs in `fe-pmtl/lib/revalidate.ts`, not duplicated across handlers.
- Next cache tags must match the tags used in `fe-pmtl/lib/api/*`; if you change a tag in one place, update the revalidation map in the same turn.

## Search Architecture Rules

- Primary search page is `fe-pmtl/app/search/page.tsx` + `fe-pmtl/app/search/SearchClient.tsx`.
- Use Meilisearch for instant retrieval and Strapi as fallback only.
- For backend search quality, prioritize stable indexing and clean ranking over analytics-heavy user tracking. This site targets simple, accurate retrieval for content readers, including older users.
- Search params are:
  - `q`: query text
  - `cat`: category slug
  - `tags`: comma-separated tag slugs
  - `time`: `all | week | month`
  - `sort`: `relevance | newest | oldest | most-viewed`
  - `page`: 1-based page number
- Debounce text input before fetching.
- Reset pagination back to page 1 whenever query, category, tags, time, or sort changes.
- Track both successful searches and zero-result searches.
- Preserve recent searches client-side and surface them only as a UX enhancement, never as a source of truth.

## Revalidation Rules

- The Strapi webhook endpoint is `fe-pmtl/app/api/revalidate/route.ts`.
- Revalidation should invalidate both tags and important paths when content changes.
- Prefer mapping by `uid` first and fall back to `model` only when necessary.
- Blog content updates should clear `/blog`, `/search`, `/archive`, and the article detail path when a slug exists.
- Revalidation is for server caches and ISR. Client caches like TanStack Query should still invalidate themselves per feature.

## PMTL Feature Areas

Common domains in this repo:

- blog and categories
- guestbook
- community posts and comments
- hub pages and dynamic blocks
- chanting / practice logs
- events and lunar calendar
- downloads / library
- push notifications
- search

## PMTL UX Direction

- Treat `lunar-calendar` as an actionable study surface, not just a date lookup page. Prefer showing:
  - today's special days
  - recommended related reading
  - direct CTA into `niem-kinh`
  - gentle reminder/settings links instead of noisy prompts
- Notification UX should stay selective and calm. Reuse existing push subscription settings, and phrase notification groups so older users can immediately understand them:
  - daily practice
  - content library
  - events and lunar reminders
  - community replies
- `shares` should emphasize moderation and respectful discussion over social-growth mechanics. Surface report tools and community-safety guidance before adding reactions or gamification.
- `events` pages should support the full event lifecycle using existing data where possible:
  - clear online/offline attendance cue
  - direct join/watch link
  - save-to-calendar link
  - location/map link
  - post-event resources if available

## Execution Checklist

Before editing:

1. Identify whether the change is FE, BE, or both.
2. Read the closest existing implementation for the same feature.
3. Confirm the data contract before changing field usage.
4. Confirm whether an existing `components/ui` primitive already solves the UI need.

Before finishing:

1. Check for type or contract drift.
2. Check that server/client boundaries still make sense.
3. Check that any UI-facing change still matches the repo's current visual language and token system.
4. Mention any unresolved debt or risks clearly.
