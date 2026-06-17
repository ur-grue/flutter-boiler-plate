import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boilerplate/core/storage/key_value_store.dart';
import 'package:flutter_boilerplate/core/storage/storage_keys.dart';

/// Tracks the onboarding page index and persists the "seen" flag. The router
/// reads [StorageKeys.onboardingDone] directly; navigation after [complete]
/// re-runs the redirect guard.
class OnboardingCubit extends Cubit<int> {
  OnboardingCubit(this._store) : super(0);

  final KeyValueStore _store;

  void setPage(int index) => emit(index);

  Future<void> complete() =>
      _store.setBool(StorageKeys.onboardingDone, value: true);
}
