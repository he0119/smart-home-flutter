import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/storage/repository/storage_repository.dart';
import 'package:smarthome/utils/exceptions.dart';

part 'item_detail_event.dart';
part 'item_detail_state.dart';

class ItemDetailBloc extends Bloc<ItemDetailEvent, ItemDetailState> {
  final StorageRepository storageRepository;

  ItemDetailBloc({
    required this.storageRepository,
  }) : super(ItemDetailInProgress());

  @override
  Stream<ItemDetailState> mapEventToState(
    ItemDetailEvent event,
  ) async* {
    if (event is ItemDetailStarted) {
      try {
        final item = await storageRepository.item(
          id: event.id,
        );
        if (item == null) {
          yield ItemDetailFailure(
            '获取物品失败，物品不存在',
            id: event.id,
          );
          return;
        }
        yield ItemDetailSuccess(item: item);
      } on MyException catch (e) {
        yield ItemDetailFailure(
          e.message,
          id: event.id,
        );
      }
    }
    final currentState = state;
    if (event is ItemDetailRefreshed && currentState is ItemDetailSuccess) {
      yield ItemDetailInProgress();
      try {
        final item = await storageRepository.item(
          id: currentState.item.id,
          cache: false,
        );
        if (item == null) {
          yield ItemDetailFailure(
            '获取物品失败，物品不存在',
            id: currentState.item.id,
          );
          return;
        }
        yield ItemDetailSuccess(item: item);
      } on MyException catch (e) {
        yield ItemDetailFailure(
          e.message,
          id: currentState.item.id,
        );
      }
    }
  }
}
