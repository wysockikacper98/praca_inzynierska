import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../helpers/firebaseHelper.dart';
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
            currentLoggedUser,
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

AlertDialog buildAlertDialogForDatePicker(
    BuildContext context, void Function(PickerDateRange range) setRange) {
  return AlertDialog(
    title: Text('Wybierz okres trwania zamówienia'),
    content: Container(
      width: 300,
      child: SfDateRangePicker(
        showActionButtons: true,
        cancelText: 'Anuluj',
        confirmText: 'Potwierdź',
        showNavigationArrow: true,
        enablePastDates: false,
        initialSelectedRange: PickerDateRange(
          DateTime.now(),
          DateTime.now().add(Duration(days: 2)),
        ),
        monthViewSettings: DateRangePickerMonthViewSettings(firstDayOfWeek: 1),
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
                    context: context, timeFrom: timeFrom, timeTo: timeTo)) {
                  setRange(
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
            setRange(value);
          }
          Navigator.of(context).pop();
        },
      ),
    ),
  );
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
