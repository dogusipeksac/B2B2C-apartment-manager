import 'dart:async';
import 'dart:io';

import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/core/supabase/supabase_client.dart';
import 'package:gotrue/gotrue.dart';

enum OtpChannel { email, phone }

abstract interface class AuthRepository {
  Future<void> sendOtp({
    required String identifier,
    required OtpChannel channel,
  });

  Future<AuthResponse> verifyOtp({
    required String identifier,
    required String code,
    required OtpChannel channel,
  });

  Future<void> signOut();

  Stream<Session?> sessionStream();

  Session? get currentSession;

  User? get currentUser;
}

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({
    GoTrueClient? authClient,
  }) : _authClient = authClient ?? supabase.auth;

  final GoTrueClient _authClient;

  @override
  Future<void> sendOtp({
    required String identifier,
    required OtpChannel channel,
  }) async {
    try {
      switch (channel) {
        case OtpChannel.email:
          await _authClient.signInWithOtp(
            email: identifier,
            shouldCreateUser: true,
          );
        case OtpChannel.phone:
          await _authClient.signInWithOtp(phone: identifier);
      }
    } on SocketException {
      throw const AppException.network();
    } on AuthException catch (e) {
      final status = int.tryParse(e.statusCode ?? '');
      final code = e.code;

      if (status == 429 || code == 'over_email_send_rate_limit') {
        throw const AppException.validation(
          code: 'rate_limit',
          messageKey: 'errorRateLimit',
        );
      }

      throw AppException.auth(code: code, messageKey: 'errorGeneric');
    } on Object {
      throw const AppException.server();
    }
  }

  @override
  Future<AuthResponse> verifyOtp({
    required String identifier,
    required String code,
    required OtpChannel channel,
  }) async {
    try {
      switch (channel) {
        case OtpChannel.email:
          return await _authClient.verifyOTP(
            email: identifier,
            token: code,
            type: OtpType.email,
          );
        case OtpChannel.phone:
          return await _authClient.verifyOTP(
            phone: identifier,
            token: code,
            type: OtpType.sms,
          );
      }
    } on SocketException {
      throw const AppException.network();
    } on AuthException catch (e) {
      final status = int.tryParse(e.statusCode ?? '');
      final code = e.code;

      if (status == 429 || code == 'over_email_send_rate_limit') {
        throw const AppException.validation(
          code: 'rate_limit',
          messageKey: 'errorRateLimit',
        );
      }

      if (code == 'otp_expired') {
        throw const AppException.validation(
          code: 'otp_expired',
          messageKey: 'errorOtpExpired',
        );
      }

      if (code == 'invalid_otp' || code == 'token_not_found') {
        throw const AppException.validation(
          code: 'invalid_otp',
          messageKey: 'errorInvalidOtp',
        );
      }

      if (status == 400 || status == 401) {
        throw const AppException.validation(messageKey: 'errorInvalidOtp');
      }

      throw AppException.auth(code: code, messageKey: 'errorGeneric');
    } on Object {
      throw const AppException.server();
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _authClient.signOut();
    } on SocketException {
      throw const AppException.network();
    } on AuthException catch (e) {
      throw AppException.auth(code: e.code, messageKey: 'errorGeneric');
    } on Object {
      throw const AppException.server();
    }
  }

  @override
  Stream<Session?> sessionStream() async* {
    yield _authClient.currentSession;
    yield* _authClient.onAuthStateChange.map((event) => event.session);
  }

  @override
  Session? get currentSession => _authClient.currentSession;

  @override
  User? get currentUser => _authClient.currentUser;
}
