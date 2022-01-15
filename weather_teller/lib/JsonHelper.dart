import 'package:weather_teller/HomeScreen.dart';

import 'WeatherAPI.dart';

class JsonHelper{
  late WeatherInfoForecast forecast;
  //this is what we need to save a read for the current weather
  Map toJsonToday() => {
    'icon': forecast.currentWeather.icon,
    'temp': forecast.currentWeather.temp,
    'day': forecast.currentDay.day,
    'month': forecast.currentDay.month,
  };

  //somehow this week days need to be added to a list and save in share preferences
  Map toJsonWeekDay() => {
    'weekDay': forecast.days.first.date.weekday,
    'month': forecast.days.first.date.month,
    'day':forecast.days.first.date.day,
    'icon': forecast.days.first.icon,
    'tempMax': forecast.days.first.tempMax,
    'tempMin':forecast.days.first.tempMin,
  };

}

class Tag {
  String name;
  int quantity;

  Tag(this.name, this.quantity);

  Map toJson() => {
    'name': name,
    'quantity': quantity,
  };
}