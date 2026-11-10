---
name: rex-agent
description: "Run and drive coding agents (Claude Code, Codex) in Rex panes by name with the rex-agent CLI: start one and wait until ready, prompt it and wait for the turn, detect approvals, read its screen. Use when the user asks to spin up, prompt, watch, or coordinate agents in Rex panes or tabs, the Rex equivalent of Herdr's agent commands. Requires REX_SESSION. Not for Claude Code's in-process subagents (the Agent tool)."
---

# rex-agent

`rex-agent` (in `~/.bin`) adds Herdr-style agent commands to Rex. Claude Code
and Codex report their state to Rex on their own (OSC 7501 program status:
`idle`, `working`, `done`, `blocked`, `error`), and `rex-agent` waits on that
state instead of guessing from the screen.

Check that you are in Rex (`test -n "$REX_SESSION"`), then run
`rex-agent --help`. The help is the reference for commands, options, and exit
codes.

## Choose the right kind of agent

- **Agent tool subagents** have no pane and return their result to you. Use
  them for read-only fan-out, such as reviews, research, and searches, when
  the user only needs the conclusion.
- **`rex-agent` panes** are full interactive sessions the user can watch and
  take over. Use them when the user asks for agents in panes or tabs, wants a
  different agent such as Codex, or wants long-running work they can step
  into.

## Typical loop

```sh
rex-agent start reviewer --kind codex          # split beside you, wait for idle
rex-agent prompt reviewer "Review the diff on this branch. Report findings only." --wait
rex-agent read reviewer --lines 80
rex-agent close reviewer                       # only agents you started
```

- Start several agents with `--tab` so splits don't get too narrow.
- For a long or multi-line prompt, write it to a file and pipe it in:
  `rex-agent prompt NAME - --wait < prompt.md`.
- `prompt --wait` has no timeout by default. Pass `--timeout` only when you
  have a reason, and remember that a timeout doesn't undo delivery.

## Rules

- **Exit 3 (blocked)** means the agent is waiting on an approval, question, or
  login. `rex-agent read NAME` shows it. Ask the user before approving
  anything you didn't plan; `rex-agent keys NAME escape` declines.
- **Exit 5 or 6** (timeout, stalled) don't prove the prompt was lost. Read the
  pane before resending.
- **Exit 7 (busy)**: wait with `rex-agent wait NAME`, or pass `--force` to
  queue a message on purpose.
- **Codex shows a hooks trust prompt at startup** until the user trusts Rex's
  hook with `/hooks` in Codex. That prompt reports no status, so `start` times
  out (exit 5) and prints the screen. Ask the user to trust the hook. To skip
  it for one session, `rex-agent keys NAME escape`, then
  `rex-agent wait NAME`.
- **Codex draws on the alternate screen**, so `read` shows only the current
  screen. For an answer longer than a screen, ask the agent to write it to a
  file and read the file.
- Leave panes you didn't create alone, and close your own when the work is
  done.
