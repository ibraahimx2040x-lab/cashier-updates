import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format.dart';
import '../../data/data_controller.dart';
import '../../data/models/misc.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';

/// Screen 15 — notes list with search, pinning and archive.
class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  String _q = '';
  bool _archived = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = ref.watch(dataProvider);
    final fmt = Fmt.of(context, use24h: d.settings.use24h);
    final q = _q.toLowerCase();
    final notes = d.notes
        .where((n) => n.archived == _archived)
        .where((n) => q.isEmpty || n.title.toLowerCase().contains(q) || n.body.toLowerCase().contains(q) || n.category.toLowerCase().contains(q))
        .toList()
      ..sort((a, b) {
        if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });
    final wide = isWide(context);

    Widget tile(Note n) => AppCard(
          onTap: () => context.push(Routes.note(n.id)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              if (n.pinned) ...[Icon(Icons.push_pin, size: 16, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 4)],
              Expanded(child: Text(n.title.isEmpty ? l.untitled : n.title, style: Theme.of(context).textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
            if (n.body.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(n.body, maxLines: 3, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: Space.s),
            Wrap(spacing: Space.s, children: [
              Text(fmt.dateTime(n.updatedAt), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: context.status.textSecondary)),
              if (n.category.isNotEmpty) Pill(label: n.category, color: Theme.of(context).colorScheme.secondary),
              if (d.goal(n.goalId) != null) Pill(label: d.goal(n.goalId)!.title, color: context.status.info, icon: Icons.flag_outlined),
            ]),
          ]),
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(l.myNotes),
        actions: [
          IconButton(
            tooltip: _archived ? l.showActive : l.showArchived,
            icon: Icon(_archived ? Icons.unarchive_outlined : Icons.inventory_2_outlined),
            onPressed: () => setState(() => _archived = !_archived),
          ),
          IconButton(tooltip: l.addNote, onPressed: () => context.push(Routes.note('new')), icon: const Icon(Icons.add)),
        ],
      ),
      body: ResponsiveContainer(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(Space.gutter),
            child: SearchField(onChanged: (v) => setState(() => _q = v.trim())),
          ),
          if (_archived)
            Padding(padding: const EdgeInsets.only(bottom: Space.s), child: Text(l.archivedNotes, style: Theme.of(context).textTheme.labelMedium)),
          Expanded(
            child: notes.isEmpty
                ? EmptyState(
                    icon: Icons.sticky_note_2_outlined,
                    title: _q.isNotEmpty ? l.noSearchResults : (_archived ? l.emptyArchived : l.noNotesYet),
                    action: _q.isEmpty && !_archived ? l.addNote : null,
                    onAction: () => context.push(Routes.note('new')),
                  )
                : wide
                    ? GridView.extent(
                        maxCrossAxisExtent: 320,
                        childAspectRatio: 1.5,
                        padding: const EdgeInsets.fromLTRB(Space.gutter, 0, Space.gutter, 96),
                        mainAxisSpacing: Space.m,
                        crossAxisSpacing: Space.m,
                        children: [for (final n in notes) tile(n)],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(Space.gutter, 0, Space.gutter, 96),
                        itemCount: notes.length,
                        separatorBuilder: (_, _) => const SizedBox(height: Space.s),
                        itemBuilder: (_, i) => tile(notes[i]),
                      ),
          ),
        ]),
      ),
    );
  }
}
