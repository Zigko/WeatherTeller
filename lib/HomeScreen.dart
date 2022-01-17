import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/JsonHelper.dart';
import 'package:weather/WeatherAPI.dart';
import 'package:weather/Location.dart';
import 'package:weather/WeatherSaverLoader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final OpenWeatherAPI weatherAPI = OpenWeatherAPI(Intl.getCurrentLocale());
  static final DateFormat monthDayFormatter = DateFormat.MMMMd();

  final WeatherSaverLoader saverLoader = WeatherSaverLoader();

  WeatherInfoForecast? forecast;

  String searchedLocation = "Coimbra";
  bool animation = false;

  static const int animationDurationMs = 500;

  // Navigator.pushNamed(context, '/details')

  @override
  void initState() {
    super.initState();
    _loadFromDisk();
    //_refresh();
  }

  _loadFromDisk() {
    _getWeatherInfo().then((value) {
      if (value != null) {
        _updateWeatherScreen(value);
      }
    });
    //     .catchError((e) {
    //   Fluttertoast.showToast(
    //       msg: "Error loading from disk", toastLength: Toast.LENGTH_LONG);
    // });
  }

  _refresh() {
    weatherAPI
        .getForecastPlaceAsync(searchedLocation)
        .then((value) => _updateWeatherScreen(value))
        .catchError((error) => Fluttertoast.showToast(
            msg: "Error getting weather forecast",
            toastLength: Toast.LENGTH_LONG));

    Fluttertoast.showToast(
        msg: "Locale: ${Intl.getCurrentLocale()}",
        toastLength: Toast.LENGTH_LONG);
  }

  _weatherHere() {
    determinePosition().then((position) {
      weatherAPI
          .getForecastPosAsync(position)
          .then((value) => _updateWeatherScreen(value))
          .catchError((error) => Fluttertoast.showToast(
              msg: error, toastLength: Toast.LENGTH_LONG));
    }).catchError((error) =>
        Fluttertoast.showToast(msg: error, toastLength: Toast.LENGTH_LONG));
  }

  //TODO fix Intl.getCurrentLocale() always en_US
  //TODO fix intl messages not in other languages, maybe previours fix fixes this fix

  _updateWeatherScreen(WeatherInfoForecast weatherInfoForecast) {
    animation = false;
    forecast = weatherInfoForecast;
    _saveWeatherInfo(weatherInfoForecast);

    setState(() {});
    Future.delayed(const Duration(milliseconds: animationDurationMs), () {
      setState(() {
        animation = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WeatherTeller'),
        actions: [
          IconButton(
              onPressed: () => _weatherHere(),
              icon: const Icon(Icons.add_location))
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade500, Colors.blue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (forecast != null)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _cloudIcon(),
                    Text(forecast!.currentWeather.description),
                    Text(
                      "${forecast?.currentWeather.temp}",
                      style: const TextStyle(
                          fontSize: 80, fontWeight: FontWeight.w100),
                    ),
                    _location(),
                  ],
                ),
              ),
            Flexible(
              child: _weekList(),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              _refresh();
            },
            child: const Icon(Icons.refresh),
          )
        ],
      ),
    );
  }

  _weekList() {
    if (forecast == null) return Container();
    return Padding(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
      child: Scrollbar(
        child: ListView.separated(
          separatorBuilder: (_, __) => const Divider(),
          scrollDirection: Axis.vertical,
          itemCount: forecast!.days.length,
          itemBuilder: (context, index) {
            var model = WeatherInfoDayModel(forecast!.days[index]);
            return _animatedWeatherLine(model);
          },
        ),
      ),
    );
  }

  _animatedWeatherLine(WeatherInfoDayModel model) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: animationDurationMs),
      opacity: animation ? 1 : 0,
      curve: Curves.easeInOutQuart,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: animationDurationMs),
        padding: animation
            ? const EdgeInsets.only(top: 5)
            : const EdgeInsets.only(top: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("${model.weekday}, ${model.monthDay}"),
            Image.network(model.imgPath),
            Text(model.temps),
          ],
        ),
      ),
    );
  }

  // Icon(Icons.brightness_3),

  _location() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.place),
        if (forecast != null)
          Column(
            children: [
              Text(forecast!.location),
              Text(monthDayFormatter.format(forecast!.currentWeather.date)),
            ],
          ),
      ],
    );
  }

  _cloudIcon() {
    if (forecast == null) return Container();
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: animationDurationMs),
        opacity: animation ? 1 : 0,
        curve: Curves.easeInOutQuart,
        child: Image.network(
          "https://openweathermap.org/img/wn/${forecast!.currentWeather.icon}@4x.png",
          height: 160,
          width: 160,
          scale: 1,
        ),
      ),
    );
  }

  _saveWeatherInfo(WeatherInfoForecast toSave) async {
    // var thisDay = forecast!.currentWeather;
    // var weekDays = forecast!.days;
    // var weather = WeatherInfo(thisDay, weekDays);
    //sharedPref.save("weather", weather);
    saverLoader.save(toSave);
  }

  Future<WeatherInfoForecast?> _getWeatherInfo() async {
    // var weather = sharedPref.read("weather");
    // debugPrint(weather);
    return saverLoader.load();
  }
}

class WeatherInfoDayModel {
  static final DateFormat weekdayFormatter = DateFormat.E();
  static final DateFormat monthDayFormatter = DateFormat.MMMd();

  late final String weekday;
  late final String monthDay;
  late final String temps;

  late final String imgPath;

  WeatherInfoDayModel(WeatherInfoDay day) {
    weekday = weekdayFormatter.format(day.date);
    monthDay = monthDayFormatter.format(day.date);
    temps = "${day.tempMax}º | ${day.tempMin}º";
    imgPath = "https://openweathermap.org/img/wn/${day.icon}.png";
  }
}

// class SharedPref {
//   static late final SharedPreferences _prefs;
//
//   setup() async {
//     _prefs = await SharedPreferences.getInstance();
//   }
//
//   read(String key) async {
//     return json.decode(_prefs.getString(key)!);
//   }
//
//   save(String key, value) async {
//     _prefs.setString(key, json.encode(value));
//   }
//
//   remove(String key) async {
//     _prefs.remove(key);
//   }
// }
//
// class WeatherInfo {
//   late WeatherInfoMoment today;
//   late List<WeatherInfoDay> week = [];
//
//   WeatherInfo(WeatherInfoMoment thisDay, List<WeatherInfoDay> weekDays) {
//     today = thisDay;
//     week = weekDays;
//     JsonHelper helper = JsonHelper();
//     // var jsonToday = helper.toMapCurrentWeather(today);
//   }
// }
