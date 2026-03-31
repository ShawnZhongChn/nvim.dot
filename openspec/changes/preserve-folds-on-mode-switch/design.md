## Context

Current Neovim behavior collapses folds when transitioning from Insert mode to Normal mode. This is disruptive during editing because visibility state changes without an explicit fold command. The change is local to editor configuration and should preserve existing manual fold controls.

## Goals / Non-Goals

**Goals:**
- Prevent mode transitions from implicitly changing fold visibility.
- Preserve per-window fold state across Insert ↔ Normal switching.
- Keep all explicit folding commands and foldmethod behavior unchanged.

**Non-Goals:**
- Redesign foldmethod/foldexpr behavior.
- Change fold persistence across buffer reloads/sessions.
- Introduce new fold UX commands.

## Decisions

- Remove or gate any mode-change autocmd/keymap logic that triggers fold-close operations on InsertLeave/ModeChanged.
  - Rationale: The root issue is implicit fold mutation on mode transitions.
  - Alternative considered: Re-open folds on Normal entry; rejected because it can conflict with user-intended closed folds.
- Scope to Insert→Normal path first, while ensuring no mode transition path alters folds unless user explicitly invokes fold commands.
  - Rationale: Matches reported pain point and keeps behavior principle clear.

## Risks / Trade-offs

- Existing workflow may have relied on auto-folding for context reset → Mitigation: keep explicit fold shortcuts intact; only remove implicit trigger.
- Multiple plugin hooks could manipulate folds indirectly → Mitigation: update the concrete mode-switch hook responsible for this behavior and verify no duplicate autocmds perform fold changes.
