import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:praca_inzynierska/models/users.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../models/meeting.dart';
import 'meeting_data_source.dart';

class CalendarScreen extends StatefulWidget {
  static const String routeName = '/calendar';

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CalendarController _controller = CalendarController();

  bool _isSchedule = false;

  @override
  void initState() {
    super.initState();
    _controller.view = CalendarView.month;
  }

  @override
  Widget build(BuildContext context) {
    print('build -> calendar_screen');
    UserType userType =
        Provider.of<UserProvider>(context, listen: false).user.type;
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    String collectionString = userType == UserType.Firm ? 'firms' : 'users';

    return Scaffold(
      appBar: AppBar(title: Text('Kalendarz')),
      floatingActionButton: FloatingActionButton(
        child:
            Icon(_isSchedule ? Icons.schedule_outlined : Icons.today_outlined),
        onPressed: () => setState(() {
          _isSchedule = !_isSchedule;
          _controller.view =
              _isSchedule ? CalendarView.schedule : CalendarView.month;
        }),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection(collectionString)
            .doc(currentUserId)
            .collection('meetings')
            .get(),
        builder: (
          BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            return SfCalendar(
              controller: _controller,
              firstDayOfWeek: 1,
              dataSource: MeetingDataSource(snapshot.data!.docs
                  .map((e) => Meeting.fromJson(e.data()))
                  .toList()),
              appointmentTimeTextFormat: 'HH:mm',
              showCurrentTimeIndicator: true,
              initialSelectedDate: DateTime.now(),
              showDatePickerButton: true,
              monthViewSettings: MonthViewSettings(
                showAgenda: true,
                appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
              ),
              headerDateFormat: 'LLLL  yyy',
              onLongPress: (CalendarLongPressDetails details) {
                DateTime date = details.date!;
                CalendarResource? resource = details.resource;
                dynamic appointments = details.appointments?.first.eventName;
                CalendarElement view = details.targetElement;
                print('''
-----------------
Date: $date
Appointments: $appointments
View: $view
Resource: $resource
''');
              },
            );
          }
        },
      ),
    );
  }
}

List<Meeting> _getDataSource() {
  final List<Meeting> meetings = [];
  final DateTime today = DateTime.now();
  final DateTime startTime =
  DateTime(today.year, today.month, today.day, 9, 0, 0);

  meetings.add(Meeting(
      eventName: 'Spotkanie',
      from: startTime.add(const Duration(days: 4)),
      to: startTime.add(const Duration(days: 6)),
      background: Colors.red));
  meetings.add(Meeting(
      eventName: 'Spotkanie',
      from: startTime.add(const Duration(hours: 2)),
      to: startTime.add(const Duration(hours: 5)),
      background: Colors.greenAccent));
  meetings.add(Meeting(
      eventName: 'Spotkanie',
      from: startTime,
      to: startTime.add(const Duration(hours: 2)),
      background: Colors.lightBlue));
  meetings.add(Meeting(
    eventName: 'Spotkanie',
    from: startTime.subtract(const Duration(hours: 2)),
    to: startTime,
    background: Colors.orangeAccent,
  ));
  meetings.add(Meeting(
    eventName: 'Spotkanie',
    from: startTime.subtract(const Duration(hours: 5)),
    to: startTime.subtract(const Duration(hours: 4)),
    background: Colors.yellow,
  ));
  return meetings;
}
