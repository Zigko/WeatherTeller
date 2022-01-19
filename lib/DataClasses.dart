import 'dart:collection';

import 'package:flutter/cupertino.dart';

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
        description = b.description;
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
