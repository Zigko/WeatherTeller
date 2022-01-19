import 'dart:collection';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'DataClasses.dart';

class OpenWeatherAPI {
  //appid : f748cf33755afb0c35061a61f1d8b9d7
  static const String appid = "f748cf33755afb0c35061a61f1d8b9d7";
  static const int days = 5;
  static const int cnt = days * 8;

  OpenWeatherAPI(this.lang) {
    remainingQuery = "&appid=$appid&lang=$lang&units=$units";
  }

  final String lang;
  final String units = "metric";
  late final String remainingQuery;

  static const String forecastURI =
      "https://api.openweathermap.org/data/2.5/forecast?";
  static const String weatherURI =
      "https://api.openweathermap.org/data/2.5/weather?";

  //5 day / 3 hour forecast data
  //api.openweathermap.org/data/2.5/forecast?q={city name}&cnt={cnt}&appid={API key}
  //Current weather
  //api.openweathermap.org/data/2.5/weather? ......
  static final DateFormat dateTimeFormat = DateFormat("yyyy-MM-dd");

  Future<WeatherInfoForecast> getForecastPosAsync(LocationData position) async {
    var lat = position.latitude, lon = position.longitude;
    var options = _makeOptions(lat: lat, lon: lon);
    return _getForecastAsync("Lat: $lat,Lon: $lon", options);
  }

  Future<WeatherInfoForecast> getForecastPlaceAsync(String place) async {
    var options = _makeOptions(place: place);
    return _getForecastAsync(place, options);
  }

  Future<WeatherInfoForecast> _getForecastAsync(
      String placeName, String options) async {
    var currentWeatherTask = _getDayDetailsAsync(options);

    var uri = Uri.parse(forecastURI + options + remainingQuery);
    var response = await http.get(uri);

    if (response.statusCode != 200) {
      if (response.statusCode == 404) {
        return Future.error(Intl.message('', name: 'city_not_found'));
      }
      return Future.error(Intl.message('', name: 'error_forecast'));
    }

    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    var list = <WeatherInfoDay>[];
    var currentDay = <WeatherInfoMoment>[];
    var currentDate = DateTime.now();

    for (var jsonObj in decodedResponse["list"]) {
      var dt = jsonObj["dt_txt"] as String;
      dt = dt.split(" ")[0];
      var date = dateTimeFormat.parse(dt);

      if (date.compareTo(currentDate) > 0) {
        if (currentDay.isNotEmpty) {
          list.add(WeatherInfoDay(currentDay));
        }
        currentDay = <WeatherInfoMoment>[];
        currentDay.add(WeatherInfoMoment.fromJson(jsonObj));
        currentDate = date;
      } else {
        currentDay.add(WeatherInfoMoment.fromJson(jsonObj));
      }
    }

    var currentWeather = await currentWeatherTask;

    return WeatherInfoForecast(
        list, currentWeather, DateTime.now(), placeName, lang);
  }

  String _makeOptions({String? place, double? lat, double? lon}) {
    var options = "";
    if (place != null) {
      options = "q=$place";
    } else if (lat != null && lon != null) {
      options = "lat=$lat&lon=$lon";
    } else {
      throw Exception("Invalid Weather Call");
    }
    return options;
  }

  Future<WeatherInfoMoment> _getDayDetailsAsync(String options) async {
    var uri = Uri.parse(weatherURI + options + remainingQuery);
    var response = await http.get(uri);

    if (response.statusCode != 200) {
      if (response.statusCode == 404) {
        return Future.error(Intl.message('', name: 'city_not_found'));
      }
      return Future.error(Intl.message('', name: 'error_forecast'));
    }

    var root =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    var main = root["main"];
    var temp = main["temp"].toInt();
    var tempMax = main["temp_max"].toInt();
    var tempMin = main["temp_min"].toInt();
    var humidity = main["humidity"].toInt();
    var weather = root["weather"][0];
    var weatherState = WeatherState.states[weather["main"]];
    var description = weather["description"];
    var icon = weather["icon"];
    var windSpeed = root["wind"]["speed"].toInt();

    return WeatherInfoMoment(DateTime.now(), temp, tempMax, tempMin, humidity,
        weatherState, description, icon, windSpeed, 0);
  }
}
