import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthome/core/providers/repository_providers.dart';
import 'package:smarthome/user/model/user.dart';
import 'package:smarthome/utils/exceptions.dart';

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
  final List<Session> sessions;

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
class SessionNotifier extends Notifier<SessionState> {
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

/// Session provider
final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(
  SessionNotifier.new,
);
