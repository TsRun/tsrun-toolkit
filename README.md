# tsrun-toolkit

Dev workflow plugins for Claude Code, split by topic so you can install only what you need.

## Plugins

| Plugin | Description |
|--------|-------------|
| `tsrun-git` | Git agent + autocommit Stop hook (commits & pushes dirty state via the agent). |
| `tsrun-dev` | Code dev skills: `/tsrun-dev:fix-types` and `/tsrun-dev:doc`. |
| `tsrun-web` | `/tsrun-web:clone-website` — pixel-perfect site cloning with parallel builder agents (requires Playwright MCP). |
| `tsrun-housekeeping` | `/tsrun-housekeeping:clean-sessions` skill + Stop hooks (sound + autocommit-session pruning). |

## Installation

Add the marketplace once:

```bash
/plugin marketplace add TsRun/tsrun-toolkit
```

Then install any subset:

```bash
/plugin install tsrun-git@tsrun-toolkit
/plugin install tsrun-dev@tsrun-toolkit
/plugin install tsrun-web@tsrun-toolkit
/plugin install tsrun-housekeeping@tsrun-toolkit
```

## Notes

- `tsrun-git`'s autocommit hook calls `claude --agent git`, so install `tsrun-git` (not just the hook) for it to work.
- `tsrun-git` and `tsrun-housekeeping` both register `Stop` hooks; install both to keep the original toolkit behavior (sound + autocommit + session cleanup).
- `CLAUDE.md` behavioral guidance ships with `tsrun-dev`.
