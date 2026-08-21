import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherData {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int weatherCode;
  final bool isDay;

  WeatherData({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.isDay,
  });

  String get condition {
    switch (weatherCode) {
      case 0:
        return 'Clear sky';
      case 1:
      case 2:
        return 'Partly cloudy';
      case 3:
        return 'Cloudy';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 66:
      case 67:
        return 'Freezing rain';
      case 71:
      case 73:
      case 75:
        return 'Snow';
      case 77:
        return 'Snow grains';
      case 80:
      case 81:
      case 82:
        return 'Rain showers';
      case 85:
      case 86:
        return 'Snow showers';
      case 95:
        return 'Thunderstorm';
      case 96:
      case 99:
        return 'Thunderstorm with hail';
      default:
        return 'Unknown';
    }
  }

  String get weatherIcon {
    if (weatherCode == 0) {
      return isDay ? '☀️' : '🌙';
    }

    if (weatherCode == 1 || weatherCode == 2) {
      return isDay ? '🌤️' : '🌙';
    }

    if (weatherCode == 3) {
      return '☁️';
    }

    if (weatherCode >= 51 && weatherCode <= 67) {
      return '🌧️';
    }

    if (weatherCode >= 80 && weatherCode <= 82) {
      return '🌦️';
    }

    if (weatherCode >= 95) {
      return '⛈️';
    }

    return '🌤️';
  }
}

class WeatherService {
  // Kathmandu coordinates
  static const double latitude = 27.7172;
  static const double longitude = 85.3240;

  static Future<WeatherData> getCurrentWeather() async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
          '?latitude=$latitude'
          '&longitude=$longitude'
          '&current=temperature_2m,relative_humidity_2m,apparent_temperature,'
          'weather_code,wind_speed_10m,is_day'
          '&timezone=Asia%2FKathmandu'
          '&temperature_unit=celsius'
          '&wind_speed_unit=kmh',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load weather: ${response.statusCode}',
      );
    }

    final Map<String, dynamic> data =
    jsonDecode(response.body);

    final current =
    data['current'] as Map<String, dynamic>;

    return WeatherData(
      temperature:
      (current['temperature_2m'] as num).toDouble(),
      feelsLike:
      (current['apparent_temperature'] as num).toDouble(),
      humidity:
      (current['relative_humidity_2m'] as num).toInt(),
      windSpeed:
      (current['wind_speed_10m'] as num).toDouble(),
      weatherCode:
      (current['weather_code'] as num).toInt(),
      isDay:
      (current['is_day'] as num).toInt() == 1,
    );
  }
}