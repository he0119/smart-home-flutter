import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarthome/user/user.dart';
import 'package:smarthome/utils/exceptions.dart';

part 'session_event.dart';
part 'session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final UserRepository userRepository;

  SessionBloc(this.userRepository) : super(SessionInProgress()) {
    on<SessionFetched>(_onSessionFetched);
    on<SessionDeleted>(_onSessionDeleted);
  }

  FutureOr<void> _onSessionFetched(
    SessionFetched event,
    Emitter<SessionState> emit,
  ) async {
    try {
      final sessions = await userRepository.sessions();
      emit(SessionSuccess(sessions: sessions));
    } on MyException catch (e) {
      emit(SessionFailure(e.message));
    }
  }

  FutureOr<void> _onSessionDeleted(
    SessionDeleted event,
    Emitter<SessionState> emit,
  ) async {
    try {
      await userRepository.deleteSession(event.id);
      final sessions = await userRepository.sessions();
      emit(SessionSuccess(sessions: sessions));
    } on MyException catch (e) {
      emit(SessionFailure(e.message));
    }
  }
}
