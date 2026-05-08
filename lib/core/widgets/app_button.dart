import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, text }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.onPressed,
    required this.child,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final AppButtonVariant variant;
  final bool isLoading;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;
    final themedChild = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : child;
    final iconWidget = icon;

    switch (variant) {
      case AppButtonVariant.primary:
        return iconWidget == null
            ? FilledButton(
                onPressed: effectiveOnPressed,
                child: themedChild,
              )
            : FilledButton.icon(
                onPressed: effectiveOnPressed,
                icon: iconWidget,
                label: themedChild,
              );
      case AppButtonVariant.secondary:
        return iconWidget == null
            ? FilledButton.tonal(
                onPressed: effectiveOnPressed,
                child: themedChild,
              )
            : FilledButton.tonalIcon(
                onPressed: effectiveOnPressed,
                icon: iconWidget,
                label: themedChild,
              );
      case AppButtonVariant.text:
        return iconWidget == null
            ? TextButton(
                onPressed: effectiveOnPressed,
                child: themedChild,
              )
            : TextButton.icon(
                onPressed: effectiveOnPressed,
                icon: iconWidget,
                label: themedChild,
              );
    }
  }
}
