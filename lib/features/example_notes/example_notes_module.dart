import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/features/example_notes/data/mock_notes_data_source.dart';
import 'package:flutter_boilerplate/features/example_notes/data/notes_repository_impl.dart';
import 'package:flutter_boilerplate/features/example_notes/domain/notes_repository.dart';
import 'package:flutter_boilerplate/features/example_notes/presentation/cubit/note_editor_cubit.dart';
import 'package:flutter_boilerplate/features/example_notes/presentation/cubit/notes_cubit.dart';
import 'package:flutter_boilerplate/features/example_notes/presentation/pages/note_editor_page.dart';
import 'package:flutter_boilerplate/features/example_notes/presentation/pages/notes_list_page.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

/// Self-contained wiring for the `example_notes` feature.
///
/// A feature OWNS its DI registrations and routes here, so several features can
/// be built in parallel (each in its own worktree) without editing the shared
/// `injector.dart` / `app_router.dart`. To activate a feature, add ONE line to
/// `core/di/feature_modules.dart` and ONE to `core/router/feature_routes.dart`
/// (both append-only — conflict-free merges).
///
/// Copy this file when you scaffold a new feature; delete it (and its two
/// registry lines) to remove the example.
void registerExampleNotes(GetIt di) {
  di
    ..registerLazySingleton<NotesRepository>(
      () => NotesRepositoryImpl(MockNotesDataSource()),
    )
    ..registerFactory<NotesCubit>(() => NotesCubit(di<NotesRepository>()))
    ..registerFactory<NoteEditorCubit>(
      () => NoteEditorCubit(di<NotesRepository>()),
    );
}

List<RouteBase> exampleNotesRoutes() => [
      GoRoute(
        path: Routes.notesPath,
        name: Routes.notes,
        builder: (_, __) => const NotesListPage(),
        routes: [
          GoRoute(
            path: Routes.noteNewPath,
            name: Routes.noteNew,
            builder: (_, __) => const NoteEditorPage(),
          ),
          GoRoute(
            path: Routes.noteEditPath,
            name: Routes.noteEdit,
            builder: (_, state) =>
                NoteEditorPage(id: state.pathParameters['id']),
          ),
        ],
      ),
    ];
