# UI Rules

Applies whenever you touch a UI file (components, views, templates, styles), regardless of framework.

## Before writing
- Reuse existing components/design tokens in `code/` before creating new ones.
- Check `.claude/writing-styles/in-app-messages.md` for copy tone on any user-facing text.

## Requirements
- Responsive by default: no fixed layouts that break on mobile viewport.
- Accessible by default: semantic elements, labeled inputs, sufficient color contrast, keyboard-reachable interactive elements.
- Loading, empty, and error states are part of "done" — not an afterthought.

## Verification
- If a dev server exists for this project, start it and actually look at the change before marking the task complete. Don't claim a UI works from reading the code alone.
- Run the golden path plus at least one edge case (empty state, long text, small viewport).

## Review
- Any task that touches UI files triggers the Designer agent in `/pre-commit` (see `.claude/agents/designer-agent.md`).
