// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consumables_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Consumables notifier

@ProviderFor(Consumables)
final consumablesProvider = ConsumablesProvider._();

/// Consumables notifier
final class ConsumablesProvider
    extends $NotifierProvider<Consumables, ConsumablesState> {
  /// Consumables notifier
  ConsumablesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'consumablesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$consumablesHash();

  @$internal
  @override
  Consumables create() => Consumables();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConsumablesState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConsumablesState>(value),
    );
  }
}

String _$consumablesHash() => r'16c302d1a6b0e9fd5252a4d2998fa7b001a75993';

/// Consumables notifier

abstract class _$Consumables extends $Notifier<ConsumablesState> {
  ConsumablesState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ConsumablesState, ConsumablesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ConsumablesState, ConsumablesState>,
              ConsumablesState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
