import 'dart:async';

import 'package:apartment_manager/features/auth/data/auth_repository.dart';
import 'package:gotrue/gotrue.dart' hide OtpChannel;

/// Local auth when `.env` has DEMO_MODE=true: no network; OTP succeeds.
class DemoAuthRepository implements AuthRepository {
  Session? _session;
  final _sessionUpdates = StreamController<Session?>.broadcast();

  void _emit(Session? session) {
    _session = session;
    _sessionUpdates.add(session);
  }

  static User _demoUser({
    required String identifier,
    required OtpChannel channel,
  }) {
    return User(
      id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      appMetadata: const {},
      userMetadata: const {'demo': true},
      aud: 'authenticated',
      email: channel == OtpChannel.email ? identifier : null,
      phone: channel == OtpChannel.phone ? identifier : null,
      createdAt: DateTime.now().toUtc().toIso8601String(),
    );
  }

  @override
  Future<void> sendOtp({
    required String identifier,
    required OtpChannel channel,
  }) async {
    await Future<void>.delayed(Duration.zero);
  }

  @override
  Future<AuthResponse> verifyOtp({
    required String identifier,
    required String code,
    required OtpChannel channel,
  }) async {
    await Future<void>.delayed(Duration.zero);
    final user = _demoUser(identifier: identifier, channel: channel);
    final session = Session(
      accessToken: 'demo_access_token',
      refreshToken: 'demo_refresh_token',
      expiresIn: 3600,
      tokenType: 'bearer',
      user: user,
    );
    _emit(session);
    return AuthResponse(session: session);
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(Duration.zero);
    _emit(null);
  }

  @override
  Stream<Session?> sessionStream() async* {
    yield _session;
    yield* _sessionUpdates.stream;
  }

  @override
  Session? get currentSession => _session;

  @override
  User? get currentUser => _session?.user;
}
