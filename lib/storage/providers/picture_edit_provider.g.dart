// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'picture_edit_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Picture edit notifier

@ProviderFor(PictureEdit)
const pictureEditProvider = PictureEditProvider._();

/// Picture edit notifier
final class PictureEditProvider
    extends $NotifierProvider<PictureEdit, PictureEditState> {
  /// Picture edit notifier
  const PictureEditProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pictureEditProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pictureEditHash();

  @$internal
  @override
  PictureEdit create() => PictureEdit();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PictureEditState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PictureEditState>(value),
    );
  }
}

String _$pictureEditHash() => r'11bc174c74f5132eac11dc24b8378da4b1b6c02d';

/// Picture edit notifier

abstract class _$PictureEdit extends $Notifier<PictureEditState> {
  PictureEditState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<PictureEditState, PictureEditState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PictureEditState, PictureEditState>,
              PictureEditState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
