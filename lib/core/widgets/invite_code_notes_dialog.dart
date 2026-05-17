import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/core/widgets/apart_sheet.dart';
import 'package:apartment_manager/core/widgets/app_button.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Result from [showInviteCodeNotesDialog] — notes + optional policy id.
class InviteCodeSheetResult {
  const InviteCodeSheetResult({
    required this.notes,
    this.policyId,
  });

  /// Trimmed note text; may be empty.
  final String notes;

  /// e.g. `single_use` or `reusable` for admin manager codes.
  final String? policyId;
}

class InviteCodePolicyOption {
  const InviteCodePolicyOption({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.icon,
  });

  final String id;
  final String label;
  final String subtitle;
  final IconData icon;
}

/// Optional notes (and policy) when creating an invite code.
///
/// Returns `null` if dismissed.
Future<InviteCodeSheetResult?> showInviteCodeNotesDialog(
  BuildContext context, {
  required String title,
  String? subtitle,
  required String hint,
  List<InviteCodePolicyOption>? policyOptions,
  String? initialPolicyId,
}) {
  return showApartBottomSheet<InviteCodeSheetResult>(
    context: context,
    child: _InviteCodeNotesSheet(
      title: title,
      subtitle: subtitle,
      hint: hint,
      policyOptions: policyOptions,
      initialPolicyId: initialPolicyId,
    ),
  );
}

class _InviteCodeNotesSheet extends StatefulWidget {
  const _InviteCodeNotesSheet({
    required this.title,
    this.subtitle,
    required this.hint,
    this.policyOptions,
    this.initialPolicyId,
  });

  final String title;
  final String? subtitle;
  final String hint;
  final List<InviteCodePolicyOption>? policyOptions;
  final String? initialPolicyId;

  @override
  State<_InviteCodeNotesSheet> createState() => _InviteCodeNotesSheetState();
}

class _InviteCodeNotesSheetState extends State<_InviteCodeNotesSheet> {
  late final TextEditingController _controller;
  late String? _selectedPolicyId;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    final options = widget.policyOptions;
    if (options != null && options.isNotEmpty) {
      final initial = widget.initialPolicyId;
      final valid = options.any((o) => o.id == initial);
      _selectedPolicyId = valid ? initial : options.first.id;
    } else {
      _selectedPolicyId = null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    Navigator.of(context).pop(
      InviteCodeSheetResult(
        notes: text,
        policyId: _selectedPolicyId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final apart = context.apart;
    final policies = widget.policyOptions;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ApartSheetHeader(
            title: widget.title,
            subtitle: widget.subtitle,
            onClose: () => Navigator.of(context).pop(),
          ),
          if (policies != null && policies.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              l10n.inviteCodeNotesPolicySection,
              style: theme.textTheme.labelSmall?.copyWith(
                color: apart.onSurfaceVariant,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            ...policies.map(
              (opt) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _PolicyOptionTile(
                  option: opt,
                  selected: _selectedPolicyId == opt.id,
                  onTap: () => setState(() => _selectedPolicyId = opt.id),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            l10n.inviteCodeNotesLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: apart.onSurfaceVariant,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            maxLines: 3,
            minLines: 2,
            maxLength: 500,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: widget.hint,
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
                borderSide: BorderSide(color: scheme.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 20),
          AppButton(
            onPressed: _submit,
            child: Text(l10n.inviteCodeNotesCreate),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.navBack),
          ),
        ],
      ),
    );
  }
}

class _PolicyOptionTile extends StatelessWidget {
  const _PolicyOptionTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final InviteCodePolicyOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final apart = context.apart;
    final borderColor = selected ? scheme.primary : apart.outlineMuted;
    final bg = selected
        ? scheme.primaryContainer.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.35 : 0.55,
          )
        : apart.surface;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: borderColor,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: selected
                      ? scheme.primary.withValues(alpha: 0.12)
                      : apart.chipInactiveBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  option.icon,
                  size: 22,
                  color: selected ? scheme.primary : apart.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: selected ? scheme.onPrimaryContainer : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option.subtitle,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: selected
                            ? scheme.onPrimaryContainer.withValues(
                                alpha: 0.85,
                              )
                            : apart.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? scheme.primary : apart.onSurfaceTertiary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
