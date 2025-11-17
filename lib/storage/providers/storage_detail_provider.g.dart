// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Storage detail notifier

@ProviderFor(StorageDetail)
const storageDetailProvider = StorageDetailFamily._();

/// Storage detail notifier
final class StorageDetailProvider
    extends $NotifierProvider<StorageDetail, StorageDetailState> {
  /// Storage detail notifier
  const StorageDetailProvider._({
    required StorageDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'storageDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$storageDetailHash();

  @override
  String toString() {
    return r'storageDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  StorageDetail create() => StorageDetail();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StorageDetailState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StorageDetailState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StorageDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$storageDetailHash() => r'de86df07359758dd07eb7d264bc36d5aebe8f223';

/// Storage detail notifier

final class StorageDetailFamily extends $Family
    with
        $ClassFamilyOverride<
          StorageDetail,
          StorageDetailState,
          StorageDetailState,
          StorageDetailState,
          String
        > {
  const StorageDetailFamily._()
    : super(
        retry: null,
        name: r'storageDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Storage detail notifier

  StorageDetailProvider call(String storageId) =>
      StorageDetailProvider._(argument: storageId, from: this);

  @override
  String toString() => r'storageDetailProvider';
}

/// Storage detail notifier

abstract class _$StorageDetail extends $Notifier<StorageDetailState> {
  late final _$args = ref.$arg as String;
  String get storageId => _$args;

  StorageDetailState build(String storageId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<StorageDetailState, StorageDetailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StorageDetailState, StorageDetailState>,
              StorageDetailState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
