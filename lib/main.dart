import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/auth_gate.dart';
import 'theme/app_theme.dart';

const supabaseUrl = 'https://dnclutzltlwgplqjlekn.supabase.co';
const supabasePublishableKey = 'sb_publishable_zRp26HgPxkRFFQKPBuKLuw_25rloXKh';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  runApp(const GameZoneApp());
}

class GameZoneApp extends StatelessWidget {
  const GameZoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GameZone',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthGate(),
    );
  }
}
