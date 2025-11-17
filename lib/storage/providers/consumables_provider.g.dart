// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consumables_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Consumables notifier

@ProviderFor(Consumables)
const consumablesProvider = ConsumablesProvider._();

/// Consumables notifier
final class ConsumablesProvider
    extends $NotifierProvider<Consumables, ConsumablesState> {
  /// Consumables notifier
  const ConsumablesProvider._()
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

String _$consumablesHash() => r'70412e6b02e74665db7a273209278da4dbb03c1f';

/// Consumables notifier

abstract class _$Consumables extends $Notifier<ConsumablesState> {
  ConsumablesState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ConsumablesState, ConsumablesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ConsumablesState, ConsumablesState>,
              ConsumablesState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
