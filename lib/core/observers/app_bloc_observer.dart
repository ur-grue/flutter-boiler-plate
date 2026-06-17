import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boilerplate/core/utils/logger.dart';

/// Global observability hook for all Cubits/Blocs.
///
/// Logs transitions in debug and always reports errors (wire to a crash
/// reporter here later).
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    AppLogger.debug(
      '${bloc.runtimeType}: ${change.currentState.runtimeType} → '
      '${change.nextState.runtimeType}',
      name: 'bloc',
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    AppLogger.error(
      '${bloc.runtimeType} error',
      error: error,
      stackTrace: stackTrace,
      name: 'bloc',
    );
    super.onError(bloc, error, stackTrace);
  }
}
