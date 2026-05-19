import 'package:flutter/material.dart';
import '../models/trip_model.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home/trip_detail_screen.dart';
import '../screens/trip/create_trip_screen.dart';
import '../screens/trip/itinerary_screen.dart';
import '../screens/trip/activity_suggestions_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/explore/explore_screen.dart';
import '../screens/explore/location_photos_screen.dart';
import '../screens/map/trip_map_screen.dart';
import '../screens/map/location_picker_screen.dart';
import '../screens/friends/friends_screen.dart';
import '../screens/friends/add_friend_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../navigation/main_tab_navigator.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String main = '/main';
  static const String tripDetail = '/trip-detail';
  static const String createTrip = '/create-trip';
  static const String itinerary = '/itinerary';
  static const String suggestions = '/suggestions';
  static const String chat = '/chat';
  static const String explore = '/explore';
  static const String locationPhotos = '/location-photos';
  static const String tripMap = '/trip-map';
  static const String locationPicker = '/location-picker';
  static const String friends = '/friends';
  static const String addFriend = '/add-friend';
  static const String friendRequests = '/friend-requests';
  static const String history = '/history';
  static const String weatherDetail = '/weather';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case main:
        return MaterialPageRoute(builder: (_) => const MainTabNavigator());
      case tripDetail:
        final trip = settings.arguments as TripModel;
        return MaterialPageRoute(builder: (_) => TripDetailScreen(trip: trip));
      case createTrip:
        return MaterialPageRoute(builder: (_) => const CreateTripScreen());
      case itinerary:
        final trip = settings.arguments as TripModel;
        return MaterialPageRoute(builder: (_) => ItineraryScreen(trip: trip));
      case suggestions:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ActivitySuggestionsScreen(
            tripId: args['tripId'],
            dayIndex: args['dayIndex'],
          ),
        );
      case chat:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: args['chatId'],
            chatName: args['chatName'],
            isTripChat: args['isTripChat'] ?? false,
          ),
        );
      case explore:
        return MaterialPageRoute(builder: (_) => const ExploreScreen());
      case locationPhotos:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => LocationPhotosScreen(
            locationName: args['locationName'],
            initialPhotos: args['initialPhotos'],
          ),
        );
      case tripMap:
        final trip = settings.arguments as TripModel;
        return MaterialPageRoute(builder: (_) => TripMapScreen(trip: trip));
      case locationPicker:
        return MaterialPageRoute(builder: (_) => const LocationPickerScreen());
      case friends:
        return MaterialPageRoute(builder: (_) => const FriendsScreen());
      case addFriend:
        return MaterialPageRoute(builder: (_) => const AddFriendScreen());
      case history:
        return MaterialPageRoute(builder: (_) => const HistoryScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Page not found', style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}