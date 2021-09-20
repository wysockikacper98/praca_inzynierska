import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:praca_inzynierska/screens/orders/order_details_screen.dart';
import 'package:provider/provider.dart';

import '../../../models/order.dart';
import '../../../models/users.dart';

Padding buildOrderListTile(
  BuildContext context,
  QueryDocumentSnapshot<Map<String, dynamic>> data,
) {
  final provider = Provider.of<UserProvider>(context);
  final ThemeData themeData = Theme.of(context);
  final UserType userType = provider.user.type;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: ListTile(
      leading: circleAvatar(userType, data),
      title: Text(
        data.data()['title'],
        style: themeData.textTheme.headline6,
      ),
      trailing: Text(
        translateStatusEnumStringToString(data.data()['status']),
        style: themeData.textTheme.subtitle2.copyWith(
          color: themeData.colorScheme.secondaryVariant,
        ),
      ),
      subtitle: Text(
        userType == UserType.PrivateUser
            ? data.data()['firmName']
            : data.data()['userName'],
        style: themeData.textTheme.subtitle1,
      ),
      onTap: () {
        print("Order id:" + data.id);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(
              orderID: data.id,
              userOrFirmID: userType == UserType.Firm
                  ? data.data()['userID']
                  : data.data()['firmID'],
            ),
          ),
        );
      },
    ),
  );
}

CircleAvatar circleAvatar(
  UserType type,
  QueryDocumentSnapshot<Map<String, dynamic>> data,
) {
  return CircleAvatar(
    radius: 30,
    foregroundImage: type == UserType.Firm
        ? networkImage(data.data()['userAvatar'])
        : networkImage(data.data()['firmAvatar']),
    backgroundImage: AssetImage('assets/images/user.png'),
  );
}

NetworkImage networkImage(String url) {
  return (url != null && url != '') ? NetworkImage(url) : null;
}

String translateStatusEnumStringToString(String status) {
  Status statusEnum =
      Status.values.firstWhere((e) => e.toString().split('.').last == status);

  switch (statusEnum) {
    case Status.PENDING_CONFIRMATION:
      return 'Oczekuje';
    case Status.IN_PROGRESS:
      return 'W trakcie';
    case Status.CONFIRMED:
      return 'Potwierdzony';
    case Status.DONE:
      return 'Ukończony';
    case Status.TERMINATE:
      return 'Przerwany';
    default:
      return 'Nieznany status';
  }
}
