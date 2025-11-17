// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tab notifier - 管理底部导航栏的当前标签

@ProviderFor(Tab)
const tabProvider = TabProvider._();

/// Tab notifier - 管理底部导航栏的当前标签
final class TabProvider extends $NotifierProvider<Tab, AppTab?> {
  /// Tab notifier - 管理底部导航栏的当前标签
  const TabProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabHash();

  @$internal
  @override
  Tab create() => Tab();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppTab? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppTab?>(value),
    );
  }
}

String _$tabHash() => r'bf4e89f61251b1dd7fed45c2b7bd1e236a17c43a';

/// Tab notifier - 管理底部导航栏的当前标签

abstract class _$Tab extends $Notifier<AppTab?> {
  AppTab? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AppTab?, AppTab?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppTab?, AppTab?>,
              AppTab?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
