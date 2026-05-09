import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// Stable device id for invite redemption (stored in secure storage).
class DeviceIdRepository {
  DeviceIdRepository(
    this._storage, {
    DeviceInfoPlugin? deviceInfo,
  }) : _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  static const _storageKey = 'device_id';

  final FlutterSecureStorage _storage;
  final DeviceInfoPlugin _deviceInfo;

  Future<String> getOrCreate() async {
    final existing = await _storage.read(key: _storageKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    const uuid = Uuid();
    final id = uuid.v4();
    await _storage.write(key: _storageKey, value: id);
    return id;
  }

  /// Optional platform summary for logs or support (no PII).
  Future<String?> deviceMetaLabel() async {
    try {
      if (kIsWeb) {
        return 'web';
      }
      if (Platform.isAndroid) {
        final info = await _deviceInfo.androidInfo;
        return 'android ${info.model} sdk ${info.version.sdkInt}';
      }
      if (Platform.isIOS) {
        final info = await _deviceInfo.iosInfo;
        return 'ios ${info.model} ${info.systemVersion}';
      }
      return Platform.operatingSystem;
    } on Object {
      return null;
    }
  }
}

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final deviceIdRepositoryProvider = Provider<DeviceIdRepository>(
  (ref) => DeviceIdRepository(ref.watch(flutterSecureStorageProvider)),
);

/// Device id string (creates and persists on first use).
final deviceIdProvider = FutureProvider<String>((ref) async {
  return ref.watch(deviceIdRepositoryProvider).getOrCreate();
});
