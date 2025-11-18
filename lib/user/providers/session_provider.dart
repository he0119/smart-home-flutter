import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smarthome/core/core.dart';
import 'package:smarthome/user/model/user.dart' as user_model;
import 'package:smarthome/utils/exceptions.dart';

part 'session_provider.g.dart';

/// Session 状态
sealed class SessionState {
  const SessionState();
}

class SessionInProgress extends SessionState {
  const SessionInProgress();

  @override
  String toString() => 'SessionInProgress()';
}

class SessionSuccess extends SessionState {
  final List<user_model.Session> sessions;

  const SessionSuccess({required this.sessions});

  @override
  String toString() => 'SessionSuccess(sessions: ${sessions.length})';
}

class SessionFailure extends SessionState {
  final String message;

  const SessionFailure(this.message);

  @override
  String toString() => 'SessionFailure(message: $message)';
}

/// Session Notifier
@Riverpod(keepAlive: true)
class Session extends _$Session {
  @override
  SessionState build() {
    return const SessionInProgress();
  }

  Future<void> fetchSessions() async {
    state = const SessionInProgress();
    try {
      final userRepository = ref.read(userRepositoryProvider);
      final sessions = await userRepository.sessions();
      state = SessionSuccess(sessions: sessions);
    } on MyException catch (e) {
      state = SessionFailure(e.message);
    }
  }

  Future<void> deleteSession(String id) async {
    try {
      final userRepository = ref.read(userRepositoryProvider);
      await userRepository.deleteSession(id);
      final sessions = await userRepository.sessions();
      state = SessionSuccess(sessions: sessions);
    } on MyException catch (e) {
      state = SessionFailure(e.message);
    }
  }
}
