// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Topic detail notifier

@ProviderFor(TopicDetail)
final topicDetailProvider = TopicDetailFamily._();

/// Topic detail notifier
final class TopicDetailProvider
    extends $NotifierProvider<TopicDetail, TopicDetailState> {
  /// Topic detail notifier
  TopicDetailProvider._({
    required TopicDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'topicDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$topicDetailHash();

  @override
  String toString() {
    return r'topicDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TopicDetail create() => TopicDetail();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TopicDetailState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TopicDetailState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TopicDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$topicDetailHash() => r'f3bfc5e56fa6f99ad60a9352ccd73461a22e053e';

/// Topic detail notifier

final class TopicDetailFamily extends $Family
    with
        $ClassFamilyOverride<
          TopicDetail,
          TopicDetailState,
          TopicDetailState,
          TopicDetailState,
          String
        > {
  TopicDetailFamily._()
    : super(
        retry: null,
        name: r'topicDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Topic detail notifier

  TopicDetailProvider call(String topicId) =>
      TopicDetailProvider._(argument: topicId, from: this);

  @override
  String toString() => r'topicDetailProvider';
}

/// Topic detail notifier

abstract class _$TopicDetail extends $Notifier<TopicDetailState> {
  late final _$args = ref.$arg as String;
  String get topicId => _$args;

  TopicDetailState build(String topicId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TopicDetailState, TopicDetailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TopicDetailState, TopicDetailState>,
              TopicDetailState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
