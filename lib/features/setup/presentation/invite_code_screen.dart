import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Mockup **3.2** — Davet kodu: 8 hane (4-4), doğrulama önizlemesi.
class InviteCodeScreen extends StatefulWidget {
  const InviteCodeScreen({super.key});

  @override
  State<InviteCodeScreen> createState() => _InviteCodeScreenState();
}

class _InviteCodeScreenState extends State<InviteCodeScreen> {
  final List<TextEditingController> _ctrls =
      List.generate(8, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(8, (_) => FocusNode());
  bool _verified = false;

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    for (final f in _nodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onCharEntered(int index, String v) {
    if (v.isNotEmpty && index < 7) {
      _nodes[index + 1].requestFocus();
    }
    final full = _ctrls.every((c) => c.text.trim().length == 1);
    setState(() => _verified = full);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.setupInviteTitle)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.setupInviteHeadline,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Yöneticinden aldığın 8 haneli kodu gir.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CodeGroup(
                        ctrls: _ctrls.sublist(0, 4),
                        nodes: _nodes.sublist(0, 4),
                        startIndex: 0,
                        onChar: _onCharEntered,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '—',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppTheme.onSurfaceTertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _CodeGroup(
                        ctrls: _ctrls.sublist(4, 8),
                        nodes: _nodes.sublist(4, 8),
                        startIndex: 4,
                        onChar: _onCharEntered,
                      ),
                    ],
                  ),
                  if (_verified) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F8F1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.success,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '✓ KOD DOĞRULANDI',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppTheme.success,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.apartment_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.demoInvitePreviewTitle,
                                      style:
                                          theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      l10n.demoInvitePreviewSubtitle,
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        color: AppTheme.onSurfaceVariant,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: FilledButton(
              onPressed: _verified ? () => context.go('/home') : null,
              child: Text(l10n.setupInviteJoin),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('QR kod tarama yakında')),
                );
              },
              child: Text.rich(
                TextSpan(
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                  children: const [
                    TextSpan(text: 'Kodum yok · '),
                    TextSpan(
                      text: 'QR kod tara',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _CodeGroup extends StatelessWidget {
  const _CodeGroup({
    required this.ctrls,
    required this.nodes,
    required this.startIndex,
    required this.onChar,
  });

  final List<TextEditingController> ctrls;
  final List<FocusNode> nodes;
  final int startIndex;
  final void Function(int, String) onChar;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        ctrls.length,
        (i) => Padding(
          padding: EdgeInsets.only(left: i == 0 ? 0 : 8),
          child: _CodeBox(
            controller: ctrls[i],
            focusNode: nodes[i],
            onChanged: (v) => onChar(startIndex + i, v),
          ),
        ),
      ),
    );
  }
}

class _CodeBox extends StatelessWidget {
  const _CodeBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 38,
      height: 48,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        maxLength: 1,
        textCapitalization: TextCapitalization.characters,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppTheme.surface,
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppTheme.outlineMuted,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: scheme.primary, width: 1.5),
          ),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
