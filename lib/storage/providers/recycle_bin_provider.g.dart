// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recycle_bin_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// RecycleBin notifier

@ProviderFor(RecycleBin)
const recycleBinProvider = RecycleBinProvider._();

/// RecycleBin notifier
final class RecycleBinProvider
    extends $NotifierProvider<RecycleBin, RecycleBinState> {
  /// RecycleBin notifier
  const RecycleBinProvider._()
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

String _$recycleBinHash() => r'9fc8c86f97c9549bf74ce52b6674a40312b7d0b2';

/// RecycleBin notifier

abstract class _$RecycleBin extends $Notifier<RecycleBinState> {
  RecycleBinState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<RecycleBinState, RecycleBinState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RecycleBinState, RecycleBinState>,
              RecycleBinState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
