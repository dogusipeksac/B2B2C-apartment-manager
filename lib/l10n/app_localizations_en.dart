// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Apartment Manager';

  @override
  String get emailEntryTitle => 'Sign in';

  @override
  String get emailHint => 'Email address';

  @override
  String get continueButton => 'Continue';

  @override
  String get otpTitle => 'Verification Code';

  @override
  String otpSubtitle(Object identifier) {
    return 'Enter the 6-digit code sent to $identifier.';
  }

  @override
  String resendIn(Object seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get resendOtp => 'Resend';

  @override
  String get verifyButton => 'Verify';

  @override
  String get profileSetupTitle => 'Profile';

  @override
  String get fullNameHint => 'Full name';

  @override
  String get saveButton => 'Save';

  @override
  String welcomeMessage(Object fullName) {
    return 'Welcome $fullName';
  }

  @override
  String get signOut => 'Sign out';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork =>
      'Please check your internet connection and try again.';

  @override
  String get errorInvalidOtp => 'Invalid code. Please try again.';

  @override
  String get errorRateLimit => 'Too many attempts. Please wait and try again.';

  @override
  String get errorOtpExpired =>
      'The verification code has expired. Please resend.';

  @override
  String get errorEmailInvalid => 'Enter a valid email address.';

  @override
  String otpSentToEmail(Object email) {
    return 'Verification code sent to $email.';
  }
}
