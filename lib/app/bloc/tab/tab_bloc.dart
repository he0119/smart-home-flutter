import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarthome/app/model/app_tab.dart';

part 'tab_event.dart';

class TabBloc extends Bloc<TabEvent, AppTab?> {
  TabBloc() : super(null);

  @override
  Stream<AppTab> mapEventToState(TabEvent event) async* {
    if (event is TabChanged) {
      yield event.tab;
    }
  }
}
