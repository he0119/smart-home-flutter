// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Item detail notifier

@ProviderFor(ItemDetail)
const itemDetailProvider = ItemDetailFamily._();

/// Item detail notifier
final class ItemDetailProvider
    extends $AsyncNotifierProvider<ItemDetail, Item> {
  /// Item detail notifier
  const ItemDetailProvider._({
    required ItemDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'itemDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$itemDetailHash();

  @override
  String toString() {
    return r'itemDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ItemDetail create() => ItemDetail();

  @override
  bool operator ==(Object other) {
    return other is ItemDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$itemDetailHash() => r'71a7da31242a8f02400eb90918e55414cad956b1';

/// Item detail notifier

final class ItemDetailFamily extends $Family
    with
        $ClassFamilyOverride<
          ItemDetail,
          AsyncValue<Item>,
          Item,
          FutureOr<Item>,
          String
        > {
  const ItemDetailFamily._()
    : super(
        retry: null,
        name: r'itemDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Item detail notifier

  ItemDetailProvider call(String itemId) =>
      ItemDetailProvider._(argument: itemId, from: this);

  @override
  String toString() => r'itemDetailProvider';
}

/// Item detail notifier

abstract class _$ItemDetail extends $AsyncNotifier<Item> {
  late final _$args = ref.$arg as String;
  String get itemId => _$args;

  FutureOr<Item> build(String itemId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<Item>, Item>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Item>, Item>,
              AsyncValue<Item>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
