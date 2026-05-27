import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/constants/app_constants.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Russian date locale
  await initializeDateFormatting('ru_RU', null);

  // Init Hive
  await Hive.initFlutter();

  // Get or generate AES-256 encryption key, stored securely
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  var keyB64 = await storage.read(key: AppConstants.hiveEncryptionKey);
  if (keyB64 == null) {
    final key = Hive.generateSecureKey(); // 32 random bytes
    keyB64 = base64UrlEncode(key);
    await storage.write(
      key: AppConstants.hiveEncryptionKey,
      value: keyB64,
    );
  }

  final cipher = HiveAesCipher(base64Url.decode(keyB64));

  // Open encrypted boxes
  await Hive.openBox<String>(
    AppConstants.notesBox,
    encryptionCipher: cipher,
  );
  await Hive.openBox<String>(
    AppConstants.cycleDaysBox,
    encryptionCipher: cipher,
  );

  runApp(
    const ProviderScope(
      child: WoNotesApp(),
    ),
  );
}
