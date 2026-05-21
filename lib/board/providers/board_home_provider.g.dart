// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'board_home_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Board home notifier

@ProviderFor(BoardHome)
final boardHomeProvider = BoardHomeProvider._();

/// Board home notifier
final class BoardHomeProvider
    extends $NotifierProvider<BoardHome, BoardHomeState> {
  /// Board home notifier
  BoardHomeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'boardHomeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$boardHomeHash();

  @$internal
  @override
  BoardHome create() => BoardHome();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BoardHomeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BoardHomeState>(value),
    );
  }
}

String _$boardHomeHash() => r'f81d8af40f3b031c6360f118706b307065bf3fd3';

/// Board home notifier

abstract class _$BoardHome extends $Notifier<BoardHomeState> {
  BoardHomeState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<BoardHomeState, BoardHomeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BoardHomeState, BoardHomeState>,
              BoardHomeState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
