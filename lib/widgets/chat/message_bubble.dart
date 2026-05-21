import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../models/message_model.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final String currentUserId;
  final String chatId;
  final bool isTripChat;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.currentUserId,
    required this.chatId,
    this.isTripChat = false,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isSystem || message.type == 'system') {
      return _buildSystemMessage();
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isMe ? 64 : 8,
          right: isMe ? 8 : 64,
          top: 4,
          bottom: 4,
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe && message.senderName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 2),
                child: Text(
                  message.senderName,
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                ),
              ),
            _buildMessageContent(context),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                _formatTime(message.timestamp),
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    switch (message.type) {
      case 'weather':
        return _buildWeatherBubble();
      case 'location':
        return _buildLocationBubble(context);
      case 'suggestion':
        return _buildSuggestionBubble();
      case 'plan_confirm':
        return _buildPlanConfirmBubble(context);
      case 'trip_proposal':
        return _buildTripProposalBubble(context);
      case 'vote_update':
        return _buildVoteUpdateBubble();
      case 'trip_created':
        return _buildTripCreatedBubble(context);
      case 'destination':
        return _buildDestinationBubble();
      default:
        return _buildTextBubble();
    }
  }

  Widget _buildTextBubble() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primary : AppColors.cardBg,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isMe ? 16 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 16),
        ),
      ),
      child: Text(
        message.text,
        style: TextStyle(
          color: isMe ? AppColors.white : AppColors.textMain,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildWeatherBubble() {
    final weather = message.metadata ?? {};
    final city = weather['cityName'] ?? weather['city'] ?? 'Unknown Location';
    final temp = weather['temp']?.toDouble() ?? 0.0;
    final description = weather['description']?.toString() ?? '';
    final humidity = weather['humidity'] ?? 0;
    final windSpeed = weather['windSpeed'] ?? 0;
    final tripDateStr = weather['tripDate'];
    final forecastTemp = weather['forecastTemp'];
    final forecastDesc = weather['forecastDesc'];

    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  city,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white54, height: 16),
          Row(
            children: [
              _getWeatherIcon(description),
              const SizedBox(width: 12),
              Text(
                '${temp.round()}°C',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description.toUpperCase(),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          if (tripDateStr != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today, color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Trip: ${DateFormat('MMM d, yyyy').format(DateTime.parse(tripDateStr))}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
          if (forecastTemp != null) ...[
            const SizedBox(height: 6),
            Text(
              '🌡️ Expected: ${forecastTemp.round()}°C, ${forecastDesc ?? ''}',
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _WeatherDetailItem(icon: Icons.water_drop, value: '$humidity%', label: 'Humidity'),
              _WeatherDetailItem(icon: Icons.air, value: '${windSpeed}m/s', label: 'Wind'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getWeatherIcon(String condition) {
    IconData iconData;
    switch (condition.toLowerCase()) {
      case 'clear':
      case 'sunny':
        iconData = Icons.wb_sunny;
        break;
      case 'clouds':
      case 'cloudy':
      case 'partly cloudy':
        iconData = Icons.wb_cloudy;
        break;
      case 'rain':
      case 'drizzle':
        iconData = Icons.water_drop;
        break;
      case 'thunderstorm':
        iconData = Icons.thunderstorm;
        break;
      case 'snow':
        iconData = Icons.ac_unit;
        break;
      default:
        iconData = Icons.wb_sunny;
    }
    return Icon(iconData, color: Colors.white, size: 40);
  }

  Widget _buildLocationBubble(BuildContext context) {
    final metadata = message.metadata ?? {};
    final lat = (metadata['lat'] as num?)?.toDouble();
    final lng = (metadata['lng'] as num?)?.toDouble();
    final locationName = metadata['locationName'] ?? 'Location';
    final address = metadata['address'];

    return GestureDetector(
      onTap: () {
        if (lat != null && lng != null) {
          _openExternalMaps(lat, lng, locationName);
        }
      },
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFA5D6A7)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lat != null && lng != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(
                  height: 140,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(lat, lng),
                      initialZoom: 14,
                      interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: Constants.osmTileUrl,
                        userAgentPackageName: Constants.osmUserAgent,
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(lat, lng),
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.location_on, color: Colors.red, size: 36),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.location_on, color: AppColors.primary, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          locationName,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (address != null && address.toString().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      address.toString(),
                      style: AppTextStyles.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            if (lat != null && lng != null) {
                              _openExternalMaps(lat, lng, locationName);
                            }
                          },
                          icon: const Icon(Icons.open_in_new, size: 14),
                          label: const Text('Open', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      ),
                      if (isTripChat) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _addLocationToTrip(context, lat!, lng!, locationName),
                            icon: const Icon(Icons.add_location, size: 14),
                            label: const Text('Add', style: TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openExternalMaps(double lat, double lng, String name) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _addLocationToTrip(BuildContext context, double lat, double lng, String name) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add to Itinerary'),
        content: Text('Add "$name" to trip activities?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                final chatProvider = context.read<ChatProvider>();
                final authProvider = context.read<AuthProvider>();
                final user = authProvider.user;
                if (user == null) return;
                await chatProvider.sendMessage(
                  chatId: chatId,
                  text: '📍 Added "$name" to itinerary',
                  senderId: user.uid,
                  senderName: user.name,
                  senderInitials: user.initials,
                  type: 'system',
                  metadata: {
                    'activityType': 'location',
                    'locationName': name,
                    'lat': lat,
                    'lng': lng,
                  },
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added "$name" to trip activities')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add: $e')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionBubble() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCC80)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: AppColors.gold, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message.text,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ FIXED: Auto YES for creator, others vote
  Widget _buildTripProposalBubble(BuildContext context) {
    final metadata = message.metadata ?? {};
    final votes = Map<String, dynamic>.from(metadata['votes'] ?? {});
    final memberIds = List<String>.from(metadata['memberIds'] ?? []);
    final destination = metadata['destination'] ?? 'Unknown';
    final startDateStr = metadata['startDate'];
    final endDateStr = metadata['endDate'];
    final weather = metadata['weather'];
    final status = metadata['status'] ?? 'voting';

    final yesVotes = votes.entries.where((e) => e.value == true).length;
    final totalMembers = memberIds.length;
    final hasVoted = votes.containsKey(currentUserId);
    final myVote = votes[currentUserId] == true;

    DateTime? startDate;
    DateTime? endDate;
    if (startDateStr != null) startDate = DateTime.tryParse(startDateStr);
    if (endDateStr != null) endDate = DateTime.tryParse(endDateStr);

    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: status == 'approved' ? AppColors.success : AppColors.primary.withValues(alpha: 0.3),
          width: status == 'approved' ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.flight_takeoff, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trip Proposal',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      destination,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          if (startDate != null && endDate != null)
            _InfoRow(
              icon: Icons.calendar_today,
              text: '${DateFormat('MMM d').format(startDate)} - ${DateFormat('MMM d, yyyy').format(endDate)}',
            ),
          if (weather != null) ...[
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.wb_sunny,
              text: '${weather['temp']?.round()}°C, ${weather['description']}',
            ),
            if (weather['windSpeed'] != null)
              Padding(
                padding: const EdgeInsets.only(left: 28, top: 2),
                child: Text(
                  'Wind: ${weather['windSpeed']} m/s • Humidity: ${weather['humidity']}%',
                  style: AppTextStyles.caption,
                ),
              ),
          ],
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: totalMembers > 0 ? yesVotes / totalMembers : 0,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(
              yesVotes >= totalMembers ? AppColors.success : AppColors.primary,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 6),
          Text(
            '$yesVotes/$totalMembers confirmed • ${totalMembers - yesVotes} needed',
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500),
          ),

          // ✅ FIXED: Show vote status for ALL (creator sees "You voted YES")
          if (status == 'voting') ...[
            const SizedBox(height: 16),
            
            if (hasVoted) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: myVote ? AppColors.successBg : AppColors.dangerBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      myVote ? Icons.check_circle : Icons.cancel,
                      color: myVote ? AppColors.success : AppColors.danger,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'You voted ${myVote ? 'YES' : 'NO'}',
                      style: TextStyle(
                        color: myVote ? AppColors.success : AppColors.danger,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _vote(context, true),
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text('YES'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _vote(context, false),
                      icon: const Icon(Icons.cancel, size: 18),
                      label: const Text('NO'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],

          if (status == 'approved') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.successBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Trip Approved! All members confirmed. Trip is being created...',
                      style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _vote(BuildContext context, bool vote) async {
    final chatProvider = context.read<ChatProvider>();
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    if (user == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await chatProvider.voteOnProposal(
        chatId: chatId,
        messageId: message.id,
        userId: user.uid,
        userName: user.name,
        userInitials: user.initials,
        vote: vote,
      );
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You voted ${vote ? 'YES' : 'NO'}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vote failed: $e')),
        );
      }
    }
  }

  Widget _buildVoteUpdateBubble() {
    final metadata = message.metadata ?? {};
    final isApproved = metadata['isApproved'] ?? false;
    final votes = Map<String, dynamic>.from(metadata['votes'] ?? {});
    final totalMembers = metadata['totalMembers'] ?? 0;
    final yesVotes = votes.entries.where((e) => e.value == true).length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isApproved ? AppColors.successBg : AppColors.primaryMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isApproved ? AppColors.success.withValues(alpha: 0.3) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isApproved ? Icons.check_circle : Icons.how_to_vote,
            color: isApproved ? AppColors.success : AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isApproved ? AppColors.success : AppColors.textMain,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '$yesVotes/$totalMembers votes',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCreatedBubble(BuildContext context) {
    final metadata = message.metadata ?? {};
    final tripId = metadata['tripId'];
    final destination = metadata['destination'] ?? 'Trip';

    return GestureDetector(
      onTap: () {
        if (tripId != null) {
          // Navigate to trip detail
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.success.withValues(alpha: 0.1), AppColors.primaryMuted],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            const Icon(Icons.celebration, color: AppColors.success, size: 40),
            const SizedBox(height: 8),
            Text(
              message.text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.success,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            if (tripId != null) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.flight_takeoff, size: 16),
                label: Text('View $destination'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationBubble() {
    final metadata = message.metadata ?? {};
    final city = metadata['city'] ?? 'Unknown';
    final weather = metadata['weather'];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF90CAF9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.search, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Destination Search: $city',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (weather != null) ...[
            const SizedBox(height: 8),
            Text('🌤️ ${weather['temp']}°C, ${weather['description']}'),
          ],
        ],
      ),
    );
  }

  Widget _buildPlanConfirmBubble(BuildContext context) {
    final metadata = message.metadata ?? {};
    final tripId = metadata['tripId'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCE93D8)),
      ),
      child: Column(
        children: [
          const Icon(Icons.fact_check, color: Color(0xFF8E24AA), size: 32),
          const SizedBox(height: 8),
          Text(
            message.text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              if (tripId != null) {
                // Navigate to trip
              }
            },
            icon: const Icon(Icons.check_circle),
            label: const Text('Confirm Plan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8E24AA),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemMessage() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.textMuted.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _WeatherDetailItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _WeatherDetailItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: AppTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}