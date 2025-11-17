import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smarthome/core/providers/repository_providers.dart';
import 'package:smarthome/user/model/user.dart';
import 'package:smarthome/user/providers/session_provider.dart';
import 'package:smarthome/utils/exceptions.dart';

import '../../mocks/mocks.mocks.dart';

void main() {
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
  });

  group('SessionNotifier', () {
    test('初始状态应该是 SessionInProgress', () {
      final container = ProviderContainer.test(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockUserRepository),
        ],
      );

      final sessionState = container.read(sessionProvider);
      expect(sessionState, isA<SessionInProgress>());
    });

    test('fetchSessions 成功应该更新为 SessionSuccess', () async {
      final testSessions = [
        Session(
          id: '1',
          ip: '192.168.1.1',
          isCurrent: true,
          isValid: true,
          lastActivity: DateTime(2024, 1, 1),
          userAgent: 'Test Agent',
        ),
        Session(
          id: '2',
          ip: '192.168.1.2',
          isCurrent: false,
          isValid: true,
          lastActivity: DateTime(2024, 1, 2),
          userAgent: 'Another Agent',
        ),
      ];

      final container = ProviderContainer.test(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockUserRepository),
        ],
      );

      when(mockUserRepository.sessions()).thenAnswer((_) async => testSessions);

      await container.read(sessionProvider.notifier).fetchSessions();

      final sessionState = container.read(sessionProvider);
      expect(sessionState, isA<SessionSuccess>());
      if (sessionState is SessionSuccess) {
        expect(sessionState.sessions, testSessions);
        expect(sessionState.sessions.length, 2);
      }
    });

    test('fetchSessions 失败应该更新为 SessionFailure', () async {
      final container = ProviderContainer.test(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockUserRepository),
        ],
      );

      when(mockUserRepository.sessions()).thenThrow(MyException('获取会话失败'));

      await container.read(sessionProvider.notifier).fetchSessions();

      final sessionState = container.read(sessionProvider);
      expect(sessionState, isA<SessionFailure>());
      if (sessionState is SessionFailure) {
        expect(sessionState.message, '获取会话失败');
      }
    });

    test('deleteSession 成功应该更新会话列表', () async {
      final initialSessions = [
        Session(
          id: '1',
          ip: '192.168.1.1',
          isCurrent: true,
          isValid: true,
          lastActivity: DateTime(2024, 1, 1),
          userAgent: 'Test Agent',
        ),
        Session(
          id: '2',
          ip: '192.168.1.2',
          isCurrent: false,
          isValid: true,
          lastActivity: DateTime(2024, 1, 2),
          userAgent: 'Another Agent',
        ),
      ];

      final updatedSessions = [
        Session(
          id: '1',
          ip: '192.168.1.1',
          isCurrent: true,
          isValid: true,
          lastActivity: DateTime(2024, 1, 1),
          userAgent: 'Test Agent',
        ),
      ];

      final container = ProviderContainer.test(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockUserRepository),
        ],
      );

      // 先设置初始会话
      when(
        mockUserRepository.sessions(),
      ).thenAnswer((_) async => initialSessions);
      await container.read(sessionProvider.notifier).fetchSessions();

      // 验证初始状态
      var state1 = container.read(sessionProvider);
      expect(state1, isA<SessionSuccess>());
      if (state1 is SessionSuccess) {
        expect(state1.sessions.length, 2);
      }

      // 删除会话
      when(mockUserRepository.deleteSession('2')).thenAnswer((_) async => {});
      when(
        mockUserRepository.sessions(),
      ).thenAnswer((_) async => updatedSessions);

      await container.read(sessionProvider.notifier).deleteSession('2');

      // 验证删除后状态
      var state2 = container.read(sessionProvider);
      expect(state2, isA<SessionSuccess>());
      if (state2 is SessionSuccess) {
        expect(state2.sessions.length, 1);
        expect(state2.sessions[0].id, '1');
      }

      verify(mockUserRepository.deleteSession('2')).called(1);
    });

    test('deleteSession 失败应该更新为 SessionFailure', () async {
      final initialSessions = [
        Session(
          id: '1',
          ip: '192.168.1.1',
          isCurrent: true,
          isValid: true,
          lastActivity: DateTime(2024, 1, 1),
          userAgent: 'Test Agent',
        ),
      ];

      final container = ProviderContainer.test(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockUserRepository),
        ],
      );

      // 先设置初始会话
      when(
        mockUserRepository.sessions(),
      ).thenAnswer((_) async => initialSessions);
      await container.read(sessionProvider.notifier).fetchSessions();

      // 删除会话失败
      when(
        mockUserRepository.deleteSession('1'),
      ).thenThrow(MyException('删除会话失败'));

      await container.read(sessionProvider.notifier).deleteSession('1');

      final sessionState = container.read(sessionProvider);
      expect(sessionState, isA<SessionFailure>());
      if (sessionState is SessionFailure) {
        expect(sessionState.message, '删除会话失败');
      }
    });

    test('多次调用 fetchSessions 应该正确更新状态', () async {
      final sessions1 = [
        Session(
          id: '1',
          ip: '192.168.1.1',
          isCurrent: true,
          isValid: true,
          lastActivity: DateTime(2024, 1, 1),
          userAgent: 'Agent 1',
        ),
      ];

      final sessions2 = [
        Session(
          id: '1',
          ip: '192.168.1.1',
          isCurrent: true,
          isValid: true,
          lastActivity: DateTime(2024, 1, 1),
          userAgent: 'Agent 1',
        ),
        Session(
          id: '2',
          ip: '192.168.1.2',
          isCurrent: false,
          isValid: true,
          lastActivity: DateTime(2024, 1, 2),
          userAgent: 'Agent 2',
        ),
      ];

      final container = ProviderContainer.test(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockUserRepository),
        ],
      );

      // 第一次获取
      when(mockUserRepository.sessions()).thenAnswer((_) async => sessions1);
      await container.read(sessionProvider.notifier).fetchSessions();

      var state1 = container.read(sessionProvider);
      expect(state1, isA<SessionSuccess>());
      if (state1 is SessionSuccess) {
        expect(state1.sessions.length, 1);
      }

      // 第二次获取
      when(mockUserRepository.sessions()).thenAnswer((_) async => sessions2);
      await container.read(sessionProvider.notifier).fetchSessions();

      var state2 = container.read(sessionProvider);
      expect(state2, isA<SessionSuccess>());
      if (state2 is SessionSuccess) {
        expect(state2.sessions.length, 2);
      }
    });
  });
}
