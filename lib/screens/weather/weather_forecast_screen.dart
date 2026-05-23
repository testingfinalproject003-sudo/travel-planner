import 'package:flutter/material.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/weather/forecast_list.dart';

class WeatherForecastScreen extends StatefulWidget {
   const WeatherForecastScreen({super.key});

  @override
  State<WeatherForecastScreen> createState() => _WeatherForecastScreenState();
}

class _WeatherForecastScreenState extends State<WeatherForecastScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _hasSearched = false;
  String _currentCity = "";

  // Mocked state fields that align precisely with your openWeather integration schema
  final List<ForecastItemData> _mockForecast = [
    const ForecastItemData(dateLabel: "Mon, May 25", temp: 28.5, conditions: "Sunny", icon: Icons.wb_sunny),
    const ForecastItemData(dateLabel: "Tue, May 26", temp: 26.0, conditions: "Cloudy", icon: Icons.cloud),
    const ForecastItemData(dateLabel: "Wed, May 27", temp: 24.5, conditions: "Rainy", icon: Icons.beach_access),
    const ForecastItemData(dateLabel: "Thu, May 28", temp: 27.0, conditions: "Clear", icon: Icons.wb_twilight),
    const ForecastItemData(dateLabel: "Fri, May 29", temp: 29.0, conditions: "Sunny", icon: Icons.wb_sunny),
  ];

  void _executeSearch() {
    if (_searchController.text.trim().isNotEmpty) {
      setState(() {
        _hasSearched = true;
        _currentCity = _searchController.text.trim();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Destination Weather", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff2d2d2d),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _searchController,
                    labelText: "Search Separate Destination",
                    hintText: "e.g., Tokyo, Paris",
                    prefixIcon: Icons.search,
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xffd99379),
                  child: IconButton(
                    icon: const Icon(Icons.check, color: Colors.white),
                    onPressed: _executeSearch,
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: !_hasSearched
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_queue, size: 64, color: Colors.grey.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        const Text(
                          "Check metrics before planning dates",
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(24),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xffd99379),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentCity.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text("Current Temperature", style: TextStyle(color: Colors.white70)),
                              const SizedBox(height: 12),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "27°C",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 56,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  Icon(Icons.wb_sunny, size: 64, color: Colors.white),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          child: Text(
                            "Forecast for Coming Dates",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ForecastList(forecastItems: _mockForecast),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}