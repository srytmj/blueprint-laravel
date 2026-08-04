# Decision Log Rules

After finishing any non-trivial task, append an entry to the **top** of `DECISION-LOG.md` (newest first) using this exact template:

```
## [YYYY-MM-DD HH:MM] Short title

- Problem: what was broken or missing
- Fix: what changed
- Why: why this approach, not an alternative
- Trade-offs: what was deliberately not done, and why
- Files: files touched
- Verification: typecheck/build/test/manual — actual result, not a guess
- Follow-ups: anything left open (link it in SCRATCHPAD.md if it needs tracking)
- Rule Updated: did this reveal a repeatable pattern?
    - If yes and it's already clear → update the relevant `.claude/rules/*.md` file now, and say so here.
    - If yes but you want more data points → write "flagged for retrospective" here.
    - If no → write "no".
```

## Why the "Rule Updated" field is mandatory
Without it this file is just a journal. With it, every task is a chance to sharpen `.claude/rules/`. Don't skip it, and don't write "no" reflexively — actually ask whether this task revealed something that will recur.

## Trade-offs field
Record what you deliberately did *not* do, and why. This is what stops the same decision being re-litigated weeks later — treat it as load-bearing, not optional color.

## Closing an open item
If this task closes something tracked in `SCRATCHPAD.md`, move it to `ARCHIVE.md` as a one-line entry **now**, in the same turn — not as a later cleanup sweep. See `SCRATCHPAD.md` for the exact archive format.
