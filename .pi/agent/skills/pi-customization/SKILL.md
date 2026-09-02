---
name: pi-customization
description: Helps decide how to extend pi (skill, prompt template, extension, or pi package) for a new workflow, and drafts simple prompt templates or skills inline. Use when the user wants to customize/extend pi itself, automate a recurring prompt/workflow, or asks "should this be a skill or a command?"
---

# Pi Customization

Entry point / router for "I want pi to do X automatically" requests. Decides
the right mechanism for a given need and, for simple cases, drafts the
artifact directly rather than deferring to a separate builder skill.

## Decision Tree

- **Just need a canned/expandable prompt**, explicitly invoked via `/name`,
  no scripts or reference docs needed → **prompt template**. Draft it inline
  (see format below).
- **Needs auto-discovery** (the model decides when to use it, without being
  asked) and/or needs bundled scripts, reference docs, or a structured
  multi-step workflow → **skill**. Draft it inline for simple cases (see
  format below), following the full rules in `skills.md` (see Documentation
  Reference below) for anything non-trivial (naming validation, frontmatter
  fields, directory layout).
- **Needs actual programmatic behavior** — custom tools, event hooks, custom
  UI, not just a better prompt → **extension**. Read `extensions.md` (see
  Documentation Reference below) before drafting; do not attempt this from
  memory alone.
- **Wants to share/bundle** multiple of the above as an installable unit →
  **pi package**. Read `packages.md` (see Documentation Reference below).

When unsure which bucket a request falls into, ask: does it need to be
auto-discovered without being asked (skill) vs. explicitly invoked (prompt
template)? Does it need scripts/reference files (skill) or is it just text
(prompt template)? Does it need real code execution/tool logic beyond
prompting (extension)?

## Documentation Reference

Pi's own docs are the source of truth for exact syntax/rules and should be
read (not guessed from memory) before drafting anything non-trivial,
especially extensions, packages, or skills with scripts/references.

Resolve the docs directory dynamically rather than hardcoding an install
path, since it varies by machine/package manager:

```bash
npm root -g
# then read <result>/@earendil-works/pi-coding-agent/docs/<file>.md
```

Relevant files in that `docs/` directory:

- `skills.md` - full skill spec: frontmatter fields, naming rules,
  validation, discovery locations.
- `prompt-templates.md` - full prompt template spec: frontmatter, argument
  syntax, loading rules.
- `extensions.md` - TypeScript extension APIs for tools, commands, events,
  custom UI.
- `packages.md` - bundling/sharing skills, prompts, extensions, themes.
- `tui.md` - referenced from `extensions.md` for custom terminal UI details.

If `npm root -g` doesn't resolve (e.g. non-npm install), fall back to
locating the `pi` binary (`which pi`) and searching nearby for a `docs/`
directory.

## Prompt Template Quick Reference

Quick summary only — read `prompt-templates.md` (see Documentation Reference
below) for the authoritative spec if anything here seems insufficient or
out of date.

- Location: `~/.pi/agent/prompts/*.md` (global) or `.pi/prompts/*.md`
  (project, only after trust).
- Format: YAML frontmatter with optional `description` and `argument-hint`,
  followed by the prompt body in Markdown.
- Filename becomes the command name: `review.md` → `/review`.
- Argument syntax: `$1`, `$2`, ...; `$@` / `$ARGUMENTS` for all args joined;
  `${1:-default}` for a default when arg 1 is absent/empty; `${@:N}` for args
  from position N; `${@:N:L}` for `L` args starting at N.
- Discovery in `prompts/` is non-recursive; use settings or a package
  manifest for subdirectories.

## Simple Skill Quick Reference

Quick summary only — read `skills.md` (see Documentation Reference below) for
the authoritative spec if anything here seems insufficient or out of date.

- Location: `~/.pi/agent/skills/<name>/SKILL.md` (global) or
  `.pi/skills/<name>/SKILL.md` (project, only after trust).
- Required frontmatter: `name` (lowercase, digits, hyphens only; 1-64 chars;
  no leading/trailing/consecutive hyphens) and `description` (specific,
  states what it does and when to use it, max 1024 chars).
- Body: freeform Markdown instructions. Add `scripts/`, `references/`,
  `assets/` subdirectories only if actually needed.
- Remind the user: skills can instruct the model to run arbitrary
  actions/scripts — review content before use.

## Formalization Principle

This skill handles simple/one-off cases inline. Only suggest formalizing a
recurring pattern into its own dedicated skill (e.g. a `skill-builder` or
`prompt-template-builder`) when **all** of the following hold:

- The same *kind* of request — the actual mechanism/structure being
  repeated, not just a similar topic — has come up **3+ times**.
- The inline approach is showing real friction: re-deriving the same
  rules/checks each time, inconsistent output, or missed validation steps.
- The task has non-trivial structure (multiple files, naming/validation
  rules, scripts, reference docs) — not a short prompt template or a
  single-file skill with a few lines of instructions.

Do **not** suggest formalizing for:

- A single occurrence, or a handful of unrelated one-off asks.
- Simple, low-effort artifacts (a short prompt template, a skill with no
  scripts/references) — these stay cheap inline indefinitely.
- Immediately after building or editing one of these — wait for a genuine
  pattern across separate requests before raising it.

At most, mention the idea once per topic. If the user declines or ignores
it, don't raise it again for that kind of request in future sessions.
