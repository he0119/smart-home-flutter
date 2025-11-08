part of 'storage_detail_bloc.dart';

class StorageDetailState extends Equatable {
  /// 当前状态
  final StorageDetailStatus status;

  /// 错误信息
  final String error;

  /// 位置页面所需数据
  final Storage storage;
  final PageInfo itemPageInfo;
  final PageInfo storagePageInfo;

  const StorageDetailState({
    this.status = StorageDetailStatus.initial,
    this.error = '',
    // 初始为空值
    this.storage = const Storage(id: '', name: ''),
    this.storagePageInfo = const PageInfo(hasNextPage: false),
    this.itemPageInfo = const PageInfo(hasNextPage: false),
  });

  bool get hasReachedMax =>
      !itemPageInfo.hasNextPage && !storagePageInfo.hasNextPage;

  @override
  List<Object?> get props => [
    status,
    error,
    storage,
    itemPageInfo,
    storagePageInfo,
  ];

  @override
  bool get stringify => true;

  StorageDetailState copyWith({
    StorageDetailStatus? status,
    String? error,
    Storage? storage,
    PageInfo? itemPageInfo,
    PageInfo? storagePageInfo,
  }) {
    return StorageDetailState(
      status: status ?? this.status,
      error: error ?? this.error,
      storage: storage ?? this.storage,
      itemPageInfo: itemPageInfo ?? this.itemPageInfo,
      storagePageInfo: storagePageInfo ?? this.storagePageInfo,
    );
  }
}
