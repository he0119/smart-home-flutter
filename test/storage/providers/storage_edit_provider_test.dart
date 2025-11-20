import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/providers/storage_edit_provider.dart';
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

  test('addStorage updates state on success', () async {
    when(
      mockStorageRepository.addStorage(
        name: anyNamed('name'),
        parentId: anyNamed('parentId'),
        description: anyNamed('description'),
      ),
    ).thenAnswer((_) async => buildStorage());

    await container.read(storageEditProvider.notifier).addStorage(name: 'Box');

    final state = container.read(storageEditProvider);
    expect(state.status, StorageEditStatus.addSuccess);
    expect(state.storage?.name, 'Storage storage-1');
  });

  test('deleteStorage reports errors from repository', () async {
    when(
      mockStorageRepository.deleteStorage(storageId: anyNamed('storageId')),
    ).thenThrow(MyException('删除失败'));

    await container
        .read(storageEditProvider.notifier)
        .deleteStorage(buildStorage(id: 'storage-1'));

    final state = container.read(storageEditProvider);
    expect(state.status, StorageEditStatus.failure);
    expect(state.errorMessage, '删除失败');
  });

  test('reset returns to initial state', () async {
    container.read(storageEditProvider.notifier).state = StorageEditState(
      status: StorageEditStatus.addSuccess,
      storage: buildStorage(),
    );

    container.read(storageEditProvider.notifier).reset();

    final state = container.read(storageEditProvider);
    expect(state.status, StorageEditStatus.initial);
    expect(state.storage, isNull);
  });
}
