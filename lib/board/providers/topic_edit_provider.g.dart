// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic_edit_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Topic edit notifier

@ProviderFor(TopicEdit)
const topicEditProvider = TopicEditProvider._();

/// Topic edit notifier
final class TopicEditProvider
    extends $NotifierProvider<TopicEdit, TopicEditState> {
  /// Topic edit notifier
  const TopicEditProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'topicEditProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$topicEditHash();

  @$internal
  @override
  TopicEdit create() => TopicEdit();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TopicEditState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TopicEditState>(value),
    );
  }
}

String _$topicEditHash() => r'ea206180032a5af79cdc0e9d22b3ca7b3a0d183a';

/// Topic edit notifier

abstract class _$TopicEdit extends $Notifier<TopicEditState> {
  TopicEditState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<TopicEditState, TopicEditState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TopicEditState, TopicEditState>,
              TopicEditState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
