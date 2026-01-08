# Dev environment (devenv template)

The goal of this repo is simple: you open a container (Codespaces, devcontainer,
Docker), run one command, and you’re instantly in a fully‑tooled shell.

This repo is **only** the dev environment. Your actual app lives in downstream
projects that copy or reference these files. Think of it as a starter kit for
[`devenv`](https://devenv.sh)‑based projects.

---

## Philosophy: devenv as the source of truth

This template leans on `devenv` to define the entire dev experience:

- `devenv.nix` describes languages, tools, Neovim, tasks, and processes.
- `devenv.yaml` pins the inputs so builds are repeatable.
- Containers and Codespaces use that same definition
- You extend the environment by editing `devenv.nix` shell setup.

If you haven’t seen `devenv` before, it’s worth a quick skim of the docs:
<https://devenv.sh>

---

## How this template fits into devenv

This repo is meant to **bootstrap the dev setup for a devenv project**:

- `devenv.nix`
  - configures languages (`nix`, `javascript` with Node.js 22),
  - installs the core CLI stack (git, gh, ripgrep, linters, formatters),
  - sets up Neovim via `nixvim` with LSP, treesitter, Telescope, Neo-tree, etc.,
  - wires `git-hooks`, `tasks`, and `processes`,
  - defines `containers.latest` with a `startupCommand` based on the `serve`
    process.
- `devenv.yaml`
  - pins `inputs.devenv`, `inputs.nixpkgs`, and `inputs.nixvim`, so the image
    you build today is reproducible later.
- When you run `devenv shell` inside your container:
  - `devenv` builds the environment described above,
  - generates `.mcp.json` for MCP‑aware tools,
  - and drops you into the configured shell.

For more on how `devenv` shells, tasks, and containers work, see:

- Shells: <https://devenv.sh/reference/cli/#devenv-shell>
- Tasks: <https://devenv.sh/reference/tasks/>
- Containers: <https://devenv.sh/reference/containers/>

---

## Container‑first quick start

Use this repo as a template or copy its files into your own project.

1. **Pull in the template files**
   - Copy at least: `devenv.nix`, `devenv.yaml`
   - Commit them into your app repo

2. **Make sure your image has devenv**
   - Base your devcontainer/Docker image on something with Nix installed, then
     add the `devenv` CLI (see <https://devenv.sh/reference/installation/>).
   - Ensure the template files are present in the build context so `devenv`
     sees them.

3. **Build and boot your devcontainer / Codespace**
   - Open the project in Codespaces (or your devcontainer).
   - You should land in a shell at the repo root inside the container.

4. **Enter the dev shell**
   - From inside the container, run:
     - `direnv allow` **or**
     - `devenv shell`
   - `devenv` will build the environment, expose the configured tools

5. **Use the built‑in tasks and processes**
   - Run `devenv tasks` to see available tasks.
   - Handy defaults:
     - `devenv task fmt:nix` – format all `*.nix` files with `alejandra`.
     - `devenv task lint:nix` – run `statix` and `deadnix`.
   - Processes in `devenv.nix` are wired for `process-compose`:
     - `serve` – production server stub (used by
       `containers.latest.startupCommand`).
     - `dev-server` – dev server stub, ready to be replaced with your app’s
       dev command.
     - `watcher` – file‑watching / linting stub.

Swap those stubs for your real commands and your container now boots straight
into a project‑aware dev environment.

---

## Tooling highlights

From the moment you run `devenv shell` in your container, you get:

- Nix‑managed toolchain with Node.js 22, npm/corepack, git, gh, ripgrep,
`markdownlint`, Biome, `alejandra`, `statix`, `deadnix`, and `zellij`.
- Neovim via `nixvim` with:
  - LSP servers: bashls, Biome, Copilot, jsonls, lua_ls, nixd, tsserver.
  - treesitter (with sensible defaults for remote performance),
  - Telescope (with fzf, file pickers, and UI select),
  - Neo-tree (file explorer with git status),
  - gitsigns, bufferline, lualine,
  - indent guides, autopairs, comment toggles,
  - which‑key and the Catppuccin theme tuned for remote sessions.
- Git hooks configured via `cachix/git-hooks.nix`:
  - `convco`, `markdownlint`, `alejandra` (check mode), `statix`, `deadnix`.
- Process management with `process-compose`:
  - logs are written to `.devenv/process-compose.log`,
  - you can extend or replace the default processes per project.

---

## Claude Code & MCP integration

This template plays nicely with Claude Code and other MCP‑aware tools:

- `devenv` exposes a built‑in `devenv` MCP server; entering the shell causes
`.mcp.json` to be written so compatible editors can auto‑discover it.
- You can also configure additional MCP servers (for example, hosted endpoints)
via your own editor or CLI configuration.
- To use Claude Code:
  - Install the Claude Code CLI (see Anthropic’s docs for install instructions).
  - Add the recommended `devenv` snippet to `~/.claude/CLAUDE.md` so Claude prefers
`devenv` shells when tools are missing.
  - Launch the shell with `direnv allow` or `devenv shell`; MCP servers from this
environment will be available automatically.
- Sidekick integration:
  - Sidekick is configured in `devenv.nix` and can launch Claude, Copilot, Codex,
and Gemini CLIs via `npx -y`, keeping those tools fresh without global installs.

---

## Neovim shortcuts

Once you’re in the container and run `devenv shell`, Neovim is ready to go:

- `Ctrl-\` – Toggle the Sidekick panel for AI assistance.
- Telescope:
  - `<leader>ff` – find files,
  - `<leader>fg` – live grep,
  - `<leader>fb` – list buffers.
- Neo-tree:
  - `<leader>e` – toggle file explorer + git status.
- Gitsigns:
  - `]h` / `[h` – next/previous hunk,
  - `<leader>hp` – preview hunk,
  - `<leader>hs` – stage hunk,
  - `<leader>hr` – reset hunk.
- Bufferline:
  - `<leader>bn` – next buffer,
  - `<leader>bp` – previous buffer,
  - `<leader>bd` – close buffer.
- LSP:
  - `<leader>ld` – go to definition,
  - `<leader>lr` – references,
  - `<leader>la` – code action,
  - `<leader>ln` – rename,
  - `<leader>lk` – hover,
  - `<leader>lf` – format.
- Diagnostics:
  - `gl` or `<leader>dd` – open diagnostic float at cursor,
  - `]d` / `[d` – next/previous diagnostic,
  - `<leader>dn` / `<leader>dp` – next/previous diagnostic (grouped under
    which‑key).
- Completion:
  - `<C-l>` – trigger `nvim-cmp` completion.
- Comments:
  - `gc` (motions) / `gcc` (line) – toggle comments.
- Sidekick CLI / edit navigation:
  - `<Tab>` (normal) – jump to/apply next suggestion (falls back to literal Tab),
  - `<C-\>` (normal/terminal/insert/visual) – toggle Sidekick CLI panel,
  - `<leader>aa` – toggle Sidekick CLI,
  - `<leader>as` – select an AI tool from the CLI,
  - `<leader>ad` – close/detach current CLI session,
  - `<leader>at` – send `{this}` (current context) to Sidekick,
  - `<leader>af` – send current file,
  - `<leader>av` – send visual selection,
  - `<leader>ap` – prompt Sidekick,
  - `<leader>ac` – toggle Copilot‑focused CLI and focus it.

---

### Which‑key leader groups

For quick discovery:

- `<leader>f` – File actions (`ff`, `fg`, `fb`).
- `<leader>b` – Buffer/window controls.
- `<leader>w` – Window management.
- `<leader>s` – Search helpers (Telescope, etc.).
- `<leader>o` – “Open” commands (Neo-tree, terminals).
- `<leader>g` – Git/gitsigns helpers.
- `<leader>a` – AI helpers (Sidekick, Claude, Copilot).
- `<leader>d` – Diagnostics helpers.

---

## Customizing the environment

This template is opinionated but not rigid — you’re expected to tweak it:

- Edit `devenv.nix` / `devenv.yaml` to add packages, services, and env vars
  specific to your project.
- Replace the stub `serve`, `dev-server`, and `watcher` processes with your own
  commands (e.g. `npm run dev`, `npm run start`, `biome check --watch .`).
- Pre‑commit caches live under `$DEVENV_RUNTIME/.cache/pre-commit` via
  `PRE_COMMIT_HOME`, so hooks can write logs even on constrained or read‑only
  `$HOME`.
- Adjust Neovim plugins, LSP servers, and keymaps directly in `devenv.nix` to
  fit your workflow.
- Remove tools you don’t need to keep the shell lean and fast.

---

## Contributing / next steps

- Keep edits focused on the **dev environment**, not on application‑specific
  logic.
- Use an `AGENTS.md` in consuming repos to document any project‑specific rules
  for agents and automation (formatting, testing, commit messages).
- When you find a general improvement (better defaults, useful tasks, nicer
  shortcuts), fold it back into this template so all future repos benefit.

Open a container and you’re ready to build.
