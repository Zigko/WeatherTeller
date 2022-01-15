import 'dart:convert';
import 'dart:js';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_teller/JsonHelper.dart';
import 'package:weather_teller/WeatherAPI.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final OpenWeatherAPI weatherAPI = OpenWeatherAPI(Intl.defaultLocale ??= "en");
  static final DateFormat monthDayFormatter = DateFormat.MMMMd();

  SharedPref sharedPref = SharedPref();

  WeatherInfoForecast? forecast;

  String searchedLocation = "Coimbra";

  bool animation = false;
  bool isStart = true;
  static const int animationDurationMs = 750;

  late WeatherInfo weatherInfo;


  @override
  void initState() {
    super.initState();
    weatherAPI.getForecast(searchedLocation).then((value) {
      if (value == null) {
        Fluttertoast.showToast(
            msg: "Error getting weather forecast",
            toastLength: Toast.LENGTH_LONG);
      } else {
        forecast = value;
        if (isStart) {
          Future.delayed(const Duration(milliseconds: animationDurationMs), () {
            setState(() {
              animation = true;
              isStart = false;
            });
          });
        } else {
          animation = true;
        }
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WeatherTeller'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/details');
              },
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
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _cloudIcon(),
              _temperature(),
              _location(),
              _weekList(),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: FloatingActionButton(
              onPressed: _refreesh,
              child: Icon(Icons.refresh),
            ),
          )
        ],
      ),
    );
  }

  _weekList() {
    if (forecast == null) return Container();
    return Padding(
      padding: const EdgeInsets.only(top: 80.0),
      child: SizedBox(
        height: 60.0 * forecast!.days.length,
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
            ? const EdgeInsets.all(4.0)
            : const EdgeInsets.only(top: 10),
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

  _refreesh() {
    setState(() {
      weatherAPI.getForecast("Coimbra").then((value) {
        if (value == null) {
          Fluttertoast.showToast(
              msg: "Error getting weather forecast",
              toastLength: Toast.LENGTH_LONG);
        } else {
          setState(() => forecast = value);
        }
      });
    });
    //_SaveWeatherInfo();
  }

  _temperature() {
    return Column(
      children: [
        Text(
          "${forecast?.currentWeather.temp}",
          style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w100),
        ),
      ],
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
    if (forecast == null) return null;
    return Padding(
      padding: const EdgeInsets.all(8.0),
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

  _SaveWeatherInfo() async {
    var thisDay = forecast!.currentWeather;
    var weekDays = forecast!.days;

    var weather = WeatherInfo(thisDay,weekDays);

    //sharedPref.save("weather", weather);
  }

  _GetWeatherInfo(){
    var weather = sharedPref.read("weather");
    debugPrint(weather);
  }


}

class SharedPref {
  read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return json.decode(prefs.getString(key)!);
  }

  save(String key, value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, json.encode(value));
  }

  remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
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

class WeatherInfo{
  late WeatherInfoMoment today;
  late List<WeatherInfoDay>  week = [];

  WeatherInfo(WeatherInfoMoment thisDay, List<WeatherInfoDay>  weekDays ) {
    today = thisDay;
    week = weekDays;
    JsonHelper helper = JsonHelper();
    var jsonToday = helper.toJsonToday();

  }


}
