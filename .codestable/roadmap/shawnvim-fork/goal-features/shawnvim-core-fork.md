# Goal Feature: shawnvim-core-fork

## Inputs

- Roadmap item: `shawnvim-core-fork`
- Design: `.codestable/features/2026-07-14-shawnvim-core-fork/shawnvim-core-fork-design.md`
- Checklist: `.codestable/features/2026-07-14-shawnvim-core-fork/shawnvim-core-fork-checklist.yaml`
- Design review: `.codestable/features/2026-07-14-shawnvim-core-fork/shawnvim-core-fork-design-review.md`
- Review: `.codestable/features/2026-07-14-shawnvim-core-fork/shawnvim-core-fork-review.md`
- QA: `.codestable/features/2026-07-14-shawnvim-core-fork/shawnvim-core-fork-qa.md`
- Acceptance: `.codestable/features/2026-07-14-shawnvim-core-fork/shawnvim-core-fork-acceptance.md`
- Depends on: `legacy-config-snapshot`
- Nature: functional

## Core Runtime Path

固定source commit `459a4c3...` → manifest/Apache attribution → `lua/shawnvim` transform → local self-spec/state/history → fixed lazy.nvim minit → namespace/spec/version/news/notice assertions；真实`init.lua`仍加载旧配置。

## Mandatory Commands

1. `nvim -l tests/minit.lua --minitest`
2. `scripts/audit-identity --json .tests/evidence/core-identity.json`
3. `scripts/audit-source-manifest --source-cache .tests/upstream/lazyvim-source --fetch-missing --core . --manifest UPSTREAM-SOURCE.json --json .tests/evidence/core-source.json`
4. `nvim -l scripts/check-lua-syntax.lua`
5. `stylua --check lua tests`（supporting；缺失按design记录baseline）
6. `selene lua tests`（supporting；缺失按design记录baseline）

## Feature DoD And Gates

- Implementation：7 steps全done；source/generated/excluded/notice/test dependency schemas完整。
- Review：独立review同时覆盖spec compliance与代码质量；数百文件机械变换重点核对。
- QA：minit/identity/source/syntax core commands passed；四分支lazy.nvim cache证据与真实import version seam通过。
- Acceptance：core artifacts与architecture/ADR/roadmap回写；checks全passed。
- Stage gates：`implementation.before_review` → `review.before_pass` → `qa.before_acceptance` → `acceptance.before_done`。

## Evidence And Deliverables

- `lua/shawnvim/`、queries、vimdoc、NEWS/CHANGELOG、LICENSE、UPSTREAM、UPSTREAM-SOURCE.json。
- 每个modified source的显著notice与manifest字段。
- minit、identity/source/syntax helpers；`core-minit.json`、identity/source JSON、resolved specs。
- review/QA/acceptance、gate/evidence pack。

## Cleanliness

- 不切真实init，不删除`lua/custom`/`lua/core`，不保留`require("lazyvim")`alias。
- 不保留临时clone/sed输出/TODO/FIXME；cache/evidence保持ignored。
- 不全局安装Stylua/Selene；supporting缺失必须显式记录。

## Failure Recovery

- Source/cache OID、manifest/notice、identity或minit失败：回implementation修复并重跑全部相关gates。
- 错OID/dirty `LAZY_PATH`：fail-closed，不reset用户checkout。
- 需要改变approved namespace/provenance/notice contract：handoff。
