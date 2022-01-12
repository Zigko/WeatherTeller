import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeatherInfoForecast {
  late final List<WeatherInfoDay> days;
  late final DateTime currentDay;
  late final String location;
  late final String language;

  WeatherInfoForecast(this.days, this.currentDay, this.location, this.language);
}

class WeatherState {
  static const String Thunderstorm = "Thunderstorm";
  static const String Drizzle = "Drizzle";
  static const String Rain = "Rain";
  static const String Snow = "Snow";
  static const String Atmosphere = "Atmosphere";
  static const String Clear = "Clear";
  static const String Clouds = "Clouds";
}

// class WeatherInfo3Hour{
//   late final DateTime date;
//   late final int tempMax;
//   late final int tempMin;
//   late final int humidity;
//   late final String weatherState;
//   late final String description;
//   late final String icon;
//   late final int windSpeed;
//   late final String rainProb;
//
//   WeatherInfo3Hour.fromJson(Map<String, dynamic> jsonObj) {
//     var dt = jsonObj["dt_txt"].toString();
//     date = DateTime.parse(dt);
//     var main = jsonObj["main"];
//     tempMax = (main["temp_max"] as double).toInt();
//     tempMin = (main["temp_min"] as double).toInt();
//     humidity = (main["humidity"] as double).toInt();
//     var weather = jsonObj["weather"][0];
//     weatherState = weather["main"];
//     description = weather["description"];
//     icon = weather["icon"];
//     windSpeed = (jsonObj["wind"]["speed"] as double).toInt();
//     rainProb = jsonObj["pop"].toString();
//   }
// }

class WeatherInfoDay {
  late final DateTime date;
  late final int tempMax;
  late final int tempMin;
  late final int humidity;
  late final String weatherState;
  late final String description;
  late final String icon;
  late final int windSpeed;
  late final String rainProb;

  static final DateFormat dateTimeFormat = DateFormat("yyyy-MM-dd");

  WeatherInfoDay.fromJson(Map<String, dynamic> jsonObj) {
    var dt = jsonObj["dt_txt"].toString();
    dt = dt.split(" ")[0];
    date = dateTimeFormat.parse(dt);
    var main = jsonObj["main"];
    tempMax = (main["temp_max"] as double).toInt();
    tempMin = (main["temp_min"] as double).toInt();
    humidity = (main["humidity"] as double).toInt();
    var weather = jsonObj["weather"][0];
    weatherState = weather["main"];
    description = weather["description"];
    icon = weather["icon"];
    windSpeed = (jsonObj["wind"]["speed"] as double).toInt();
    rainProb = jsonObj["pop"].toString();
  }
}

class WeatherAPI {
  static const String appid = "f748cf33755afb0c35061a61f1d8b9d7";

  WeatherAPI(this.lang);

  final String lang;
  final String units = "metric";
  final int days = 5;

  //Call 16 day / daily forecast data
  //api.openweathermap.org/data/2.5/forecast?q={city name}&cnt={cnt}&appid={API key}

  //Current weather
  //api.openweathermap.org/data/2.5/weather?q=Coimbra&appid=f748cf33755afb0c35061a61f1d8b9d7&lang=PT&units=metric

  //&appid=f748cf33755afb0c35061a61f1d8b9d7

  Future<WeatherInfoForecast?> getForecast(String place) async {
    var uri = Uri.parse("https://api.openweathermap.org/data/2.5/forecast?"
        "q=$place&appid=$appid&lang=$lang&units=$units&cnt=${days * 8}  ");
    var response = await http.get(uri);

    if (response.statusCode != 200) return null;

    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    var list = <WeatherInfoDay>[];
    for (var jsonObj in decodedResponse["list"]) {
      var dt = jsonObj["dt_txt"];
      dt = dt.split(" ")[1];
      if (dt != "12:00:00") continue;
      list.add(WeatherInfoDay.fromJson(jsonObj));
    }

    return WeatherInfoForecast(list, DateTime.now(), place, lang);
  }

  Future<Object?> getDayDetails(String place) async {
    var uri = Uri.parse("https://api.openweathermap.org/data/2.5/weather?"
        "q=$place&appid=$appid&lang=$lang&units=$units");
    var response = await http.get(uri);

    if (response.statusCode != 200) {
      return null;
    }

    return null; //TODO
  }
}
