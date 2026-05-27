class AppConstants {
  AppConstants._();

  static const String appName = 'WoNotes';

  // Hive box names
  static const String notesBox = 'notes';
  static const String cycleDaysBox = 'cycle_days';

  // Secure storage key
  static const String hiveEncryptionKey = 'hive_aes_key_v1';

  // Animation durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 320);
  static const Duration animSlow = Duration(milliseconds: 480);

  // Note stack
  static const int stackMaxVisible = 4;
  static const double stackCardPeek = 9.0;

  // Layout
  static const double bottomNavHeight = 72.0;
  static const double bottomNavPadding = 16.0;
  static const double pagePadding = 20.0;
  static const double cardRadius = 22.0;
  static const double smallRadius = 14.0;
}
