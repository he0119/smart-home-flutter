# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/lang/zh-CN/spec/v2.0.0.html).

## [Unreleased]

## [0.5.4] - 2020-08-07

### Added

- 添加设置界面

### Changed

- 检查更新通过 GitHub Releases 页面获取最新版本号

## [0.5.3] - 2020-08-01

### Changed

- 更新下载地址使用 FastGit 加速服务器
- 应用图标使用知行何家的图标

### Fixed

- 修复网页版博客页面无法转跳的问题

## [0.5.2] - 2020-07-26

### Changed

- 日期文字使用 24 小时制

### Fixed

- 修复无法立即获取数据的问题
- 修复修改刷新间隔之后，页面的刷新间隔并没有改变的问题

## [0.5.1] - 2020-07-22

### Changed

- 优化博客页面体验

## [0.5.0] - 2020-07-20

### Added

- 物联网功能

## [0.4.0] - 2020-07-16

### Added

- 留言板（仅有添加话题和留言的功能）
- 设置服务器地址的功能

### Changed

- 优化页面导航逻辑
- 完善登录逻辑

### Fixed

- 修复物品详情无法选中复制的问题
- 修复进入搜索界面无法自动选中搜索框的问题

## [0.3.2] - 2020-06-28

### Added

- 登陆时可自动填写用户名密码（暂时只支持在 `web` 上保存用户名密码） [flutter#55613](https://github.com/flutter/flutter/issues/55613)

## [0.3.1] - 2020-03-26

### Fixed

- 网页版无法使用 `WebView`
- 网页版不需要检查应用更新

## [0.3.0] - 2020-03-21

### Added

- 新版本提示

## [0.2.2] - 2020-03-20

### Changed

- 使物品管理首页显示的时间符合日常习惯

## [0.2.1] - 2020-03-16

### Changed

- 调整 SnackBar 的颜色

### Fixed

- 修复上一级界面的物品数据没有自动更新的问题

## [0.2.0] - 2020-03-13

### Added

- 搜索结果添加关键字高亮
- 位置详情界面添加位置指示

### Changed

- 物品管理主界面将展示过期物品，即将过期，最近添加和最近更新的物品
- 调整 `Webview` 将 `IOT` 和博客内嵌至软件

## [0.1.2] - 2020-03-09

### Added

- 添加各种操作提示

### Changed

- 单击导航按钮时会直接打开网页

## [0.1.1] - 2020-03-09

### Added

- 通过调用 WebView 在软件中展示 IOT 和博客网站
- 在物品和位置详情页添加搜索按钮
- 添加 App Shortcuts

### Changed

- 完善启动软件时的错误处理

## [0.1.0] - 2020-03-08

### Added

- 利用 Flutter 编写的第一个可用的智慧家庭客户端

[Unreleased]: https://github.com/he0119/smart-home-flutter/compare/v0.5.4...HEAD

[0.5.4]: https://github.com/he0119/smart-home-flutter/compare/v0.5.3...v0.5.4
[0.5.3]: https://github.com/he0119/smart-home-flutter/compare/v0.5.2...v0.5.3
[0.5.2]: https://github.com/he0119/smart-home-flutter/compare/v0.5.1...v0.5.2
[0.5.1]: https://github.com/he0119/smart-home-flutter/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/he0119/smart-home-flutter/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/he0119/smart-home-flutter/compare/v0.3.2...v0.4.0
[0.3.2]: https://github.com/he0119/smart-home-flutter/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/he0119/smart-home-flutter/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/he0119/smart-home-flutter/compare/v0.2.2...v0.3.0
[0.2.2]: https://github.com/he0119/smart-home-flutter/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/he0119/smart-home-flutter/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/he0119/smart-home-flutter/compare/v0.1.2...v0.2.0
[0.1.2]: https://github.com/he0119/smart-home-flutter/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/he0119/smart-home-flutter/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/he0119/smart-home-flutter/releases/tag/v0.1.0
