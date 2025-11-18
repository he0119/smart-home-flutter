// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigator_context_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 提供全局Navigator的BuildContext

@ProviderFor(NavigatorContext)
const navigatorContextProvider = NavigatorContextProvider._();

/// 提供全局Navigator的BuildContext
final class NavigatorContextProvider
    extends $NotifierProvider<NavigatorContext, BuildContext?> {
  /// 提供全局Navigator的BuildContext
  const NavigatorContextProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'navigatorContextProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$navigatorContextHash();

  @$internal
  @override
  NavigatorContext create() => NavigatorContext();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BuildContext? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BuildContext?>(value),
    );
  }
}

String _$navigatorContextHash() => r'ef17591b446b01aa15ffc14dd8a83f23b1a6f9fd';

/// 提供全局Navigator的BuildContext

abstract class _$NavigatorContext extends $Notifier<BuildContext?> {
  BuildContext? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<BuildContext?, BuildContext?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BuildContext?, BuildContext?>,
              BuildContext?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
