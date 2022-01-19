import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'DataClasses.dart';


class DetailsScreen extends StatefulWidget {
  static const routeName = '/details';

  const DetailsScreen({Key? key}) : super(key: key);

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late final WeatherInfoDay day = ModalRoute.of(context)!.settings.arguments as WeatherInfoDay;

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
                  Text("Coimbra"),
                  Text(monthDayFormatter.format(day.date)),
                  _icon(),
                  Text(day.weatherState.weatherState),
                  Text(day.description),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Max: ${day.tempMax}º"),
                Text("Min: ${day.tempMin}º"),
                Text("Probability: ${day.rainProb}º"),
                Text("Wind: ${day.windSpeed}º"),
              ],
            ),
            Flexible(child: _hourList())
          ],
        ),
      ),
    );
  }

  _icon() {
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

  _hourList(){
    return Padding(
      padding: const EdgeInsets.only(left: 50),
      child: Scrollbar(
        child: ListView.separated(
          separatorBuilder: (_, __) => const Divider(),
          scrollDirection: Axis.horizontal,
          itemCount: day.blocks.length,
          itemBuilder: (context, index) {
            //var model = hourModel(day.blocks[index]);
            return _animatedHourColumn(day.blocks[index]);
          },
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
              ? const EdgeInsets.only(left: 20, right: 20)
              : const EdgeInsets.only(left: 20, right: 20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${block.date.hour}:${block.date.minute}"),
                Text("${block.tempMax}º"),
                //Image.network(block.icon),
                Text(block.icon),
                Text("${block.tempMin}º"),
              ],
            ),
          ),
      ),
    );
  }
}

