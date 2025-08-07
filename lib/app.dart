import 'package:flutter/material.dart';
import 'core/config/app_routes.dart';
import 'package:lboard/providers/auth_provider.dart';
import 'package:lboard/providers/load_provider.dart';
import 'package:provider/provider.dart';
import 'splash_screen.dart';
import 'login_screen.dart';
import 'broker_dashboard.dart';
import 'carrier_dashboard.dart';
import 'post_load_screen.dart' as pls;
import 'load_details_screen.dart';
import 'themes/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LoadProvider()),
      ],
      child: MaterialApp(
        title: 'LBoard',
        theme: AppTheme.buildRasketTheme(),
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (context) => const SplashScreen(),
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.brokerDashboard: (context) => const BrokerDashboard(),
          AppRoutes.carrierDashboard: (context) => const CarrierDashboard(),
          AppRoutes.postLoad: (context) => const pls.PostLoadScreen(),
          AppRoutes.loadDetails: (context) => const LoadDetailsScreen(),
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(builder: (context) => const SplashScreen());
        },
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}
