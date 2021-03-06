import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    title: Text('Anulowa?? zam??wienie?'),
    content: Text('Anulowanie zam??wienia jest operacj?? nieodwracaln??.'),
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
    title: Text('Rozpocznij wykonywanie zam??wienia'),
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
    title: Text('Zako??czy?? wykonywanie zam??wienia?'),
    content: Text(
        'Zako??czenie zam??wienia jest nieodwracalne. Upewnij si??, ??e wszystkie prace z nim zwi??zane zosta??y zako??czone.'),
    elevation: 24.0,
    actions: [
      TextButton(
        child: Text('Nie'),
        onPressed: () => Navigator.of(context).pop(),
      ),
      TextButton(
        child: Text('Zako??cz'),
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
            'B????dnie podane godziny us??ugi. Godzina rozpocz??cia po godzienie ko??ca.'),
      ),
    );
    return false;
  }
}

double timeOfDayToDouble(TimeOfDay myTime) =>
    myTime.hour + myTime.minute / 60.0;
