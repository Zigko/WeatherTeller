import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'WeatherAPI.dart';

class JsonHelper {
  static Map<String, String> toMapFromWeatherMoment(
      WeatherInfoMoment weatherMoment) {
    return {
      'icon': weatherMoment.icon,
      'temp': weatherMoment.temp.toString(),
      'date': weatherMoment.date.toString(),
      'tempMax': weatherMoment.tempMax.toString(),
      'tempMin': weatherMoment.tempMin.toString(),
      'humidity': weatherMoment.humidity.toString(),
      'weatherState': weatherMoment.weatherState.weatherState,
      'description': weatherMoment.description,
      'windSpeed': weatherMoment.windSpeed.toString(),
      'rainProb': weatherMoment.rainProb.toString(),
    };
  }

  static Map<String, String> toMapWeekDay(WeatherInfoDay day) {
    var blockMaps = day.blocks.map((e) => toMapFromWeatherMoment(e)).toList();
    var encodedBlocks = jsonEncode(blockMaps);

    return {
      'date': day.date.toString(),
      'icon': day.icon.toString(),
      'tempMax': day.tempMax.toString(),
      'tempMin': day.tempMin.toString(),
      'humidity': day.humidity.toString(),
      'weatherState': day.weatherState.weatherState,
      'description': day.description,
      'windSpeed': day.windSpeed.toString(),
      'rainProb': day.rainProb.toString(),
      'blocks': encodedBlocks,
    };
  }

  static WeatherInfoMoment fromMapToWeatherMoment(Map<String, dynamic> map) {
    var weatherMoment = WeatherInfoMoment.empty();
    weatherMoment.temp = int.parse(map['temp']!);
    weatherMoment.tempMax = int.parse(map['tempMax']!);
    weatherMoment.tempMin = int.parse(map['tempMin']!);
    weatherMoment.humidity = int.parse(map['humidity']!);
    weatherMoment.windSpeed = int.parse(map['windSpeed']!);
    weatherMoment.rainProb = int.parse(map['rainProb']!);
    weatherMoment.icon = map['icon']!;
    weatherMoment.description = map['description']!;
    weatherMoment.date = DateTime.parse(map['date']!);
    weatherMoment.weatherState = WeatherState.states[map['weatherState']!];
    return weatherMoment;
  }

  static WeatherInfoDay fromMapToWeatherDay(Map<String, dynamic> map) {
    var weatherMoment = WeatherInfoDay.empty();
    weatherMoment.tempMax = int.parse(map['tempMax']!);
    weatherMoment.tempMin = int.parse(map['tempMin']!);
    weatherMoment.humidity = int.parse(map['humidity']!);
    weatherMoment.windSpeed = int.parse(map['windSpeed']!);
    weatherMoment.rainProb = int.parse(map['rainProb']!);
    weatherMoment.icon = map['icon']!;
    weatherMoment.description = map['description']!;
    weatherMoment.date = DateTime.parse(map['date']!);
    weatherMoment.weatherState = WeatherState.states[map['weatherState']!];
    var decodedBlocks = jsonDecode(map['blocks']);
    var blocks = <WeatherInfoMoment>[];
    for(var day in decodedBlocks){
      blocks.add(fromMapToWeatherMoment(day));
    }
    weatherMoment.blocks = blocks;
    return weatherMoment;
  }
}
// static WeatherInfoMoment fromPrefsToWeatherMoment
//     (SharedPreferences prefs) {
//   var weatherMoment = WeatherInfoMoment.empty();
//   weatherMoment.temp = prefs.getInt('temp')!;
//   weatherMoment.tempMax = prefs.getInt('tempMax')!;
//   weatherMoment.tempMin = prefs.getInt('tempMin')!;
//   weatherMoment.humidity = prefs.getInt('humidity')!;
//   weatherMoment.windSpeed = prefs.getInt('windSpeed')!;
//   weatherMoment.rainProb = prefs.getInt('rainProb')!;
//   weatherMoment.icon = prefs.getString('icon')!;
//   weatherMoment.description = prefs.getString('description')!;
//   weatherMoment.date = DateTime.parse(prefs.getString('date')!);
//   weatherMoment.weatherState =
//   WeatherState.states[prefs.getString('weatherState')!];
//   return weatherMoment;
// }
