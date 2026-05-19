import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';
import '../../widgets/trip/trip_card.dart';
import '../../widgets/common/app_avatar.dart';
import '../../widgets/common/app_loader.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user != null) {
      Provider.of<TripProvider>(context, listen: false).loadUserTrips(auth.user!.uid);
    }
  }

  @override
  Widget build(BuildContext buildContext) {
    final user = Provider.of<AuthProvider>(buildContext).user;
    final tripProvider = Provider.of<TripProvider>(buildContext);

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${user?.name ?? "Explorer"} 👋'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: AppDimensions.md),
              child: AppAvatar(name: user.name, size: AvatarSize.sm),
            )
        ],
      ),
      body: SafeArea(
        child: tripProvider.isLoading
            ? const AppLoader(label: 'Trips load ho rahi hain...')
            : tripProvider.trips.isEmpty
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.explore_outlined, size: 72, color: AppColors.textMuted),
                const SizedBox(height: AppDimensions.md),
                Text('Koi trip planned nahi hai', style: AppTextStyles.heading2),
                const SizedBox(height: AppDimensions.xs),
                const Text('Apna pehla adventure plan karne ke liye nichay diye gaye button par click karein.', textAlign: TextAlign.center, style: AppTextStyles.small),
              ],
            ),
          ),
        )
            : ListView(
          padding: const EdgeInsets.all(AppDimensions.lg),
          children: [
            Text('Your Trips', style: AppTextStyles.heading2),
            const SizedBox(height: AppDimensions.md),
            ...tripProvider.trips.map((trip) => TripCard(
              trip: trip,
              onTap: () => Navigator.pushNamed(context, '/trip-detail', arguments: trip),
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        onPressed: () => Navigator.pushNamed(context, '/create-trip'),
        child: const Icon(Icons.add),
      ),
    );
  }
}