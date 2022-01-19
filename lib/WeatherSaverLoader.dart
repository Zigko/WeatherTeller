import 'dart:convert';

import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/JsonHelper.dart';

import 'DataClasses.dart';

class WeatherSaverLoader {
  save(WeatherInfoForecast forecast) async {
    var prefs = await SharedPreferences.getInstance();

    var currentWeatherMap =
        JsonHelper.toMapFromWeatherMoment(forecast.currentWeather);
    var currentWeatherJson = jsonEncode(currentWeatherMap);
    prefs.setString('currentWeather', currentWeatherJson);
    prefs.setString('currentDay', forecast.currentDay.toIso8601String());
    prefs.setString('language', forecast.language);
    if (forecast.latLon != null) {
      prefs.setString(
          'latLon', '${forecast.latLon!.lat},${forecast.latLon!.lon}');
    }
    prefs.setString('location', forecast.location);

    var days = <Map<String, String>>[];
    for (var day in forecast.days) {
      days.add(JsonHelper.toMapWeekDay(day));
    }

    var daysJson = days.map((e) => jsonEncode(e)).toList();
    prefs.setStringList('days', daysJson);
  }

  Future<WeatherInfoForecast?> load() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('location') == null) return null;

    var forecast = WeatherInfoForecast.empty();

    var currentWeatherMap = jsonDecode(prefs.getString('currentWeather')!);
    forecast.currentWeather =
        JsonHelper.fromMapToWeatherMoment(currentWeatherMap);
    forecast.currentDay = DateTime.parse(prefs.getString('currentDay')!);
    forecast.language = prefs.getString('language')!;

    var latLon = prefs.getString('latLon');
    if (latLon != null) {
      var split = latLon.split(',');
      forecast.latLon = LatLon(double.parse(split[0]), double.parse(split[1]));
    }

    forecast.location = prefs.getString('location')!;
    var daysJsonList = prefs.getStringList('days') as List<String>;
    var days = <WeatherInfoDay>[];
    for (var dayJsonStr in daysJsonList) {
      var decoded = jsonDecode(dayJsonStr) as Map<String, dynamic>;
      days.add(JsonHelper.fromMapToWeatherDay(decoded));
    }

    forecast.days = days;
    return forecast;
  }
}
