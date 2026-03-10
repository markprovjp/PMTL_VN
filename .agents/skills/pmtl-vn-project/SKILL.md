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
- Pages belong in `fe-pmtl/app`, reusable UI in `fe-pmtl/components`, feature data access in `fe-pmtl/lib/api`.
- Reuse components before inventing new abstractions.

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

## Cross-Layer Rules

- Frontend and backend must agree on field names and response shape.
- If a content type or custom endpoint changes, inspect both `BE_PMTL/src/api` and `fe-pmtl/lib/api`.
- For route work, inspect the page or route handler, its API helper, and the backing Strapi controller/service together.
- Prefer one clear cache strategy per feature.

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
