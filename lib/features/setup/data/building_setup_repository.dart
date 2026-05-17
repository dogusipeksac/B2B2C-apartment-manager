import 'dart:io';

import 'package:apartment_manager/core/config/env.dart';
import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/features/auth/data/invite_code_repository.dart';
import 'package:apartment_manager/features/auth/data/local_session.dart';
import 'package:apartment_manager/features/setup/domain/setup_unit_spec.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Server-side building + units creation (Edge Function, service role).
class BuildingSetupRepository {
  BuildingSetupRepository({
    required Dio dio,
  })  : _dio = dio,
        _disabled = false;

  BuildingSetupRepository.disabled()
      : _dio = Dio(),
        _disabled = true;

  final Dio _dio;
  final bool _disabled;

  /// [monthlyDuesKurus] minor units (kuruş), integer.
  Future<FinalizeBuildingResult> finalizeBuilding({
    required LocalSession session,
    required String buildingName,
    required String address,
    required String city,
    required String district,
    required int monthlyDuesKurus,
    required int duesDueDay,
    required bool lateFeeEnabled,
    required bool singleBlock,
    required int blockCount,
    required int floors,
    required int perFloor,
    required bool namingAutomatic,
    List<SetupUnitSpec>? customUnits,
    String? managerFullName,
  }) async {
    if (_disabled) {
      throw const AppException.validation(code: 'demo_mode');
    }

    final token = session.sessionToken;
    if (token == null || token.isEmpty) {
      throw const AppException.auth(code: 'no_session_token');
    }

    final url = '${Env.supabaseUrl}/functions/v1/finalize_building_setup';

    try {
      final response = await _dio.post<dynamic>(
        url,
        data: <String, dynamic>{
          'device_id': session.deviceId,
          'session_token': token,
          if (managerFullName != null && managerFullName.trim().isNotEmpty)
            'manager_full_name': managerFullName.trim(),
          'building': <String, dynamic>{
            'name': buildingName.trim(),
            'address': address.trim(),
            'city': city.trim(),
            'district': district.trim(),
            'monthly_dues_minor': monthlyDuesKurus,
            'dues_due_day': duesDueDay,
            'late_fee_enabled': lateFeeEnabled,
            'single_block': singleBlock,
            'block_count': blockCount,
            'floors': floors,
            'per_floor': perFloor,
            'naming_automatic': namingAutomatic,
            if (!namingAutomatic && customUnits != null)
              'units': customUnits
                  .map(
                    (u) => <String, dynamic>{
                      'floor': u.floor,
                      'door_number': u.doorNumber,
                      'block': u.block,
                    },
                  )
                  .toList(),
          },
        },
        options: Options(
          headers: <String, String>{
            'Authorization': 'Bearer ${Env.supabaseAnonKey}',
            'apikey': Env.supabaseAnonKey,
            'Content-Type': 'application/json',
          },
          validateStatus: (_) => true,
        ),
      );

      final status = response.statusCode ?? 0;
      final raw = response.data;
      final body = raw is Map<String, dynamic>
          ? raw
          : raw is Map
              ? Map<String, dynamic>.from(raw as Map<dynamic, dynamic>)
              : <String, dynamic>{};

      if (status >= 500) {
        throw AppException.server(code: body['error'] as String?);
      }

      if (status == 401 || status == 403) {
        throw AppException.auth(code: body['error'] as String?);
      }

      if (status == 404 || status == 409) {
        throw AppException.validation(code: body['error'] as String?);
      }

      if (status == 422 || status == 400) {
        throw AppException.validation(code: body['error'] as String?);
      }

      if (status == 200 &&
          body['success'] == true &&
          body['building_id'] is String &&
          body['profile_id'] is String) {
        final countRaw = body['unit_count'];
        final unitCount = countRaw is int
            ? countRaw
            : int.tryParse('$countRaw') ?? 0;
        final serverName = body['building_name'];
        final label = serverName is String && serverName.trim().isNotEmpty
            ? serverName.trim()
            : buildingName.trim();
        return FinalizeBuildingResult(
          buildingId: body['building_id']! as String,
          profileId: body['profile_id']! as String,
          unitCount: unitCount,
          buildingLabel: label,
        );
      }

      throw const AppException.unknown();
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const AppException.network();
      }
      throw const AppException.unknown();
    } on SocketException {
      throw const AppException.network();
    } on Object {
      throw const AppException.unknown();
    }
  }
}

class FinalizeBuildingResult {
  const FinalizeBuildingResult({
    required this.buildingId,
    required this.profileId,
    required this.unitCount,
    required this.buildingLabel,
  });

  final String buildingId;
  final String profileId;
  final int unitCount;
  final String buildingLabel;
}

final buildingSetupRepositoryProvider = Provider<BuildingSetupRepository>(
  (ref) {
    if (Env.demoMode) {
      return BuildingSetupRepository.disabled();
    }
    return BuildingSetupRepository(dio: ref.watch(dioProvider));
  },
);
