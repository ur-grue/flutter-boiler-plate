import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boilerplate/core/di/injector.dart';
import 'package:flutter_boilerplate/core/l10n/l10n.dart';
import 'package:flutter_boilerplate/core/theme/app_spacing.dart';
import 'package:flutter_boilerplate/core/utils/validators.dart';
import 'package:flutter_boilerplate/core/widgets/app_button.dart';
import 'package:flutter_boilerplate/features/example_notes/presentation/cubit/note_editor_cubit.dart';
import 'package:flutter_boilerplate/features/example_notes/presentation/cubit/note_editor_state.dart';
import 'package:go_router/go_router.dart';

class NoteEditorPage extends StatelessWidget {
  const NoteEditorPage({this.id, super.key});

  final String? id;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NoteEditorCubit>()..loadForEdit(id),
      child: _NoteEditorView(isNew: id == null),
    );
  }
}

class _NoteEditorView extends StatefulWidget {
  const _NoteEditorView({required this.isNew});
  final bool isNew;

  @override
  State<_NoteEditorView> createState() => _NoteEditorViewState();
}

class _NoteEditorViewState extends State<_NoteEditorView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _prefilled = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<NoteEditorCubit>().save(
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? l10n.noteNewTitle : l10n.noteEditTitle),
      ),
      body: BlocConsumer<NoteEditorCubit, NoteEditorState>(
        listener: (context, state) {
          if (state is NoteEditing && !_prefilled) {
            _prefilled = true;
            _titleController.text = state.note?.title ?? '';
            _bodyController.text = state.note?.body ?? '';
          }
          if (state is NoteSaved) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(l10n.noteSaved)));
            context.pop();
          }
          if (state is NoteEditorError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.failure.message)));
          }
        },
        builder: (context, state) {
          if (state is NoteEditorLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final saving = state is NoteSaving;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration:
                          InputDecoration(labelText: l10n.noteTitleLabel),
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          Validators.notEmpty(v, field: l10n.noteTitleLabel),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _bodyController,
                      decoration: InputDecoration(
                        labelText: l10n.noteBodyLabel,
                        alignLabelWithHint: true,
                      ),
                      maxLines: 8,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: l10n.actionSave,
                      isLoading: saving,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
