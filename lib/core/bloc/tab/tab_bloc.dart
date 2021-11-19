import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarthome/core/model/models.dart';

part 'tab_event.dart';

class TabBloc extends Bloc<TabEvent, AppTab?> {
  TabBloc() : super(null) {
    on<TabChanged>((event, emit) => emit(event.tab));
  }
}
