import 'package:apartment_manager/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Box-style invite code entry (manager 8 / resident 5 characters).
class InviteOtpInput extends StatelessWidget {
  const InviteOtpInput({
    required this.length,
    required this.controller,
    required this.focusNode,
    required this.inputFormatters,
    this.separatorBeforeIndex,
    this.onSubmitted,
    super.key,
  });

  final int length;
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<TextInputFormatter> inputFormatters;

  /// When set, inserts a dash before this cell index (e.g. 4 → XXXX-XXXX).
  final int? separatorBeforeIndex;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final apart = context.apart;
    final theme = Theme.of(context);
    final code = controller.text;
    final activeIndex = code.length >= length ? length - 1 : code.length;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: focusNode.requestFocus,
      child: SizedBox(
        height: 52,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < length; i++) ...[
                  if (separatorBeforeIndex == i)
                    SizedBox(
                      width: 12,
                      child: Center(
                        child: Text(
                          '-',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: apart.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: InviteOtpCell(
                        char: i < code.length ? code[i] : null,
                        focused: focusNode.hasFocus && i == activeIndex,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Theme(
              data: theme.copyWith(
                splashFactory: NoSplash.splashFactory,
                highlightColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                autocorrect: false,
                enableSuggestions: false,
                keyboardType: TextInputType.visiblePassword,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: inputFormatters,
                style: const TextStyle(
                  color: Colors.transparent,
                  fontSize: 18,
                  height: 1,
                ),
                cursorColor: Colors.transparent,
                showCursor: false,
                maxLength: length,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                  filled: false,
                ),
                onSubmitted: onSubmitted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single-line field matching [InviteOtpCell] borders (name, etc.).
class InviteFormRow extends StatelessWidget {
  const InviteFormRow({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.icon,
    this.textCapitalization = TextCapitalization.none,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final IconData icon;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final apart = context.apart;
    final theme = Theme.of(context);
    final focused = focusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      height: 52,
      decoration: BoxDecoration(
        color: apart.surface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: focused ? AppTheme.primary : apart.outlineMuted,
          width: focused ? 2 : 1,
        ),
      ),
      alignment: Alignment.center,
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(
            icon,
            size: 22,
            color: AppTheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textCapitalization: textCapitalization,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: apart.onSurfaceTertiary,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
    );
  }
}

/// Single character cell for [InviteOtpInput].
class InviteOtpCell extends StatelessWidget {
  const InviteOtpCell({
    required this.char,
    required this.focused,
    super.key,
  });

  final String? char;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    final apart = context.apart;
    final theme = Theme.of(context);
    final letter = char == null || char!.isEmpty ? null : char;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = (w * 1.15).clamp(44.0, 52.0);
        final fontSize = (w * 0.52).clamp(15.0, 19.0);
        final radius = (w * 0.22).clamp(8.0, 11.0);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: apart.surface,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: focused ? AppTheme.primary : apart.outlineMuted,
              width: focused ? 2 : 1,
            ),
          ),
          child: letter == null
              ? null
              : Text(
                  letter,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    fontSize: fontSize,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
        );
      },
    );
  }
}
