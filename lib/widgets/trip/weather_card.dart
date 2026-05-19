import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../services/weather_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';

class WeatherCard extends StatefulWidget {
  final String destination;

  const WeatherCard({super.key, required this.destination});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  final WeatherService _weatherService = WeatherService();
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _weatherData;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      final metrics = await _weatherService.getWeather(widget.destination);
      if (mounted) {
        setState(() {
          _weatherData = metrics;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext buildContext) {
    if (_loading) {
      return Shimmer.fromColors(
        baseColor: AppColors.shimmer,
        highlightColor: AppColors.white,
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
        ),
      );
    }

    if (_error != null || _weatherData == null) {
      return Container(
        padding: const EdgeInsets.all(AppDimensions.lg),
        decoration: BoxDecoration(
          color: AppColors.dangerBg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        child: Text('Mausam ki malomat nahi mil sakin.', style: AppTextStyles.body.copyWith(color: AppColors.danger)),
      );
    }

    final double temp = _weatherData!['temp'];
    final String condition = _weatherData!['condition'];
    final int humidity = _weatherData!['humidity'];
    final double wind = _weatherData!['windSpeed'];

    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.destination, style: AppTextStyles.whiteBody.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppDimensions.xs),
              Text('${temp.toStringAsFixed(1)}°C', style: AppTextStyles.heading1.copyWith(color: AppColors.white, fontSize: 36)),
              Text(condition, style: AppTextStyles.whiteMuted),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(Icons.wb_sunny, color: AppColors.gold, size: 40),
              const SizedBox(height: AppDimensions.md),
              Text('Humidity: $humidity%', style: AppTextStyles.whiteMuted),
              Text('Wind: ${wind.toStringAsFixed(1)} m/s', style: AppTextStyles.whiteMuted),
            ],
          )
        ],
      ),
    );
  }
}