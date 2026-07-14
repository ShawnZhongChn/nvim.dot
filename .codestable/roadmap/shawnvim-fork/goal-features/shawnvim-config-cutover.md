# Goal Feature: shawnvim-config-cutover

## Inputs

- Roadmap item: `shawnvim-config-cutover`
- Design: `.codestable/features/2026-07-14-shawnvim-config-cutover/shawnvim-config-cutover-design.md`
- Checklist: `.codestable/features/2026-07-14-shawnvim-config-cutover/shawnvim-config-cutover-checklist.yaml`
- Design review: `.codestable/features/2026-07-14-shawnvim-config-cutover/shawnvim-config-cutover-design-review.md`
- Review: `.codestable/features/2026-07-14-shawnvim-config-cutover/shawnvim-config-cutover-review.md`
- QA: `.codestable/features/2026-07-14-shawnvim-config-cutover/shawnvim-config-cutover-qa.md`
- Acceptance: `.codestable/features/2026-07-14-shawnvim-config-cutover/shawnvim-config-cutover-acceptance.md`
- Depends on: `shawnvim-core-fork`
- Nature: functional

## Core Runtime Path

Destructive preflight → thin Config Shell → state/lock → exact old runtime removal → four-XDG first/second bootstrap + deterministic failure → real-config isolated health/identity/tree/lock closure。

## Mandatory Commands

1. `scripts/test-clean-start --json .tests/evidence/cutover-start.json`
2. `scripts/audit-identity --json .tests/evidence/cutover-identity.json`
3. `scripts/audit-runtime-tree --json .tests/evidence/cutover-tree.json`
4. `scripts/test-clean-start --real-config --json .tests/evidence/cutover-real-health.json`
5. `git ls-files --error-unmatch lazy-lock.json && git ls-files --error-unmatch shawnvim.json`
6. `scripts/generate-lock --check-resolved --json .tests/evidence/cutover-lock.json`

## Feature DoD And Gates

- Implementation：任何mutation前preflight passed；6 steps全done。
- Review：独立review核对destructive diff、bootstrap/lock helpers与spec quality。
- QA：clean-room、real-config、identity/tree/state/lock/clone failure全部passed。
- Acceptance：真实启动架构/attention/requirements/roadmap回写；checks全passed。
- Stage gates：`implementation.before_review` → `review.before_pass` → `qa.before_acceptance` → `acceptance.before_done`。

## Evidence And Deliverables

- 根init、`lua/config/`、empty `lua/plugins/`、`shawnvim.json`、tracked `lazy-lock.json`。
- exact deletion/preserve lists；test-clean-start、runtime-tree、generate-lock helpers。
- clean-room/real-config startup logs、resolved specs、three-way lock classification、health/identity evidence。
- review/QA/acceptance、gate/evidence pack。

## Cleanliness

- 只删除approved exact allowlist；不保留`.disabled`、backup dirs、临时XDG、旧init注释或迁移TODO。
- 不运行两个旧setup scripts；不推远端、不建release tag。

## Failure Recovery

- Preflight失败：tree不变，修复依赖后重试。
- Mutation后startup/lock失败：保留Git恢复能力，修复候选tree；不得从legacy迁移个人行为绕过。
- 需要改变deletion/preserve/state/import contract：handoff。
