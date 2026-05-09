import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/features/announcements/data/announcement_repository.dart';
import 'package:apartment_manager/features/announcements/data/demo_announcement_repository.dart';
import 'package:apartment_manager/features/announcements/data/supabase_announcement_repository.dart';
import 'package:apartment_manager/features/announcements/domain/announcement_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final announcementRepositoryProvider = Provider<AnnouncementRepository>(
  (ref) {
    if (Env.demoMode) {
      return const DemoAnnouncementRepository();
    }
    return SupabaseAnnouncementRepository();
  },
);

final announcementsListProvider = FutureProvider<List<AnnouncementUi>>(
  (ref) => ref.watch(announcementRepositoryProvider).listAnnouncements(),
);
