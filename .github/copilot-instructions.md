# GitHub Copilot instructions

These repository instructions guide GitHub Copilot and other coding agents.
Subdirectories can override behaviour with their own `AGENTS.md` files.

## Core principles

- Fix root causes instead of papering over symptoms.
- Match existing patterns; avoid new paradigms without a clear reason.

## Working style

- State assumptions up front if requirements are unclear.
- Ask before proceeding when choices are ambiguous or significant.
- Use todo lists for multi-step tasks and keep progress visible.
- Summarize what changed, why, files touched, and follow-ups.

## Code changes

- Read code before modifying it; avoid edits to unseen areas.
- Keep diffs small and focused on the request; avoid reformatting, renames, or refactors beyond what’s needed.
- Do not create commits or branches unless requested.
- Remove unused code instead of leaving placeholders or `_unused` stubs.

## Code style

### JavaScript/TypeScript

- Formatter: Biome (`biome check --write`)
- Style: 2-space indent, single quotes, semicolons, 80 char line width
- Imports: auto-organized by Biome; unused imports fail checks
- Hooks run Biome automatically

### Nix

- Formatter: alejandra; statix and deadnix enforced by hooks
- Prefer conventional, readable Nix over cleverness

### Markdown

- Linter: markdownlint
- Links: use descriptive link text, not raw URLs
- Code: break long inline code to stay within line limits

### General defaults

- Encoding: UTF-8 with LF line endings
- Files end with a newline; no trailing whitespace or BOM
- Line length: aim for 80 characters, never exceed 120
- Indentation: spaces only (2 for JS/TS/JSON/YAML, 4 for Python)
- Imports: stdlib, third-party, then local; one per line; remove unused
- Naming: snake_case for Python, camelCase for JS/TS functions, PascalCase for
classes/types, UPPER_SNAKE_CASE for constants
- Quotes: single for JS/TS, double for JSON or Python docstrings

## Git and commits

- Follow Conventional Commits: `type(scope): imperative summary` (<=72 chars)
- One logical change per commit; do not mix unrelated edits
- No attribution lines like "Generated with" in commit messages

## Testing

- Add or update focused tests when logic changes and a harness exists.
- Keep tests deterministic, isolated, and fast.
- Do not fix unrelated failing tests.

## Dependencies

- Avoid adding dependencies unless necessary; justify size, security, and
maintenance impact.

## Security

- Never add secrets to files or logs.
- Avoid unsafe constructs (eval on untrusted input, injection risks, etc.).
- Validate inputs at boundaries and minimize exposed surface area.

## Performance

- Prefer simple, efficient solutions; document trade-offs when adding
complexity.

## Tool usage

- Prefer specialized read/edit/write tools over ad hoc shell edits.
- Use ripgrep for searching; read large files in chunks when needed.
- Respect sandboxing and request approval for privileged operations.

## Documentation and libraries

- Use the Context7 MCP server for up-to-date library docs and examples.
- Workflow:
  1. Call `mcp__context7__resolve-library-id` to find the library ID.
  2. Call `mcp__context7__get-library-docs` with that ID.
  3. Use `mode='code'` for APIs/examples; `mode='info'` for concepts.

## Overrides

- No project-specific overrides yet.
