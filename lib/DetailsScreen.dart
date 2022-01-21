import 'package:flutter/cupertino.dart';
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
  late final Arguments args =
  ModalRoute
      .of(context)!
      .settings
      .arguments as Arguments;

  late final WeatherInfoDay day = args.day;
  late final String location = args.location;
  static final DateFormat monthDayFormatter = DateFormat.MMMd();

  bool animation = true;

  static const int animationDurationMs = 1000;

  ScrollController controller = ScrollController();

  TextStyle style20 = const TextStyle(fontSize: 18);
  TextStyle style24 = const TextStyle(fontSize: 24);

  int index = 0;
  late WeatherInfoMoment thisDay = WeatherInfoMoment(
      day.date,
      0,
      day.tempMax,
      day.tempMin,
      day.humidity,
      day.weatherState,
      day.description,
      day.icon,
      day.windSpeed,
      day.rainProb);
  late WeatherInfoMoment moment = WeatherInfoMoment(
      day.date,
      0,
      day.tempMax,
      day.tempMin,
      day.humidity,
      day.weatherState,
      day.description,
      day.icon,
      day.windSpeed,
      day.rainProb);

  @override
  void initState() {
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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                moment = thisDay;
                setState(() {

                });
              },
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(location, style: style24),
                    Text(monthDayFormatter.format(moment.date), style: style24),
                    _iconDay(),
                    Text(moment.description, style: style24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40.0, top: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if(moment.tempMin == moment.tempMax)...[
                    Text("Temp: ${moment.tempMax}º", style: style20),
                  ] else
                    ... [
                      Text("Max: ${moment.tempMax}º", style: style20),
                      Text("Min: ${moment.tempMin}º", style: style20),
                    ],
                  Text(
                      "${Intl.message("", name: "probability")}: ${moment
                          .rainProb}%",
                      style: style20),
                  Text(
                      "${Intl.message("", name: "wind")}: ${moment
                          .windSpeed} Km/h",
                      style: style20),
                  Text(
                      "${Intl.message("", name: "humidity")}: ${moment
                          .humidity}%",
                      style: style20),
                ],
              ),
            ),
            SizedBox(height: 180, child: _hourList())
          ],
        ),
      ),
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
          "https://openweathermap.org/img/wn/${moment.icon}@4x.png",
          height: 130,
          width: 130,
          scale: 1,
        ),
      ),
    );
  }

  _iconBlock(String icon) {
    return Image.network(
      "https://openweathermap.org/img/wn/$icon@2x.png",
      height: 80,
      width: 80,
      scale: 1,
    );
  }

  _hourList() {
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Scrollbar(
          controller: controller,
          child: ListView.separated(
            shrinkWrap: true,
            separatorBuilder: (_, __) => const VerticalDivider(),
            controller: controller,
            scrollDirection: Axis.horizontal,
            // TODO this wont work
            itemCount: day.blocks.length,
            itemBuilder: (context, index) {
              return _animatedHourColumn(day.blocks[index]);
            },
          ),
        ));
  }

  _animatedHourColumn(WeatherInfoMoment block) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: animationDurationMs),
      opacity: animation ? 1 : 0,
      curve: Curves.easeInOutQuart,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: animationDurationMs),
        padding: animation
            ? const EdgeInsets.only(top: 5)
            : const EdgeInsets.only(top: 15),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            moment = block;
            setState(() {});
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("${block.date.hour}H"),
              Text("${block.tempMax}º"),
              Image.network(
                "https://openweathermap.org/img/wn/${block.icon}@2x.png",
                height: 80,
                width: 80,
                scale: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

}
