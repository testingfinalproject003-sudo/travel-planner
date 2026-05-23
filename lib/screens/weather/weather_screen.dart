import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/weather_provider.dart';

class WeatherScreen extends StatefulWidget {
  final String? city;
  const WeatherScreen({super.key, this.city});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.city != null) {
      _cityController.text = widget.city!;
      _loadWeather(widget.city!);
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _loadWeather(String city) async {
    final weatherProvider = context.read<WeatherProvider>();
    await weatherProvider.getCurrentWeather(city);
    await weatherProvider.getForecast(city);
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = context.watch<WeatherProvider>();
    final weather = weatherProvider.currentWeather;
    final forecast = weatherProvider.forecast;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Search
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    hintText: 'Search city...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () {
                        if (_cityController.text.isNotEmpty) {
                          _loadWeather(_cityController.text);
                        }
                      },
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      _loadWeather(value);
                    }
                  },
                ),
              ),
            ),

            // Current Weather
            if (weather != null)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        weather.city,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Image.network(
                        weather.iconUrl,
                        width: 100,
                        height: 100,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.wb_sunny, size: 80, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${weather.temperature.round()}°C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        weather.description.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildWeatherInfo(
                            Icons.thermostat,
                            '${weather.feelsLike.round()}°C',
                            'Feels Like',
                          ),
                          _buildWeatherInfo(
                            Icons.water_drop,
                            '${weather.humidity}%',
                            'Humidity',
                          ),
                          _buildWeatherInfo(
                            Icons.air,
                            '${weather.windSpeed} m/s',
                            'Wind',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // Forecast
            if (forecast.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '5-Day Forecast',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final day = forecast[index * 8]; // Every 8th item is a new day
                      if (index >= forecast.length ~/ 8) return null;
                      return _buildForecastCard(day);
                    },
                    childCount: forecast.length ~/ 8,
                  ),
                ),
              ),
            ],

            if (weatherProvider.isLoading)
              const SliverToBoxAdapter(
                child: Center(child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                )),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherInfo(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildForecastCard(dynamic day) {
    final dateFormat = DateFormat('EEE, MMM dd');
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Image.network(
          day.iconUrl,
          width: 50,
          height: 50,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.wb_cloudy, color: AppColors.primary),
        ),
        title: Text(dateFormat.format(day.date)),
        subtitle: Text(day.description),
        trailing: Text(
          '${day.temperature.round()}°C',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
