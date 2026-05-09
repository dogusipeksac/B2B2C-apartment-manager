import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

/// Blur + lock when prod UI still shows mock layouts (“coming soon”).
class DemoModuleLockOverlay extends StatelessWidget {
  const DemoModuleLockOverlay({
    required this.locked,
    required this.message,
    required this.child,
    super.key,
  });

  final bool locked;
  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!locked) {
      return child;
    }
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AbsorbPointer(child: child),
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16),
                color: scheme.surface.withValues(alpha: 0.65),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 40,
                      color: scheme.primary,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
