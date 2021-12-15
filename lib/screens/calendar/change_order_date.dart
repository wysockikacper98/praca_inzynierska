import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:praca_inzynierska/screens/orders/widget/alerts_dialog_for_orders.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../helpers/colorful_print_messages.dart';
import '../../models/meeting.dart';
import 'meeting_data_source.dart';

class ChangeOrderDate extends StatefulWidget {
  final PickerDateRange _defaultPickedDate;
  final String _orderID;
  final void Function() _refresh;

  ChangeOrderDate(this._defaultPickedDate, this._orderID, this._refresh);

  @override
  _ChangeOrderDateState createState() => _ChangeOrderDateState();
}

class _ChangeOrderDateState extends State<ChangeOrderDate> {
  late Future<QuerySnapshot<Map<String, dynamic>>> _future;
  late PickerDateRange _pickedDate;
  late Color _selectedColor;

  final String currentFirm = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();

    _selectedColor = Colors.deepPurple;

    _future = FirebaseFirestore.instance
        .collection('firms')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('meetings')
        .get();

    _pickedDate = widget._defaultPickedDate;
  }

  @override
  Widget build(BuildContext context) {
    final double grayscale = (0.299 * _selectedColor.red) +
        (0.587 * _selectedColor.green) +
        (0.114 * _selectedColor.blue);

    final _isSelectedColorLight = grayscale > 128;

    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          'Wybierz nowy okres zamówienia',
          maxLines: 1,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: changeOrderAndMeetingsDate,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder(
              future: _future,
              builder: (
                BuildContext context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
              ) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  return Container(
                    height: 500,
                    child: SfCalendar(
                      view: CalendarView.month,
                      firstDayOfWeek: 1,
                      dataSource: MeetingDataSource(snapshot.data!.docs
                          .map((e) => Meeting.fromJson(e.data()))
                          .toList()),
                      appointmentTimeTextFormat: 'HH:mm',
                      showCurrentTimeIndicator: true,
                      selectionDecoration: BoxDecoration(),
                      initialSelectedDate: widget._defaultPickedDate.startDate,
                      showDatePickerButton: true,
                      monthViewSettings: MonthViewSettings(
                        showAgenda: true,
                        appointmentDisplayMode:
                            MonthAppointmentDisplayMode.indicator,
                      ),
                      headerDateFormat: 'LLLL  yyy',
                      onTap: _updateSelectedDate,
                      monthCellBuilder: (BuildContext buildContext,
                          MonthCellDetails details) {
                        // Nieaktywne dni
                        if (details.date.isBefore(
                            DateTime.now().subtract(Duration(days: 1)))) {
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 0.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                details.date.day.toString(),
                                style: TextStyle(
                                    color: Colors.black.withAlpha(100)),
                              ),
                            ),
                          );
                        }
                        //Rysowanie pomiędzy dniami
                        else if (details.date.isAfter(_pickedDate.startDate!) &&
                            details.date.isBefore(_pickedDate.endDate!)) {
                          return Container(
                            decoration: BoxDecoration(
                              color: _selectedColor.withAlpha(100),
                            ),
                            child: Center(
                              child: Text(
                                details.date.day.toString(),
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          );
                        } else if (details.date.isAtSameMomentAs(
                                DateUtils.dateOnly(_pickedDate.startDate!)) &&
                            details.date.isAtSameMomentAs(
                                DateUtils.dateOnly(_pickedDate.endDate!))) {
                          // Selected only one date
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _selectedColor,
                            ),
                            child: Center(
                              child: Text(
                                details.date.day.toString(),
                                style: TextStyle(
                                  color: _isSelectedColorLight
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            ),
                          );
                        } else if (details.date
                            .isAtSameMomentAs(_pickedDate.startDate!)) {
                          // Is start day
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40),
                                bottomLeft: Radius.circular(40),
                              ),
                              color: _selectedColor,
                            ),
                            child: Center(
                              child: Text(
                                details.date.day.toString(),
                                style: TextStyle(
                                  color: _isSelectedColorLight
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            ),
                          );
                        } else if (details.date
                            .isAtSameMomentAs(_pickedDate.endDate!)) {
                          // Is end day
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(40),
                                bottomRight: Radius.circular(40),
                              ),
                              color: _selectedColor,
                            ),
                            child: Center(
                              child: Text(
                                details.date.day.toString(),
                                style: TextStyle(
                                  color: _isSelectedColorLight
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            ),
                          );
                        } else
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 0.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                details.date.day.toString(),
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          );
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> changeOrderAndMeetingsDate() async {
    printColor(
      text: 'OrderID: ${widget._orderID}',
      color: PrintColor.cyan,
    );
    printColor(
      text: 'FirmID: $currentFirm',
      color: PrintColor.green,
    );

    if (DateUtils.dateOnly(_pickedDate.startDate!)
        .isAtSameMomentAs(DateUtils.dateOnly(_pickedDate.endDate!))) {
      final TimeOfDay? timeFrom = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        helpText: 'WYBIERZ GODZINĘ ROZPOCZĘCIA',
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );

      final TimeOfDay? timeTo = timeFrom != null
          ? await showTimePicker(
              context: context,
              initialTime: timeFrom,
              helpText: 'WYBIERZ GODZINĘ ZAKOŃCZENIA',
              builder: (BuildContext context, Widget? child) {
                return MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(alwaysUse24HourFormat: true),
                  child: child!,
                );
              },
            )
          : null;

      if (timeFrom == null || timeTo == null) {
        printColor(
            text: 'Wybrano zła godzinę lub przerwano wybieranie',
            color: PrintColor.red);
        return;
      }

      if (timeOfDayIsAfter(
        context: context,
        timeFrom: timeFrom,
        timeTo: timeTo,
      )) {
        _pickedDate = PickerDateRange(
          DateTime(
            _pickedDate.startDate!.year,
            _pickedDate.startDate!.month,
            _pickedDate.startDate!.day,
            timeFrom.hour,
            timeFrom.minute,
          ),
          DateTime(
            _pickedDate.endDate!.year,
            _pickedDate.endDate!.month,
            _pickedDate.endDate!.day,
            timeTo.hour,
            timeTo.minute,
          ),
        );
      }
    }

    printColor(
      text: 'New date: $_pickedDate',
      color: PrintColor.magenta,
    );
    try {
      //get meetingId info
      late final String meetingsId;
      await FirebaseFirestore.instance
          .collection('firms')
          .doc(currentFirm)
          .collection('meetings')
          .where('orderId', isEqualTo: widget._orderID.toString())
          .get()
          .then((value) => meetingsId = value.docs.first.id);

      //update Order
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget._orderID)
          .update({
        'dateFrom': _pickedDate.startDate,
        'dateTo': _pickedDate.endDate,
      });

      //update meetings
      await FirebaseFirestore.instance
          .collection('firms')
          .doc(currentFirm)
          .collection('meetings')
          .doc(meetingsId)
          .update({
        'from': _pickedDate.startDate,
        'to': _pickedDate.endDate,
      });

      widget._refresh();
      Navigator.of(context).pop();
    } catch (e) {
      printColor(text: e.toString(), color: PrintColor.red);
    }
  }

  void _updateSelectedDate(CalendarTapDetails value) {
    if (value.date!.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
      return;
    }

    //Postępowanie gdy wybrany 1 dzień
    if (_pickedDate.startDate!.isAtSameMomentAs(_pickedDate.endDate!)) {
      if (_pickedDate.startDate!.isBefore(value.date!)) {
        setState(() {
          _pickedDate = PickerDateRange(_pickedDate.startDate, value.date);
        });
      } else {
        setState(() {
          _pickedDate = PickerDateRange(value.date, _pickedDate.endDate);
        });
      }
    } else {
      // IMPORTANT: Wybrane 2 różne daty
      setState(() {
        _pickedDate = PickerDateRange(value.date, value.date);
      });
    }
  }
}
