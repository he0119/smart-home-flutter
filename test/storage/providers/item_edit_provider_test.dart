import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/providers/item_edit_provider.dart';
import 'package:smarthome/utils/exceptions.dart';

import '../../helpers/storage_test_utils.dart';
import '../../mocks/mocks.mocks.dart';

void main() {
  late MockStorageRepository mockStorageRepository;
  late ProviderContainer container;

  setUp(() {
    mockStorageRepository = MockStorageRepository();
    container = ProviderContainer.test(
      overrides: [
        storageRepositoryProvider.overrideWithValue(mockStorageRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('addItem produces success state', () async {
    when(
      mockStorageRepository.addItem(
        name: anyNamed('name'),
        number: anyNamed('number'),
        storageId: anyNamed('storageId'),
        description: anyNamed('description'),
        price: anyNamed('price'),
        expiredAt: anyNamed('expiredAt'),
      ),
    ).thenAnswer((_) async => buildItem(id: 'item-1'));

    await container
        .read(itemEditProvider.notifier)
        .addItem(name: 'Keyboard', number: 1);

    final state = container.read(itemEditProvider);
    expect(state.status, ItemEditStatus.addSuccess);
    expect(state.item?.id, 'item-1');
  });

  test('deleteItem failure surfaces error message', () async {
    when(
      mockStorageRepository.deleteItem(itemId: anyNamed('itemId')),
    ).thenThrow(MyException('删除失败'));

    await container
        .read(itemEditProvider.notifier)
        .deleteItem(buildItem(id: 'item-1'));

    final state = container.read(itemEditProvider);
    expect(state.status, ItemEditStatus.failure);
    expect(state.errorMessage, '删除失败');
  });

  test('reset clears edit state', () {
    container.read(itemEditProvider.notifier).state = ItemEditState(
      status: ItemEditStatus.addSuccess,
      item: buildItem(),
    );

    container.read(itemEditProvider.notifier).reset();

    final state = container.read(itemEditProvider);
    expect(state.status, ItemEditStatus.initial);
    expect(state.item, isNull);
  });
}
