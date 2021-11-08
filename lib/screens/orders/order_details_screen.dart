import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:praca_inzynierska/helpers/firebase_firestore.dart';
import 'package:praca_inzynierska/models/notification.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../models/firm.dart';
import '../../models/order.dart';
import '../../models/users.dart';
import '../../widgets/calculate_rating.dart';
import '../../widgets/comment/comment_widgets.dart';
import 'widget/alerts_dialog_for_orders.dart';
import 'widget/widgets_for_order_screens.dart';

class OrderDetailsScreen extends StatefulWidget {
  static const String routeName = '/order-details';

  final String orderID;
  final String userOrFirmID;

  OrderDetailsScreen({required this.orderID, required this.userOrFirmID});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late Users userToShowInDetails;
  late Firm firmToShowInDetails;
  late List<String> chatName;
  late List<String> idList;

  Future<DocumentSnapshot<Map<String, dynamic>>> _getOrderDetails(
    UserType userType,
  ) async {
    final String currentUserID = FirebaseAuth.instance.currentUser!.uid;
    final String collection = userType == UserType.Firm ? 'users' : 'firms';
    final DocumentSnapshot<Map<String, dynamic>> dataFromFirebase =
        await FirebaseFirestore.instance
            .collection(collection)
            .doc(widget.userOrFirmID)
            .get();

    if (userType == UserType.Firm) {
      userToShowInDetails = Users.fromJson(dataFromFirebase.data()!);
      //creating list of ids
      idList = [dataFromFirebase.id, currentUserID];
      // creating chat name
      final firm = Provider.of<FirmProvider>(context, listen: false).firm;
      chatName = [
        '${userToShowInDetails.lastName} ${userToShowInDetails.firstName}',
        '${firm!.lastName} ${firm.firstName}, ${firm.firmName}',
      ];
    } else {
      firmToShowInDetails = Firm.fromJson(dataFromFirebase.data()!);
      //creating list of ids
      idList = [
        currentUserID,
        dataFromFirebase.id,
      ];
      //creating chat name
      final user = Provider.of<UserProvider>(context, listen: false).user;
      chatName = [
        '${user!.lastName} ${user.firstName}',
        '${firmToShowInDetails.lastName} ${firmToShowInDetails.firstName}, ${firmToShowInDetails.firmName}',
      ];
    }

    return FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderID)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    print('build -> order_details_screen');
    final provider = Provider.of<UserProvider>(context, listen: false);
    final UserType userType = provider.user!.type;

