// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'picture_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Picture notifier

@ProviderFor(PictureNotifier)
const pictureProvider = PictureNotifierFamily._();

/// Picture notifier
final class PictureNotifierProvider
    extends $AsyncNotifierProvider<PictureNotifier, Picture> {
  /// Picture notifier
  const PictureNotifierProvider._({
    required PictureNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'pictureProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pictureNotifierHash();

  @override
  String toString() {
    return r'pictureProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PictureNotifier create() => PictureNotifier();

  @override
  bool operator ==(Object other) {
    return other is PictureNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pictureNotifierHash() => r'be0b529298a88f4e8c80c0604a42fa3dcb52aba2';

/// Picture notifier

final class PictureNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          PictureNotifier,
          AsyncValue<Picture>,
          Picture,
          FutureOr<Picture>,
          String
        > {
  const PictureNotifierFamily._()
    : super(
        retry: null,
        name: r'pictureProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Picture notifier

  PictureNotifierProvider call(String pictureId) =>
      PictureNotifierProvider._(argument: pictureId, from: this);

  @override
  String toString() => r'pictureProvider';
}

/// Picture notifier

abstract class _$PictureNotifier extends $AsyncNotifier<Picture> {
  late final _$args = ref.$arg as String;
  String get pictureId => _$args;

  FutureOr<Picture> build(String pictureId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<Picture>, Picture>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Picture>, Picture>,
              AsyncValue<Picture>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
