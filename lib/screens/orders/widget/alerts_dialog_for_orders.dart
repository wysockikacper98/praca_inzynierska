import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:praca_inzynierska/models/meeting.dart';
import 'package:praca_inzynierska/screens/calendar/meeting_data_source.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../helpers/firebase_firestore.dart';
import '../../../models/order.dart';
import '../../../models/users.dart';
import '../../firm/firm_profile_screen.dart';

AlertDialog buildAlertDialogForNewMessage({
  required BuildContext context,
  required Widget title,
  Widget? content,
  required Widget cancelButton,
  required Widget acceptButton,
  required String addressee,
  required List<String> chatName,
  required List<String> listID,
}) {
  final currentLoggedUser =
      Provider.of<UserProvider>(context, listen: false).user;

  return AlertDialog(
    title: title,
    content: content,
    elevation: 24.0,
    actions: [
      TextButton(
        child: cancelButton,
        onPressed: () => Navigator.of(context).pop(),
      ),
      TextButton(
        child: acceptButton,
        onPressed: () {
          Navigator.of(context).pop();
          createOrOpenChat(
            context,
            currentLoggedUser!,
            addressee,
            chatName,
            listID,
          );
        },
      ),
    ],
  );
}

AlertDialog buildAlertDialogForPhoneCallAndEmail({
  required BuildContext context,
  required Widget title,
  Widget? content,
  required Widget cancelButton,
  required Widget acceptButton,
  required bool isPhoneCall,
  required String contactData,
}) {
  return AlertDialog(
    title: title,
    content: content,
    elevation: 24,
    actions: [
      TextButton(
        child: cancelButton,
        onPressed: () => Navigator.of(context).pop(),
      ),
      TextButton(
        child: acceptButton,
        onPressed: () async {
          Navigator.of(context).pop();
          isPhoneCall
              ? callPhone('tel:$contactData')
              : sendEmail(
                  Uri(
                    scheme: 'mailto',
                    path: contactData,
                  ).toString(),
                );
        },
      ),
    ],
  );
}

AlertDialog buildAlertDialogForCancelingOrder(
  BuildContext context,
  String id,
) {
  return AlertDialog(
    title: Text('Anulować zamówienie?'),
    content: Text('Anulowanie zamówienia jest operacją nieodwracalną.'),
    elevation: 24,
    actions: [
      TextButton(
        child: Text('Nie'),
        onPressed: () => Navigator.of(context).pop(),
      ),
      TextButton(
        child: Text('Tak'),
        onPressed: () => _cancelOrder(context, id),
      ),
    ],
  );
}

AlertDialog buildAlertDialogForStartingOrder(
  BuildContext context,
  String id,
  Future<void> Function(BuildContext context, String id) startOrder,
) {
  return AlertDialog(
    title: Text('Rozpocznij wykonywanie zamówienia'),
    elevation: 24.0,
    actions: [
      TextButton(
        child: Text('Anuluj'),
        onPressed: () => Navigator.of(context).pop(),
      ),
      TextButton(
        child: Text('Rozpocznij'),
        onPressed: () => startOrder(context, id),
      ),
    ],
  );
}

AlertDialog buildAlertDialogForFinishingOrder(
  BuildContext context,
  String id,
  Future<void> Function(BuildContext context, String id) finishOrder,
) {
  return AlertDialog(
    title: Text('Zakończyć wykonywanie zamówienia?'),
    content: Text(
        'Zakończenie zamówienia jest nieodwracalne. Upewnij się, że wszystkie prace z nim związane zostały zakończone.'),
    elevation: 24.0,
    actions: [
      TextButton(
        child: Text('Nie'),
        onPressed: () => Navigator.of(context).pop(),
      ),
      TextButton(
        child: Text('Zakończ'),
        onPressed: () => finishOrder(context, id),
      ),
    ],
  );
}

Future<void> _cancelOrder(
  BuildContext context,
  String id,
) async {
  Navigator.of(context).pop();
  await FirebaseFirestore.instance
      .collection('orders')
      .doc(id)
      .update({'status': Status.COMPLETED.toString().split('.').last});
  Navigator.of(context).pop();
}

class BuildAlertDialogForDatePicker extends StatefulWidget {
  final List<ColorSwatch> _colors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];
  final void Function(PickerDateRange range) setRange;
  final void Function(Color color) setColor;

  BuildAlertDialogForDatePicker(this.setRange, this.setColor);

  @override
  _BuildAlertDialogForDatePickerState createState() =>
      _BuildAlertDialogForDatePickerState();
}

