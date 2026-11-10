# Global Codex Guidance

## Work Style
- Inspect the repo before changing files. Prefer `rg` and `rg --files` for search.
- Preserve user changes. Never revert, delete, or rewrite unrelated work unless explicitly asked.
- Keep edits scoped to the requested behavior and the repo's existing style.
- Prefer existing tools, scripts, helpers, and package managers over introducing new patterns.

## Safety
- Ask before destructive operations such as `git reset --hard`, `git clean`, broad `rm`, `kubectl delete`, `terraform apply`, or `terraform destroy`.
- Treat credentials, tokens, kubeconfigs, `.env` files, and private config as sensitive. Do not print secret values.
- Do not stage, commit, push, or open PRs unless the user asks for that workflow.

## Implementation
- Read nearby code and tests before designing a change.
- Use structured parsers or native tooling when available instead of ad hoc text edits.
- Add focused tests or checks when behavior changes. Scale test effort with risk and blast radius.
- For shell work, prefer idempotent functions over aliases when arguments, confirmations, or error handling matter.

## Verification
- Run the narrowest meaningful checks first, then broader checks when touching shared behavior.
- If a check cannot run because of missing tools, permissions, network, or time, report that clearly.
- Before finishing, summarize changed files, validation run, and any remaining risk.

## Communication
- Keep updates short and specific.
- In code reviews, lead with findings and file references.
- In final responses, focus on what changed and how it was verified.

## Rex inbox
In a Rex pane (REX_SESSION is set), rex-inbox reaches the user and other agents. Load the rex-inbox skill for how. Reach for it when:
- You need a decision and the user may be away, or they should know something later: leave them a note, with what you recommend and what you'll do meanwhile.
- You've built something running locally for the user to see or approve: share it with rex-inbox, never a localhost link (they may be on their phone).
- A "[rex-inbox] Message #N" arrives: answer it with `rex-inbox reply N`, only with substance.
- You finish a task: end with a short summary of what changed, how it was checked, and what's left. The inbox shows it on the Finished item.
