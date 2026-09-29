# Changelog

One entry per working session, newest first. Each entry covers what was studied, what was built,
and any decisions made.

## 2026-09-29

**Built**
- Repo skeleton: PGlite-backed scripts (`db:rebuild`, `queries`, `sql`), chapter template,
  gitignored `book-refs/` for figure photos, README, and CLAUDE.md working rules.
- Restructured by volume (`volumes/vN-slug/NN-slug/`) because chapter numbers restart in each
  book. Each volume loads into its own Postgres schema (`v1`, `v2`, `v3`), with `search_path`
  falling back to earlier volumes.
- Added TODO.md (progress and tooling) and this changelog.

**Decisions**
- PGlite instead of Docker/Postgres, since neither is installed. Native tooling is tracked in TODO.md.
- Workflow: one figure at a time. The user photographs it, we transcribe and confirm, discuss,
  then implement. One commit per figure.
- The per-chapter mini-app and ops practice is deferred; the core deliverable is the SQL,
  the diagram, and the notes.

**Next**
- Vol 1, Ch 2: first figure (the Party model with Person and Organization).
