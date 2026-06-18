import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Screen Imports
import 'features/auth/presentation/landing_screen.dart';
import 'features/auth/presentation/signup_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/profile/presentation/dashboard_screen.dart';
import 'features/profile/presentation/medical_form_screen.dart';
import 'features/profile/presentation/emergency_contacts_screen.dart';
import 'features/profile/presentation/crash_detection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://souuhbwhiaauteecbozl.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNvdXVoYndoaWFhdXRlZWNib3psIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg2MTExOTYsImV4cCI6MjA4NDE4NzE5Nn0.y0nyHbgTbkF8tQfo5B3jVM8Cd_NapKazTgUGCiayemQ',
  );

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('medical_records');
  await Hive.openBox('user_settings');

  runApp(const ImpactPulseApp());
}

class ImpactPulseApp extends StatefulWidget {
  const ImpactPulseApp({super.key});

  @override
  State<ImpactPulseApp> createState() => _ImpactPulseAppState();
}

class _ImpactPulseAppState extends State<ImpactPulseApp> {
  @override
  void initState() {
    super.initState();

    // 🔑 SINGLE auth listener for the whole app
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;

      if (!mounted) return;

      if (session != null) {
        navigatorKey.currentState
            ?.pushNamedAndRemoveUntil('/dashboard', (_) => false);
      }
    });
  }

  // Global navigator key (simple + safe)
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'ImpactPulse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF8C00),
          primary: const Color(0xFFFF8C00),
          secondary: const Color(0xFFB8860B),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/medical_form': (context) => const MedicalFormScreen(),
        '/emergency_contacts': (context) =>
            const EmergencyContactsScreen(),
        '/crash_detection': (context) =>
            const CrashDetectionScreen(),
      },
    );
  }
}
