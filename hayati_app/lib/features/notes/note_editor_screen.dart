import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/data_controller.dart';
import '../../data/models/misc.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import '../../widgets/home_logo.dart';

enum _SaveState { idle, pending, saved, error }

/// Note editor with visible autosave state.
class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({super.key, this.noteId});
  final String? noteId;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late final DataController _c = ref.read(dataProvider.notifier);
  late final Note? _orig = _c.snapshot.note(widget.noteId);
  late final String _id = _orig?.id ?? newId();
  late final _title = TextEditingController(text: _orig?.title ?? '');
  late final _body = TextEditingController(text: _orig?.body ?? '');
  late final _cat = TextEditingController(text: _orig?.category ?? '');
  late String? _goalId = _orig?.goalId;
  Timer? _debounce;
  _SaveState _state = _SaveState.idle;

  @override
  void initState() {
    super.initState();
    _c; // capture before dispose, where ref is no longer usable
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _flush();
    _title.dispose();
    _body.dispose();
    _cat.dispose();
    super.dispose();
  }

  void _changed() {
    setState(() => _state = _SaveState.pending);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), _flush);
  }

  void _flush() {
    if (_state != _SaveState.pending) return;
    if (_title.text.trim().isEmpty && _body.text.trim().isEmpty) return;
    final existing = _c.snapshot.note(_id);
    try {
      _c.saveNote(Note(
        id: _id,
        title: _title.text.trim(),
        body: _body.text,
        category: _cat.text.trim(),
        pinned: existing?.pinned ?? false,
        archived: existing?.archived ?? false,
        goalId: _goalId,
        updatedAt: DateTime.now(),
      ));
      _state = _SaveState.saved;
    } catch (_) {
      _state = _SaveState.error;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final note = d.note(_id);
    final c = ref.read(dataProvider.notifier);
    final status = switch (_state) {
      _SaveState.idle => note == null ? '' : l.saved,
      _SaveState.pending => l.saving,
      _SaveState.saved => l.saved,
      _SaveState.error => l.errSave,
    };
    return Scaffold(
      appBar: AppBar(
        title: Text(status, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.status.textSecondary)),
        actions: [
          if (note != null) ...[
            IconButton(
              tooltip: note.pinned ? l.unpin : l.pin,
              icon: Icon(note.pinned ? Icons.push_pin : Icons.push_pin_outlined),
              onPressed: () => c.saveNote(note.copyWith(pinned: !note.pinned)),
            ),
            IconButton(
              tooltip: note.archived ? l.unarchive : l.archive,
              icon: Icon(note.archived ? Icons.unarchive_outlined : Icons.archive_outlined),
              onPressed: () {
                c.saveNote(note.copyWith(archived: !note.archived));
                showSnack(context, note.archived ? l.unarchived : l.archived);
              },
            ),
            IconButton(
              tooltip: l.delete,
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                if (await confirmDialog(context, title: l.deleteNoteTitle, message: l.deleteNoteBody, confirmLabel: l.delete)) {
                  _debounce?.cancel();
                  _state = _SaveState.idle;
                  c.deleteNote(_id);
                  if (context.mounted) context.pop();
                }
              },
            ),
          ], const HomeLogoButton()],
      ),
      body: ResponsiveContainer(
        maxWidth: 760,
        child: ListView(padding: const EdgeInsets.all(Space.gutter), children: [
          TextField(
            controller: _title,
            autofocus: _orig == null,
            style: Theme.of(context).textTheme.titleLarge,
            decoration: InputDecoration(hintText: l.noteTitle, border: InputBorder.none, filled: false),
            onChanged: (_) => _changed(),
          ),
          TextField(
            controller: _body,
            minLines: 10,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(hintText: l.noteBody, border: InputBorder.none, filled: false),
            onChanged: (_) => _changed(),
          ),
          const Divider(height: Space.xxl),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _cat,
                decoration: InputDecoration(labelText: l.categoryOptional, isDense: true),
                onChanged: (_) => _changed(),
              ),
            ),
            const SizedBox(width: Space.m),
            Expanded(
              child: DropdownButtonFormField<String?>(
                isExpanded: true,
                initialValue: d.goal(_goalId) == null ? null : _goalId,
                isDense: true,
                decoration: InputDecoration(labelText: l.linkedGoalOptional, isDense: true),
                items: [
                  DropdownMenuItem(value: null, child: Text(l.none)),
                  for (final g in d.goals) DropdownMenuItem(value: g.id, child: Text(g.title, overflow: TextOverflow.ellipsis)),
                ],
                onChanged: (v) {
                  _goalId = v;
                  _changed();
                },
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}
