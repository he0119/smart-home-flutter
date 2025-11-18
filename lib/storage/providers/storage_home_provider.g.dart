// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_home_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Storage home notifier

@ProviderFor(StorageHome)
const storageHomeProvider = StorageHomeProvider._();

/// Storage home notifier
final class StorageHomeProvider
    extends $NotifierProvider<StorageHome, StorageHomeState> {
  /// Storage home notifier
  const StorageHomeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storageHomeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storageHomeHash();

  @$internal
  @override
  StorageHome create() => StorageHome();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StorageHomeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StorageHomeState>(value),
    );
  }
}

String _$storageHomeHash() => r'cfaf3454cff2c993cede642966d0b0dec0068a0e';

/// Storage home notifier

abstract class _$StorageHome extends $Notifier<StorageHomeState> {
  StorageHomeState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<StorageHomeState, StorageHomeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StorageHomeState, StorageHomeState>,
              StorageHomeState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
