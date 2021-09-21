import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:praca_inzynierska/models/order.dart';
import 'package:praca_inzynierska/screens/orders/widget/widgets_for_order_screens.dart';
import 'package:provider/provider.dart';

import '../../models/firm.dart';
import '../../models/users.dart';
import 'widget/alerts_dialog_for_orders.dart';

class OrderDetailsScreen extends StatefulWidget {
  static const String routeName = '/order-details';

  final String orderID;
  final String userOrFirmID;

  OrderDetailsScreen({this.orderID, this.userOrFirmID});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Users userToShowInDetails;
  Firm firmToShowInDetails;
  List<String> chatName;
  List<String> idList;

  Future<DocumentSnapshot<Map<String, dynamic>>> _getOrderDetails(
    UserType userType,
  ) async {
    final String currentUserID = FirebaseAuth.instance.currentUser.uid;
    final String collection = userType == UserType.Firm ? 'users' : 'firms';
    final DocumentSnapshot<Map<String, dynamic>> dataFromFirebase =
        await FirebaseFirestore.instance
            .collection(collection)
            .doc(widget.userOrFirmID)
            .get();

    if (userType == UserType.Firm) {
      userToShowInDetails = Users.fromJson(dataFromFirebase.data());
      //creating list of ids
      idList = [dataFromFirebase.id, currentUserID];
      idList.forEach((e) => print(e));
      // creating chat name
      final firm = Provider.of<FirmProvider>(context, listen: false).firm;
      chatName = [
        '${userToShowInDetails.lastName} ${userToShowInDetails.firstName}',
        '${firm.lastName} ${firm.firstName}, ${firm.firmName}',
      ];
    } else {
      firmToShowInDetails = Firm.fromJson(dataFromFirebase.data());
      //creating list of ids
      idList = [
        currentUserID,
        dataFromFirebase.id,
      ];
      //creating chat name
      final user = Provider.of<UserProvider>(context, listen: false).user;
      chatName = [
        '${user.lastName} ${user.firstName}',
        '${firmToShowInDetails.lastName} ${firmToShowInDetails.firstName}, ${firmToShowInDetails.firmName}',
      ];
    }

    return FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderID)
        .get();
  }

  Future<void> _updateStatus(String status, String docID) {
    return FirebaseFirestore.instance
        .collection('orders')
        .doc(docID)
        .update({'status': '$status'}).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);
    final UserType userType = provider.user.type;

    return Scaffold(
      appBar: AppBar(title: Text('Szczegóły zamówienia')),
      body: FutureBuilder(
        future: _getOrderDetails(userType),
        builder: (
          ctx,
          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData) {
            return buildErrorMessage(context);
          } else {
            return Column(
              children: [
                SizedBox(height: 10),
                userType == UserType.Firm
                    ? _createUserToShowInDetails(
                        context,
                        provider,
                        userToShowInDetails,
                      )
                    : _createFirmToShowInDetails(
                        context,
                        provider,
                        firmToShowInDetails,
                      ),
                _buildTextNormalThenBold(
                  context: context,
                  normal: 'Rodzaj usługi: ',
                  bold: snapshot.data.data()['category'],
                ),
                _buildTextNormalThenBold(
                  context: context,
                  normal: 'Status usługi: ',
                  bold: translateStatusEnumStringToString(
                      snapshot.data.data()['status']),
                ),
                _buildTextNormalThenBold(
                  context: context,
                  normal: 'Tytuł: ',
                  bold: snapshot.data.data()['title'],
                ),
                _buildDescription(context, snapshot),
                //TODO: wyświetlanie okresu / dnia wykonania zamówienia
                _buildDatePreview(),
                SizedBox(height: 16),
                _buildContactButtons(
                  context: context,
                  snapshot: snapshot,
                  userType: userType,
                  chatName: chatName,
                  listID: idList,
                  contactPhoneNumber: userType == UserType.Firm
                      ? userToShowInDetails.telephone
                      : firmToShowInDetails.telephone,
                  contactEmail: userType == UserType.Firm
                      ? userToShowInDetails.email
                      : firmToShowInDetails.email,
                ),
                SizedBox(height: 16),
                _buildButtonsDependingOnStatus(context, snapshot),
              ],
            );
          }
        },
      ),
    );
  }

  Center _buildDatePreview() {
    return Center(
      child: Text(
        'Tutaj wyświetlać dzień / okres wykonania usługi',
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  Padding _buildDescription(
    BuildContext context,
    AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Opis:',
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              snapshot.data.data()['description'] != null
                  ? snapshot.data.data()['description']
                  : 'Brak opisu',
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ],
        ),
      ),
    );
  }

  Padding _buildTextNormalThenBold({
    BuildContext context,
    String normal,
    String bold,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        child: RichText(
          text: TextSpan(
            text: normal,
            style: Theme.of(context).textTheme.subtitle1,
            children: [
              TextSpan(
                text: bold,
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtonsDependingOnStatus(
    BuildContext context,
    AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot,
  ) {
    switch (stringToStatus(snapshot.data.data()['status'])) {
      case Status.PENDING_CONFIRMATION:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              child: Text('Odrzuć'),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => buildAlertDialogForChangingStatus(
                  context: context,
                  status: Status.TERMINATE.toString().split('.').last,
                  docID: snapshot.data.id,
                  updateStatus: _updateStatus,
                  title: Text('Odrzucić zamówienie?'),
                  cancelButton: Text('Anuluj'),
                  acceptButton: Text('Potwierdź'),
                ),
              ),
            ),
            ElevatedButton(
              child: Text('Akceptuj'),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => buildAlertDialogForChangingStatus(
                  context: context,
                  status: Status.CONFIRMED.toString().split('.').last,
                  docID: snapshot.data.id,
                  updateStatus: _updateStatus,
                  title: Text('Zaakcpetować zamówienie?'),
                  cancelButton: Text('Anuluj'),
                  acceptButton: Text('Potwierdź'),
                ),
              ),
            ),
          ],
        );
      case Status.TERMINATE:
        return Row(
          children: [],
        );
      default:
        return Container();
    }
  }

  Status stringToStatus(String status) {
    return Status.values
        .firstWhere((e) => e.toString().split('.').last == status);
  }
}

