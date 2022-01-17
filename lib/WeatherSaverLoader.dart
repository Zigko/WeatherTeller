import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/HomeScreen.dart';
import 'package:weather/JsonHelper.dart';
import 'package:weather/WeatherAPI.dart';

class WeatherSaverLoader {
  save(WeatherInfoForecast forecast) async {
    var prefs = await SharedPreferences.getInstance();

    var currentWeatherMap =
        JsonHelper.toMapFromWeatherMoment(forecast.currentWeather);
    var currentWeatherJson = jsonEncode(currentWeatherMap);
    prefs.setString('currentWeather', currentWeatherJson);
    prefs.setString('currentDay', forecast.currentDay.toIso8601String());
    prefs.setString('language', forecast.language);
    prefs.setString('location', forecast.location);

    var days = <Map<String, dynamic>>[];
    for (var day in forecast.days) {
      days.add(JsonHelper.toMapWeekDay(day));
    }
    var daysJson = days.map((e) => jsonEncode(e)).toList();
    prefs.setStringList('days', daysJson);
  }

  Future<WeatherInfoForecast?> load() async {
    var prefs = await SharedPreferences.getInstance();
  }
}
