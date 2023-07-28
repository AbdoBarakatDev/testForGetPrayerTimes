import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:test_for_eyad/api_service.dart';
import 'package:test_for_eyad/prayer_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

DateTime _selectedValue = DateTime.now();
PrayerModel? prayerModel;
String? selectedDate;

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    selectedDate = _selectedValue.day < 10
        ? "0${_selectedValue.day}"
        : _selectedValue.day.toString();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 100,
                child: DatePicker(
                  DateTime.now(),
                  initialSelectedDate: DateTime.now(),
                  selectionColor: Colors.black,
                  selectedTextColor: Colors.white,
                  onDateChange: (date) async {
                    // New date selected
                    setState(() {
                      log("Selected Date is $_selectedValue");
                      _selectedValue = date;
                    });
                    await ApiServices()
                        .getPrayerTime(_selectedValue)
                        .then((value) {
                      setState(() {
                        prayerModel = value;
                      });
                      if (prayerModel != null) {
                        log(prayerModel!.data![0].timings.toString());
                      }
                      log(" _selectedValue.day.toString() : ${_selectedValue.day.toString()}");
                    });
                  },
                ),
              ),
              SizedBox(
                height: 20,
              ),
              if (prayerModel != null)
                Text(prayerModel!.data!
                    .firstWhere((element) =>
                        (element.date!.gregorian!.day.toString() ==
                            selectedDate))
                    .date!
                    .readable
                    .toString()),
              SizedBox(
                height: 20,
              ),
              if (prayerModel != null)
                Card(
                    child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: drawHijriSection())),
              SizedBox(
                height: 20,
              ),
              if (prayerModel != null)
                Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Column(
                      children: prayerModel!.data!
                          .map(
                            (e) => (e.date!.gregorian!.day == selectedDate)
                                ? Column(
                                    children: [
                                      Text("Fajr :${e.timings!.fajr!}"),
                                      Text("Sunrise :${e.timings!.sunrise!}"),
                                      Text("Dhuhr :${e.timings!.dhuhr!}"),
                                      Text("Asr :${e.timings!.asr!}"),
                                      Text("Maghrib :${e.timings!.maghrib!}"),
                                      Text("Isha :${e.timings!.isha!}"),
                                    ],
                                  )
                                : SizedBox(),
                          )
                          .toList(),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Text drawHijriSection() {
    Hijri hijri = prayerModel!.data!
        .firstWhere((element) =>
            (element.date!.gregorian!.day.toString() == selectedDate))
        .date!
        .hijri!;

    return Text("${hijri.day!} ${hijri.month!.ar} ${hijri.year}");
  }
}
