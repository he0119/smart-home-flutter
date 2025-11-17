// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_edit_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Comment edit notifier

@ProviderFor(CommentEdit)
const commentEditProvider = CommentEditProvider._();

/// Comment edit notifier
final class CommentEditProvider
    extends $NotifierProvider<CommentEdit, CommentEditState> {
  /// Comment edit notifier
  const CommentEditProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'commentEditProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$commentEditHash();

  @$internal
  @override
  CommentEdit create() => CommentEdit();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommentEditState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommentEditState>(value),
    );
  }
}

String _$commentEditHash() => r'45b7c346a91aee89385c314b1b9d6671f8e0692b';

/// Comment edit notifier

abstract class _$CommentEdit extends $Notifier<CommentEditState> {
  CommentEditState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<CommentEditState, CommentEditState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CommentEditState, CommentEditState>,
              CommentEditState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
