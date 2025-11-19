import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/storage/providers/picture_edit_provider.dart';
import 'package:smarthome/utils/exceptions.dart';

import '../../mocks/mocks.mocks.dart';

Picture buildPicture({String id = 'picture-1'}) =>
    Picture(id: id, description: 'Picture $id');

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

  test('addPicture sets addSuccess state', () async {
    when(
      mockStorageRepository.addPicture(
        itemId: anyNamed('itemId'),
        picturePath: anyNamed('picturePath'),
        description: anyNamed('description'),
        boxX: anyNamed('boxX'),
        boxY: anyNamed('boxY'),
        boxH: anyNamed('boxH'),
        boxW: anyNamed('boxW'),
      ),
    ).thenAnswer((_) async => buildPicture());

    await container
        .read(pictureEditProvider.notifier)
        .addPicture(
          itemId: 'item-1',
          picturePath: '/tmp/a.png',
          boxX: 0,
          boxY: 0,
          boxH: 10,
          boxW: 10,
        );

    final state = container.read(pictureEditProvider);
    expect(state.status, PictureEditStatus.addSuccess);
    expect(state.picture?.id, 'picture-1');
  });

  test('deletePicture handles errors', () async {
    when(
      mockStorageRepository.deletePicture(pictureId: anyNamed('pictureId')),
    ).thenThrow(MyException('删除失败'));

    await container
        .read(pictureEditProvider.notifier)
        .deletePicture(buildPicture(id: 'picture-1'));

    final state = container.read(pictureEditProvider);
    expect(state.status, PictureEditStatus.failure);
    expect(state.errorMessage, '删除失败');
  });

  test('reset clears state', () {
    container.read(pictureEditProvider.notifier).state = PictureEditState(
      status: PictureEditStatus.addSuccess,
      picture: buildPicture(),
    );

    container.read(pictureEditProvider.notifier).reset();

    final state = container.read(pictureEditProvider);
    expect(state.status, PictureEditStatus.initial);
    expect(state.picture, isNull);
  });
}
