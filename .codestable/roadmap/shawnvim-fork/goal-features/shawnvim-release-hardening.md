# Goal Feature: shawnvim-release-hardening

## Inputs

- Roadmap item: `shawnvim-release-hardening`
- Design: `.codestable/features/2026-07-14-shawnvim-release-hardening/shawnvim-release-hardening-design.md`
- Checklist: `.codestable/features/2026-07-14-shawnvim-release-hardening/shawnvim-release-hardening-checklist.yaml`
- Design review: `.codestable/features/2026-07-14-shawnvim-release-hardening/shawnvim-release-hardening-design-review.md`
- Review: `.codestable/features/2026-07-14-shawnvim-release-hardening/shawnvim-release-hardening-review.md`
- QA: `.codestable/features/2026-07-14-shawnvim-release-hardening/shawnvim-release-hardening-qa.md`
- Acceptance: `.codestable/features/2026-07-14-shawnvim-release-hardening/shawnvim-release-hardening-acceptance.md`
- Depends on: `shawnvim-config-cutover`, `shawnvim-development-docs`
- Nature: mixed

## Core Runtime And Publish Path

统一local/CI test与release docs → independent review/QA → immutable candidate commit → **具体OID/refs owner approval gate** → non-force candidate push → exact-SHA v0.11.2/stable CI → annotated legacy/release tags → tag双OID/Release 404 → `.codestable`-only admin commit → final convergence。

## Mandatory Commands

1. `scripts/test --json-evidence .tests/evidence/release-local.json`
2. `scripts/audit-license --json .tests/evidence/release-license.json`
3. `git diff --check`
4. `git fetch origin --prune --no-tags`
5. `git merge-base --is-ancestor origin/master "$CANDIDATE_OID"`
6. Candidate push后fetch并断言`origin/master == CANDIDATE_OID`。
7. GitHub Actions REST按`head_sha`选唯一push run，保存run id。
8. 同一run id的`test (v0.11.2)`与`test (stable)` jobs均success。
9. 本地两个annotated tags、release target与message验证。
10. 远端两个tags的tag-object/peeled OID逐项比较。
11. Release-by-tag API必须精确HTTP 404。
12. Admin push后fetch，断言branch OID、candidate ancestor与`.codestable`-only diff。

完整shell命令以feature checklist为权威，不得简化tag ref或HTTP判断。

## Feature DoD And Gates

- Implementation：test/CI/docs/candidate/admin 6 steps全done；workflow固定job id/name/matrix/action SHA/permissions/timeout/no-cache。
- Review：独立review覆盖spec compliance、code/tool quality、Git/CI/API副作用。
- QA：local gates、approval、candidate exact-SHA CI、tag/API/remote preflight/convergence全部有证据。
- Acceptance：tracked PublishEvidence不嵌admin/final branch OID；post-admin FinalConvergenceEvidence ignored；两个roadmaps/architecture/requirements回写。
- Stage gates：`implementation.before_review` → `review.before_pass` → `qa.before_acceptance` → `acceptance.before_done`。

## Mandatory Owner Approval

Candidate commit创建且本地review/QA passed后，第一次remote mutation前：

1. 写`.codestable/features/2026-07-14-shawnvim-release-hardening/approval-report.md`。
2. 列出candidate OID、origin URL、`master`、legacy tag、`v0.1.0`、后续admin push。
3. 明确所有push non-force、不覆盖tag、不创建GitHub Release。
4. 等owner明确批准并把report状态改approved。

缺批准必须写goal-state handoff；不得把本次design批准自动解释成具体publish批准。

## Evidence And Deliverables

- `scripts/test`、audit-license、CI workflow、README、CONTRIBUTING、license/provenance声明。
- candidate/admin commits、approved publish report、exact-SHA CI run/jobs、两个annotated tags。
- branch/tag双OID、Release 404、tracked PublishEvidence、ignored FinalConvergenceEvidence。
- review/QA/acceptance、gate/evidence pack、roadmap/architecture/requirements回写。

## Cleanliness

- 不提交CI logs、temp XDG/plugin caches、tokens、debug输出、TODO/FIXME、注释workflow。
- 不force、不额外分支、不GitHub Release；admin commit只改`.codestable/`。
- `GITHUB_TOKEN`若使用只来自环境，绝不写入文件或输出。

## Failure Recovery

- Local/review/QA失败：修payload并生成新candidate；旧candidate不得tag。
- Approval拒绝/缺失、remote divergence、tag冲突、权限缺失：handoff，不push/merge/rebase/force。
- CI transient failure可记录并重试同SHA；兼容性失败回implementation，产生新candidate并重跑review/QA/approval/CI。
- 部分tag/admin push失败：保留本地对象，重新fetch/reconcile后只重试缺失ref；错误同名对象仍阻塞。
