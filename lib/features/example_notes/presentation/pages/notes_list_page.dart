import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boilerplate/core/di/injector.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/router/routes.dart';
import 'package:flutter_boilerplate/core/widgets/error_view.dart';
import 'package:flutter_boilerplate/core/widgets/loading_view.dart';
import 'package:flutter_boilerplate/features/example_notes/domain/note.dart';
import 'package:flutter_boilerplate/features/example_notes/presentation/cubit/notes_cubit.dart';
import 'package:flutter_boilerplate/features/example_notes/presentation/cubit/notes_state.dart';
import 'package:flutter_boilerplate/features/settings/presentation/cubit/subscription_cubit.dart';
import 'package:flutter_boilerplate/services/ads/ads_service.dart';
import 'package:flutter_boilerplate/services/ads/widgets/banner_ad_view.dart';
import 'package:go_router/go_router.dart';

class NotesListPage extends StatelessWidget {
  const NotesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NotesCubit>()..load(),
      child: const _NotesListView(),
    );
  }
}

class _NotesListView extends StatelessWidget {
  const _NotesListView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Premium users don't see ads.
    final isPremium = context.watch<SubscriptionCubit>().state;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notesTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.pushNamed(Routes.settings),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.pushNamed(Routes.noteNew);
          if (context.mounted) await context.read<NotesCubit>().refresh();
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<NotesCubit, NotesState>(
              builder: (context, state) {
                return switch (state) {
                  NotesLoading() => const LoadingView(),
                  NotesError(:final failure) => ErrorView(
                      failure: failure,
                      onRetry: context.read<NotesCubit>().load,
                    ),
                  NotesLoaded(:final notes) when notes.isEmpty => Center(
                      child: Text(l10n.notesEmpty),
                    ),
                  NotesLoaded(:final notes) => _NotesList(notes: notes),
                };
              },
            ),
          ),
          BannerAdView(adsService: getIt<AdsService>(), show: !isPremium),
        ],
      ),
    );
  }
}

class _NotesList extends StatelessWidget {
  const _NotesList({required this.notes});

  final List<Note> notes;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return RefreshIndicator(
      onRefresh: context.read<NotesCubit>().refresh,
      child: ListView.separated(
        itemCount: notes.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final note = notes[index];
          return Dismissible(
            key: ValueKey(note.id),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Theme.of(context).colorScheme.errorContainer,
              alignment: AlignmentDirectional.centerEnd,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete_outline),
            ),
            onDismissed: (_) {
              context.read<NotesCubit>().delete(note.id);
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(l10n.noteDeleted)));
            },
            child: ListTile(
              title: Text(note.title),
              subtitle: Text(
                note.body,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () async {
                await context.pushNamed(
                  Routes.noteEdit,
                  pathParameters: {'id': note.id},
                );
                if (context.mounted) {
                  await context.read<NotesCubit>().refresh();
                }
              },
            ),
          );
        },
      ),
    );
  }
}
