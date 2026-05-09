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
  String get splashTagline => 'Everything for your building in one place';

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
  String get demoSplashTagline => 'Everything for your building in one place';

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
  String get profileSetupDemoResident => 'Continue as resident';

  @override
  String get profileSetupDemoManager => 'Continue as manager';
}
