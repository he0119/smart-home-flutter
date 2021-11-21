# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/lang/zh-CN/spec/v2.0.0.html).

## [Unreleased]

## [0.8.2] - 2021-11-21

### Added

- 支持从网页上传图片

### Changed

- 优化了应用启动流程
- 使用 SettingsController 来管理设置

### Fixed

- 修复头像无法显示的问题
- 修复在 Android 11(API 级别 30) 中无法在浏览器中打开网页的问题

## [0.8.1] - 2021-11-14

### Fixed

- 修复无法修改删除话题或评论的问题

## [0.8.0] - 2021-11-14

### Added

- 添加页面转跳动画
- 添加直接从软件访问 Django Admin 的功能

### Changed

- 升级至 Flutter 2.5
- 使用服务器提供的头像

### Fixed

- 修复无设备数据时的报错
- 修复小米推送注册的问题

## [0.7.5] - 2021-10-29

### Added

- 添加主题设置
- 上传界面支持从图库中选择图片

### Changed

- 升级至 Flutter 2.2
- 优化物品界面，总是显示添加物品的按钮
- 优化搜索体验，去除抖动

## [0.7.4] - 2021-03-29

### Added

- 集成 Sentry
- 切换到空安全

### Changed

- 调整项目结构
- 图片背景颜色跟随系统

### Fixed

- 修复网页版无法正常显示的问题
- 根据 `very_good_analysis` 规则修复代码
- 修复添加评论的文本框无法使用回车换行的问题
- 修复登录界面 `RenderFlex overflowed` 问题
- 修复无法通过网址转跳到博客页面的问题

## [0.7.3] - 2021-03-21

### Added

- 支持显示图片网址
- 优化客户端的图片显示，支持放大缩小

### Changed

- 重新创建项目，并修改了名称
- 设置上传文件的 contentType，并直接传递图片地址

### Fixed

- 修复通过 URL 访问物品详情页面出错的问题

## [0.7.2] - 2021-03-12

### Added

- 支持上传物品照片

## [0.7.1] - 2021-03-05

### Changed

- 升级至 Flutter 2.0.0
- 更换安卓应用 ID
- 优化 Android 应用链接

### Fixed

- 修复刷新令牌失效后无法正常登出的问题
- 修复请求不必要数据的问题

## [0.7.0] - 2021-01-11

### Added

- 支持 Android 应用链接
- 所有列表均添加无限列表

### Changed

- 优化物品管理加载页面的显示
- 给更多的页面添加网址支持
- 给客户端加上 User-Agent
- 移除网址上的 # 号
- 网页版的物品管理相关网址直接显示物品或者位置名称
- 仅在安卓上显示小米推送的设置

### Fixed

- 修复消息条挡住评论框的问题
- 修复搜索界面单击搜索结果后键盘未收起的问题
- 修复评论编辑预览界面还存在编辑按钮的问题
- 修复话题详情界面的网址显示

## [0.6.1] - 2020-12-25

### Added

- 评论支持选择倒序排列

### Fixed

- 修复物品备注为 null 时无法显示的问题
- 修复物联网数据显示不正常的问题

## [0.6.0] - 2020-12-25

### Added

- 添加路由支持，网页版现在可以通过 URL 导航
- 完善留言板
- 添加回收站与耗材管理

### Changed

- 使用 relay 格式

### Fixed

- 修复物品管理中错误提示显示两次的问题
- 修复物联网界面出现网络问题时会一直转圈的问题

## [0.5.11] - 2020-12-17

### Added

- 支持在安卓保存用户名密码用以自动填充

### Changed

- 统一 SnackBar

### Fixed

- 修复提示更新的时候，新版本的安装文件不存在的问题

## [0.5.10] - 2020-12-05

### Added

- 添加注册多个设备的功能
- 添加手动同步小米推送的注册标识码的功能
- 开发和正式版使用不同的应用 ID

## [0.5.9] - 2020-11-28

### Fixed

- 修复文本框删除键一次删除两个字符的问题

## [0.5.8] - 2020-11-28

### Added

- 小米推送

## [0.5.7] - 2020-11-13

### Added

- 添加初步的 Windows 支持（不完善）

### Changed

- 允许留言板详情界面中的文字被选中

### Fixed

- 修复搜索界面图标在选中文本框时无法看清的问题
- 修复修改物品时有效期消失的问题
- 修复令牌过期时，无法正确提示并删除过期令牌的问题
- 修复网页版无法打开关于界面的问题

## [0.5.6] - 2020-08-17

### Added

- 添加独立设置界面和工具提示消息

### Changed

- 在更多页面使用消息栏提示
- 统一按钮样式
- 图片使用 webp 格式
- 提高 Drawer 中头像的分辨率至 512px

## [0.5.5] - 2020-08-08

### Added

- 添加登出按钮

### Changed

- 优化表单验证
- 优化登录过程
- 完善主页面的显示

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

[Unreleased]: https://github.com/he0119/smart-home-flutter/compare/v0.8.2...HEAD

[0.8.2]: https://github.com/he0119/smart-home-flutter/compare/v0.8.1...v0.8.2
[0.8.1]: https://github.com/he0119/smart-home-flutter/compare/v0.8.0...v0.8.1
[0.8.0]: https://github.com/he0119/smart-home-flutter/compare/v0.7.5...v0.8.0
[0.7.5]: https://github.com/he0119/smart-home-flutter/compare/v0.7.4...v0.7.5
[0.7.4]: https://github.com/he0119/smart-home-flutter/compare/v0.7.3...v0.7.4
[0.7.3]: https://github.com/he0119/smart-home-flutter/compare/v0.7.2...v0.7.3
[0.7.2]: https://github.com/he0119/smart-home-flutter/compare/v0.7.1...v0.7.2
[0.7.1]: https://github.com/he0119/smart-home-flutter/compare/v0.7.0...v0.7.1
[0.7.0]: https://github.com/he0119/smart-home-flutter/compare/v0.6.1...v0.7.0
[0.6.1]: https://github.com/he0119/smart-home-flutter/compare/v0.6.0...v0.6.1
[0.6.0]: https://github.com/he0119/smart-home-flutter/compare/v0.5.11...v0.6.0
[0.5.11]: https://github.com/he0119/smart-home-flutter/compare/v0.5.10...v0.5.11
[0.5.10]: https://github.com/he0119/smart-home-flutter/compare/v0.5.9...v0.5.10
[0.5.9]: https://github.com/he0119/smart-home-flutter/compare/v0.5.8...v0.5.9
[0.5.8]: https://github.com/he0119/smart-home-flutter/compare/v0.5.7...v0.5.8
[0.5.7]: https://github.com/he0119/smart-home-flutter/compare/v0.5.6...v0.5.7
[0.5.6]: https://github.com/he0119/smart-home-flutter/compare/v0.5.5...v0.5.6
[0.5.5]: https://github.com/he0119/smart-home-flutter/compare/v0.5.4...v0.5.5
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
