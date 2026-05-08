import 'package:apartment_manager/core/errors/app_exception.dart';
import 'package:apartment_manager/features/auth/data/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotrue/gotrue.dart' hide OtpChannel;
import 'package:mocktail/mocktail.dart';

class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  setUpAll(() {
    registerFallbackValue(OtpType.email);
  });

  late GoTrueClient authClient;
  late AuthRepository repository;

  setUp(() {
    authClient = MockGoTrueClient();
    repository = SupabaseAuthRepository(authClient: authClient);
  });

  test('sendOtp email başarılı → exception fırlatmaz', () async {
    when(
      () => authClient.signInWithOtp(
        email: any(named: 'email'),
        shouldCreateUser: any(named: 'shouldCreateUser'),
      ),
    ).thenAnswer((_) async {});

    await repository.sendOtp(identifier: 'a@b.com', channel: OtpChannel.email);
  });

  test('sendOtp AuthException → AppException.auth', () async {
    when(
      () => authClient.signInWithOtp(
        email: any(named: 'email'),
        shouldCreateUser: any(named: 'shouldCreateUser'),
      ),
    ).thenThrow(const AuthException('fail'));

    expect(
      () => repository.sendOtp(
        identifier: 'a@b.com',
        channel: OtpChannel.email,
      ),
      throwsA(const AppException.auth()),
    );
  });

  test('verifyOtp başarılı → AuthResponse döner', () async {
    final expected = AuthResponse(
      session: Session(
        accessToken: 'token',
        tokenType: 'bearer',
        expiresIn: 3600,
        refreshToken: 'refresh',
        user: User(
          id: 'u1',
          appMetadata: const {},
          userMetadata: const {},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
        ),
      ),
      user: User(
        id: 'u1',
        appMetadata: const {},
        userMetadata: const {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      ),
    );

    when(
      () => authClient.verifyOTP(
        email: any(named: 'email'),
        token: any(named: 'token'),
        type: any(named: 'type'),
      ),
    ).thenAnswer((_) async => expected);

    final result = await repository.verifyOtp(
      identifier: 'a@b.com',
      code: '123456',
      channel: OtpChannel.email,
    );

    expect(result, expected);
  });

  test('verifyOtp invalid code → AppException.validation', () async {
    when(
      () => authClient.verifyOTP(
        email: any(named: 'email'),
        token: any(named: 'token'),
        type: any(named: 'type'),
      ),
    ).thenThrow(const AuthException('invalid', statusCode: '400'));

    expect(
      () => repository.verifyOtp(
        identifier: 'a@b.com',
        code: '000000',
        channel: OtpChannel.email,
      ),
      throwsA(const AppException.validation()),
    );
  });
}
