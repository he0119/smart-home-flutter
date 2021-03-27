part of 'tab_bloc.dart';

abstract class TabEvent extends Equatable {
  const TabEvent();
}

class TabChanged extends TabEvent {
  final AppTab tab;

  const TabChanged(this.tab);

  @override
  List<Object> get props => [tab];

  @override
  String toString() => 'TabChanged(tab: $tab)';
}
