import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../helpers/colorful_print_messages.dart';
import '../../models/address.dart';
import '../../models/firm.dart';
import '../../models/order.dart';
import '../../models/users.dart';
import '../../widgets/calculate_rating.dart';
import '../../widgets/comment/comment_widgets.dart';
import '../../widgets/theme/theme_Provider.dart';
import '../calendar/change_order_date.dart';
import '../firm/firm_profile_screen.dart';
import '../user/user_profile_screen.dart';
import 'widget/alerts_dialog_for_orders.dart';

class OrderDetailsScreen extends StatefulWidget {
  static const String routeName = '/order-details';

  final String orderID;

  OrderDetailsScreen({required this.orderID});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late Users userToShowInDetails;
  late Firm firmToShowInDetails;
  late List<String> chatName;
  late List<String> idList;
  late String userOrFirmID;

  late final UserType _userType;
  late Future<DocumentSnapshot<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _userType = Provider.of<UserProvider>(context, listen: false).user!.type;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future = _getOrderDetails(_userType);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _getOrderDetails(
    UserType userType,
  ) async {
    printColor(text: '_getOrderDetails', color: PrintColor.cyan);

    final String currentUserID = FirebaseAuth.instance.currentUser!.uid;
    final String collection = userType == UserType.Firm ? 'users' : 'firms';
    final DocumentSnapshot<Map<String, dynamic>> orderDetails =
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(widget.orderID)
            .get();

    userOrFirmID = userType == UserType.Firm
        ? orderDetails.data()!['userID']
        : orderDetails.data()!['firmID'];

    final DocumentSnapshot<Map<String, dynamic>> dataFromFirebase =
        await FirebaseFirestore.instance
            .collection(collection)
            .doc(userOrFirmID)
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

    return orderDetails;
  }

  @override
  Widget build(BuildContext context) {
    print('build -> order_details_screen');
    final provider = Provider.of<UserProvider>(context, listen: false);
    final bool _isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      appBar: AppBar(title: Text('Szczegóły zamówienia')),
      body: FutureBuilder(
        future: _future,
        builder: (
          ctx,
          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == null) {
              printColor(
                text: 'TO NIE MA DANYCH:\n${snapshot.data?.data()}',
                color: PrintColor.red,
              );
              return buildErrorMessage(context);
            } else {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    _userType == UserType.Firm
                        ? _createUserToShowInDetails(
                            context,
                            provider,
                            userToShowInDetails,
                            idList.first,
                          )
                        : _createFirmToShowInDetails(
                            context,
                            provider,
                            firmToShowInDetails,
                            idList.last,
                          ),
                    SizedBox(height: 16),
                    _buildCategoriesPreview(snapshot.data!.data()!['category']),
                    _buildTitle(snapshot.data!.data()!['title']),
                    _buildDescription(context, snapshot),
                    if (_userType == UserType.Firm)
                      _buildLocation(context, snapshot),
                    _buildDateTitleAndButton(context, snapshot),
                    _buildDatePreview(snapshot),
                    SizedBox(height: 16),
                    _buildContactButtons(
                      context: context,
                      snapshot: snapshot,
                      userType: _userType,
                      chatName: chatName,
                      listID: idList,
                      contactPhoneNumber: _userType == UserType.Firm
                          ? userToShowInDetails.telephone!
                          : firmToShowInDetails.telephone!,
                      contactEmail: _userType == UserType.Firm
                          ? userToShowInDetails.email
                          : firmToShowInDetails.email,
                      isDarkMode: _isDarkMode,
                    ),
                    SizedBox(height: 16),
                    _buildButtonsDependingOnStatus(
                      context,
                      snapshot,
                      _userType,
                      idList,
                    ),
                    SizedBox(height: 100),
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

  Widget _buildDateTitleAndButton(
    BuildContext context,
    AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Data wykonania usługi:',
            style: Theme.of(context)
                .textTheme
                .subtitle1!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          if (snapshot.data!.data()!['status'] == 'PENDING' &&
              _userType == UserType.Firm)
            ElevatedButton.icon(
              icon: Icon(Icons.date_range_outlined),
              label: Text('Zmień datę'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => ChangeOrderDate(
                      PickerDateRange(
                        snapshot.data?.data()?['dateFrom'].toDate(),
                        snapshot.data?.data()?['dateTo'].toDate(),
                      ),
                      snapshot.data!.id,
                      refreshWidget,
                      snapshot.data!.data()!,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _startOrder(
    BuildContext context,
    String id,
  ) async {
    Navigator.of(context).pop();
    FirebaseFirestore.instance
        .collection('orders')
        .doc(id)
        .update({'status': Status.PROCESSING.toString().split('.').last}).then(
            (_) => refreshWidget());
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
    }).then((value) => refreshWidget());
  }

  Widget _buildDatePreview(
    AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot,
  ) {
    PickerDateRange _range = PickerDateRange(
        snapshot.data!.data()?['dateFrom'].toDate(),
        snapshot.data!.data()?['dateTo'].toDate());
    if (_range.endDate == null) return Text('Nie wybrano daty zamówienia.');
    //dwudniowe wyświetlanie daty
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
      //jednodniowe wyświetlanie daty
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
    setState(() {
      _future = _getOrderDetails(_userType);
    });
  }

  Status stringToStatus(String status) {
    return Status.values
        .firstWhere((e) => e.toString().split('.').last == status);
  }

  Widget _buildLocation(BuildContext context,
      AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
    final Address address = Address.fromJson(snapshot.data!.data()!['address']);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lokalizacja:',
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  label: Text('Otwórz w Google Map'),
                  icon: Icon(Icons.directions_outlined),
                  onPressed: () async {
                    String query = Uri.encodeComponent(
                        address.streetAndHouseNumber + ', ' + address.city);
                    String googleUrl =
                        "https://www.google.com/maps/search/?api=1&query=$query";

                    if (await canLaunch(googleUrl)) {
                      await launch(googleUrl);
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              address.toStringEnvelopeFormat(),
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesPreview(String category) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rodzaj usługi:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            InputChip(
              showCheckmark: false,
              selected: true,
              label: Text(category),
              onSelected: (_) {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tytuł:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
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
  required bool isDarkMode,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      IconButton(
        icon: Icon(Icons.question_answer_outlined),
        iconSize: 80,
        color: isDarkMode ? Colors.white : Theme.of(context).primaryColor,
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
        color: isDarkMode ? Colors.white : Theme.of(context).primaryColor,
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
        color: isDarkMode ? Colors.white : Theme.of(context).primaryColor,
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
  String userID,
) {
  final double _rating = calculateRating(user.rating!, user.ratingNumber!);
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
          rating: _rating,
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
            text: _rating.toString(),
            style: Theme.of(context).textTheme.headline6,
            children: [
              TextSpan(
                text: ' (${user.ratingNumber!.round()})',
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
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfileScreen(userID),
        ),
      );
    },
  );
}

ListTile _createFirmToShowInDetails(
  BuildContext context,
  UserProvider provider,
  Firm firm,
  String firmID,
) {
  final double _rating = calculateRating(firm.rating!, firm.ratingNumber!);
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
          rating: _rating,
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
            text: _rating.toString(),
            style: Theme.of(context).textTheme.headline6,
            children: [
              TextSpan(
                  text: ' (${firm.ratingNumber!.round()})',
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(fontWeight: FontWeight.normal))
            ],
          ),
        ),
      ],
    ),
    onTap: () {
      Navigator.of(context).pushNamed(
        FirmProfileScreen.routeName,
        arguments: FirmsAuth(firmID),
      );
    },
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
