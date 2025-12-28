import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/config/app_config.dart';
import 'core/services/ai_service.dart';
import 'core/services/auth_service.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/responsive_wrapper.dart';
import 'features/auth/presentation/login_page.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'features/main/screens/main_screen.dart';
import 'features/admin/screens/admin_portal_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try loading .env, but don't crash if it doesn't exist (production)
  try {
    await dotenv.load(fileName: ".env");
    // Pass the env value to AppConfig for fallback
    AppConfig.initFromEnv(dotenv.env['GROQ_API_KEY']);
    if (kDebugMode) {
      print('[AppConfig] Loaded .env successfully');
    }
  } catch (e) {
    // .env not found - this is expected in production
    if (kDebugMode) {
      print('[AppConfig] .env not found, using --dart-define values');
    }
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const WargaPlusApp());
}

class WargaPlusApp extends StatelessWidget {
  const WargaPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => AiService()), // Add AI Service
      ],
      child: MaterialApp(
        title: 'Warga+',
        theme: AppTheme.lightTheme,
        // Wrap the builder to apply responsive constraints globally
        builder: (context, child) {
          return ResponsiveWrapper(child: child!);
        },
        home: const AuthWrapper(),
        routes: {
          '/admin': (context) => const AdminPortalScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    if (authService.user != null) {
      return const MainScreen();
    } else {
      return const LoginPage();
    }
  }
}
