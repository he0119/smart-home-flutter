import 'package:bloc/bloc.dart';
import 'package:logging/logging.dart';

Logger blocLogger = Logger('bloc');

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    blocLogger.fine(event);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    blocLogger.severe(error);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    blocLogger.fine(transition);
  }
}
