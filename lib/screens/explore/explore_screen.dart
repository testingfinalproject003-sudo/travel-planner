import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/place_model.dart';
import '../../core/providers/explore_provider.dart';
import '../../core/providers/trip_provider.dart';
import '../../core/models/activity_model.dart';
import '../../core/services/notification_service.dart';
import '../../widgets/explore/place_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();
  bool _showSearchResults = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final exploreProvider = context.read<ExploreProvider>();
      exploreProvider.loadPopularDestinations();
      exploreProvider.loadNearbyPlaces();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_searchController.text.isEmpty) return;
    final exploreProvider = context.read<ExploreProvider>();
    await exploreProvider.searchPlaces(_searchController.text);
    setState(() => _showSearchResults = true);
  }

  @override
  Widget build(BuildContext context) {
    final exploreProvider = context.watch<ExploreProvider>();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore Places',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search destinations, attractions...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _showSearchResults = false);
                                  exploreProvider.clearSearch();
                                },
                              )
                            : null,
                      ),
                      onSubmitted: (_) => _search(),
                    ),
                  ],
                ),
              ),
            ),

            if (_showSearchResults)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: exploreProvider.isLoading
                    ? const SliverToBoxAdapter(
                        child: Center(child: LoadingIndicator()),
                      )
                    : exploreProvider.places.isEmpty
                        ? SliverToBoxAdapter(
                            child: EmptyState(
                              icon: Icons.search_off,
                              title: 'No results found',
                              subtitle: 'Try a different search term',
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return PlaceCard(
                                  place: exploreProvider.places[index],
                                  onTap: () => _navigateToPlaceDetail(context, exploreProvider.places[index]),
                                  onAddToTrip: () => _addToTrip(context, exploreProvider.places[index]),
                                  onCheckWeather: () => context.push('/weather', 
                                      extra: exploreProvider.places[index].name),
                                );
                              },
                              childCount: exploreProvider.places.length,
                            ),
                          ),
              ),

            if (!_showSearchResults) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Popular Destinations',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 280,
                  child: exploreProvider.isLoading && exploreProvider.popularDestinations.isEmpty
                      ? const Center(child: LoadingIndicator())
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: exploreProvider.popularDestinations.length,
                          itemBuilder: (context, index) {
                            return _buildDestinationCard(
                              context,
                              exploreProvider.popularDestinations[index],
                            );
                          },
                        ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Nearby Places',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: exploreProvider.nearbyPlaces.isEmpty
                    ? SliverToBoxAdapter(
                        child: EmptyState(
                          icon: Icons.location_off,
                          title: 'No nearby places',
                          subtitle: 'Enable location to see nearby attractions',
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return PlaceCard(
                              place: exploreProvider.nearbyPlaces[index],
                              onTap: () => _navigateToPlaceDetail(context, exploreProvider.nearbyPlaces[index]),
                              onAddToTrip: () => _addToTrip(context, exploreProvider.nearbyPlaces[index]),
                              onCheckWeather: () => context.push('/weather',
                                  extra: exploreProvider.nearbyPlaces[index].name),
                            );
                          },
                          childCount: exploreProvider.nearbyPlaces.length,
                        ),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _navigateToPlaceDetail(BuildContext context, PlaceModel place) {
    context.push('/place-detail', extra: place);
  }

  void _addToTrip(BuildContext context, PlaceModel place) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add to Trip',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.add_location_alt, color: AppColors.primary),
                title: const Text('Create New Trip'),
                subtitle: Text('Plan a trip to ${place.name}'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/create-trip', extra: place);
                },
              ),
              ListTile(
                leading: const Icon(Icons.playlist_add, color: AppColors.primary),
                title: const Text('Add to Existing Trip'),
                subtitle: const Text('Select from your upcoming trips'),
                onTap: () {
                  Navigator.pop(context);
                  _showTripSelectionDialog(context, place);
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTripSelectionDialog(BuildContext context, PlaceModel place) {
    final tripProvider = context.read<TripProvider>();
    final upcomingTrips = tripProvider.upcomingTrips;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Trip'),
        content: SizedBox(
          width: double.maxFinite,
          child: upcomingTrips.isEmpty
              ? const Text('No upcoming trips. Create one first!')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: upcomingTrips.length,
                  itemBuilder: (context, index) {
                    final trip = upcomingTrips[index];
                    return ListTile(
                      leading: const Icon(Icons.flight, color: AppColors.primary),
                      title: Text(trip.name),
                      subtitle: Text(trip.destination),
                      onTap: () async {
                        final activity = ActivityModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: 'Visit ${place.name}',
                          date: trip.startDate,
                          time: null,
                        );
                        await tripProvider.addActivity(trip.id, activity);
                        if (context.mounted) {
                          Navigator.pop(context);
                          NotificationService.showToast('Added to ${trip.name}!');
                        }
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationCard(BuildContext context, PlaceModel place) {
    return GestureDetector(
      onTap: () => _navigateToPlaceDetail(context, place),
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: place.photoUrl != null
              ? DecorationImage(
                  image: NetworkImage(place.photoUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha:0.8),
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (place.famousFor != null)
                Text(
                  place.famousFor!,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha:0.8),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 8),
              if (place.rating != null)
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${place.rating}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}