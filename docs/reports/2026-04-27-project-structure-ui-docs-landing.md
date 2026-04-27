# 2026-04-27 项目结构与 UI/Docs 统一入口整理报告

## 背景问题

本轮整理前，仓库中同时存在 `miniapp/`、`app_flutter/`、根目录静态原型文件和 `docs/` 文档目录：

- 代码目录命名不统一，微信小程序与 Flutter 端名称和用户期望不一致。
- 根路径直接进入 UI 原型，`ui` 与 `docs` 缺少统一、清晰的在线入口。
- Cloudflare 构建产物中只有旧的 `/wechat/...`、`/android/...`、`/ios/...` 深链，缺少 `/ui/...` 的规范路径。
- CI、测试、文档仍引用旧目录，后续维护容易漂移。

## 调整目标

1. 仓库根目录形成清晰边界：`ui/`、`docs/`、`server/`、`wxapp/`、`flutter/`。
2. `miniapp/` 统一改名为 `wxapp/`。
3. `app_flutter/` 统一改名为 `flutter/`。
4. Cloudflare 根路径 `/` 成为统一入口，明确进入 `/ui/` 与 `/docs/`。
5. 新增 `/ui/` 规范 UI 原型路径，同时保留旧 `/wechat/...`、`/android/...`、`/ios/...` 兼容访问。
6. `/docs/` 提供文档中心卡片入口，Markdown 文档继续美化渲染，并保留 `?raw=1` 原文访问。

## 实际改动

### 目录结构

- `miniapp/` → `wxapp/`
- `app_flutter/` → `flutter/`
- 根静态 UI 文件迁入 `ui/`：
  - `ui/index.html`
  - `ui/app.js`
  - `ui/styles.css`
  - `ui/markdown.js`
- 根目录新增轻量统一入口 `index.html`。

### 构建与路由

- `build-dist.py` 调整为：
  - 复制根入口到 `dist/index.html`。
  - 复制 UI 原型到 `dist/ui/`。
  - 生成 `/ui/{platform}/{route}/` 规范预览路由。
  - 保留旧 `/{platform}/{route}/` 兼容预览路由。
  - 生成 `/docs/` 文档中心。
  - 将本报告加入 Markdown 预览与文档中心。

### 测试与 CI

- `route-coverage.spec.cjs` 增加 `/`、`/ui/`、`/docs/` 覆盖，并同时验证新旧平台深链。
- `product-refinement.spec.cjs` 改为优先验证 `/ui/wechat/...` 规范路径。
- GitHub Actions 改用 `wxapp/`，并补充 Flutter analyze/test 与 route coverage 测试。

### 文档

- README、UI 说明、架构报告、产品功能清单、验证报告等同步更新为 `wxapp/`、`flutter/`、`ui/`、`docs/` 的新边界。
- 旧历史报告中的历史事实按需保留或用当前命令补充说明。

## 预期访问路径

- 统一入口：`/`
- UI 原型入口：`/ui/`
- Docs 文档中心：`/docs/`
- 新 UI 深链：`/ui/wechat/home/`、`/ui/android/inr/`、`/ui/ios/me/`
- 旧兼容深链：`/wechat/home/`、`/android/inr/`、`/ios/me/`
- 本报告：`/docs/reports/2026-04-27-project-structure-ui-docs-landing/`

## 验证要求

本轮完成前需要通过：

```sh
python3 -m py_compile build-dist.py
node --check ui/app.js
node --check ui/markdown.js
node --check route-coverage.spec.cjs
npm run build
npm run test:product
npm run test:routes
npm run test:md-preview
cd wxapp && npm test
cd server && go test ./... && go vet ./...
cd flutter && flutter analyze && flutter test
```

部署后需要线上冒烟 `/`、`/ui/`、`/docs/`、至少一个 `/ui/...` 深链、至少一个旧兼容深链和本报告 URL。
