// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AptKeeper';

  @override
  String get splashTagline => 'Apartment & building management';

  @override
  String get emailEntryTitle => 'Sign in';

  @override
  String get emailLoginHeadline => 'Your email';

  @override
  String get emailLoginSubtitle => 'We\'ll send you a one-time code.';

  @override
  String get emailFieldLabel => 'EMAIL';

  @override
  String get kvkkEmailNotice =>
      'We\'re GDPR-aligned. Your email is only used to sign in.';

  @override
  String get loginLegalPrefix => 'By continuing you accept the ';

  @override
  String get loginLegalTerms => 'Terms of Use';

  @override
  String get loginLegalMiddle => ' and ';

  @override
  String get loginLegalPrivacy => 'Privacy Policy';

  @override
  String get loginLegalSuffix => '.';

  @override
  String get legalLinkPlaceholder => 'This content will be available soon.';

  @override
  String get emailHint => 'Email address';

  @override
  String get continueButton => 'Continue';

  @override
  String get otpAppBarTitle => 'Verification';

  @override
  String get otpHeadline => 'Enter the code';

  @override
  String otpSentParagraph(Object identifier) {
    return 'We sent a 6-digit code to $identifier.';
  }

  @override
  String get otpResendPrompt => 'Didn\'t get a code?';

  @override
  String otpResendLineCooldown(Object time) {
    return 'Didn\'t get a code? Resend ($time)';
  }

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
  String get profileSetupTitle => 'Create profile';

  @override
  String get profileHeadline => 'How should we introduce you?';

  @override
  String get profileSubtitle =>
      'Neighbors and your manager will see this name.';

  @override
  String get profileAvatarTitle => 'Photo';

  @override
  String get profileAvatarSubtitle => 'You can add it later';

  @override
  String get fullNameFieldLabel => 'FULL NAME';

  @override
  String get fullNameHint => 'Full name';

  @override
  String get phoneFieldLabel => 'PHONE (OPTIONAL)';

  @override
  String get phoneHint => '+90 5__ ___ __ __';

  @override
  String get saveButton => 'Save';

  @override
  String welcomeMessage(Object fullName) {
    return 'Welcome $fullName';
  }

  @override
  String get signOut => 'Sign out';

  @override
  String get rememberMeLabel => 'Remember me';

  @override
  String get rememberMeHint => 'Keep me signed in when I open the app';

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

  @override
  String get demoHubTitle => 'Demo — Screen catalog';

  @override
  String get demoHubSubtitle =>
      'All screens from the HTML mockup and analysis. Sample data only.';

  @override
  String get demoBadge => 'DEMO';

  @override
  String get demoBackToHub => 'Back to catalog';

  @override
  String get demoSectionAuth => '1 · Auth & onboarding';

  @override
  String get demoSectionHome => '2 · Home';

  @override
  String get demoSectionSetup => '3 · Building setup';

  @override
  String get demoSectionResident => '4 · Resident (dues, news, profile)';

  @override
  String get demoSectionIssues => '5 · Issues';

  @override
  String get demoSectionAdmin => '6 · Manager';

  @override
  String get demoSectionReports => '7 · Reports';

  @override
  String get demoSectionDocs => '8 · Documents & voting';

  @override
  String get demoSectionSubscription => '9 · Subscription & settings';

  @override
  String get demoTileSplashPreview => '1.1 Splash';

  @override
  String get demoTileWelcome => '1.2 Onboarding';

  @override
  String get demoTileLoginReal => '1.3 Sign-in screen';

  @override
  String get demoTileOtpReal => '1.4 OTP verification';

  @override
  String get demoTileProfileReal => '1.5 Create profile';

  @override
  String get demoTileResidentHome => '2.1 Resident home';

  @override
  String get demoTileAdminHome => '2.2 Manager home';

  @override
  String get demoTileRoleSelect => '3.1 Role selection';

  @override
  String get demoTileInviteCode => '3.2 Invite code';

  @override
  String get demoTileSetupBuilding => '3.3 Setup · Building';

  @override
  String get demoTileSetupStructure => '3.4 Setup · Structure';

  @override
  String get demoTileSetupUnits => '3.5 Setup · Units';

  @override
  String get demoTileSetupDues => '3.6 Setup · Dues';

  @override
  String get demoTileDuesHistory => '4.1 Dues history';

  @override
  String get demoTileDuesDetail => '4.2 Dues detail';

  @override
  String get demoTilePaymentCheckout => '4.3 Checkout (iyzico)';

  @override
  String get demoTilePaymentSuccess => '4.4 Payment success';

  @override
  String get demoTileAnnouncements => '4.5 Announcements feed';

  @override
  String get demoTileAnnouncementDetail => '4.6 Announcement detail';

  @override
  String get demoTileProfileResident => '4.7 Profile';

  @override
  String get demoTileIssuesList => '5.1 Issue list';

  @override
  String get demoTileIssueNew => '5.2 New issue';

  @override
  String get demoTileIssueDetail => '5.3 Issue detail';

  @override
  String get demoTileIssuesKanban => '5.4 Manager kanban';

  @override
  String get demoTileUnitsGrid => '6.1 Units';

  @override
  String get demoTileInviteResidents => '6.2 Invite residents';

  @override
  String get demoTilePeriods => '6.3 Periods';

  @override
  String get demoTileExpenseNew => '6.4 New expense';

  @override
  String get demoTileReportsOverview => '7.1 Financial overview';

  @override
  String get demoTileDocuments => '8.1 Documents';

  @override
  String get demoTilePolls => '8.2 Voting';

  @override
  String get demoTileSubscription => '9.1 Subscription';

  @override
  String get demoTileBuildingSettings => '9.2 Building settings';

  @override
  String get demoSplashTagline => 'Apartment & building management';

  @override
  String get demoWelcomeSlide1Title =>
      'Run your building, keep residents informed';

  @override
  String get demoWelcomeSlide1Body =>
      'Dues, announcements, issues, and polls — in one app.';

  @override
  String get demoWelcomeSlide2Title => 'Transparent dues and payments';

  @override
  String get demoWelcomeSlide2Body =>
      'See your balance instantly and pay securely.';

  @override
  String get demoWelcomeSlide3Title => 'Your community in one place';

  @override
  String get demoWelcomeSlide3Body =>
      'Stay connected with news, documents, and polls.';

  @override
  String get demoSkip => 'Skip';

  @override
  String get demoBuildingHeaderLine => 'GREEN VALLEY APT · 3A';

  @override
  String get residentBuildingHeaderFallback => 'RESIDENT · Building';

  @override
  String demoHelloName(Object name) {
    return 'Hello $name 👋';
  }

  @override
  String get demoOpenDebt => 'OUTSTANDING';

  @override
  String demoDueLabel(Object date, Object status) {
    return 'Due: $date · $status';
  }

  @override
  String get demoPayNow => 'Pay now';

  @override
  String get demoAnnouncementsSection => 'Announcements';

  @override
  String get demoIssuesSection => 'Issues';

  @override
  String get demoPinAnnouncement => 'Pinned';

  @override
  String get demoAnnouncementSampleTitle =>
      'Elevator maintenance tomorrow 10:00–12:00';

  @override
  String get demoAnnouncementSampleMeta => 'Management · 124 views';

  @override
  String get demoIssueSampleTitle => 'Roof leak — stairwell end';

  @override
  String get demoIssueSampleMeta => 'Open · High priority';

  @override
  String get demoNavHome => 'Home';

  @override
  String get demoNavAnnouncements => 'News';

  @override
  String get demoNavFinance => 'Dues';

  @override
  String get demoNavIssues => 'Issues';

  @override
  String get demoNavProfile => 'Profile';

  @override
  String get demoAdminSummaryTitle => 'This month';

  @override
  String get demoCollected => 'Collected';

  @override
  String get demoExpected => 'Expected';

  @override
  String get demoExpenseTotal => 'Expenses';

  @override
  String get demoQuickActions => 'Quick actions';

  @override
  String get demoActionInvite => 'Invite code';

  @override
  String get demoActionExpense => 'New expense';

  @override
  String get demoActionIssues => 'Issues';

  @override
  String get demoChartPlaceholder => 'Collection chart (demo)';

  @override
  String get demoRoleTitle => 'How do you want to continue?';

  @override
  String get demoRoleSubtitle =>
      'Residents join with a code; managers start building setup.';

  @override
  String get demoRoleResident => 'Resident — I have an invite code';

  @override
  String get demoRoleAdmin => 'Manager — create a building';

  @override
  String get demoInviteTitle => 'Invite code';

  @override
  String get demoInviteSubtitle =>
      'Enter the 8-digit code; you will see a building preview.';

  @override
  String get demoInviteHint => 'CODE';

  @override
  String get demoInviteVerify => 'Verify and join';

  @override
  String get demoInvitePreviewTitle => 'Green Valley Apartments';

  @override
  String get demoInvitePreviewSubtitle => 'Üsküdar · Istanbul';

  @override
  String get demoSetupBuildingTitle => 'Building details';

  @override
  String get demoSetupBuildingName => 'Building name';

  @override
  String get demoSetupAddress => 'Full address';

  @override
  String get demoSetupCity => 'City / district';

  @override
  String demoSetupStep(Object current, Object total) {
    return 'Step $current / $total';
  }

  @override
  String get demoSetupStructureTitle => 'Structure';

  @override
  String get demoSetupFloors => 'Floor count';

  @override
  String get demoSetupUnitsPerFloor => 'Units per floor';

  @override
  String demoSetupUnitsPreview(Object count) {
    return 'Preview: ~$count units';
  }

  @override
  String get demoSetupUnitsTitle => 'Units';

  @override
  String get demoSetupNamingAuto => 'Auto naming';

  @override
  String get demoSetupDuesTitle => 'Dues template';

  @override
  String get demoSetupDuesAmount => 'Monthly amount';

  @override
  String get demoSetupDueDay => 'Due day';

  @override
  String get demoSetupSmsReminder => 'SMS reminder';

  @override
  String get demoSetupLateFee => 'Late payment notice';

  @override
  String get demoFilterAll => 'All';

  @override
  String get demoFilterPaid => 'Paid';

  @override
  String get demoFilterDebt => 'Overdue';

  @override
  String get demoMonthMarch2026 => 'March 2026';

  @override
  String get demoMonthFebruary2026 => 'February 2026';

  @override
  String get demoDuesDetailTitle => 'Dues detail';

  @override
  String get demoBreakdownBase => 'Dues amount';

  @override
  String get demoBreakdownLate => 'Late fee';

  @override
  String demoInvoiceRef(Object ref) {
    return 'Invoice no: $ref';
  }

  @override
  String get demoPaymentTitle => 'Payment';

  @override
  String get demoPaymentSavedCard => 'Saved card';

  @override
  String get demoPaymentCvv => 'CVV';

  @override
  String get demoPaymentSecure => 'Secure payment with 3D Secure';

  @override
  String get demoPaymentSubmit => 'Complete payment';

  @override
  String get demoPaymentSuccessTitle => 'Payment received';

  @override
  String get demoPaymentSuccessBody =>
      'Your payment was successful. You can download the receipt.';

  @override
  String get demoDownloadReceipt => 'Download receipt';

  @override
  String get demoAnnouncementDetailHint => 'Write a comment…';

  @override
  String get demoAnnouncementSampleBody =>
      'A power outage may occur; be careful when using the elevator.';

  @override
  String get demoAttachmentPdf => 'meeting_notes.pdf';

  @override
  String get demoProfileBuildingCard => 'Building card';

  @override
  String get demoProfileSettings => 'Settings';

  @override
  String get demoProfileNotifications => 'Notifications';

  @override
  String get demoProfilePrivacy => 'Privacy & GDPR';

  @override
  String get demoIssueCategory => 'Category';

  @override
  String get demoIssueLocation => 'Location';

  @override
  String get demoIssuePriority => 'Priority';

  @override
  String get demoIssueAddPhoto => 'Add photo';

  @override
  String get demoIssueSubmit => 'Submit issue';

  @override
  String get demoIssueTimelineLogged => 'Ticket created';

  @override
  String get demoIssueTimelineAssigned => 'Assigned to technical team';

  @override
  String get demoIssueAdminNote =>
      'Manager note: Will be checked tomorrow morning.';

  @override
  String get demoKanbanOpen => 'Open';

  @override
  String get demoKanbanProgress => 'In progress';

  @override
  String get demoKanbanDone => 'Done';

  @override
  String demoUnitsFloor(Object floor) {
    return 'Floor $floor';
  }

  @override
  String demoUnitDebt(Object amount) {
    return 'Debt $amount';
  }

  @override
  String get demoUnitPaid => 'Paid';

  @override
  String get demoUnitEmpty => 'Vacant';

  @override
  String get demoInviteQrHelp => 'Share QR or copy the code.';

  @override
  String get demoInviteShare => 'Share invite';

  @override
  String get demoInviteBulk => 'Bulk invite (CSV)';

  @override
  String get demoPeriodActive => 'Active period';

  @override
  String get demoPeriodCollectionRate => 'Collection rate';

  @override
  String get demoExpenseNotifyResidents => 'Notify residents';

  @override
  String get demoExpenseSave => 'Save expense';

  @override
  String get demoExpenseCategoryWater => 'Water';

  @override
  String get demoExpenseCategoryElectric => 'Electric';

  @override
  String get demoExpenseCategoryElevator => 'Elevator';

  @override
  String get demoExpenseCategoryOther => 'Other';

  @override
  String get demoReportsTitle => 'Reports';

  @override
  String get demoReportsCashflow => 'Cash flow';

  @override
  String get demoReportsExpenseSplit => 'Expense breakdown';

  @override
  String get demoDocumentsTitle => 'Documents';

  @override
  String get demoDocumentsFolderMeeting => 'Meetings';

  @override
  String get demoDocumentsFolderContracts => 'Contracts';

  @override
  String get demoPollsTitle => 'Polls';

  @override
  String get demoPollsActive => 'Active';

  @override
  String get demoPollsClosed => 'Completed';

  @override
  String get demoPollSampleTitle => 'Roof renovation proposal';

  @override
  String get demoSubscriptionTitle => 'Subscription';

  @override
  String get demoSubscriptionPlan => 'Professional plan';

  @override
  String get demoSubscriptionPrice => '₺299 / month · one building';

  @override
  String get demoSubscriptionCta => 'Choose plan';

  @override
  String get demoSettingsTitle => 'Building settings';

  @override
  String get demoSettingsDues => 'Dues rules';

  @override
  String get demoSettingsRoles => 'Manager roles';

  @override
  String get demoLegendPaid => 'Paid';

  @override
  String get demoLegendDebt => 'Debt';

  @override
  String get demoLegendVacant => 'Vacant';

  @override
  String get demoSampleDelay => '3 days overdue';

  @override
  String get demoSampleDateShort => 'March 5, 2026';

  @override
  String get demoPriorityHigh => 'High priority';

  @override
  String get homeRecentAnnouncements => 'Recent announcements';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get homeAnnouncementTagPin => 'PIN';

  @override
  String get homeAnnouncementTagInfo => 'Info';

  @override
  String get homeOpenIssuesSection => 'Open issues';

  @override
  String get homeIssueStatusInProgress => 'In progress';

  @override
  String homeIssueUpdatedAgo(Object time) {
    return 'Updated $time ago';
  }

  @override
  String get homeManagerBuildingLine => 'MANAGER · GREEN VALLEY APT.';

  @override
  String get homeManagerMonthYear => 'March 2026';

  @override
  String get homeManagerCollectionLabel => 'COLLECTION';

  @override
  String get homeManagerIncomeLabel => 'INCOME THIS MONTH';

  @override
  String get homeManagerOpenDebtLabel => 'OUTSTANDING DEBT';

  @override
  String get homeManagerOpenIssuesLabel => 'OPEN ISSUES';

  @override
  String homeManagerUnitsSuffix(Object count) {
    return '$count units';
  }

  @override
  String homeManagerHighPrioritySuffix(Object count) {
    return '$count high priority';
  }

  @override
  String homeManagerIncomeDelta(Object percent) {
    return '↑ $percent vs last month';
  }

  @override
  String get homeChartSixMonths => 'Last 6 months · Income / Expense';

  @override
  String get homeChartLegendIncome => 'Income';

  @override
  String get homeChartLegendExpense => 'Expense';

  @override
  String get homeQuickNewPeriod => 'New period';

  @override
  String get homeQuickSendAnnouncement => 'Send announcement';

  @override
  String get homeQuickSendInvite => 'Send invite';

  @override
  String get homeQuickAddExpense => 'Add expense';

  @override
  String get homeQuickActionsSection => 'QUICK ACTIONS';

  @override
  String get homeDemoSwitchManager => 'Manager view';

  @override
  String get homeDemoSwitchResident => 'Resident view';

  @override
  String get homeEmptyNoRecords => 'No records yet.';

  @override
  String get homeNoOutstandingDebt => 'You have no outstanding balance.';

  @override
  String get homeAidatSectionTitle => 'Dues overview';

  @override
  String get homeDemoDuesMarchTitle => 'March 2026 dues';

  @override
  String get homeDemoDuesMarchSubtitle => 'Past due date';

  @override
  String get homeDemoDuesFebTitle => 'February 2026 dues';

  @override
  String get homeDemoDuesFebSubtitle => 'Paid · Feb 28, 2026';

  @override
  String get homeDemoElevatorAnnouncementTitle =>
      'Elevator maintenance · Mar 12';

  @override
  String get homeDemoElevatorAnnouncementAuthor => 'Ayşe Demir';

  @override
  String get homeDemoHotWaterTitle => 'Hot water outage 14:00–16:00';

  @override
  String get homeDemoHotWaterAuthor => 'Ali Kaya';

  @override
  String get homeDemoRoofLeakTitle => 'Roof water leak';

  @override
  String get homeDemoIssueUpdatedHours => '2 hours';

  @override
  String homeNotificationsBadge(Object count) {
    return '$count notifications';
  }

  @override
  String get homeFeatureSoon => 'Coming soon.';

  @override
  String get demoPersonaScreenTitle => 'Account type';

  @override
  String get demoPersonaScreenSubtitle =>
      'How are you joining your building? You can change this later from your profile in demo.';

  @override
  String get demoPersonaResidentTitle => 'Continue as resident';

  @override
  String get demoPersonaResidentBody =>
      'Connect to your unit with the invite code from your manager.';

  @override
  String get demoPersonaManagerTitle => 'Continue as manager';

  @override
  String get demoPersonaManagerBody =>
      'Set up your building from scratch and invite residents.';

  @override
  String get demoPersonaTrialBanner => 'First 30 days free. No card required.';

  @override
  String get catalogEmptyTitle => 'Nothing here yet';

  @override
  String get catalogLoadError => 'Could not load data';

  @override
  String get duesMyTitle => 'My dues';

  @override
  String get duesOpenDebt => 'OUTSTANDING';

  @override
  String duesUnpaidSummary(Object unpaid, Object late) {
    return '$unpaid unpaid · $late';
  }

  @override
  String get duesFilterAll => 'All';

  @override
  String get duesFilterOpen => 'Open';

  @override
  String get duesFilterPaid => 'Paid';

  @override
  String get duesFilterLate => 'Late';

  @override
  String get duesPayNow => 'Pay now';

  @override
  String get duesDetailTitle => 'Dues detail';

  @override
  String get duesAmountDue => 'AMOUNT DUE';

  @override
  String get duesLineBase => 'Dues';

  @override
  String duesLineLateFee(Object days) {
    return 'Late fee ($days days)';
  }

  @override
  String duesPayCta(Object amount) {
    return 'Pay $amount';
  }

  @override
  String get paymentTitle => 'Payment';

  @override
  String get paymentSecurePay => 'Pay securely';

  @override
  String get paymentSuccessTitle => 'Payment successful';

  @override
  String get paymentSuccessBody =>
      'Your dues are paid. We emailed the receipt.';

  @override
  String get announcementsTitle => 'Announcements';

  @override
  String get announcementDetailTitle => 'Announcement';

  @override
  String announcementsChipAll(Object count) {
    return 'All · $count';
  }

  @override
  String announcementsChipPinned(Object count) {
    return '📌 Pinned · $count';
  }

  @override
  String get announcementsChipUrgent => '⚠️ Urgent';

  @override
  String get announcementsChipInfo => 'Info';

  @override
  String get announcementsChipMaintenance => 'Maintenance';

  @override
  String get announcementsReadLabel => 'Read';

  @override
  String announcementCommentPlaceholder(Object count) {
    return 'Write a comment... ($count)';
  }

  @override
  String get announcementDetailTagPinnedMaintenance => '⭐ PINNED · MAINTENANCE';

  @override
  String get announcementDownloadComingSoon => 'Download coming soon';

  @override
  String announcementViewsFallback(Object count) {
    return '$count views';
  }

  @override
  String get issuesTitle => 'Issues';

  @override
  String get issueNewTitle => 'New issue';

  @override
  String get issueDetailTitle => 'Issue detail';

  @override
  String get issueSubmit => 'Submit report';

  @override
  String get issuesKanbanTitle => 'Issue board';

  @override
  String issuesChipAll(Object count) {
    return 'All · $count';
  }

  @override
  String issuesChipOpen(Object count) {
    return 'Open · $count';
  }

  @override
  String issuesChipInProgress(Object count) {
    return 'In progress · $count';
  }

  @override
  String issuesChipResolved(Object count) {
    return 'Resolved · $count';
  }

  @override
  String get issuesBadgeOpen => 'Open';

  @override
  String get issuesBadgeInProgress => 'In progress';

  @override
  String get issuesBadgeResolved => 'Resolved';

  @override
  String get issuesFooterOwnReport => 'Your report';

  @override
  String issuesFooterTracking(Object name) {
    return '$name on it';
  }

  @override
  String get profileMenuTitle => 'Profile';

  @override
  String get profileSwitchToManager => 'Switch to manager view';

  @override
  String get profileSwitchToResident => 'Switch to resident view';

  @override
  String get setupInviteTitle => 'Invite code';

  @override
  String get setupInviteJoin => 'Join building';

  @override
  String get setupWizardTitle => 'Building setup';

  @override
  String get setupWizardStepUnitsPlaceholder => 'Units · summary';

  @override
  String get setupWizardStepDuesPlaceholder => 'Dues plan';

  @override
  String get managerUnitsTitle => 'Units';

  @override
  String managerFloorHeading(Object floor) {
    return 'FLOOR $floor';
  }

  @override
  String managerFloorUnitCount(Object count) {
    return '$count units';
  }

  @override
  String get managerInviteTitle => 'Invite resident';

  @override
  String get managerPeriodsTitle => 'Dues periods';

  @override
  String get managerExpenseTitle => 'New expense';

  @override
  String get commonClose => 'Close';

  @override
  String get duesDetailApartmentTitle => 'Apartment';

  @override
  String get duesDetailApartmentValue => '3A · Mehmet Yılmaz';

  @override
  String get duesDetailPeriodTitle => 'Period';

  @override
  String get duesDetailDueTitle => 'Due date';

  @override
  String get duesDetailInvoiceTitle => 'Invoice no';

  @override
  String get payment3dInfo =>
      'Secure payment with 3D Secure. SMS verification will follow.';

  @override
  String get paymentNewCard => 'Add new card';

  @override
  String paymentTotal(Object amount) {
    return 'Total $amount';
  }

  @override
  String get paymentReceiptAmountLabel => 'AMOUNT';

  @override
  String get paymentReceiptPeriodLabel => 'PERIOD';

  @override
  String get paymentReceiptTxnLabel => 'TXN';

  @override
  String get paymentReceiptMethodLabel => 'METHOD';

  @override
  String get paymentReceiptAmountValue => '₺1,530.00';

  @override
  String get paymentReceiptPeriodValue => 'March 2026 · 3A';

  @override
  String get paymentReceiptTxnValue => 'İZ-9F4A2-26';

  @override
  String get paymentReceiptMethodValue => 'VISA **** 4729';

  @override
  String get announcementCatPinned => 'PINNED';

  @override
  String get announcementCatMaintenance => 'Maintenance';

  @override
  String get announcementCatUrgent => 'Urgent';

  @override
  String get profileBadgeResident => 'Resident';

  @override
  String get profileBadgeManager => 'Manager';

  @override
  String get profileBadgeSuperAdmin => 'Super admin';

  @override
  String get profileCardSubtitleManager =>
      'This device is linked for building administration.';

  @override
  String get profileCardSubtitleResident =>
      'This device is linked to a unit via invite code.';

  @override
  String get profileCardNoBuildingTitle => 'No building info yet';

  @override
  String get profileCardNoBuildingBody =>
      'Shows here after setup or invite completes.';

  @override
  String get profileCardFetchingBuildingTitle => 'Loading building info…';

  @override
  String get profileCardFetchingBuildingBody =>
      'Fetching building name from the server.';

  @override
  String get profileDemoCardTitle => 'Demo environment';

  @override
  String get profileDemoCardSubtitle =>
      'Turn off DEMO_MODE for real building data.';

  @override
  String get profileSectionAccount => 'ACCOUNT';

  @override
  String get profileSectionSupport => 'SUPPORT';

  @override
  String get profileMenuProfileInfo => 'Profile details';

  @override
  String get profileMenuNotifications => 'Notification settings';

  @override
  String get profileMenuSavedCards => 'Saved cards';

  @override
  String get profileMenuHelpCenter => 'Help center';

  @override
  String get profileVersionFooter => 'Version 1.0.0';

  @override
  String get issueFieldTitle => 'Title';

  @override
  String get issueFieldDescription => 'Description';

  @override
  String get issueCreateAppBarTitle => 'New issue report';

  @override
  String get issueCategorySection => 'CATEGORY';

  @override
  String get issueCategoryWater => 'Water';

  @override
  String get issueCategoryElectric => 'Electric';

  @override
  String get issueCategoryMechanical => 'Mechanical';

  @override
  String get issueCategoryOther => 'Other';

  @override
  String get issueLocationSection => 'LOCATION';

  @override
  String get issueLocationApartment => 'Inside unit';

  @override
  String get issueLocationParking => 'Parking';

  @override
  String get issueLocationRoof => 'Roof';

  @override
  String get issueLocationGarden => 'Garden';

  @override
  String get issueLocationElevator => 'Elevator';

  @override
  String get issuePrioritySection => 'PRIORITY';

  @override
  String get issuePriorityLow => 'Low';

  @override
  String get issuePriorityMedium => 'Medium';

  @override
  String get issuePriorityHigh => 'High';

  @override
  String get issueDescriptionPlaceholder => 'Describe the issue...';

  @override
  String get issuePhotoAdd => 'Photo';

  @override
  String get issuePhotoComingSoon => 'Photo upload coming soon';

  @override
  String get issueSubmittedDemo => 'Demo: report saved.';

  @override
  String get issueTimelineSection => 'TIMELINE';

  @override
  String get issueTimelineReported => 'Reported';

  @override
  String get issueTimelineSeen => 'Seen';

  @override
  String get issueTimelineInProgress => 'In progress';

  @override
  String get issueTimelineResolved => 'Resolved';

  @override
  String get issueTimelinePending => '—';

  @override
  String get issueDemoReportedBy => 'Reported by Mehmet Y. (3A).';

  @override
  String issueTimelineSeenBody(Object assignee) {
    return '$assignee (manager) took the task';
  }

  @override
  String get issueDemoInProgressNote =>
      'Plumber called; arriving tomorrow 10:00.';

  @override
  String get issueDemoManagerName => 'Ayşe Demir';

  @override
  String get navBack => 'Back';

  @override
  String get setupInviteHeadline => 'Connect to your building';

  @override
  String get setupFloorCountLabel => 'Floors';

  @override
  String get setupWizardPerFloorLabel => 'Units per floor';

  @override
  String get setupBuildingNameLabel => 'Building name';

  @override
  String get setupAddressLabel => 'Street address';

  @override
  String get setupProvinceLabel => 'Province';

  @override
  String get setupDistrictLabel => 'District';

  @override
  String get setupFieldRequired => 'This field is required.';

  @override
  String get setupProvincesLoadError =>
      'Could not load provinces. Check your connection and try again.';

  @override
  String get setupProvincesRetry => 'Retry';

  @override
  String get setupAddressRequired => 'Street address is required.';

  @override
  String get setupProvinceRequired => 'Province is required.';

  @override
  String get setupDistrictRequired => 'District is required.';

  @override
  String get accountRoleHeadline => 'How are you joining your building?';

  @override
  String get accountRoleSubtitle => 'You can change this later.';

  @override
  String get accountRoleResidentShortTitle => 'I\'m a resident';

  @override
  String get accountRoleManagerShortTitle => 'I\'m a manager';

  @override
  String get accountRoleResidentShortBody =>
      'Connect to your unit with the invite code from your manager.';

  @override
  String get accountRoleManagerShortBody =>
      'Set up your building from scratch and invite residents.';

  @override
  String get residentInvitePlaceholderTitle => 'Invite code';

  @override
  String get residentInvitePlaceholderBody =>
      'This flow will be wired next. You can finish manager setup for now.';

  @override
  String get residentInviteBackToRole => 'Back to account type';

  @override
  String setupWizardStepProgress(Object step, Object total) {
    return 'STEP $step / $total';
  }

  @override
  String get setupWizardStep1AppBar => 'Building info';

  @override
  String get setupWizardStep2AppBar => 'Structure';

  @override
  String get setupWizardStep3AppBar => 'Units';

  @override
  String setupWizardUnitsCountLabel(Object count) {
    return 'Units · $count';
  }

  @override
  String get setupWizardStep4AppBar => 'Dues plan';

  @override
  String get setupWizardSkip => 'Skip';

  @override
  String get setupWizardLetsMeetBuilding => 'Let\'s get to know your building';

  @override
  String get setupWizardChangeLaterShort =>
      'You can change this later in settings.';

  @override
  String get setupYearBuiltOptional => 'YEAR BUILT (OPTIONAL)';

  @override
  String get setupYearBuiltHint => 'e.g. 2008';

  @override
  String get setupAddressHint => 'Neighborhood, street, no.';

  @override
  String get setupWizardStructureHeadline => 'Building structure';

  @override
  String get setupWizardStructureSubtitle =>
      'Blocks and floors — units are created automatically in the next step.';

  @override
  String get setupBlockCountLabel => 'Number of blocks';

  @override
  String get setupSingleBlock => 'Single block';

  @override
  String get setupMultipleBlocks => 'Multiple blocks';

  @override
  String setupBlockHeading(Object block) {
    return 'Block $block';
  }

  @override
  String setupStructureSummaryTailMulti(
    Object floors,
    Object perFloor,
    Object blocks,
  ) {
    return 'will be created ($floors floors × $perFloor units/block × $blocks blocks). You can edit in the next step.';
  }

  @override
  String setupStructureCountBold(Object count) {
    return '$count units';
  }

  @override
  String setupStructureSummaryTail(Object floors, Object perFloor) {
    return 'will be created ($floors floors × $perFloor units). You can edit in the next step.';
  }

  @override
  String get setupWizardUnitsInstruction =>
      'Review the auto-generated list; add or remove units if needed.';

  @override
  String get setupWizardUnitsEdit => 'Edit';

  @override
  String setupShowMoreFloorsDetail(Object floors) {
    return '+ Show more (floors $floors)';
  }

  @override
  String get setupWizardCollapseFloors => 'Show less';

  @override
  String get setupNamingAutomatic => 'Automatic (1A–6C)';

  @override
  String get setupNamingCustom => 'Custom names';

  @override
  String get setupWizardUnitsInstructionCustom =>
      'Enter the label shown for each unit. Names must be unique within a block.';

  @override
  String get setupCustomNameHint => 'Unit name';

  @override
  String get setupCustomNameEmpty => 'All unit names must be filled in.';

  @override
  String get setupCustomNameDuplicate =>
      'Duplicate unit names are not allowed within the same block.';

  @override
  String get setupCustomNameTooLong =>
      'Unit names can be at most 40 characters.';

  @override
  String get setupWizardProceed => 'Continue';

  @override
  String get setupDuesHeadline => 'Set dues';

  @override
  String get setupDuesSubtitle => 'Monthly amount residents will see and pay.';

  @override
  String get setupDueDayLabel => 'DUE DAY';

  @override
  String get setupDuesMonthlyPerUnitLabel => 'MONTHLY PER UNIT';

  @override
  String get setupLateFeeTitle => 'Automatic late fee';

  @override
  String get setupLateFeeSubtitle => '2% / month';

  @override
  String get setupSmsReminderTitle => 'Reminder SMS';

  @override
  String get setupSmsReminderSubtitle => '3 days before due date';

  @override
  String get setupTotalMonthlyCollection => 'Total monthly collection';

  @override
  String get setupCompleteWizard => 'Complete setup';

  @override
  String get setupPerApartmentSuffix => 'monthly / unit';

  @override
  String get profileSetupDemoResident => 'Continue as resident';

  @override
  String get profileSetupDemoManager => 'Continue as manager';

  @override
  String get adminInviteTitle => 'Manager invite code';

  @override
  String get adminInviteSubtitle =>
      'Enter the admin invite code you created in Supabase. After validation you continue to building setup; finishing saves the building and units to the server.';

  @override
  String get adminInviteHeadline => 'Building setup';

  @override
  String get adminInviteEightCharHint =>
      'Enter the 8-character code from your manager or admin panel.';

  @override
  String get adminInviteChecking => 'Checking code…';

  @override
  String get adminInviteVerifiedBadge => 'CODE VERIFIED';

  @override
  String get adminInviteVerifiedCardTitle => 'Manager code ready';

  @override
  String get adminInviteVerifiedCardBody =>
      'You can start registering your building. Tap below to continue.';

  @override
  String get adminInvitePrimaryButton => 'Continue to setup';

  @override
  String get adminInviteResumeHeadline => 'Welcome back';

  @override
  String get adminInviteResumeSubtitle =>
      'This building was already registered with this code. Sign in to continue.';

  @override
  String get adminInviteResumeCardBadge => 'ALREADY REGISTERED';

  @override
  String get adminInviteResumeCardBody =>
      'Setup for this invite code is complete. Continue from the home screen.';

  @override
  String get adminInviteResumeSignIn => 'Sign in';

  @override
  String get inviteFooterNoCode => 'I don\'t have a code';

  @override
  String get inviteFooterScanQr => 'Scan QR code';

  @override
  String get inviteFooterNoCodeNotice =>
      'Get a manager code from Supabase or support.';

  @override
  String get inviteFooterQrSoon => 'QR login coming soon.';

  @override
  String get adminInviteCodeLabel => 'Invite code';

  @override
  String get adminInviteCodeHint => 'e.g. DOGUS001';

  @override
  String get adminInviteContinue => 'Continue';

  @override
  String get adminInviteCodeTooShort => 'Code must be at least 4 characters.';

  @override
  String get adminInviteCodeNotFound => 'Code not found or expired.';

  @override
  String get adminInviteNotAdminCode =>
      'This is not a manager code. Choose «I\'m a resident» for a resident invite.';

  @override
  String get adminInviteUnexpectedError =>
      'Something went wrong. Please try again.';

  @override
  String get setupFinalizeFailed =>
      'Setup could not be saved. Check your connection and try again.';

  @override
  String get setupFinalizeBuildingNameRequired =>
      'Building name is required to complete setup.';

  @override
  String get homeManagerLockedPlaceholder =>
      'Summary and chart data will appear here soon.';

  @override
  String get homeQuickLockedHint => 'This feature is coming soon.';

  @override
  String get managerInviteSubtitle =>
      'Creates a persistent invite code for the selected unit—valid for login until you revoke it.';

  @override
  String get managerInviteGenerate => 'Generate invite code';

  @override
  String get managerInviteYourCode => 'Invite code';

  @override
  String get managerInviteCopy => 'Copy to clipboard';

  @override
  String get managerInviteCopied => 'Code copied to clipboard.';

  @override
  String get managerInviteFailed =>
      'Could not create the code. Check your session and try again.';

  @override
  String get managerInviteCodeCreated => 'New invite code is ready.';

  @override
  String get managerInviteShareHint =>
      'Send this code to the resident over a trusted channel; it stays valid for login until revoked.';

  @override
  String get managerInviteDemoBanner =>
      'In demo mode the code is generated locally; set DEMO_MODE=false for real invites.';

  @override
  String get managerInviteSelectUnit => 'Unit';

  @override
  String get residentInviteScreenTitle => 'Your invite code';

  @override
  String get residentInviteHeadline => 'Join your building';

  @override
  String get residentInviteJoinHint =>
      'Enter the 5-character unit code from your building manager.';

  @override
  String get residentInviteCodeSection => 'INVITE CODE';

  @override
  String get residentInviteAccountSection => 'YOUR ACCOUNT';

  @override
  String get residentInviteVerifiedBadge => 'CODE VERIFIED';

  @override
  String get residentInviteCodeLabel => 'Invite code';

  @override
  String get residentInviteCodeHint => 'e.g. A3XY2';

  @override
  String get residentInviteFullNameLabel => 'Full name';

  @override
  String get residentInviteSubmit => 'Join building';

  @override
  String get residentInviteCodeTooShort => 'The code must be 5 characters.';

  @override
  String get residentInviteNameTooShort =>
      'Full name must be at least 3 characters.';

  @override
  String get residentInviteUnexpected =>
      'Something went wrong. Check the code and try again.';

  @override
  String get managerInviteRetry => 'Try again';

  @override
  String get managerInviteSelectedUnitHint =>
      'The generated code is tied to this unit; residents who use it register for this apartment.';

  @override
  String get managerInviteNoSessionHint =>
      'No session found. Complete setup or sign in first.';

  @override
  String get managerInviteNoUnits =>
      'There are no units for this building yet. Complete building setup first.';

  @override
  String get managerInviteFilterAll => 'All';

  @override
  String get managerInviteFilterWithCode => 'Has code';

  @override
  String get managerInviteFilterWithoutCode => 'No code';

  @override
  String get managerInviteFilterEmpty => 'No units match this filter.';

  @override
  String managerInviteDetailHeadline(Object unit) {
    return 'Invitation for unit $unit';
  }

  @override
  String get managerInviteDetailSubtitle =>
      'The new resident joins this apartment using this code.';

  @override
  String get managerInviteDavetCodeCaps => 'INVITE CODE';

  @override
  String managerInviteValidDays(Object days) {
    return 'Valid $days days';
  }

  @override
  String managerInviteValidUntilDate(Object date) {
    return 'until $date';
  }

  @override
  String get managerInviteGenerateAction => 'Generate invite code';

  @override
  String get managerInviteBulkTitle => 'Bulk invitations';

  @override
  String get managerInviteBulkSubtitle =>
      'Generate codes for all empty units at once (coming soon).';

  @override
  String managerInviteShareBody(Object code) {
    return 'My building invite code: $code';
  }

  @override
  String get managerInviteShareWhatsapp => 'WhatsApp';

  @override
  String get managerInviteShareEmail => 'Email';

  @override
  String get managerInviteShareSms => 'SMS';

  @override
  String get managerInviteShareMore => 'More';

  @override
  String get residentInviteScreenBody =>
      'The 5-character code is tied to one unit by your manager; registration attaches you to that unit. Enter your full name and tap Join.';

  @override
  String get residentInvitePreviewTitle => 'Linked with this code';

  @override
  String get residentInviteWrongCodeType =>
      'This is a manager invite code. Ask your manager for a unit code to join as a resident.';

  @override
  String get residentInvitePreviewDemo =>
      'Demo mode has no server validation; run with DEMO_MODE off for the real flow.';

  @override
  String get residentInviteResumeHeadline => 'Registration found';

  @override
  String get residentInviteResumeSubtitle =>
      'This code was already used. Sign in to continue.';

  @override
  String get residentInviteResumeCardBadge => 'ALREADY REGISTERED';

  @override
  String get residentInviteResumeCardBody =>
      'This unit code was used before. You will reconnect to the same apartment.';

  @override
  String get residentInviteResumeSignIn => 'Sign in';

  @override
  String get residentInviteChecking => 'Checking code…';

  @override
  String get homeManagerRolePrefix => 'MANAGER';

  @override
  String get homeManagerBuildingFallback => 'MANAGER · Building';

  @override
  String get residentRolePrefix => 'RESIDENT';

  @override
  String get demoModuleLockedBody => 'Live data will unlock this section.';

  @override
  String get accountRoleSuperAdminShortTitle => 'I\'m a super admin';

  @override
  String get accountRoleSuperAdminShortBody =>
      'See all buildings; issue manager and unit invite codes.';

  @override
  String get demoPersonaSuperAdminTitle => 'Super admin';

  @override
  String get demoPersonaSuperAdminBody =>
      'Demo: cross-building codes and directory.';

  @override
  String get superadminAccessTitle => 'Super-admin access';

  @override
  String get superadminAccessHeadline => 'Your access code';

  @override
  String get superadminAccessBody =>
      'Enter the super-admin code configured on the server. It is never stored in the app—only validated by Edge.';

  @override
  String get superadminAccessFieldLabel => 'ACCESS CODE';

  @override
  String get superadminAccessContinue => 'Continue';

  @override
  String get superadminAccessCodeTooShort =>
      'Code must be at least 4 characters.';

  @override
  String get superadminAccessWrongRole =>
      'That code did not grant a super-admin session.';

  @override
  String get superadminAccessUnexpectedError =>
      'Could not sign in. Check the code and connection.';

  @override
  String get superadminDashboardTitle => 'Super-admin dashboard';

  @override
  String get superadminNavHome => 'Home';

  @override
  String get superadminNavManagerCodes => 'Codes';

  @override
  String get superadminNavBuildings => 'Buildings';

  @override
  String get superadminHomeComingSoon => 'This section is under development.';

  @override
  String get superadminRefresh => 'Refresh';

  @override
  String get superadminDemoBanner => 'Demo mode shows sample data only.';

  @override
  String get superadminDemoSwitch => 'Demo: switch role';

  @override
  String get superadminSectionManagerCodes => 'Manager invite codes';

  @override
  String get superadminCreateManagerCode => 'Create manager code';

  @override
  String get superadminManagerCodeCreated =>
      'Manager code copied to clipboard.';

  @override
  String get superadminNoAdminCodesYet =>
      'No codes listed yet—you can create one.';

  @override
  String get superadminSectionBuildings => 'Buildings';

  @override
  String get superadminNoBuildings => 'No buildings yet.';

  @override
  String get superadminCopied => 'Copied';

  @override
  String get superadminBuildingInviteTitle => 'Resident invites';

  @override
  String get superadminDeleteBuildingTitle => 'Delete building';

  @override
  String get superadminDeleteBuildingBody =>
      'This permanently deletes the building and related records (units, memberships, dues, announcements, etc.). This cannot be undone.';

  @override
  String get superadminDeleteBuildingConfirm => 'Delete';

  @override
  String get superadminBuildingDeleted => 'Building deleted.';

  @override
  String get superadminDeleteBuildingFailed => 'Could not delete building.';

  @override
  String get superadminAdminCodeMultiBadge => 'Multi setup';

  @override
  String get superadminAdminCodePolicyHint =>
      'The same code can be used again on another device or after reinstall until it expires.';

  @override
  String get superadminAdminCodeStatusActive => 'Active';

  @override
  String get superadminAdminCodeStatusRevoked => 'Revoked';

  @override
  String get superadminAdminCodeExpires => 'Expires';

  @override
  String get superadminAdminCodeCreated => 'Created';

  @override
  String get superadminRevokeAdminCode => 'Revoke code';

  @override
  String get superadminRevokeAdminCodeTitle => 'Revoke manager code';

  @override
  String get superadminRevokeAdminCodeBody =>
      'This code will no longer work. Continue?';

  @override
  String get superadminRevokeAdminCodeConfirm => 'Revoke';

  @override
  String get superadminCodeRevoked => 'Code revoked.';

  @override
  String get inviteCodeNotesCreate => 'Create';

  @override
  String get inviteCodeNotesAdminTitle => 'Manager code note';

  @override
  String get inviteCodeNotesAdminHint =>
      'Optional: which manager or building (e.g. John – Block A)';

  @override
  String get inviteCodeNotesUnitTitle => 'Resident / unit note';

  @override
  String get inviteCodeNotesUnitHint =>
      'Optional: resident or unit context (e.g. 6A – New tenant)';

  @override
  String get inviteCodeNotesLabel => 'Note';

  @override
  String get managerInviteRevokeAction => 'Revoke code';

  @override
  String get managerInviteRevokeTitle => 'Revoke invite code';

  @override
  String get managerInviteRevokeBody =>
      'This code can no longer be used to sign in. You can create a new one.';

  @override
  String get managerInviteRevokeConfirm => 'Revoke';

  @override
  String get managerInviteRevoked => 'Invite code revoked.';

  @override
  String get managerInviteActiveUntilRevoked => 'Valid until revoked';

  @override
  String get managerUnitJoinedViaCode => 'Joined via code';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsThemeLabel => 'Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeLightHint => 'Light interface';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeDarkHint => 'Dark interface';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeSystemHint => 'Follow device setting';

  @override
  String get settingsSectionLanguage => 'Language';

  @override
  String get settingsLanguageTurkish => 'Turkish';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsApplyHint =>
      'Your language and theme choices are saved automatically.';

  @override
  String get settingsLoadFailed => 'Could not load settings.';
}
