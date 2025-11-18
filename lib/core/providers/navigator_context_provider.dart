import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigator_context_provider.g.dart';

/// 提供全局Navigator的BuildContext
@riverpod
class NavigatorContext extends _$NavigatorContext {
  @override
  BuildContext? build() => null;

  void setContext(BuildContext context) {
    state = context;
  }

  void clearContext() {
    state = null;
  }
}