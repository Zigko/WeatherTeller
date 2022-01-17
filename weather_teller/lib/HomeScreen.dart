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
  final OpenWeatherAPI weatherAPI = OpenWeatherAPI(Intl.getCurrentLocale());
  static final DateFormat monthDayFormatter = DateFormat.MMMMd();
  final SharedPref sharedPref = SharedPref();

  final myController = TextEditingController();

  late WeatherInfo weatherInfo;
  WeatherInfoForecast? forecast;

  String searchedLocation = "Coimbra";
  bool animation = false;

  bool typing = false;

  static const int animationDurationMs = 500;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: typing ? _searchText() : Center(child: Text("WeatherTeller")),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/details');
              },
              icon: const Icon(Icons.add_location))
        ],
        leading: IconButton(
          icon: Icon(typing ? Icons.done : Icons.search),
          onPressed: () {
            setState(() {
              typing = !typing;
              var text = myController.text;
              if(text.isNotEmpty && text != searchedLocation){
                searchedLocation = text;
              }
            });
          },
        ),
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _cloudIcon(),
            if (forecast != null)
              Center(
                child: Column(
                  children: [
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
            _weekList(),
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

  _searchText(){
    return TextField(
      controller: myController,
      decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
          hintText: searchedLocation,
          hintStyle: const TextStyle(color: Colors.grey),
          fillColor: Colors.white
      ),
      style: const TextStyle(
        fontSize: 20.0,
        //height: 1.0,
        color: Colors.white,
      ),
    );
  }

  _weekList() {
    if (forecast == null) return Container();
    return Padding(
      padding: const EdgeInsets.only(top: 80, left: 20, right: 20),
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

  _refresh() {
    animation = false;
    weatherAPI.getForecast(searchedLocation).then((value) {
      if (value == null) {
        Fluttertoast.showToast(
            msg: "Error getting weather forecast",
            toastLength: Toast.LENGTH_LONG);
      } else {
        forecast = value;
        setState(() {});
        Future.delayed(const Duration(milliseconds: animationDurationMs), () {
          setState(() {
            animation = true;
          });
        });
      }
    });
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

    var weather = WeatherInfo(thisDay, weekDays);

    //sharedPref.save("weather", weather);
  }

  _GetWeatherInfo() {
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

class WeatherInfo {
  late WeatherInfoMoment today;
  late List<WeatherInfoDay> week = [];

  WeatherInfo(WeatherInfoMoment thisDay, List<WeatherInfoDay> weekDays) {
    today = thisDay;
    week = weekDays;
    JsonHelper helper = JsonHelper();
    var jsonToday = helper.toJsonToday();
  }
}
