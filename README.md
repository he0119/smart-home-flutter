# Smart Home Flutter

[智慧家庭](https://github.com/he0119/smart-home) 客户端（不支持 iOS）

## Requirements

- Flutter (Channel dev, 1.26.0-8.0.pre)

## Setup

启用 Web 和 Windows 功能

```shell
flutter channel dev
flutter upgrade
flutter config --enable-web
flutter config --enable-windows-desktop
```

## Run

项目通过 `main_dev.dart` 和 `main_prod.dart` 两个文件分离测试和正式环境的配置。运行时需要指定文件。

```shell
flutter run -t ./lib/main_dev.dart
# flutter run -t ./lib/main_prod.dart
```

## Android

编译正式版 `Android` 软件需要先根据 [文档](https://flutter.dev/docs/deployment/android) 创建签名。
接着运行 `flutter build apk --split-per-abi -t ./lib/main_prod.dart --flavor prod` 完成编译。

## Web

使用 `flutter build web -t ./lib/main_prod.dart` 编译网页版。

## Windows

使用 `flutter build windows -t ./lib/main_prod.dart` 编译 Windows 版。