    return Scaffold(
      appBar: AppBar(title: Text('Szczegóły zamówienia')),
      body: FutureBuilder(
        future: _getOrderDetails(userType),
        builder: (
          ctx,
          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (!snapshot.hasData) {
              print('TO NIE MA DANYCH:\n${snapshot.data}');
              return buildErrorMessage(context);
            } else {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.local_fire_department),
                      onPressed: () {
                        sendPushMessage(
                          snapshot.data!.data()!['userID'],
                          NotificationData(
                            title: 'Dodano nowe zamówienie',
                            body: snapshot.data!.data()!['title'],
                          ),
                          NotificationDetails(
                            name: OrderDetailsScreen.routeName,
                            details: snapshot.data!.id,
                          ),
                        );
                      },
                      // => orderNotification(
                      //     snapshot.data!.id,
                      //     snapshot.data!.data()!['userID'],
                      //     snapshot.data!.data()!['firmID']),
                    ),
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
                      bold: snapshot.data!.data()!['category'],
                    ),
                    _buildTextNormalThenBold(
                      context: context,
                      normal: 'Status usługi: ',
                      bold: translateStatusEnumStringToString(
                          snapshot.data!.data()!['status']),
                    ),
                    _buildTextNormalThenBold(
                      context: context,
                      normal: 'Tytuł: ',
                      bold: snapshot.data!.data()!['title'],
                    ),
                    _buildDescription(context, snapshot),
                    _buildDatePreview(snapshot),
                    SizedBox(height: 16),
                    _buildContactButtons(
                      context: context,
                      snapshot: snapshot,
                      userType: userType,
                      chatName: chatName,
                      listID: idList,
                      contactPhoneNumber: userType == UserType.Firm
                          ? userToShowInDetails.telephone!
                          : firmToShowInDetails.telephone!,
                      contactEmail: userType == UserType.Firm
                          ? userToShowInDetails.email
                          : firmToShowInDetails.email,
                    ),
                    SizedBox(height: 16),
                    _buildButtonsDependingOnStatus(
                        context, snapshot, userType, idList),
                  ],
                ),
              );
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<void> _startOrder(
    BuildContext context,
    String id,
  ) async {
    Navigator.of(context).pop();
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(id)
        .update({'status': Status.PROCESSING.toString().split('.').last});
    setState(() {});
  }

  Future<void> _finishOrder(
    BuildContext context,
    String id,
  ) async {
    Navigator.of(context).pop();
    await FirebaseFirestore.instance.collection('orders').doc(id).update({
      'status': Status.COMPLETED.toString().split('.').last,
      'canUserComment': true,
      'canFirmComment': true,
    });
    setState(() {});
  }

  Widget _buildDatePreview(
    AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot,
  ) {
    PickerDateRange _range = PickerDateRange(
        snapshot.data!.data()?['dateFrom'].toDate(),
        snapshot.data!.data()?['dateTo'].toDate());
    if (_range.endDate == null) return Text('Nie wybrano daty zamówienia.');
    if (_range.startDate!.year != _range.endDate!.year ||
        _range.startDate!.month != _range.endDate!.month ||
        _range.startDate!.day != _range.endDate!.day) {
      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(DateFormat.yMMMMEEEEd('pl_PL').format(_range.startDate!)),
          Icon(Icons.arrow_right_alt),
          Text(DateFormat.yMMMMEEEEd('pl_PL').format(_range.endDate!)),
        ],
      );
    } else {
      return Text(
        DateFormat.Hm('pl_PL').format(_range.startDate!) +
            ' - ' +
            DateFormat.Hm('pl_PL').format(_range.endDate!) +
            ' ' +
            DateFormat.yMMMMEEEEd('pl_PL').format(_range.startDate!),
      );
    }
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
                  .subtitle1!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              (snapshot.data!.data()!['description'] != null &&
                      snapshot.data!.data()!['description'] != '')
                  ? snapshot.data!.data()!['description']
                  : 'Brak opisu',
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ],
        ),
      ),
    );
  }

  Padding _buildTextNormalThenBold({
    required BuildContext context,
    required String normal,
    required String bold,
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
                    .subtitle1!
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
    UserType userType,
    List<String> idList,
  ) {
    final bool canShowComment = userType == UserType.Firm
        ? (snapshot.data!.data()!['canFirmComment'] != null &&
            snapshot.data!.data()!['canFirmComment'] == true)
        : (snapshot.data!.data()!['canUserComment'] != null &&
            snapshot.data!.data()!['canUserComment'] == true);

    final double buttonWidth = MediaQuery.of(context).size.width * 0.9;
    switch (stringToStatus(snapshot.data!.data()!['status'])) {
      case Status.PENDING:
        return SizedBox(
          width: buttonWidth,
          child: Row(
            children: [
              Flexible(
                flex: 5,
                fit: FlexFit.tight,
                child: ElevatedButton(
                  child: Text('Anuluj'),
                  onPressed: () => showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (_) => buildAlertDialogForCancelingOrder(
                      context,
                      snapshot.data!.id,
                    ),
                  ),
                ),
              ),
              if (userType == UserType.Firm)
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Container(),
                ),
              if (userType == UserType.Firm)
                Flexible(
                  flex: 5,
                  fit: FlexFit.tight,
                  child: ElevatedButton(
                    child: Text('Rozpocznij'),
                    onPressed: () => showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (_) => buildAlertDialogForStartingOrder(
                        context,
                        snapshot.data!.id,
                        _startOrder,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      case Status.PROCESSING:
        return SizedBox(
          width: buttonWidth,
          child: Row(
            children: [
              if (userType == UserType.Firm)
                Flexible(
                  flex: 5,
                  fit: FlexFit.tight,
                  child: ElevatedButton(
                    child: Text('Zakończ'),
                    onPressed: () => showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (_) => buildAlertDialogForFinishingOrder(
                        context,
                        snapshot.data!.id,
                        _finishOrder,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      case Status.COMPLETED:
        return SizedBox(
          width: buttonWidth,
          child: Row(
            children: [
              if (canShowComment)
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.add_comment_outlined),
                    label: Text(' Dodaj komentarz'),
                    onPressed: () => showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => BuildAlertDialogAddComment(
                        idList,
                        snapshot.data!.id,
                        refreshWidget,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      default:
        return Container();
    }
  }

  void refreshWidget() {
    setState(() {});
  }

  Status stringToStatus(String status) {
    return Status.values
        .firstWhere((e) => e.toString().split('.').last == status);
  }
}

Widget _buildContactButtons({
  required BuildContext context,
  required AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot,
  required UserType userType,
  required List<String> chatName,
  required List<String> listID,
  required String contactEmail,
  required String contactPhoneNumber,
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
                  ? snapshot.data!.data()!['userID']
                  : snapshot.data!.data()!['firmID'],
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
          rating: user.rating!,
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
            text: user.rating.toString(),
            style: Theme.of(context).textTheme.headline6,
            children: [
              TextSpan(
                text: ' (${user.ratingNumber})',
                style: Theme.of(context)
                    .textTheme
                    .headline6!
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
    subtitle: Text('${firm.firstName} ${firm.lastName}'),
    trailing: Column(
      children: [
        RatingBarIndicator(
          rating: calculateRating(firm.rating!, firm.ratingNumber!),
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
            text: calculateRating(firm.rating!, firm.ratingNumber!).toString(),
            style: Theme.of(context).textTheme.headline6,
            children: [
              TextSpan(
                  text: ' (${firm.ratingNumber})',
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
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

NetworkImage? networkImage(String? url) {
  return (url != null && url != '') ? NetworkImage(url) : null;
}
