import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_home/models/models.dart';

part 'tab_event.dart';

class TabBloc extends Bloc<TabEvent, AppTab> {
  TabBloc() : super(AppTab.storage);

  @override
  Stream<AppTab> mapEventToState(TabEvent event) async* {
    if (event is TabChanged) {
      yield event.tab;
    }
  }
}
