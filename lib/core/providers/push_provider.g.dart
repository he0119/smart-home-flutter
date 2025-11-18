// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Push Notifier

@ProviderFor(Push)
const pushProvider = PushProvider._();

/// Push Notifier
final class PushProvider extends $NotifierProvider<Push, PushInfo> {
  /// Push Notifier
  const PushProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushHash();

  @$internal
  @override
  Push create() => Push();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PushInfo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PushInfo>(value),
    );
  }
}

String _$pushHash() => r'ea4a9e974aa704076ea4a1fc38f43ea0aefec075';

/// Push Notifier

abstract class _$Push extends $Notifier<PushInfo> {
  PushInfo build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<PushInfo, PushInfo>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PushInfo, PushInfo>,
              PushInfo,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
