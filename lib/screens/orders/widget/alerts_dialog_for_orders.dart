import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:praca_inzynierska/screens/firm/firm_profile_screen.dart';
import 'package:provider/provider.dart';

import '../../../helpers/firebaseHelper.dart';
import '../../../models/users.dart';

AlertDialog buildAlertDialogForChangingStatus({
  @required BuildContext context,
  @required String status,
  @required String docID,
  @required Future<void> Function(String status, String docID) updateStatus,
  @required Widget title,
  Widget content,
  @required Widget cancelButton,
  @required Widget acceptButton,
}) {
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
          updateStatus(status, docID);
        },
      ),
    ],
  );
}

AlertDialog buildAlertDialogForNewMessage({
  @required BuildContext context,
  @required Widget title,
  Widget content,
  @required Widget cancelButton,
  @required Widget acceptButton,
  @required String addressee,
  @required List<String> chatName,
  @required List<String> listID,
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
  @required BuildContext context,
  @required Widget title,
  Widget content,
  @required Widget cancelButton,
  @required Widget acceptButton,
  @required bool isPhoneCall,
  @required String contactData,
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
