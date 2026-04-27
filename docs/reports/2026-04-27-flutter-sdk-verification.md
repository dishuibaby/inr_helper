# 2026-04-27 Flutter SDK 安装与端侧验证报告

## 1. 现有问题

上一轮验证中，`app_flutter` 无法执行 Flutter 测试，根因是当前机器缺少可调用的 Flutter CLI：

```text
flutter: command not found
```

这会导致 Flutter Android/iOS 端只能做代码静态阅读，无法通过 `flutter analyze` 与 `flutter test` 对模型解析、请求序列化和页面代码进行真实 SDK 级验证。

## 2. 改动原因

用户明确要求“缺少环境就安装环境，有问题就解决问题”，因此本轮不再把缺少 Flutter 作为阻塞项，而是按 PUA / systematic-debugging 流程处理：

1. 先确认系统架构、磁盘、现有工具链和 Flutter 缺失状态；
2. 安装用户级 Flutter SDK，避免污染项目目录和系统包；
3. 跑真实 Flutter 验证；
4. 对 SDK 升级暴露出的代码问题做最小修复；
5. 将验证结论沉淀到文档站。

## 3. 环境处理

本机已配置：

- Flutter SDK：`/home/pi/.hermes/tools/flutter`
- CLI 链接：`/home/pi/.local/bin/flutter`
- 安装方式：用户目录安装，不写入项目仓库，不记录任何凭据。

> 说明：`flutter doctor` 仍可能提示 Android SDK、Chrome 或 Linux 桌面构建依赖缺失；这不影响本轮 `app_flutter` 的 Dart/Flutter 单元测试与静态分析。后续如要真机构建 Android/iOS，再按目标平台补齐原生工具链。

## 4. 代码修复

安装 Flutter 后执行 `flutter analyze` 暴露出 SDK API 兼容问题，本轮做了三处最小修复：

| 文件 | 问题 | 处理 |
|---|---|---|
| `app_flutter/lib/core/theme/app_theme.dart` | 新版 Flutter `ThemeData.cardTheme` 期望 `CardThemeData?` | 将 `CardTheme` 调整为 `CardThemeData` |
| `app_flutter/lib/features/home/widgets/reminder_banner.dart` | `Color.withOpacity` 已废弃 | 改为 `withValues(alpha: 0.10)` |
| `app_flutter/lib/features/inr/inr_page.dart` | `DropdownButtonFormField.value` 已废弃 | 改为 `initialValue` |

此外，首次执行 `flutter pub get` 生成 `app_flutter/pubspec.lock`，用于锁定当前 Flutter 端依赖版本，提升后续验证可复现性。

## 5. 验证结果

已完成以下 Flutter 验证：

```sh
cd app_flutter
flutter analyze
flutter test
```

结果：

- `flutter analyze`：通过，`No issues found!`
- `flutter test`：通过，5 个测试全部通过

测试覆盖点包括：

- 首页 `latestInr` 与 `nextTestAt` 契约字段解析；
- INR 异常分层枚举解析与未知枚举兜底；
- 服药完成后计划/手动明日剂量序列化；
- INR 请求 UTC 时间与 offset 序列化；
- 检测周期 day/week/month 设置解析与序列化。

## 6. 当前效果

本轮完成后，Flutter 端不再停留在“代码已写但本机不可验证”的状态；现在可以在当前开发机上执行真实 Flutter SDK 验证，并纳入后续完整验证流水线。

这意味着：首页最近 INR、下次检测时间、服药后明日剂量、INR 校准前/后字段、检测方式、检测周期等核心契约，已经能被 Flutter 端测试直接覆盖。

## 7. 后续建议

1. 后续 CI 可增加 Flutter SDK 缓存与 `cd app_flutter && flutter analyze && flutter test`。
2. Android 真机构建前补 Android SDK、命令行工具和签名配置。
3. iOS 构建仍需 macOS/Xcode 环境，不应在当前 Linux/ARM64 机器上承诺本地完成。
4. 如后续需要桌面预览，再补齐 Chrome/Linux desktop 依赖。
