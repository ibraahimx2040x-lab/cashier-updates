import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/labels.dart';
import '../../data/data_controller.dart';
import '../../domain/fitness/exercises.dart';
import '../../domain/fitness/programs.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/common.dart';
import '../../widgets/hero_surface.dart';
import 'exercise_screen.dart' show muscleIcon;

/// Screen 19b — one program: what it's for, its exercises, safety notes,
/// and (for pregnancy and after birth) the doctor's go-ahead first.
class ProgramScreen extends ConsumerStatefulWidget {
  const ProgramScreen({super.key, required this.programId});
  final String programId;

  @override
  ConsumerState<ProgramScreen> createState() => _ProgramScreenState();
}

class _ProgramScreenState extends ConsumerState<ProgramScreen> {
  bool _agree = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = ref.watch(settingsProvider);
    final t = Theme.of(context).textTheme;
    final lang = l.localeName;
    final p = programById(widget.programId);
    // Women's and men's programs open only for that audience.
    if (p == null || !programVisible(p, s)) {
      return Scaffold(appBar: AppBar(), body: EmptyState(icon: Icons.lock_outline, title: l.programUnavailable, message: l.programUnavailableBody));
    }
    final cleared = clearedFor(p, s.health);
    final variants = p.group == null ? const <Program>[] : programs.where((x) => x.group == p.group).toList();
    final warnings = switch (p.clearance) {
      Clearance.pregnancy => [l.warnBleeding, l.warnContractions, l.warnFluid, l.warnDizzy, l.warnChest, l.warnHeadache, l.warnCalf],
      Clearance.postpartum => [l.warnHeavyBleeding, l.warnPelvicHeaviness, l.warnLeaking, l.warnPain],
      Clearance.none => [l.warnPain, l.warnDizzy],
    };

    return Scaffold(
      appBar: AppBar(title: Text(p.name(lang))),
      body: ResponsiveContainer(
        maxWidth: 720,
        child: ListView(padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.gutter, 120), children: [
          HeroSurface(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(
                switch (p.audience) { Audience.female => Icons.female, Audience.male => Icons.male, Audience.all => Icons.self_improvement },
                color: AppColors.gold,
                size: 32,
              ),
              const SizedBox(height: Space.m),
              Text(p.name(lang), style: t.headlineSmall?.copyWith(color: Colors.white)),
              const SizedBox(height: Space.xs),
              Text(p.about(lang), style: t.bodyMedium?.copyWith(color: Colors.white70)),
              const SizedBox(height: Space.s),
              Text('${l.unitMinutes(p.minutes)} · ${l.exerciseCount(p.items.length)}', style: t.labelMedium?.copyWith(color: Colors.white70)),
            ]),
          ),
          if (variants.length > 1) ...[
            const SizedBox(height: Space.l),
            Wrap(spacing: Space.s, runSpacing: Space.s, children: [
              for (final v in variants)
                ChoiceChip(
                  label: Text(v.name(lang).split('—').last.trim()),
                  selected: v.id == p.id,
                  onSelected: (_) => context.pushReplacement(Routes.program(v.id)),
                ),
            ]),
          ],
          if (p.clearance != Clearance.none && !cleared) ...[
            const SizedBox(height: Space.l),
            AppCard(
              color: context.status.highlight,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(children: [
                  const IconBadge(Icons.medical_services_outlined, color: AppColors.goldDeep),
                  const SizedBox(width: Space.m),
                  Expanded(child: Text(l.clearanceTitle, style: t.titleSmall)),
                ]),
                const SizedBox(height: Space.s),
                Text(p.clearance == Clearance.pregnancy ? l.clearancePregnancy : l.clearancePostpartum, style: t.bodyMedium),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _agree,
                  onChanged: (v) => setState(() => _agree = v ?? false),
                  title: Text(l.clearanceConfirm),
                ),
                FilledButton(
                  onPressed: !_agree
                      ? null
                      : () => ref.read(dataProvider.notifier).updateHealth((h) => p.clearance == Clearance.pregnancy
                          ? h.copyWith(pregnancyCleared: true)
                          : h.copyWith(postpartumCleared: true)),
                  child: Text(l.continueLabel),
                ),
              ]),
            ),
          ],
          const SizedBox(height: Space.xl),
          SectionHeader(l.programExercises),
          for (final x in p.items)
            if (exerciseById(x.exerciseId) case final e?)
              Padding(
                padding: const EdgeInsets.only(bottom: Space.s),
                child: AppCard(
                  onTap: () => context.push(Routes.exercise(e.id)),
                  child: Row(children: [
                    IconBadge(muscleIcon(e.muscle)),
                    const SizedBox(width: Space.m),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(e.name(lang), style: t.titleSmall),
                        Text(l.prescription(x), style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
                      ]),
                    ),
                    const Icon(Icons.chevron_right),
                  ]),
                ),
              ),
          const SizedBox(height: Space.l),
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.warning_amber_rounded, color: context.status.warning),
                const SizedBox(width: Space.s),
                Expanded(child: Text(l.stopIf, style: t.titleSmall)),
              ]),
              const SizedBox(height: Space.s),
              for (final w in warnings)
                Padding(
                  padding: const EdgeInsets.only(bottom: Space.xs),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('•  '),
                    Expanded(child: Text(w, style: t.bodyMedium)),
                  ]),
                ),
              const SizedBox(height: Space.xs),
              Text(l.programDisclaimer, style: t.bodySmall?.copyWith(color: context.status.textSecondary)),
            ]),
          ),
        ]),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Space.l),
          child: ResponsiveContainer(
            maxWidth: 720,
            child: PrimaryButton(
              label: l.startProgram,
              icon: Icons.play_arrow,
              onPressed: cleared ? () => context.push(Routes.programSession(p.id)) : null,
            ),
          ),
        ),
      ),
    );
  }
}
