# Shared Agent Skills

This directory is the dotfiles-managed source for global agent skills.

- `agents` is linked to `~/.agents`.
- `agents/skills` is the shared skill directory.
- `agents/.skill-lock.json` preserves Skills CLI install metadata.
- `install.sh` also links every shared skill into agent-specific skill directories when the agent config directory exists, currently Codex, Claude Code, OpenCode, and Factory.

Add or update skills with the normal Skills CLI commands, for example:

```shell
npx skills add owner/repo@skill-name
npx skills update
```

Because `~/.agents` points back into this repo after installation, skill changes are captured as dotfiles changes.

Refresh the links without running the full machine bootstrap:

```shell
just agent-skills
```
