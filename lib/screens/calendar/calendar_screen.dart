import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarScreen extends StatelessWidget {
  static const String routeName = '/calendar';

  @override
  Widget build(BuildContext context) {
    print('build -> calendar_screen');

    return Scaffold(
      appBar: AppBar(title: Text('Kalendarz')),
      body: SfCalendar(),
    );
  }
}
