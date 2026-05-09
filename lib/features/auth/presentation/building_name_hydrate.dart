import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/features/auth/data/session_metadata_repository.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Loads building display name via Edge when session has `buildingId` but no
/// `buildingName` (e.g. older installs before redeem returned `building_name`).
Future<void> hydrateBuildingNameFromEdge(WidgetRef ref) async {
  if (Env.demoMode) {
    return;
  }
  final session = await ref.read(localSessionRepositoryProvider).load();
  if (session == null) {
    return;
  }
  final bid = session.buildingId;
  if (bid == null || bid.isEmpty) {
    return;
  }
  final hasName =
      session.buildingName != null && session.buildingName!.trim().isNotEmpty;
  if (hasName) {
    return;
  }
  try {
    final repo = ref.read(sessionMetadataRepositoryProvider);
    final name = await repo.fetchBuildingName(session);
    if (name == null || name.isEmpty) {
      return;
    }
    await ref.read(localSessionRepositoryProvider).save(
          session.copyWith(
            buildingName: name.trim(),
            savedAt: DateTime.now(),
          ),
        );
    ref.notifyLocalSessionChanged();
  } on Object {
    // Optional hydrate; ignore failures.
  }
}
