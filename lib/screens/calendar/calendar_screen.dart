import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../models/meeting.dart';
import '../../models/users.dart';
import '../orders/order_details_screen.dart';
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
        Provider.of<UserProvider>(context, listen: false).user!.type;
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    String collectionString = userType == UserType.Firm ? 'firms' : 'users';

    return Scaffold(
      appBar: AppBar(title: Text('Kalendarz')),
      floatingActionButton: FloatingActionButton(
        child: Icon(_isSchedule ? Icons.today : Icons.calendar_view_day),
        onPressed: () => setState(() {
          _isSchedule = !_isSchedule;
          _controller.view =
              _isSchedule ? CalendarView.schedule : CalendarView.month;
        }),
      ),
      body: FutureBuilder(
        // TODO: zastanowić się czy nie wypadało by ograniczyć ilość zapytań do 2 obecnych miesięcy, sam kalendarz powinien mieć wbudowane wsparcie do tego
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
              onTap: (CalendarTapDetails details) {
                if (details.targetElement == CalendarElement.appointment) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailsScreen(
                          orderID: details.appointments!.first.orderId),
                    ),
                  );
                }
              },
              scheduleViewMonthHeaderBuilder: (
                BuildContext buildContext,
                ScheduleViewMonthHeaderDetails details,
              ) {
                final String monthName = _getMonthDate(details.date.month);
                return Stack(
                  children: [
                    //TODO: dodać zdjęcia w wioku podglądu kalendarza
                    Image(
                      // image: ExactAssetImage(
                      //     'assets/images/monthImages' + monthName + '.png'),
                      image: ExactAssetImage('assets/images/tempPicture3.png'),
                      fit: BoxFit.cover,
                      width: details.bounds.width,
                      height: details.bounds.height,
                    ),
                    Positioned(
                      left: 55,
                      right: 0,
                      top: 20,
                      bottom: 0,
                      child: Text(
                        monthName + ' ' + details.date.year.toString(),
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }

  String _getMonthDate(int month) {
    switch (month) {
      case 1:
        return 'Styczeń';
      case 2:
        return 'Luty';
      case 3:
        return 'Marzec';
      case 4:
        return 'Kwiecień';
      case 5:
        return 'Maj';
      case 6:
        return 'Czerwiec';
      case 7:
        return 'Lipiec';
      case 8:
        return 'Sierpień';
      case 9:
        return 'Wrzesień';
      case 10:
        return 'Październik';
      case 11:
        return 'Listopad';
      case 12:
        return 'Grudzień';
    }
    return '';
  }
}
