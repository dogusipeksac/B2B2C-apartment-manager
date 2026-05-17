import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/features/auth/presentation/providers/auth_providers.dart';
import 'package:apartment_manager/features/elections/data/demo_election_repository.dart';
import 'package:apartment_manager/features/elections/data/election_ops_repository.dart';
import 'package:apartment_manager/features/elections/data/election_repository.dart';
import 'package:apartment_manager/features/elections/data/supabase_election_repository.dart';
import 'package:apartment_manager/features/elections/domain/election_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final electionRepositoryProvider = Provider<ElectionRepository>((ref) {
  if (Env.demoMode) {
    return const DemoElectionRepository();
  }
  return SupabaseElectionRepository(ref.watch(electionOpsRepositoryProvider));
});

final electionsListProvider = FutureProvider<List<ElectionUi>>((ref) async {
  final session = await ref.watch(localSessionProvider.future);
  if (session == null) {
    return [];
  }
  return ref.read(electionRepositoryProvider).listElections(session);
});

final activeElectionProvider = FutureProvider<ElectionUi?>((ref) async {
  final session = await ref.watch(localSessionProvider.future);
  if (session == null) {
    return null;
  }
  return ref.read(electionRepositoryProvider).activeElection(session);
});

final electionDetailProvider = FutureProvider.family<ElectionDetailUi?, String>(
  (ref, electionId) async {
    final session = await ref.watch(localSessionProvider.future);
    if (session == null) {
      return null;
    }
    return ref.read(electionRepositoryProvider).getElection(session, electionId);
  },
);
