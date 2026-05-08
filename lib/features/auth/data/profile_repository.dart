import 'dart:io';

import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/core/supabase/supabase_client.dart';
import 'package:apartment_manager/features/auth/domain/profile.dart';
import 'package:postgrest/postgrest.dart';

abstract interface class ProfileRepository {
  Future<Profile?> getProfile(String userId);
  Future<Profile> upsertProfile(Profile profile);
  Future<void> updateNotificationToken({
    required String userId,
    required String token,
  });
}

abstract interface class ProfileRemoteDataSource {
  Future<Map<String, dynamic>?> getProfileRow(String userId);
  Future<Map<String, dynamic>> upsertProfileRow(Map<String, dynamic> row);
  Future<void> updateNotificationToken({
    required String userId,
    required String token,
  });
}

class SupabaseProfileRemoteDataSource implements ProfileRemoteDataSource {
  const SupabaseProfileRemoteDataSource();

  static const _table = 'profiles';

  @override
  Future<Map<String, dynamic>?> getProfileRow(String userId) async {
    final data = await supabase
          .from(_table)
          .select()
          .eq('id', userId)
          .maybeSingle();
    return data == null ? null : Map<String, dynamic>.from(data);
  }

  @override
  Future<Map<String, dynamic>> upsertProfileRow(
    Map<String, dynamic> row,
  ) async {
    final data = await supabase
          .from(_table)
          .upsert(row)
          .select()
          .single();
    return Map<String, dynamic>.from(data);
  }

  @override
  Future<void> updateNotificationToken({
    required String userId,
    required String token,
  }) async {
    await supabase
        .from(_table)
        .update({'notification_token': token}).eq('id', userId);
  }
}

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository({
    ProfileRemoteDataSource? remoteDataSource,
  }) : _remote = remoteDataSource ?? const SupabaseProfileRemoteDataSource();

  final ProfileRemoteDataSource _remote;

  @override
  Future<Profile?> getProfile(String userId) async {
    try {
      final row = await _remote.getProfileRow(userId);
      return row == null ? null : Profile.fromJson(row);
    } on SocketException {
      throw const AppException.network();
    } on PostgrestException {
      throw const AppException.server();
    } on Object {
      throw const AppException.unknown();
    }
  }

  @override
  Future<Profile> upsertProfile(Profile profile) async {
    try {
      final row = await _remote.upsertProfileRow(profile.toJson());
      return Profile.fromJson(row);
    } on SocketException {
      throw const AppException.network();
    } on PostgrestException {
      throw const AppException.server();
    } on Object {
      throw const AppException.unknown();
    }
  }

  @override
  Future<void> updateNotificationToken({
    required String userId,
    required String token,
  }) async {
    try {
      await _remote.updateNotificationToken(userId: userId, token: token);
    } on SocketException {
      throw const AppException.network();
    } on PostgrestException {
      throw const AppException.server();
    } on Object {
      throw const AppException.unknown();
    }
  }
}
