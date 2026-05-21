// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recycle_bin_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// RecycleBin notifier

@ProviderFor(RecycleBin)
final recycleBinProvider = RecycleBinProvider._();

/// RecycleBin notifier
final class RecycleBinProvider
    extends $NotifierProvider<RecycleBin, RecycleBinState> {
  /// RecycleBin notifier
  RecycleBinProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recycleBinProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recycleBinHash();

  @$internal
  @override
  RecycleBin create() => RecycleBin();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecycleBinState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecycleBinState>(value),
    );
  }
}

String _$recycleBinHash() => r'5d082b32359beb2745380e60ba3b7e926d155a13';

/// RecycleBin notifier

abstract class _$RecycleBin extends $Notifier<RecycleBinState> {
  RecycleBinState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<RecycleBinState, RecycleBinState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RecycleBinState, RecycleBinState>,
              RecycleBinState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
