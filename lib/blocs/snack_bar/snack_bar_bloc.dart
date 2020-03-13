import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:smart_home/models/message_type.dart';

part 'snack_bar_event.dart';
part 'snack_bar_state.dart';

class SnackBarBloc extends Bloc<SnackBarEvent, SnackBarState> {
  @override
  SnackBarState get initialState => SnackBarInitial();

  @override
  Stream<SnackBarState> mapEventToState(
    SnackBarEvent event,
  ) async* {
    if (event is SnackBarChanged) {
      yield SnackBarSuccess(
        message: event.message,
        messageType: event.messageType,
      );
    }
  }
}
