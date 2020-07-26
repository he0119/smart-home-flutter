import 'package:bloc/bloc.dart';
import 'package:logging/logging.dart';

Logger blocLogger = Logger('BLoC');

class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    blocLogger.fine(event);
  }

  @override
  void onError(Cubit cubit, Object error, StackTrace stacktrace) {
    super.onError(cubit, error, stacktrace);
    blocLogger.severe(error);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    blocLogger.fine(transition);
  }
}
