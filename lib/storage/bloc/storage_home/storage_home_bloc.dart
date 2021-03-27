import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarthome/app/model/relay.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/storage/storage_repository.dart';
import 'package:smarthome/utils/exceptions.dart';

part 'storage_home_event.dart';
part 'storage_home_state.dart';

class StorageHomeBloc extends Bloc<StorageHomeEvent, StorageHomeState> {
  final StorageRepository storageRepository;

  StorageHomeBloc({required this.storageRepository})
      : super(StorageHomeInProgress());

  @override
  Stream<StorageHomeState> mapEventToState(
    StorageHomeEvent event,
  ) async* {
    final StorageHomeState currentState = state;
    if (event is StorageHomeFetched) {
      // 如果需要刷新，则显示加载界面
      // 因为需要请求网络最好提示用户
      // 如果切换了物品种类，也显示加载提示
      if (!event.cache ||
          (currentState is StorageHomeSuccess &&
              currentState.itemType != event.itemType)) {
        yield StorageHomeInProgress();
      }
      try {
        if (event.cache &&
            currentState is StorageHomeSuccess &&
            event.itemType == currentState.itemType &&
            !currentState.hasReachedMax) {
          // 如果不需要刷新，不是首次启动，或遇到错误，并且有下一页
          // 则获取下一页
          switch (event.itemType) {
            case ItemType.expired:
              final results = await storageRepository.expiredItems(
                after: currentState.pageInfo.endCursor,
                cache: false,
              );
              yield StorageHomeSuccess(
                expiredItems: currentState.expiredItems! + results.item1,
                pageInfo: currentState.pageInfo.copyWith(results.item2),
                itemType: ItemType.expired,
              );
              break;
            case ItemType.nearExpired:
              final results = await storageRepository.nearExpiredItems(
                after: currentState.pageInfo.endCursor,
                cache: false,
              );
              yield StorageHomeSuccess(
                nearExpiredItems:
                    currentState.nearExpiredItems! + results.item1,
                pageInfo: currentState.pageInfo.copyWith(results.item2),
                itemType: ItemType.nearExpired,
              );
              break;
            case ItemType.recentlyCreated:
              final results = await storageRepository.recentlyCreatedItems(
                after: currentState.pageInfo.endCursor,
                cache: false,
              );
              yield StorageHomeSuccess(
                recentlyCreatedItems:
                    currentState.recentlyCreatedItems! + results.item1,
                pageInfo: currentState.pageInfo.copyWith(results.item2),
                itemType: ItemType.recentlyCreated,
              );
              break;
            case ItemType.recentlyEdited:
              final results = await storageRepository.recentlyEditedItems(
                after: currentState.pageInfo.endCursor,
                cache: false,
              );
              yield StorageHomeSuccess(
                recentlyEditedItems:
                    currentState.recentlyEditedItems! + results.item1,
                pageInfo: currentState.pageInfo.copyWith(results.item2),
                itemType: ItemType.recentlyEdited,
              );
              break;
            case ItemType.all:
              break;
          }
        } else {
          // 其他情况根据设置看是否需要打开缓存，并获取第一页
          switch (event.itemType) {
            case ItemType.expired:
              final results =
                  await storageRepository.expiredItems(cache: event.cache);
              yield StorageHomeSuccess(
                expiredItems: results.item1,
                pageInfo: results.item2,
                itemType: ItemType.expired,
              );
              break;
            case ItemType.nearExpired:
              final results =
                  await storageRepository.nearExpiredItems(cache: event.cache);
              yield StorageHomeSuccess(
                nearExpiredItems: results.item1,
                pageInfo: results.item2,
                itemType: ItemType.nearExpired,
              );
              break;
            case ItemType.recentlyCreated:
              final results = await storageRepository.recentlyCreatedItems(
                  cache: event.cache);
              yield StorageHomeSuccess(
                recentlyCreatedItems: results.item1,
                pageInfo: results.item2,
                itemType: ItemType.recentlyCreated,
              );
              break;
            case ItemType.recentlyEdited:
              final results = await storageRepository.recentlyEditedItems(
                  cache: event.cache);
              yield StorageHomeSuccess(
                recentlyEditedItems: results.item1,
                pageInfo: results.item2,
                itemType: ItemType.recentlyEdited,
              );
              break;
            case ItemType.all:
              Map<String, List<Item>> homepage =
                  await storageRepository.homePage(cache: event.cache);
              yield StorageHomeSuccess(
                  recentlyCreatedItems: homepage['recentlyCreatedItems'],
                  recentlyEditedItems: homepage['recentlyEditedItems'],
                  expiredItems: homepage['expiredItems'],
                  nearExpiredItems: homepage['nearExpiredItems'],
                  itemType: ItemType.all,
                  pageInfo: PageInfo(hasNextPage: false));
              break;
          }
        }
      } on MyException catch (e) {
        yield StorageHomeFailure(
          e.message,
          itemType: event.itemType,
        );
      }
    }
  }
}
