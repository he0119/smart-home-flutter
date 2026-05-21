// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_home_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Storage home notifier

@ProviderFor(StorageHome)
final storageHomeProvider = StorageHomeProvider._();

/// Storage home notifier
final class StorageHomeProvider
    extends $NotifierProvider<StorageHome, StorageHomeState> {
  /// Storage home notifier
  StorageHomeProvider._()
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

String _$storageHomeHash() => r'2abea5b3ddcd6313a056b649e042c49895f8e856';

/// Storage home notifier

abstract class _$StorageHome extends $Notifier<StorageHomeState> {
  StorageHomeState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<StorageHomeState, StorageHomeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StorageHomeState, StorageHomeState>,
              StorageHomeState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
