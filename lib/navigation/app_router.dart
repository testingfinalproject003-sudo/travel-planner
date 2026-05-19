import 'package:flutter/material.dart';
import '../models/trip_model.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../navigation/main_tab_navigator.dart';
import '../screens/home/trip_detail_screen.dart';
import '../screens/trip/create_trip_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const MainTabNavigator());
      case '/trip-detail':
        final trip = settings.arguments as TripModel;
        return MaterialPageRoute(builder: (_) => TripDetailScreen(trip: trip));
      case '/create-trip':
        return MaterialPageRoute(builder: (_) => const CreateTripScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}