// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_edit_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Storage edit notifier

@ProviderFor(StorageEdit)
const storageEditProvider = StorageEditProvider._();

/// Storage edit notifier
final class StorageEditProvider
    extends $NotifierProvider<StorageEdit, StorageEditState> {
  /// Storage edit notifier
  const StorageEditProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storageEditProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storageEditHash();

  @$internal
  @override
  StorageEdit create() => StorageEdit();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StorageEditState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StorageEditState>(value),
    );
  }
}

String _$storageEditHash() => r'1dcecd062c92efb3c09cad038d804ba552de1e93';

/// Storage edit notifier

abstract class _$StorageEdit extends $Notifier<StorageEditState> {
  StorageEditState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<StorageEditState, StorageEditState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StorageEditState, StorageEditState>,
              StorageEditState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
