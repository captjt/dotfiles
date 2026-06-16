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
