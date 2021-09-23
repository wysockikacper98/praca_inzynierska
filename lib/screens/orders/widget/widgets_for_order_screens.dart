import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/users.dart';
import '../order_details_screen.dart';

Padding buildOrderListTile(
  BuildContext context,
  QueryDocumentSnapshot<Map<String, dynamic>> data,
) {
  final provider = Provider.of<UserProvider>(context, listen: false);
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
  switch (status) {
    case 'PENDING':
      return 'Oczekuje';
    case 'PROCESSING':
      return 'W trakcie';
    case 'COMPLETED':
      return 'Ukończone';
    default:
      return 'Nieznany status';
  }
}
