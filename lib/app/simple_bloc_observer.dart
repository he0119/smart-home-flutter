import 'package:bloc/bloc.dart';
import 'package:logging/logging.dart';

Logger blocLogger = Logger('BLoC');

class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    blocLogger.fine(event);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    blocLogger.severe('bloc: ${bloc.runtimeType}, error: $error');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    blocLogger.fine(transition);
  }
}
