import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Shared secure storage — tuned for session/device persistence on mobile.
const FlutterSecureStorage appSecureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
    resetOnError: true,
  ),
  iOptions: IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  ),
);
