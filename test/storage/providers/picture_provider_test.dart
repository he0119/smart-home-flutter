import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/storage/model/storage.dart';
import 'package:smarthome/storage/providers/picture_provider.dart';
import 'package:smarthome/utils/exceptions.dart';

import '../../helpers/provider_test_utils.dart';
import '../../mocks/mocks.mocks.dart';

Future<void> _flush() => Future<void>.delayed(Duration.zero);

Picture buildPicture({String id = 'picture-1'}) =>
    Picture(id: id, description: 'Picture $id');

void main() {
  late MockStorageRepository mockStorageRepository;
  late ProviderContainer container;

  setUp(() {
    mockStorageRepository = MockStorageRepository();
    container = ProviderContainer(
      overrides: [
        storageRepositoryProvider.overrideWithValue(mockStorageRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('build returns picture detail', () async {
    when(
      mockStorageRepository.picture(id: 'picture-1', cache: true),
    ).thenAnswer((_) async => buildPicture(id: 'picture-1'));

    final picture = await container.read(pictureProvider('picture-1').future);
    expect(picture.id, 'picture-1');
  });

  test('refresh reloads image data', () async {
    when(
      mockStorageRepository.picture(id: 'picture-1', cache: true),
    ).thenAnswer((_) async => buildPicture(id: 'picture-1'));
    when(
      mockStorageRepository.picture(id: 'picture-1', cache: false),
    ).thenAnswer((_) async => buildPicture(id: 'picture-1'));

    final provider = pictureProvider('picture-1');
    await container.read(provider.future);

    await container.read(provider.notifier).refresh();

    verify(
      mockStorageRepository.picture(id: 'picture-1', cache: false),
    ).called(1);
  });

  test('emits error state when picture cannot be found', () async {
    when(
      mockStorageRepository.picture(id: 'missing', cache: true),
    ).thenAnswer((_) async => null);

    final provider = pictureProvider('missing');
    keepProviderAlive(container, provider);

    container.read(provider);
    await _flush();

    final state = container.read(provider);
    expect(state.hasError, true);
    expect(state.error, isA<MyException>());
  });
}
