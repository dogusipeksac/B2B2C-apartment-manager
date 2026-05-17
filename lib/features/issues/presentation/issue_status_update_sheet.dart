import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/core/widgets/apart_sheet.dart';
import 'package:apartment_manager/core/widgets/app_button.dart';
import 'package:apartment_manager/features/issues/domain/issue_status_update_input.dart';
import 'package:apartment_manager/features/issues/domain/issue_ui.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Manager: pick status + optional process note (themed bottom sheet).
Future<IssueStatusUpdateInput?> showIssueStatusUpdateSheet({
  required BuildContext context,
  required IssueUiStatus currentStatus,
  required String issueCode,
}) {
  return showApartBottomSheet<IssueStatusUpdateInput>(
    context: context,
    child: _IssueStatusUpdateSheet(
      currentStatus: currentStatus,
      issueCode: issueCode,
    ),
  );
}

class _IssueStatusUpdateSheet extends StatefulWidget {
  const _IssueStatusUpdateSheet({
    required this.currentStatus,
    required this.issueCode,
  });

  final IssueUiStatus currentStatus;
  final String issueCode;

  @override
  State<_IssueStatusUpdateSheet> createState() => _IssueStatusUpdateSheetState();
}

class _IssueStatusUpdateSheetState extends State<_IssueStatusUpdateSheet> {
  late IssueUiStatus _status;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _status = widget.currentStatus;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _applyQuickNote(String text) {
    final current = _noteController.text.trim();
    if (current.isEmpty) {
      _noteController.text = text;
    } else if (!current.contains(text)) {
      _noteController.text = '$current. $text';
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final apart = context.apart;

    final quickNotes = [
      l10n.issueStatusQuickNoteTechnician,
      l10n.issueStatusQuickNoteMaterial,
      l10n.issueStatusQuickNoteResident,
      l10n.issueStatusQuickNoteDone,
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ApartSheetHeader(
            title: l10n.issueStatusSheetTitle,
            subtitle: '${widget.issueCode} · ${l10n.issueStatusSheetSubtitle}',
            onClose: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.issueStatusPickLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: apart.onSurfaceVariant,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          _StatusPickerRow(
            selected: _status,
            onPick: (s) => setState(() => _status = s),
            l10n: l10n,
          ),
          const SizedBox(height: 20),
          Text(
            l10n.issueStatusNoteLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: apart.onSurfaceVariant,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            maxLines: 3,
            maxLength: 500,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: l10n.issueStatusNoteHint,
              filled: true,
              fillColor: apart.scaffoldBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: apart.outlineMuted),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: apart.outlineMuted),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: scheme.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: quickNotes.map((label) {
              return ActionChip(
                label: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                backgroundColor: apart.chipInactiveBg,
                side: BorderSide(color: apart.outlineMuted),
                onPressed: () => _applyQuickNote(label),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          AppButton(
            onPressed: () {
              final note = _noteController.text.trim();
              Navigator.of(context).pop(
                IssueStatusUpdateInput(
                  status: _status,
                  note: note.isEmpty ? null : note,
                ),
              );
            },
            child: Text(l10n.issueStatusSave),
          ),
        ],
      ),
    );
  }
}

class _StatusPickerRow extends StatelessWidget {
  const _StatusPickerRow({
    required this.selected,
    required this.onPick,
    required this.l10n,
  });

  final IssueUiStatus selected;
  final ValueChanged<IssueUiStatus> onPick;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatusCard(
            label: l10n.duesFilterOpen,
            icon: Icons.fiber_new_rounded,
            selected: selected == IssueUiStatus.open,
            accent: AppTheme.info,
            accentBg: AppTheme.infoContainer,
            onTap: () => onPick(IssueUiStatus.open),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatusCard(
            label: l10n.issueTimelineInProgress,
            icon: Icons.engineering_outlined,
            selected: selected == IssueUiStatus.inProgress,
            accent: AppTheme.warning,
            accentBg: AppTheme.warningContainer,
            onTap: () => onPick(IssueUiStatus.inProgress),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatusCard(
            label: l10n.duesFilterPaid,
            icon: Icons.check_circle_outline,
            selected: selected == IssueUiStatus.resolved,
            accent: AppTheme.success,
            accentBg: const Color(0xFFE8F5E9),
            onTap: () => onPick(IssueUiStatus.resolved),
          ),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.accent,
    required this.accentBg,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color accent;
  final Color accentBg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final apart = context.apart;
    final theme = Theme.of(context);
    return Material(
      color: selected ? accentBg : apart.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? accent : apart.outlineMuted,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? accent : apart.onSurfaceVariant, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? accent : apart.onSurfaceVariant,
                  fontSize: 11,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
