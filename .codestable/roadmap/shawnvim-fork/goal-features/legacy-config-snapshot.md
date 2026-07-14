# Goal Feature: legacy-config-snapshot

## Inputs

- Roadmap item: `legacy-config-snapshot`
- Design: `.codestable/features/2026-07-14-legacy-config-snapshot/legacy-config-snapshot-design.md`
- Checklist: `.codestable/features/2026-07-14-legacy-config-snapshot/legacy-config-snapshot-checklist.yaml`
- Design review: `.codestable/features/2026-07-14-legacy-config-snapshot/legacy-config-snapshot-design-review.md`
- Review: `.codestable/features/2026-07-14-legacy-config-snapshot/legacy-config-snapshot-review.md`
- QA: `.codestable/features/2026-07-14-legacy-config-snapshot/legacy-config-snapshot-qa.md`
- Acceptance: `.codestable/features/2026-07-14-legacy-config-snapshot/legacy-config-snapshot-acceptance.md`
- Depends on: none
- Nature: mixed（Git migration safety + recovery behavior）

## Core Runtime Path

记录 PRE_HEAD/远端refs → inventory tracked/untracked/ignored → stage全部有效旧状态 → snapshot commit → annotated legacy tag → 验证ancestor/tree/remote unchanged。

## Mandatory Commands

1. `git status --short --branch && git ls-files --others --ignored --exclude-standard`
2. `git cat-file -t legacy-nvim-config-2026-07-14`
3. `git rev-parse legacy-nvim-config-2026-07-14^{}`
4. `git merge-base --is-ancestor origin/master legacy-nvim-config-2026-07-14^{}`
5. `git ls-remote origin refs/heads/master refs/tags/legacy-nvim-config-2026-07-14`
6. `git cat-file -e legacy-nvim-config-2026-07-14:lua/custom/debug/init.lua && git cat-file -e legacy-nvim-config-2026-07-14:lazy-lock.json`
7. 从`.tests/evidence/legacy-pre-head.txt`验证PRE_HEAD是tag peeled target祖先。
8. 用相同`ls-remote`参数生成after并`cmp` before/after。

## Feature DoD And Gates

- Implementation：4 steps全done；snapshot/tag/evidence存在；不删除旧文件、不push。
- Review：独立reviewer确认无历史重写、遗漏或远端mutation。
- QA：tag object/peeled、双ancestor、关键blobs、remote comparison全部passed。
- Acceptance：checks全passed；items/roadmap回写；记录恢复命令。
- Stage gates：`implementation.before_review` → `review.before_pass` → `qa.before_acceptance` → `acceptance.before_done`。

## Evidence And Deliverables

- Snapshot commit、annotated tag、PRE_HEAD、pre/post origin refs、inventory分类、Git object outputs。
- review/QA/acceptance、gate/evidence pack。

## Cleanliness

- 不新增`.bak`、日志、插件数据、临时patch、TODO/FIXME。
- `.tests/evidence`保持ignored；关键OID与结论写入acceptance。

## Failure Recovery

- Tag冲突、Git identity缺失、tree/ancestor失败：停止；不移动tag、不reset/rebase。
- Commit成功但tag失败：保留commit，修复后只重试tag。
- 远端before/after不同：fail-closed并handoff，不尝试归因或改远端。
