# AGENTS.md

## 项目概览

这是“智慧家庭”的 Flutter 客户端，不支持 iOS，主要面向 Android、Web 和 Windows。

- `lib/main_dev.dart` 和 `lib/main_prod.dart` 是开发/生产环境入口。
- `lib/app` 放应用启动、主题、Riverpod observer 等顶层配置。
- `lib/core` 放路由、设置、登录、GraphQL client、更新检查等通用能力。
- `lib/storage` 放物品/位置/图片/耗材管理。
- `lib/board` 放留言板。
- `lib/blog` 放博客相关页面。
- `lib/user` 放用户和会话相关逻辑。
- `lib/widgets` 放跨业务复用的 UI 组件。
- `test` 主要覆盖 provider、repository 组合和状态流转。

## 常用命令

- 安装依赖：`flutter pub get`
- 静态检查：`flutter analyze --no-pub`
- 运行测试：`flutter test --no-pub`
- 生成代码：`dart run build_runner build --delete-conflicting-outputs`
- 开发运行：`flutter run -t ./lib/main_dev.dart`
- 生产构建入口使用 `./lib/main_prod.dart`

## 开发约定

- 项目使用 Riverpod、GoRouter、GraphQL 和 json_serializable。
- 修改带 `part '*.g.dart'` 的 provider/model 后，记得重新跑 build_runner。
- 不要手改 `*.g.dart`、`app_localizations*.dart`、`test/mocks/mocks.mocks.dart` 这类生成文件。
- 改动后优先跑 `flutter analyze --no-pub`，涉及逻辑再跑相关测试或全量 `flutter test --no-pub`。
- 提交和 PR 标题遵循仓库已有风格：使用 conventional commit，优先中文描述，例如 `fix(storage): 修复...`、`style: 修正...`。
- 分支名也沿用仓库习惯，例如 `fix/...`、`feat/...`、`test/...`、`chore/...`，不要默认加 `codex/` 或 `[codex]` 前缀。
