import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/core/widgets/app_button.dart';
import 'package:apartment_manager/core/widgets/app_scaffold.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePlaceholderScreen extends ConsumerWidget {
  const HomePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final profileAsync = ref.watch(currentProfileProvider);
    final name = profileAsync.maybeWhen(
      data: (profile) => profile?.fullName ?? '',
      orElse: () => '',
    );

    return AppScaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.welcomeMessage(name)),
              const SizedBox(height: 16),
              AppButton(
                variant: AppButtonVariant.secondary,
                onPressed: () async {
                  try {
                    await ref.read(authRepositoryProvider).signOut();
                    if (!context.mounted) {
                      return;
                    }
                    context.go('/splash');
                  } on AppException catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.userMessage)),
                    );
                  }
                },
                child: Text(l10n.signOut),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
