// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_edit_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Item edit notifier

@ProviderFor(ItemEdit)
const itemEditProvider = ItemEditProvider._();

/// Item edit notifier
final class ItemEditProvider
    extends $NotifierProvider<ItemEdit, ItemEditState> {
  /// Item edit notifier
  const ItemEditProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'itemEditProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$itemEditHash();

  @$internal
  @override
  ItemEdit create() => ItemEdit();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ItemEditState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ItemEditState>(value),
    );
  }
}

String _$itemEditHash() => r'e201b819e520c77f61fa1f145513d156a52a208d';

/// Item edit notifier

abstract class _$ItemEdit extends $Notifier<ItemEditState> {
  ItemEditState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ItemEditState, ItemEditState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ItemEditState, ItemEditState>,
              ItemEditState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
