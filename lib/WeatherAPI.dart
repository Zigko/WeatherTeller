import 'dart:collection';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeatherInfoForecast {
  late final List<WeatherInfoDay> days;
  late final WeatherInfoMoment currentWeather;
  late final DateTime currentDay;
  late final String location;
  late final String language;

  WeatherInfoForecast(this.days, this.currentWeather, this.currentDay,
      this.location, this.language);

  WeatherInfoForecast.empty();
}

class WeatherState {
  late final int importance;
  late final String weatherState;
  late final IconData icon;

  WeatherState(this.weatherState, this.importance);

  static final HashMap states = HashMap.from({
    "Clear": WeatherState("Clear", 1),
    "Atmosphere": WeatherState("Atmosphere", 2),
    "Clouds": WeatherState("Clouds", 3),
    "Drizzle": WeatherState("Drizzle", 4),
    "Rain": WeatherState("Rain", 5),
    "Snow": WeatherState("Snow", 6),
    "Thunderstorm": WeatherState("Thunderstorm", 7),
  });
}

class WeatherInfoMoment {
  late DateTime date;
  late int temp = 0;
  late int tempMax;
  late int tempMin;
  late int humidity;
  late WeatherState weatherState;
  late String description;
  late String icon;
  late int windSpeed;
  late int rainProb;

  WeatherInfoMoment.empty();

  WeatherInfoMoment(
      this.date,
      this.temp,
      this.tempMax,
      this.tempMin,
      this.humidity,
      this.weatherState,
      this.description,
      this.icon,
      this.windSpeed,
      this.rainProb);

  WeatherInfoMoment.fromJson(Map<String, dynamic> root) {
    var dt = root["dt_txt"].toString();
    date = DateTime.parse(dt);
    var main = root["main"];
    tempMax = main["temp_max"].toInt();
    tempMin = main["temp_min"].toInt();
    humidity = main["humidity"].toInt();
    var weather = root["weather"][0];
    weatherState = WeatherState.states[weather["main"]];
    description = weather["description"];
    icon = weather["icon"];
    windSpeed = root["wind"]["speed"].toInt();
    rainProb = (root["pop"] * 100).toInt();
  }

  @override
  String toString() {
    return 'WeatherInfoMoment{date: $date, temp: $temp, tempMax: $tempMax, tempMin: $tempMin, humidity: $humidity, weatherState: $weatherState, description: $description, icon: $icon, windSpeed: $windSpeed, rainProb: $rainProb}';
  }
}

class WeatherInfoDay {
  late DateTime date;
  late int tempMax = -100000;
  late int tempMin = 100000;
  late int humidity = 0;
  late WeatherState weatherState = WeatherState.states["Clear"];
  late String icon;
  late String description;
  late int windSpeed = 0;
  late int rainProb = 0;
  late final List<WeatherInfoMoment> blocks;

  WeatherInfoDay.empty();

  WeatherInfoDay(this.blocks) {
    date = blocks[0].date;
    var iconIsSet = false;
    for (var b in blocks) {
      if (b.tempMax > tempMax) tempMax = b.tempMax;
      if (b.tempMin < tempMin) tempMin = b.tempMin;
      if (b.date.hour >= 9 && b.date.hour < 16) {
        if (b.weatherState.importance >= weatherState.importance) {
          weatherState = b.weatherState;
          icon = b.icon;
          description = b.description;
        }
      } else if (!iconIsSet) {
        iconIsSet = true;
        weatherState = b.weatherState;
        icon = b.icon;
      }
      humidity += b.humidity;
      windSpeed += b.windSpeed;
      rainProb += b.rainProb;
    }
    humidity = humidity ~/ blocks.length;
    windSpeed = windSpeed ~/ blocks.length;
    rainProb = rainProb ~/ blocks.length;
  }
}

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

  Future<WeatherInfoForecast?> getForecastPos(Position position) async {
    var lat = position.latitude, lon = position.longitude;
    var options = _makeOptions(lat: lat, lon: lon);
    return _getForecast("Lat: $lat,Lon: $lon", options);
  }

  Future<WeatherInfoForecast?> getForecastPlace(String place) async {
    var options = _makeOptions(place: place);
    return _getForecast(place, options);
  }

  Future<WeatherInfoForecast?> _getForecast(
      String placeName, String options) async {
    var currentWeatherTask = _getDayDetails(options);

    var uri = Uri.parse(forecastURI + options + remainingQuery);
    var response = await http.get(uri);
    if (response.statusCode != 200) return null;

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
    if (currentWeather == null) return null;

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

  Future<WeatherInfoMoment?> _getDayDetails(String options) async {
    var uri = Uri.parse(weatherURI + options + remainingQuery);
    var response = await http.get(uri);

    if (response.statusCode != 200) return null;

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
