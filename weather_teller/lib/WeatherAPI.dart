import 'dart:convert';
import 'package:http/http.dart' as http;

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

class WeatherInfoDay {
  late final String unixTime;
  late final double tempMax;
  late final double tempMin;
  late final double humidity;
  late final String weatherState;
  late final String description;
  late final double windSpeed;
  late final double rainProb;

  WeatherInfoDay(this.unixTime, this.tempMax, this.tempMin, this.humidity,
      this.weatherState, this.description, this.windSpeed, this.rainProb);

  WeatherInfoDay.fromJson(Map<String, dynamic> jsonObj) {
    unixTime = jsonObj["dt"];
    tempMax = jsonObj["temp"]["max"];
    tempMin = jsonObj["temp"]["min"];
    humidity = jsonObj["humidity"];
    weatherState = jsonObj["weather"]["main"];
    description = jsonObj["weather"]["description"];
    windSpeed = jsonObj["speed"];
    rainProb = jsonObj["pop"];
  }
}

class WeatherAPI {
  static const String appid = "f748cf33755afb0c35061a61f1d8b9d7";

  WeatherAPI(this.lang);

  final String lang;
  final String units = "metric";
  final int days = 7;

  //Call 16 day / daily forecast data
  //api.openweathermap.org/data/2.5/forecast/daily?q={city name}&cnt={cnt}&appid={API key}

  //Current weather
  //api.openweathermap.org/data/2.5/weather?q=Coimbra&appid=f748cf33755afb0c35061a61f1d8b9d7&lang=PT&units=metric

  //&appid=f748cf33755afb0c35061a61f1d8b9d7

  Future<WeatherInfoForecast?> getForecast(String place) async {
    var uri = Uri.parse("api.openweathermap.org/data/2.5/forecast?"
        "q=$place&appid=$appid&lang=$lang&units=$units&cnt=$days");
    var response = await http.get(uri);

    if (response.statusCode != 200) {
      return null;
    }

    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    var list = <WeatherInfoDay>[];
    for (var json in decodedResponse["list"]) {
      list.add(WeatherInfoDay.fromJson(json));
    }

    return WeatherInfoForecast(list, DateTime.now(), place, lang);
  }

  Future<Object?> getDayDetails(String place) async {
    var uri = Uri.parse("api.openweathermap.org/data/2.5/weather?"
        "q=$place&appid=$appid&lang=$lang&units=$units");
    var response = await http.get(uri);

    if (response.statusCode != 200) {
      return null;
    }

    return null; //TODO
  }
}
