import 'package:flutter/material.dart';

class WeatherIcon extends StatelessWidget {
  final String iconCode;
  final double size;
  final Color? color;

  const WeatherIcon({
    super.key,
    required this.iconCode,
    this.size = 50,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Map OpenWeather icon codes to Material icons
    IconData getIconData() {
      switch (iconCode.substring(0, 2)) {
        case '01': // clear sky
          return Icons.wb_sunny;
        case '02': // few clouds
          return Icons.wb_cloudy;
        case '03': // scattered clouds
        case '04': // broken clouds
          return Icons.cloud;
        case '09': // shower rain
        case '10': // rain
          return Icons.water_drop;
        case '11': // thunderstorm
          return Icons.thunderstorm;
        case '13': // snow
          return Icons.ac_unit;
        case '50': // mist
          return Icons.foggy;
        default:
          return Icons.wb_sunny;
      }
    }

    return Icon(
      getIconData(),
      size: size,
      color: color ?? Colors.white,
    );
  }
}