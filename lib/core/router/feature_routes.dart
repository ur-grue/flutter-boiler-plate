import 'package:flutter_boilerplate/features/example_notes/example_notes_module.dart';
import 'package:go_router/go_router.dart';

/// Append-only registry of feature route lists (companion to
/// `core/di/feature_modules.dart`). The router splices these in after the core
/// shell routes (splash / onboarding / sign-in / settings).
List<RouteBase> featureRoutes() => [
      ...exampleNotesRoutes(),
    ];
