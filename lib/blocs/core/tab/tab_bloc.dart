import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smarthome/models/models.dart';

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
