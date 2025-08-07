import 'package:flutter/material.dart';
import 'package:lboard/screens/tawk_to_chat_page.dart';
import 'package:lboard/settingscreen.dart';
import '/splash_screen.dart';
import '/login_screen.dart';
import '/forget_password_screen.dart';
import '/broker_dashboard.dart';
import '/carrier_dashboard.dart';
import '/post_load_screen.dart';
import '/post_required_load_screen.dart';
import '/load_details_screen.dart';
import '/bid_screen.dart';
import '/screens/safer_web_search_screen.dart';
import '/screens/safer_web_details_screen.dart';
import '/screens/enhanced_register_screen.dart';
import '/screens/fmcsa_profile_screen.dart';
import '/screens/lane_preference_settings_screen.dart';
import '/screens/notifications_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const brokerDashboard = '/brokerDashboard';
  static const carrierDashboard = '/carrierDashboard';
  static const postLoad = '/postLoad';
  static const postRequiredLoad = '/postRequiredLoad';
  static const loadDetails = '/loadDetails';
  static const bid = '/bid';
  static const register = '/register';
  static const forgetPassword = '/forgetPassword';
  static const settings = '/settings';
  static const saferWebSearch = '/saferWebSearch';
  static const saferWebDetails = '/saferWebDetails';
  static const enhancedRegister = '/enhancedRegister';
  static const fmcsaProfile = '/fmcsaProfile';
  static const lanePreferenceSettings = '/lanePreferenceSettings';
  static const tawkToChat = '/tawkToChat';
  static const notifications = '/notifications';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      brokerDashboard: (context) => const BrokerDashboard(),
      carrierDashboard: (context) => const CarrierDashboard(),
      postLoad: (context) => const PostLoadScreen(),
      postRequiredLoad: (context) => const PostRequiredLoadScreen(),
      loadDetails: (context) => const LoadDetailsScreen(),
      bid: (context) => const BidScreen(),
      register: (context) => const EnhancedRegisterScreen(), // Use enhanced register
      settings: (context) => const SettingsScreen(),
      forgetPassword: (context) => const ForgetPasswordScreen(),
      saferWebSearch: (context) => const SaferWebSearchScreen(),
      fmcsaProfile: (context) => const FmcsaProfileScreen(),
      lanePreferenceSettings: (context) => LanePreferenceSettingsScreen(),
      tawkToChat: (context) => const TawkToChatPage(),
      notifications: (context) => const NotificationsScreen(),
    };
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.brokerDashboard:
        return MaterialPageRoute(builder: (_) => const BrokerDashboard());
      case AppRoutes.carrierDashboard:
        return MaterialPageRoute(builder: (_) => const CarrierDashboard());
      case AppRoutes.postLoad:
        return MaterialPageRoute(builder: (_) => const PostLoadScreen());
      case AppRoutes.postRequiredLoad:
        return MaterialPageRoute(builder: (_) => const PostRequiredLoadScreen());
      case AppRoutes.loadDetails:
        return MaterialPageRoute(builder: (_) => const LoadDetailsScreen());
      case AppRoutes.bid:
        return MaterialPageRoute(builder: (_) => const BidScreen());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (context) => const EnhancedRegisterScreen());
      case AppRoutes.forgetPassword:
        return MaterialPageRoute(builder: (_) => const ForgetPasswordScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: RouteSettings(name: settings.name),
        );
      case AppRoutes.saferWebSearch:
        return MaterialPageRoute(
          builder: (_) => const SaferWebSearchScreen(),
          settings: RouteSettings(name: settings.name),
        );
      case AppRoutes.saferWebDetails:
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) => SaferWebDetailsScreen(
            identifier: args['identifier']!,
            title: args['title']!,
          ),
          settings: RouteSettings(name: settings.name),
        );
      case AppRoutes.fmcsaProfile:
        return MaterialPageRoute(
          builder: (_) => const FmcsaProfileScreen(),
          settings: RouteSettings(name: settings.name),
        );
      case AppRoutes.lanePreferenceSettings:
        return MaterialPageRoute(
          builder: (_) => LanePreferenceSettingsScreen(),
          settings: RouteSettings(name: settings.name),
        );
      case AppRoutes.notifications:
        return MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
          settings: RouteSettings(name: settings.name),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Welcome TO Isovia LoadBoard'),
            ),
          ),
          settings: RouteSettings(name: settings.name),
        );
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(
          child: Text('Unknown route'),
        ),
      ),
    );
  }
}
