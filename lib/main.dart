import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'core/config/app_routes.dart';
import 'core/init_test_users.dart';
import 'core/init_test_loads.dart';
import 'core/services/auth_service.dart';
import '/splash_screen.dart';
import '/login_screen.dart';
import '/broker_dashboard.dart';
import '/carrier_dashboard.dart';
import '/post_load_screen.dart' ;
import '/post_required_load_screen.dart' ;
import '/load_details_screen.dart';
import '/bid_screen.dart';
import '/screens/safer_web_search_screen.dart';
import '/screens/chat_screen.dart';
import 'package:lboard/providers/provider.dart';
import 'package:lboard/providers/safer_web_provider.dart';
import 'package:lboard/providers/analytics_provider.dart';
import 'package:lboard/core/services/platform_database_service.dart' as platform_db;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'services/fmcsa_verification_service.dart';
import 'services/safer_web_api_service.dart';
import 'package:lboard/providers/theme_provider.dart';
import 'themes/app_theme.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS|| Platform.isAndroid || Platform.isIOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize platform-specific database
  final dbService = platform_db.PlatformDatabaseService.instance;
  await dbService.init();

  await InitTestUsers.insertTestUsers();
  await InitTestLoads.insertTestLoads();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => LoadProvider()),
        ChangeNotifierProvider(create: (_) => CarrierProvider()),
        ChangeNotifierProvider(create: (_) => SaferWebProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider<FmcsaVerificationService>(create: (_) => FmcsaVerificationService()),
        Provider<SaferWebApiService>(create: (_) => SaferWebApiService()),
      ],
      child: const MyApp(),
    ),
  );
}

// Remove this class since we now import InitTestLoads from core/init_test_loads.dart

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final _ = authProvider.user;
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Isovia Load Board',
      theme: AppTheme.buildBlueTheme(),
      darkTheme: AppTheme.buildRedTheme(),
      themeMode: themeProvider.themeMode,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.brokerDashboard: (context) => const BrokerDashboard(),
        AppRoutes.carrierDashboard: (context) => const CarrierDashboard(),
        AppRoutes.postLoad: (context) => const PostLoadScreen(),
        AppRoutes.postRequiredLoad: (context) => const PostRequiredLoadScreen(),
        AppRoutes.loadDetails: (context) => const LoadDetailsScreen(),
        AppRoutes.bid: (context) => const BidScreen(),
        AppRoutes.saferWebSearch: (context) => const SaferWebSearchScreen(),
        '/chat': (context) => const ChatScreen(),
      },
      onGenerateRoute: AppRoutes.onGenerateRoute,
      onUnknownRoute: AppRoutes.onUnknownRoute,
    );
  }
}