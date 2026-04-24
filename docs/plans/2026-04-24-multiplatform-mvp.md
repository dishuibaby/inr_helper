# 抗凝小助手正式开发执行计划

> **For Hermes:** Use subagent-driven-development skill to implement this plan task-by-task. 开发实现阶段优先通过 Codex CLI 执行，Hermes 负责拆任务、验收、代码审查、提交与沟通。

**Goal:** 基于当前静态原型，启动微信小程序、Android/iOS Flutter、Go/Gin 服务端三线并行的 MVP 正式工程开发。

**Architecture:** Monorepo。服务端使用 Go + Gin 单体分层架构，先提供内存/SQLite 可测版本，再演进 MySQL/Redis；微信小程序使用 TypeScript 原生小程序结构；Android/iOS 使用 Flutter 共用一套代码。三端共享 OpenAPI/API contract、业务规则和变更记录。

**Tech Stack:** Go 1.19+/Gin、TypeScript 微信小程序、Flutter/Riverpod/Dio、OpenAPI、Playwright/Go test、Codex CLI 第三方代理开发与审查。

---

## 执行规则

1. 每个可独立验证的阶段必须及时提交 Git。
2. 每次提交前更新 `CHANGELOG.md`。
3. 开发任务优先交给 Codex CLI 执行；Hermes 做验收、补充沟通、集成与部署。
4. 代码落地前后必须有自动化验证；当前环境缺少 Flutter SDK 时，Flutter 阶段先生成工程代码与文档，SDK 安装后补跑完整测试。
5. 重要变更使用第三方代理/独立上下文审查：Codex 自审 + Hermes independent reviewer 双重检查。
6. 医疗相关逻辑只做记录、提醒与风险分层，不输出剂量调整建议。

---

## Task 1: Monorepo 基础治理与契约目录

**Objective:** 建立正式开发目录、API 契约位置、变更记录和工程说明。

**Files:**
- Create: `CHANGELOG.md`
- Create: `docs/plans/2026-04-24-multiplatform-mvp.md`
- Create: `packages/api-contract/openapi.yaml`
- Modify: `README.md`

**Steps:**
1. 新增 OpenAPI 初稿，覆盖 health、auth、home summary、medication records、INR records、settings。
2. 新增 CHANGELOG，记录正式开发启动。
3. README 增加 monorepo 开发入口、验证命令和当前环境限制。
4. 运行 Markdown/产品测试。
5. 提交：`docs: start multiplatform mvp plan`。

**Verification:**
- `npm run test:product`
- `npm run test:md-preview`
- `git status --short` clean after commit。

---

## Task 2: 服务端 Go/Gin MVP 骨架

**Objective:** 创建 `server/` Go API 服务，先实现内存仓储版本，便于三端联调。

**Files:**
- Create: `server/go.mod`
- Create: `server/cmd/api/main.go`
- Create: `server/internal/model/*.go`
- Create: `server/internal/service/*.go`
- Create: `server/internal/handler/*.go`
- Create: `server/internal/repository/memory/*.go`
- Create: `server/internal/router/router.go`
- Create: `server/tests/api_test.go`

**Acceptance:**
- `GET /healthz` 返回 ok。
- `GET /api/v1/home/summary` 返回首页强提醒、最近 INR、下次检测、今日服药状态。
- `POST /api/v1/medication/records` 记录 action_type、系统时间、明日剂量选择。
- `POST /api/v1/inr/records` 保存 raw/corrected INR、检测方式、异常分层。
- `GET/PUT /api/v1/settings` 支持检测方式、偏移量、检测周期 day/week/month。

**Verification:**
- `cd server && go test ./...`
- `go run ./cmd/api` 后 curl smoke test。
- 提交：`feat(server): add Go API MVP skeleton`。

---

## Task 3: 微信小程序 TypeScript MVP 骨架

**Objective:** 创建 `miniapp/` 原生小程序 TS 结构，按当前 UI 方案实现核心页面骨架与 API 请求层。

**Files:**
- Create: `miniapp/project.config.json`
- Create: `miniapp/miniprogram/app.json`
- Create: `miniapp/miniprogram/app.ts`
- Create: `miniapp/miniprogram/utils/request.ts`
- Create: `miniapp/miniprogram/types/api.ts`
- Create: `miniapp/miniprogram/pages/home/*`
- Create: `miniapp/miniprogram/pages/medication/*`
- Create: `miniapp/miniprogram/pages/inr/*`
- Create: `miniapp/miniprogram/pages/settings/*`

**Acceptance:**
- 首页显示最近 INR、下次检测、强提醒。
- 完成服药弹出明日剂量选择。
- INR 页面双曲线数据结构、异常分层文案。
- 设置页检测方式、偏移量、检测周期。

**Verification:**
- `cd miniapp && npm test` 或最小 TypeScript 校验。
- 提交：`feat(miniapp): add TypeScript mini program MVP skeleton`。

---

## Task 4: Flutter Android/iOS MVP 骨架

**Objective:** 创建 `app_flutter/` Flutter 跨端结构，复用 API contract 和当前 UI 信息架构。

**Files:**
- Create: `app_flutter/pubspec.yaml`
- Create: `app_flutter/lib/main.dart`
- Create: `app_flutter/lib/core/api/api_client.dart`
- Create: `app_flutter/lib/features/home/*`
- Create: `app_flutter/lib/features/medication/*`
- Create: `app_flutter/lib/features/inr/*`
- Create: `app_flutter/lib/features/settings/*`
- Create: `app_flutter/test/*`

**Acceptance:**
- Android/iOS 共用页面：首页、记录/服药、INR、我的/设置。
- 支持校正后/校正前 INR 展示模型。
- 首页强提醒与服药完成后明日剂量选择。

**Verification:**
- 当前环境若无 Flutter SDK：提交源码骨架与 `app_flutter/README.md` 标注待 SDK 验证。
- SDK 可用后运行 `flutter test`。
- 提交：`feat(app): add Flutter MVP skeleton`。

---

## Task 5: 集成联调、审查与变更记录

**Objective:** 服务端与两类客户端统一接口、完成端到端 smoke test、第三方代理代码审查。

**Files:**
- Modify: `CHANGELOG.md`
- Create: `docs/reviews/*.md`
- Create: `docs/runbooks/local-dev.md`

**Steps:**
1. 启动服务端，跑 API smoke。
2. 检查小程序/Flutter API 类型与 OpenAPI 一致。
3. 使用 Codex CLI 做第三方代码审查，输出到 `docs/reviews/`。
4. Hermes independent reviewer 复核关键 diff。
5. 修复审查问题。
6. 最终提交和部署/预览更新。

**Verification:**
- `cd server && go test ./...`
- `npm run test:product && npm run test:md-preview`
- Codex review 记录存在。
- Git clean。
