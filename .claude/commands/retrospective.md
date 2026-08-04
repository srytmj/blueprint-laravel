---
description: Review recent DECISION-LOG entries and propose rule updates
---

Run every 1-2 weeks, or on request:

1. Read the most recent 15-20 entries in `DECISION-LOG.md` (or all entries if fewer exist).
2. Look for anything that recurs 3+ times: a bug pattern, a repeated Trade-off, a repeated manual correction, a repeated "Rule Updated: flagged for retrospective".
3. For each pattern found:
   - Name it precisely (not "sometimes things are inconsistent" — the actual repeated behavior).
   - Propose a concrete addition/edit to the relevant `.claude/rules/*.md` file (quote the exact text to add).
4. Present the proposed rule changes to the user before editing any rule file — this is a plan, not an auto-apply.
5. Once approved, apply the edits and add a `DECISION-LOG.md` entry for the retrospective itself (Fix: which rules were updated; Rule Updated: yes, listed above).
6. If nothing recurs 3+ times, say so — don't invent a pattern to justify the pass.
