import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:smart_home/models/models.dart';

part 'snack_bar_event.dart';
part 'snack_bar_state.dart';

class SnackBarBloc extends Bloc<SnackBarEvent, SnackBarState> {
  SnackBarBloc() : super(SnackBarInitial());

  @override
  Stream<SnackBarState> mapEventToState(
    SnackBarEvent event,
  ) async* {
    if (event is SnackBarChanged) {
      yield SnackBarSuccess(
        position: event.position,
        message: event.message,
        type: event.type,
        duration: event.duration,
      );
    }
  }
}
