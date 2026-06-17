/// Route paths and names. Use the names with `context.goNamed`/`pushNamed`.
abstract final class Routes {
  static const String splash = 'splash';
  static const String splashPath = '/splash';

  static const String onboarding = 'onboarding';
  static const String onboardingPath = '/onboarding';

  static const String signIn = 'signin';
  static const String signInPath = '/signin';

  static const String notes = 'notes';
  static const String notesPath = '/notes';

  static const String noteNew = 'note-new';
  static const String noteNewPath = 'new'; // child of /notes

  static const String noteEdit = 'note-edit';
  static const String noteEditPath = ':id'; // child of /notes

  static const String settings = 'settings';
  static const String settingsPath = '/settings';

  static const String paywall = 'paywall';
  static const String paywallPath = 'paywall'; // child of /settings

  static const String notifications = 'notifications';
  static const String notificationsPath = 'notifications'; // child of /settings
}
