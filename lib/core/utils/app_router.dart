import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/auth/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/home/home_content_screen.dart';
import '../../screens/trips/create_trip_screen.dart';
import '../../screens/trips/trip_detail_screen.dart';
import '../../screens/trips/trip_history_screen.dart';
import '../../screens/chat/chat_list_screen.dart';
import '../../screens/chat/chat_screen.dart';
import '../../screens/explore/explore_screen.dart';
// import '../../screens/explore/place_detail_screen.dart';
import '../../screens/weather/weather_screen.dart';
import '../../screens/friends/friends_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/common/error_screen.dart';
// import '../../screens/common/loading_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter get router => GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeContentScreen(),
          ),
          GoRoute(
            path: '/explore',
            builder: (context, state) => const ExploreScreen(),
          ),
          GoRoute(
            path: '/chat',
            builder: (context, state) => const ChatListScreen(),
          ),
          GoRoute(
            path: '/friends',
            builder: (context, state) => const FriendsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/create-trip',
        builder: (context, state) => const CreateTripScreen(),
      ),
      GoRoute(
        path: '/trip-detail',
        builder: (context, state) {
          final tripId = state.extra as String;
          return TripDetailScreen(tripId: tripId);
        },
      ),
      GoRoute(
        path: '/trip-history',
        builder: (context, state) => const TripHistoryScreen(),
      ),
      GoRoute(
        path: '/chat-detail',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return ChatScreen(
            chatId: args['chatId'] as String,
            chatName: args['chatName'] as String,
            tripId: args['tripId'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/weather',
        builder: (context, state) {
          final city = state.extra as String?;
          return WeatherScreen(city: city);
        },
      ),
     
    ],
    errorBuilder: (context, state) => ErrorScreen(
      message: 'Page not found: ${state.uri.path}',
      onRetry: () => context.go('/home'),
    ),
  );
}