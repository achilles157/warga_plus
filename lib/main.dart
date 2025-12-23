import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/services/ai_service.dart';
import 'core/services/auth_service.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/responsive_wrapper.dart';
import 'features/auth/presentation/login_page.dart';
import 'package:flutter/foundation.dart'; // For kReleaseMode
import 'package:device_preview/device_preview.dart';
import 'features/main/screens/main_screen.dart';
import 'features/admin/screens/admin_portal_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Disable DevicePreview in release mode so users get the real responsive web app
  runApp(DevicePreview(
    enabled: !kReleaseMode,
    builder: (context) => const WargaPlusApp(),
  ));
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
          // DevicePreview builder first if enabled
          var widget = DevicePreview.appBuilder(context, child);
          // Then wrap with our responsive constraint
          return ResponsiveWrapper(child: widget);
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
