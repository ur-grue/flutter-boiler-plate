import 'package:flutter_boilerplate/features/example_notes/example_notes_module.dart';
import 'package:get_it/get_it.dart';

/// Append-only registry of feature DI modules.
///
/// Each feature adds exactly ONE entry here (and one in
/// `core/router/feature_routes.dart`) instead of editing `injector.dart`, so
/// features can be built in parallel with conflict-free merges. `injector.dart`
/// runs these after the core/platform registrations.
final List<void Function(GetIt di)> featureModules = [
  registerExampleNotes,
];
