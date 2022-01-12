import 'dart:js';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_teller/WeatherAPI.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  //TODO put language and use INTL
  final WeatherAPI weatherAPI = WeatherAPI("pt");

  WeatherInfoForecast? forecast;

  @override
  void initState() {
    super.initState();
    var forecastTask = weatherAPI.getForecast("Coimbra");
    forecastTask.then((value) {
      setState(() {
        forecast = value;
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
              _date(),
              _weekList(),
            ],
          ),
        ),
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
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("${model.weekday}, ${model.monthDay}"),
                  Image.network(model.imgPath),
                  Text(model.temps),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  _temperature() {
    return Column(
      //crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          '-10',
          style: TextStyle(fontSize: 80, fontWeight: FontWeight.w100),
        ),
      ],
    );
  }

  _location() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      //crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        Icon(Icons.place),
        SizedBox(
          width: 20,
        ),
        Text('Coimbra, Portugal'),
      ],
    );
  }

  _date() {
    return Column(
      children: const [
        SizedBox(
          width: 20,
        ),
        Text('12/01/2021'),
      ],
    );
  }

  _cloudIcon() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Icon(
        Icons.cloud,
        size: 80,
      ),
    );
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
