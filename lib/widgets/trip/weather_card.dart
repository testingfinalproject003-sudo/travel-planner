import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../services/weather_service.dart';
import '../common/app_loader.dart';

class WeatherCard extends StatelessWidget {
  final String city;
  final bool compact;
  final WeatherService _weatherService = WeatherService();

  WeatherCard({
    super.key,
    required this.city,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _weatherService.getCurrentWeather(city),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildSkeleton();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _buildError();
        }

        final data = snapshot.data!;
        return compact ? _buildCompact(data) : _buildFull(data);
      },
    );
  }

  Widget _buildCompact(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryMuted,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        children: [
          Icon(
            _weatherService.getWeatherIcon(data['condition']),
            color: AppColors.primary,
            size: 28,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${data['temp'].round()}°C',
                style: AppTextStyles.heading3.copyWith(fontSize: 16),
              ),
              Text(
                data['condition'],
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const Spacer(),
          Text(
            data['cityName'] ?? city,
            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildFull(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _weatherService.getWeatherIcon(data['condition']),
                color: AppColors.white,
                size: 48,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${data['temp'].round()}°C',
                    style: AppTextStyles.heading1.copyWith(color: AppColors.white),
                  ),
                  Text(
                    data['description'].toString().capitalize(),
                    style: AppTextStyles.body.copyWith(color: AppColors.white.withValues(alpha:0.8)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _WeatherDetail(
                icon: Icons.water_drop,
                label: 'Humidity',
                value: '${data['humidity']}%',
              ),
              _WeatherDetail(
                icon: Icons.air,
                label: 'Wind',
                value: '${data['windSpeed']} km/h',
              ),
              _WeatherDetail(
                icon: Icons.thermostat,
                label: 'Feels Like',
                value: '${data['feelsLike'].round()}°C',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.shimmer,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: const AppLoader(size: 20),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.dangerBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
          const SizedBox(width: 8),
          Text(
            'Weather unavailable',
            style: AppTextStyles.caption.copyWith(color: AppColors.danger),
          ),
        ],
      ),
    );
  }
}

class _WeatherDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WeatherDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.white.withValues(alpha:0.7), size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: AppColors.white.withValues(alpha:0.6), fontSize: 11)),
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}