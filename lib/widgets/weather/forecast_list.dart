import 'package:flutter/material.dart';

class ForecastItemData {
  final String dateLabel;
  final double temp;
  final String conditions;
  final IconData icon;

  const ForecastItemData({
    required this.dateLabel,
    required this.temp,
    required this.conditions,
    required this.icon,
  });
}

class ForecastList extends StatelessWidget {
  final List<ForecastItemData> forecastItems;

  const ForecastList({
    super.key,
    required this.forecastItems,
  });

  @override
  Widget build(BuildContext context) {
    if (forecastItems.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text("No upcoming forecast data available."),
      );
    }

    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: forecastItems.length,
        itemBuilder: (context, index) {
          final item = forecastItems[index];
          return Container(
            width: 95,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: const Color(0xfffafafa),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xffe0e0e0).withValues(alpha: 0.6)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.dateLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Icon(item.icon, color: const Color(0xffd99379), size: 28),
                const SizedBox(height: 8),
                Text(
                  "${item.temp.toStringAsFixed(0)}°C",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff2d2d2d),
                  ),
                ),
                Text(
                  item.conditions,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}