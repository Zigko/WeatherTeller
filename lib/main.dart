import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:weather/DetailsScreen.dart';
import 'package:weather/HomeScreen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'DataClasses.dart';
import 'WeatherAPI.dart';
import 'generated/l10n.dart';

void main() {
  //Intl.defaultLocale = Platform.localeName;
  // initializeDateFormatting(Intl.defaultLocale).then((value) {
  runApp(const MyApp());
  // });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Teller',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.blue,
      ),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        DetailsScreen.routeName : (_) => const DetailsScreen(),
      },

    );
  }
}

class Arguments{
  late WeatherInfoDay day;
  late String location;

  Arguments(this.day, this.location);
}