Widget _buildContactButtons({
  @required BuildContext context,
  @required AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot,
  @required UserType userType,
  @required List<String> chatName,
  @required List<String> listID,
  @required String contactEmail,
  @required String contactPhoneNumber,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      IconButton(
        icon: Icon(Icons.question_answer_outlined),
        iconSize: 80,
        color: Theme.of(context).primaryColor,
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => buildAlertDialogForNewMessage(
              context: context,
              title: Text('Rozpocząć wiadomość?'),
              cancelButton: Text('Nie'),
              acceptButton: Text('Tak'),
              addressee: userType == UserType.Firm
                  ? snapshot.data.data()['userID']
                  : snapshot.data.data()['firmID'],
              chatName: chatName,
              listID: listID,
            ),
            barrierDismissible: true,
          );
        },
      ),
      IconButton(
        icon: Icon(Icons.phone),
        iconSize: 80,
        color: Theme.of(context).primaryColor,
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => buildAlertDialogForPhoneCallAndEmail(
              context: context,
              title: Text(
                  'Zadzwonić do ${userType == UserType.Firm ? 'użytkownika' : 'firmy'}?'),
              cancelButton: Text('Anuluj'),
              acceptButton: Text('Zadzwoń'),
              isPhoneCall: true,
              contactData: contactPhoneNumber,
            ),
            barrierDismissible: true,
          );
        },
      ),
      IconButton(
        icon: Icon(Icons.email_outlined),
        iconSize: 80,
        color: Theme.of(context).primaryColor,
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => buildAlertDialogForPhoneCallAndEmail(
              context: context,
              title: Text(
                  'Wysłać maila do ${userType == UserType.Firm ? 'użytkownika' : 'firmy'}?'),
              cancelButton: Text('Anuluj'),
              acceptButton: Text('Wyślij'),
              isPhoneCall: false,
              contactData: contactEmail,
            ),
          );
        },
      ),
    ],
  );
}

ListTile _createUserToShowInDetails(
  BuildContext context,
  UserProvider provider,
  Users user,
) {
  return ListTile(
    leading: CircleAvatar(
      radius: 30,
      backgroundImage: AssetImage('assets/images/user.png'),
      foregroundImage: networkImage(user.avatar),
    ),
    title: Text(
      user.firstName + ' ' + user.lastName,
      style: Theme.of(context).textTheme.headline6,
    ),
    subtitle: Text(user.email),
    trailing: Column(
      children: [
        RatingBarIndicator(
          rating: double.parse(user.rating),
          itemBuilder: (context, index) => Icon(
            Icons.star,
            color: Colors.amber,
          ),
          itemCount: 5,
          itemSize: 25.0,
          direction: Axis.horizontal,
        ),
        RichText(
          text: TextSpan(
            text: user.rating,
            style: Theme.of(context).textTheme.headline6,
            children: [
              TextSpan(
                text: ' (${user.ratingNumber})',
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(fontWeight: FontWeight.normal),
              )
            ],
          ),
        ),
      ],
    ),
  );
}

ListTile _createFirmToShowInDetails(
  BuildContext context,
  UserProvider provider,
  Firm firm,
) {
  return ListTile(
    leading: CircleAvatar(
      radius: 30,
      backgroundImage: AssetImage('assets/images/user.png'),
      foregroundImage: networkImage(firm.avatar),
    ),
    title: Text(
      firm.firmName,
      style: Theme.of(context).textTheme.headline6,
    ),
    trailing: Column(
      children: [
        RatingBarIndicator(
          rating: double.parse(firm.rating),
          itemBuilder: (context, index) => Icon(
            Icons.star,
            color: Colors.amber,
          ),
          itemCount: 5,
          itemSize: 25.0,
          direction: Axis.horizontal,
        ),
        RichText(
          text: TextSpan(
            text: firm.rating,
            style: Theme.of(context).textTheme.headline6,
            children: [
              TextSpan(
                  text: ' (${firm.ratingNumber})',
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(fontWeight: FontWeight.normal))
            ],
          ),
        ),
      ],
    ),
  );
}

Center buildErrorMessage(BuildContext context) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
            'Wystąpił błąd z pobraniem danych.\n\nSpróbuj otworzyć stronę ponownie!'),
        SizedBox(height: 20),
        ElevatedButton(
          child: Text("Wyjdź"),
          onPressed: () => Navigator.of(context).pop(),
        )
      ],
    ),
  );
}

NetworkImage networkImage(String url) {
  return (url != null && url != '') ? NetworkImage(url) : null;
}
