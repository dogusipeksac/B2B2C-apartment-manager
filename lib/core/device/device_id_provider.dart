import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apartment_manager/core/storage/secure_storage_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// Opaque device id for Edge calls — stable across app reinstalls on mobile.
///
/// Android: Settings.Secure Android ID (survives reinstall).
/// iOS: identifierForVendor (stable until all vendor apps removed).
/// Web/desktop: random UUID in secure storage (cleared on uninstall if any).
///
/// Raw OS ids are not sent to the API; we use SHA-256 and Base64URL.
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

    final id = await _createNewId();
    await _storage.write(key: _storageKey, value: id);
    return id;
  }

  Future<String> _createNewId() async {
    if (kIsWeb) {
      return const Uuid().v4();
    }

    try {
      if (Platform.isAndroid) {
        final info = await _deviceInfo.androidInfo;
        final raw = info.id.trim();
        if (raw.isNotEmpty) {
          return _opaqueFromHardwareRaw(raw);
        }
      } else if (Platform.isIOS) {
        final info = await _deviceInfo.iosInfo;
        final raw = info.identifierForVendor?.trim();
        if (raw != null && raw.isNotEmpty) {
          return _opaqueFromHardwareRaw(raw);
        }
      }
    } on Object {
      // Fall back to random UUID below.
    }

    return const Uuid().v4();
  }

  /// Deterministic opaque token — URL-safe, fixed length.
  String _opaqueFromHardwareRaw(String rawOsId) {
    final bytes = utf8.encode('apartment_manager.device.v1|$rawOsId');
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes).replaceAll('=', '');
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
  (ref) => appSecureStorage,
);

final deviceIdRepositoryProvider = Provider<DeviceIdRepository>(
  (ref) => DeviceIdRepository(ref.watch(flutterSecureStorageProvider)),
);

/// Device id string for invite redemption and Edge session pairing.
final deviceIdProvider = FutureProvider<String>((ref) async {
  return ref.watch(deviceIdRepositoryProvider).getOrCreate();
});
