import 'package:shared_preferences/shared_preferences.dart';

import 'WeatherAPI.dart';

class JsonHelper {
  //this is what we need to save a read for the current weather
  static Map<String, String> toMapFromWeatherMoment(
      WeatherInfoMoment weatherMoment) {
    print(weatherMoment.toString());
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

  static WeatherInfoMoment toWeatherMomentFromMap
      (Map<String, String> map) {
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

  static WeatherInfoMoment toObjectWeatherMomentFromPrefs
      (SharedPreferences prefs) {
    var weatherMoment = WeatherInfoMoment.empty();
    weatherMoment.temp = prefs.getInt('temp')!;
    weatherMoment.tempMax = prefs.getInt('tempMax')!;
    weatherMoment.tempMin = prefs.getInt('tempMin')!;
    weatherMoment.humidity = prefs.getInt('humidity')!;
    weatherMoment.windSpeed = prefs.getInt('windSpeed')!;
    weatherMoment.rainProb = prefs.getInt('rainProb')!;
    weatherMoment.icon = prefs.getString('icon')!;
    weatherMoment.description = prefs.getString('description')!;
    weatherMoment.date = DateTime.parse(prefs.getString('date')!);
    weatherMoment.weatherState =
    WeatherState.states[prefs.getString('weatherState')!];
    return weatherMoment;
  }

//somehow this week days need to be added to a list and save in share preferences
  static Map<String, dynamic> toMapWeekDay
      (WeatherInfoDay day) =>
      {
        'date': day.date,
        'icon': day.icon,
        'tempMax': day.tempMax,
        'tempMin': day.tempMin,
        'humidity': day.humidity,
        'weatherState': day.weatherState.weatherState,
        'description': day.description,
        'windSpeed': day.windSpeed,
        'rainProb': day.rainProb,
// TODO , talvez, meter também os detalhes dos dias, se não mostramos um
//  toast a dizer ai aiai, faz refresh se queres
      };
}

class Tag {
  String name;
  int quantity;

  Tag(this.name, this.quantity);

  Map toJson() =>
      {
        'name': name,
        'quantity': quantity,
      };
}
