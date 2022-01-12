import 'dart:js';

import 'package:flutter/material.dart';
import 'package:weather_teller/WeatherAPI.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WeatherTeller'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/details');
              },
              icon: Icon(Icons.add_location))
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.grey.shade500,
              Colors.blue,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _cloudIcon(),
              _temprature(),
              _location(),
              _date(),
              _weekPrediction(),
            ],
          ),
        ),
      ),
    );
  }

  final days = ['Day 13', 'Day 14', 'Day 15', 'Day 16', 'Day 17'];

  _weekPrediction() {
    return Padding(
      padding: const EdgeInsets.only(top: 80.0),
      child: Container(
        height: 50 * 5,
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: days.length,
          itemBuilder: (context, index) {
            return Container(
              height: 50,
              child: Card(
                child: Center(
                  child: Text('${days[index]}'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  _temprature() {
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
