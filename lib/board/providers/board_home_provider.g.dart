// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'board_home_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Board repository provider

@ProviderFor(boardRepository)
const boardRepositoryProvider = BoardRepositoryProvider._();

/// Board repository provider

final class BoardRepositoryProvider
    extends
        $FunctionalProvider<BoardRepository, BoardRepository, BoardRepository>
    with $Provider<BoardRepository> {
  /// Board repository provider
  const BoardRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'boardRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$boardRepositoryHash();

  @$internal
  @override
  $ProviderElement<BoardRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BoardRepository create(Ref ref) {
    return boardRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BoardRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BoardRepository>(value),
    );
  }
}

String _$boardRepositoryHash() => r'a18f76f69296152aa04c5c28cff6f082c9e79665';

/// Board home notifier

@ProviderFor(BoardHome)
const boardHomeProvider = BoardHomeProvider._();

/// Board home notifier
final class BoardHomeProvider
    extends $NotifierProvider<BoardHome, BoardHomeState> {
  /// Board home notifier
  const BoardHomeProvider._()
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

String _$boardHomeHash() => r'a4b70e56447968920b3868502390e319d25d918e';

/// Board home notifier

abstract class _$BoardHome extends $Notifier<BoardHomeState> {
  BoardHomeState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<BoardHomeState, BoardHomeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BoardHomeState, BoardHomeState>,
              BoardHomeState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
