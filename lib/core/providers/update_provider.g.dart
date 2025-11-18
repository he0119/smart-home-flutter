// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Update Notifier

@ProviderFor(Update)
const updateProvider = UpdateProvider._();

/// Update Notifier
final class UpdateProvider extends $NotifierProvider<Update, UpdateInfo> {
  /// Update Notifier
  const UpdateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateHash();

  @$internal
  @override
  Update create() => Update();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateInfo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateInfo>(value),
    );
  }
}

String _$updateHash() => r'593b943735df2a71975dd41ebf2c3d1acdfd6f17';

/// Update Notifier

abstract class _$Update extends $Notifier<UpdateInfo> {
  UpdateInfo build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<UpdateInfo, UpdateInfo>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UpdateInfo, UpdateInfo>,
              UpdateInfo,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
