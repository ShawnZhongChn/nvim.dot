# Goal Feature: shawnvim-development-docs

## Inputs

- Roadmap item: `shawnvim-development-docs`
- Design: `.codestable/features/2026-07-14-shawnvim-development-docs/shawnvim-development-docs-design.md`
- Checklist: `.codestable/features/2026-07-14-shawnvim-development-docs/shawnvim-development-docs-checklist.yaml`
- Design review: `.codestable/features/2026-07-14-shawnvim-development-docs/shawnvim-development-docs-design-review.md`
- Review: `.codestable/features/2026-07-14-shawnvim-development-docs/shawnvim-development-docs-review.md`
- QA: `.codestable/features/2026-07-14-shawnvim-development-docs/shawnvim-development-docs-qa.md`
- Acceptance: `.codestable/features/2026-07-14-shawnvim-development-docs/shawnvim-development-docs-acceptance.md`
- Depends on: `shawnvim-core-fork`
- Nature: non-functional（静态文档基线；用完整性/重放/人工阅读替代runtime path）

## Core Validation Path

固定docs commit `85e5b49...` → 138 Markdown inventory/3 YAML exclusion → structural transform/Tabs mapping → ShawnVim calibration → byte-identical upstream news + generated working news → 139目标Markdown全量audit与五类页面人工阅读。

## Mandatory Commands

1. `scripts/audit-docs --source-cache .tests/upstream/lazyvim-docs --fetch-missing --docs docs/development/0.1.0 --manifest docs/development/0.1.0/SOURCE.json --core . --json .tests/evidence/docs.json`
2. `scripts/audit-identity --json .tests/evidence/docs-identity.json`
3. `git diff --check`

## Feature DoD And Gates

- Implementation：5 steps全done；138 source + 1 generated = 139，3 YAML只有excluded records。
- Review：独立review核对transform parser/manifest/tool质量与rights边界。
- QA：fixed-source replay、125/487/975 Tabs、links/anchors/core digest、news bytes、五类阅读全部passed。
- Acceptance：UPSTREAM-DOCS与README rights双入口、文档维护架构与roadmap回写；checks全passed。
- Stage gates：`implementation.before_review` → `review.before_pass` → `qa.before_acceptance` → `acceptance.before_done`。

## Evidence And Deliverables

- `docs/development/0.1.0/` 139 Markdown、SOURCE.json、UPSTREAM-DOCS.md、README license section。
- 138双hash、受限operation replay、Tabs group/branch、slugger fixtures、core ancestor/manifest/tree digest。
- byte-identical `upstream/lazyvim-news.md`、manual reading/rights evidence、audit JSON。
- review/QA/acceptance、gate/evidence pack。

## Cleanliness

- 不复制任何非Markdown上游文件、图片、logo、category YAML或站点工程。
- 无MDX/Docusaurus残留、坏链接、空页面、TODO/FIXME、临时clone/build。

## Failure Recovery

- Count/hash/replay/link/core identity失败：回implementation定位具体source/op并全量重跑。
- Parser对异常source不确定：不得手工跳过；修parser并重跑138文件。
- 需要扩大上游范围或改变rights contract：handoff。
