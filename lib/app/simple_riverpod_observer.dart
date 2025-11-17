import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

Logger riverpodLogger = Logger('Riverpod');

final class SimpleRiverpodObserver extends ProviderObserver {
  @override
  void didAddProvider(ProviderObserverContext context, Object? value) {
    riverpodLogger.fine(
      'Provider added: ${context.provider.name ?? context.provider.runtimeType}',
    );
  }

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    riverpodLogger.fine(
      'Provider updated: ${context.provider.name ?? context.provider.runtimeType} | '
      'Previous: $previousValue | New: $newValue',
    );
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    riverpodLogger.fine(
      'Provider disposed: ${context.provider.name ?? context.provider.runtimeType}',
    );
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    riverpodLogger.severe(
      'Provider error: ${context.provider.name ?? context.provider.runtimeType} | Error: $error',
      error,
      stackTrace,
    );
  }
}
