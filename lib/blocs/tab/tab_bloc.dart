import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:smart_home/models/models.dart';

part 'tab_event.dart';

class TabBloc extends Bloc<TabEvent, AppTab> {
  final AppTab defaultTab;

  TabBloc({@required this.defaultTab}) : super(defaultTab);

  @override
  Stream<AppTab> mapEventToState(TabEvent event) async* {
    if (event is TabChanged) {
      yield event.tab;
    }
  }
}
