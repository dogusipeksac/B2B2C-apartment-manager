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
    } on AuthException {
      throw const AppException.auth();
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
      if (e.statusCode == '400' || e.statusCode == '401') {
        throw const AppException.validation();
      }
      throw const AppException.auth();
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
    } on AuthException {
      throw const AppException.auth();
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
  User? get currentUser => _authClient.currentUser;
}