class _BuildAlertDialogForDatePickerState
    extends State<BuildAlertDialogForDatePicker> {
  late Color _selectedColor;

  final DateTime _today = DateTime.now();
  final DateTime _theDayAfterTomorrow = DateTime.now().add(Duration(days: 2));

  late Future<QuerySnapshot<Map<String, dynamic>>> _future;
  late PickerDateRange _pickedDate;

  @override
  void initState() {
    super.initState();
    _selectedColor = Colors.green;

    _future = FirebaseFirestore.instance
        .collection('firms')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('meetings')
        .get();
    _pickedDate = PickerDateRange(
      DateTime(_today.year, _today.month, _today.day),
      DateTime(
        _theDayAfterTomorrow.year,
        _theDayAfterTomorrow.month,
        _theDayAfterTomorrow.day,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double grayscale = (0.299 * _selectedColor.red) +
        (0.587 * _selectedColor.green) +
        (0.114 * _selectedColor.blue);
    final double _height = MediaQuery.of(context).size.height;

    final _isSelectedColorLight = grayscale > 128;

    return Scaffold(
      appBar: AppBar(title: Text('Wybierz okres zamówienia')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.edit,
                    color: _isSelectedColorLight ? Colors.black : Colors.white,
                  ),
                  label: Text(
                    ' Wybierz kolor zamówienia',
                    style: TextStyle(
                      color:
                          _isSelectedColorLight ? Colors.black : Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(primary: _selectedColor),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Wybierz kolor zamówienia'),
                      content: MaterialColorPicker(
                        selectedColor: _selectedColor,
                        colors: widget._colors,
                        onColorChange: (value) {
                          //   setState(() {
                          _selectedColor = value;
                                  //   });
                                  //   widget.setColor(value);
                                },
                              ),
                              actions: [
                                TextButton(
                                    child: Text('Ok'),
                                    onPressed: () {
                                      setState(() {});
                                      Navigator.of(context).pop();
                                    }),
                              ],
                            ),
                      ),
                ),
              ),
            ),
            SizedBox(height: 16),
            // FIXME: Testowy kalenarz
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
                      initialSelectedDate: null,
                      selectionDecoration: BoxDecoration(),
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
                        //IMPORTANT: Rysowanie pomiędzy dniami
                        if (details.date.isAfter(_pickedDate.startDate!) &&
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
                        } else if (details.date
                                .isAtSameMomentAs(_pickedDate.startDate!) &&
                            details.date
                                .isAtSameMomentAs(_pickedDate.endDate!)) {
                          // IMPORTANT: selected only one date
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
                          // IMPORTANT: is start day
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
                          // IMPORTANT: is end day
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
                                )),
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
            SizedBox(height: 16),
            Container(
              color: Colors.white,
              child: SfDateRangePicker(
                showActionButtons: true,
                cancelText: 'Anuluj',
                confirmText: 'Potwierdź',
                showNavigationArrow: true,
                enablePastDates: false,
                rangeSelectionColor: _selectedColor.withOpacity(0.3),
                startRangeSelectionColor: _selectedColor,
                endRangeSelectionColor: _selectedColor,
                initialSelectedRange: PickerDateRange(
                  DateTime.now(),
                  DateTime.now().add(Duration(days: 2)),
                ),
                monthViewSettings:
                DateRangePickerMonthViewSettings(firstDayOfWeek: 1),
                selectionMode: DateRangePickerSelectionMode.range,
                onCancel: () => Navigator.of(context).pop(),
                onSubmit: (value) async {
                  if (value is PickerDateRange) {
                    if (value.endDate == null) {
                      final TimeOfDay? timeFrom = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        helpText: 'WYBIERZ GODZINĘ ROZPOCZĘCIA',
                        builder: (BuildContext context, Widget? child) {
                          return MediaQuery(
                            data: MediaQuery.of(context)
                                .copyWith(alwaysUse24HourFormat: true),
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
                      if (timeFrom != null && timeTo != null) {
                        if (timeOfDayIsAfter(
                            context: context,
                            timeFrom: timeFrom,
                            timeTo: timeTo)) {
                          widget.setRange(
                            PickerDateRange(
                              DateTime(
                                value.startDate!.year,
                                value.startDate!.month,
                                value.startDate!.day,
                                timeFrom.hour,
                                timeFrom.minute,
                              ),
                              DateTime(
                                value.startDate!.year,
                                value.startDate!.month,
                                value.startDate!.day,
                                timeTo.hour,
                                timeTo.minute,
                              ),
                            ),
                          );
                        }
                        Navigator.of(context).pop();
                        return;
                      }
                    }
                    widget.setRange(value);
                  }
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateSelectedDate(CalendarTapDetails value) {
    if (value.date!.isBefore(DateTime.now())) {
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

bool timeOfDayIsAfter({
  required BuildContext context,
  required TimeOfDay timeFrom,
  required TimeOfDay timeTo,
}) {
  if (timeOfDayToDouble(timeFrom) < timeOfDayToDouble(timeTo)) {
    return true;
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
            'Błędnie podane godziny usługi. Godzina rozpoczęcia po godzienie końca.'),
      ),
    );
    return false;
  }
}

double timeOfDayToDouble(TimeOfDay myTime) =>
    myTime.hour + myTime.minute / 60.0;
