import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/main.dart';

import 'DataClasses.dart';


class DetailsScreen extends StatefulWidget {
  static const routeName = '/details';

  const DetailsScreen({Key? key}) : super(key: key);

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late final Arguments args = ModalRoute.of(context)!.settings.arguments as Arguments;

  late final WeatherInfoDay day = args.day;
  late final String location = args.location;
  static final DateFormat monthDayFormatter = DateFormat.MMMd();

  bool animation = true;

  static const int animationDurationMs = 500;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("WeatherTeller")),
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
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(location, style: const TextStyle(fontSize: 24)),
                  Text(monthDayFormatter.format(day.date), style: const TextStyle(fontSize: 24)),
                  _iconDay(),
                  //Text(day.weatherState.weatherState, style: const TextStyle(fontSize: 20)),
                  Text(day.description, style: const TextStyle(fontSize: 24)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40.0, top: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Max: ${day.tempMax}º", style: const TextStyle(fontSize: 22)),
                  Text("Min: ${day.tempMin}º", style: const TextStyle(fontSize: 22)),
                  Text("${Intl.message("",name: "probability")}: ${day.rainProb}%", style: const TextStyle(fontSize: 22)),
                  Text("${Intl.message("",name: "wind")}: ${day.windSpeed} Km/h", style: const TextStyle(fontSize: 22)),
                ],
              ),
            ),
            Flexible(child: _hourList())
          ],
        ),
      ),
    );
  }

  _textStyle(){
    return const TextStyle(
      fontSize: 20
    );
  }

  _iconDay() {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: animationDurationMs),
        opacity: animation ? 1 : 0,
        curve: Curves.easeInOutQuart,
        child: Image.network(
          "https://openweathermap.org/img/wn/${day.icon}@4x.png",
          height: 160,
          width: 160,
          scale: 1,
        ),
      ),
    );
  }

  _iconBlock(String icon) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: animationDurationMs),
        opacity: animation ? 1 : 0,
        curve: Curves.easeInOutQuart,
        child: Image.network(
          "https://openweathermap.org/img/wn/$icon@2x.png",
          height: 80,
          width: 80,
          scale: 1,
        ),
      ),
    );
  }

  _hourList(){
    return Container(
      width: 100,
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Scrollbar(
          isAlwaysShown: true,
          child: ListView.separated(
            separatorBuilder: (_, __) => const VerticalDivider(),
            scrollDirection: Axis.horizontal, // TODO this wont work
            itemCount: day.blocks.length,
            itemBuilder: (context, index) {
              return _animatedHourColumn(day.blocks[index]);
            },
          ),
        ),
      ),
    );
  }

  _animatedHourColumn(WeatherInfoMoment block) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: animationDurationMs),
      opacity: animation ? 1 : 0,
      curve: Curves.easeInOutQuart,
      child: AnimatedPadding(
          duration: const Duration(milliseconds: animationDurationMs),
          padding: animation
              ? const EdgeInsets.only(left: 5, right: 5)
              : const EdgeInsets.only(left: 5, right: 5),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("${block.date.hour}H"),
                  Text("${block.tempMax}º"),
                  _iconBlock(block.icon),
                  Text("${Intl.message("",name: "wind")}: ${block.windSpeed} Km/h"),
                ],
              ),
            ),
          ),
      ),
    );
  }
}

