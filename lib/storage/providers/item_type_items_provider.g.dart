// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_type_items_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 某一类物品的完整列表（首页分组点「全部」进来）

@ProviderFor(ItemTypeItems)
final itemTypeItemsProvider = ItemTypeItemsFamily._();

/// 某一类物品的完整列表（首页分组点「全部」进来）
final class ItemTypeItemsProvider
    extends $NotifierProvider<ItemTypeItems, ItemTypeItemsState> {
  /// 某一类物品的完整列表（首页分组点「全部」进来）
  ItemTypeItemsProvider._({
    required ItemTypeItemsFamily super.from,
    required ItemType super.argument,
  }) : super(
         retry: null,
         name: r'itemTypeItemsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$itemTypeItemsHash();

  @override
  String toString() {
    return r'itemTypeItemsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ItemTypeItems create() => ItemTypeItems();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ItemTypeItemsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ItemTypeItemsState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ItemTypeItemsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$itemTypeItemsHash() => r'5c06f35b90e213cac241850f62177c9a4d8f8383';

/// 某一类物品的完整列表（首页分组点「全部」进来）

final class ItemTypeItemsFamily extends $Family
    with
        $ClassFamilyOverride<
          ItemTypeItems,
          ItemTypeItemsState,
          ItemTypeItemsState,
          ItemTypeItemsState,
          ItemType
        > {
  ItemTypeItemsFamily._()
    : super(
        retry: null,
        name: r'itemTypeItemsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 某一类物品的完整列表（首页分组点「全部」进来）

  ItemTypeItemsProvider call(ItemType type) =>
      ItemTypeItemsProvider._(argument: type, from: this);

  @override
  String toString() => r'itemTypeItemsProvider';
}

/// 某一类物品的完整列表（首页分组点「全部」进来）

abstract class _$ItemTypeItems extends $Notifier<ItemTypeItemsState> {
  late final _$args = ref.$arg as ItemType;
  ItemType get type => _$args;

  ItemTypeItemsState build(ItemType type);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ItemTypeItemsState, ItemTypeItemsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ItemTypeItemsState, ItemTypeItemsState>,
              ItemTypeItemsState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
