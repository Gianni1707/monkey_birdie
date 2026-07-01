---
name: multi-agent
description: Orchestrate multiple agents (agent teams) to tackle a task in parallel — decompose work, fan out subagents, coordinate them, and synthesize their results. Use when the user wants to run several agents at once, split a large task across a team, parallelize research/review/migration, build a lead+workers setup, or explicitly asks for "agent team", "multi-agent", "subagent", "fan out", or "in parallel".
---

# Multi-Agent Orchestration

Coordinate a team of agents to solve a task faster and more thoroughly than a single
agent could. This skill assumes the experimental Agent Teams feature is enabled via
`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` (set in `.claude/settings.local.json`).

## When to use this skill

Reach for a team when the work is **decomposable** and the pieces are **mostly
independent**:

- **Breadth** — a question spans many files/dirs/subsystems; fan out readers, keep the
  conclusions, not the file dumps.
- **Parallelism** — independent units of work (per-file migration, per-module review,
  per-source research) that don't block each other.
- **Confidence** — generate several independent attempts or perspectives, then have
  adversarial verifiers/judges check them before committing.
- **Scale** — work too large to hold in one context (broad audits, sweeps, refactors).

Do **not** spin up a team for a single-fact lookup, a trivial edit, or strictly
sequential work where each step needs the previous step's full output.

## Two ways to run a team

### 1. Ad-hoc agents (the `Agent` tool)

Best for one-shot fan-out where you decide the structure.

- Launch independent agents **in a single message** (multiple tool calls) so they run
  concurrently.
- Pick the right `subagent_type`: `Explore` for read-only search, `Plan` for design,
  `general-purpose` for multi-step execution, `claude` as the catch-all.
- Continue an existing agent with `SendMessage` (keeps its context) instead of starting a
  fresh `Agent` (loses context).
- Use `isolation: "worktree"` when agents edit files in parallel and would otherwise
  conflict.
- Use `run_in_background: true` for long jobs; you'll be notified on completion.
- The agent's final message is the result returned to **you**, not shown to the user —
  relay what matters.

### 2. Deterministic orchestration (the `Workflow` tool)

Best when control flow should be code, not model judgment (loops, conditionals, retries,
fan-out over a work-list). Requires explicit user opt-in. Prefer `pipeline()` (no barrier
between stages) over `parallel()` (barrier); reserve `parallel()` for when a stage truly
needs all prior results at once. See the Workflow tool docs for the scripting API.

## Orchestration patterns

Pick and compose based on the task:

- **Lead + workers** — a coordinator decomposes the task, assigns slices to workers,
  collects and merges. Keep the lead's job to planning + synthesis; push heavy lifting to
  workers.
- **Map / fan-out** — same operation over N items; one worker per item.
- **Find → verify** — finders surface candidates; independent skeptics try to *refute*
  each one. Keep only those that survive a majority vote. Prevents plausible-but-wrong
  results.
- **Judge panel** — N independent attempts from different angles; parallel judges score;
  synthesize from the winner while grafting the best ideas from runners-up.
- **Multi-modal sweep** — agents each search a different way (by file, by content, by
  symbol, by history); each blind to the others. Good when one angle won't find
  everything.
- **Loop-until-dry** — for unknown-size discovery, keep spawning finders until K
  consecutive rounds find nothing new.

## Recipe (lead role)

1. **Scope** the task and decide if a team helps. If not, just do it yourself.
2. **Decompose** into independent slices; write them down (TodoWrite) so the plan is visible.
3. **Assign & launch** — fan out agents in one message; give each a tight, self-contained
   prompt and the exact output you expect back.
4. **Coordinate** — let independent work run in parallel; use `SendMessage` to follow up
   with a specific agent without restarting it.
5. **Synthesize** — merge results, resolve conflicts, dedupe, and (when correctness
   matters) run a verify/judge pass before presenting.
6. **Report** — give the user the synthesized conclusion and what each agent contributed,
   not raw transcripts.

## Guardrails

- One clear owner of the final answer (you) — agents return data; you decide.
- Give every agent a crisp contract: its input, its scope, and the shape of its output.
- Don't silently cap coverage — if you sample, top-N, or skip retries, say so.
- Match team size to the request: a couple of agents for "find any bugs", a larger pool +
  multi-vote verification for "thoroughly audit this".
- Parallel file edits → isolate in worktrees to avoid clobbering.
