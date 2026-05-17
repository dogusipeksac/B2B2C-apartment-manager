import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/features/auth/data/invite_code_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Province / district from [turkiyeapi.dev](https://turkiyeapi.dev) (free, no key).
class TurkeyProvince {
  const TurkeyProvince({
    required this.id,
    required this.name,
    required this.districts,
  });

  final int id;
  final String name;
  final List<TurkeyDistrict> districts;
}

class TurkeyDistrict {
  const TurkeyDistrict({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;
}

/// Fetches Turkish provinces and nested districts.
class TurkeyLocationsRepository {
  TurkeyLocationsRepository({required Dio dio}) : _dio = dio;

  static const _provincesUrl = 'https://turkiyeapi.dev/api/v1/provinces';

  final Dio _dio;

  Future<List<TurkeyProvince>> fetchProvinces() async {
    try {
      final response = await _dio.get<dynamic>(
        _provincesUrl,
        options: Options(
          validateStatus: (_) => true,
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 20),
        ),
      );

      final status = response.statusCode ?? 0;
      if (status < 200 || status >= 300) {
        throw const AppException.network();
      }

      final raw = response.data;
      if (raw is! Map<String, dynamic>) {
        throw const AppException.unknown();
      }

      return parseTurkeyProvincesResponse(raw);
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
    } on Object {
      throw const AppException.unknown();
    }
  }

}

/// Pure parser for unit tests and [TurkeyLocationsRepository].
List<TurkeyProvince> parseTurkeyProvincesResponse(Map<String, dynamic> raw) {
  final data = raw['data'];
  if (data is! List<dynamic>) {
    throw const AppException.unknown();
  }

  final provinces = data.map(_parseProvince).toList()
    ..sort((a, b) => _compareTr(a.name, b.name));

  return provinces;
}

TurkeyProvince _parseProvince(dynamic item) {
  final m = Map<String, dynamic>.from(item as Map<dynamic, dynamic>);
  final id = m['id'];
  final name = (m['name'] as String?)?.trim() ?? '';
  final districtsRaw = m['districts'];
  final districts = <TurkeyDistrict>[];
  if (districtsRaw is List<dynamic>) {
    for (final d in districtsRaw) {
      final dm = Map<String, dynamic>.from(d as Map<dynamic, dynamic>);
      final dId = dm['id'];
      final dName = (dm['name'] as String?)?.trim() ?? '';
      if (dId is int && dName.isNotEmpty) {
        districts.add(TurkeyDistrict(id: dId, name: dName));
      }
    }
  }
  if (id is! int || name.isEmpty) {
    throw const AppException.unknown();
  }
  districts.sort((a, b) => _compareTr(a.name, b.name));
  return TurkeyProvince(id: id, name: name, districts: districts);
}

int _compareTr(String a, String b) {
  return a.toLowerCase().compareTo(b.toLowerCase());
}

final turkeyLocationsRepositoryProvider = Provider<TurkeyLocationsRepository>(
  (ref) => TurkeyLocationsRepository(dio: ref.watch(dioProvider)),
);

final turkeyProvincesProvider = FutureProvider<List<TurkeyProvince>>(
  (ref) => ref.read(turkeyLocationsRepositoryProvider).fetchProvinces(),
);
