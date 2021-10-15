import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../models/users.dart';
import '../screens/firm/firm_edit_profile_screen.dart';
import '../screens/firm/firm_profile_screen.dart';
import '../screens/user/user_edit_profile_screen.dart';

Container buildUserInfo(BuildContext context, Users user) {
  var screenSize = MediaQuery.of(context).size;
  var height = screenSize.height;

  final userID = FirebaseAuth.instance.currentUser!.uid;

  final provider = Provider.of<UserProvider>(context);

  return Container(
    height: height * 0.2,
    child: DrawerHeader(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(color: Theme.of(context).primaryColor),
      child: Center(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundImage: AssetImage('assets/images/user.png'),
            foregroundImage:
                user.avatar != '' ? NetworkImage(user.avatar!) : null,
            radius: 30,
          ),
          title: AutoSizeText(
            user.firstName + ' ' + user.lastName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            minFontSize: 15,
            maxFontSize: 20,
            style: TextStyle(
              fontSize: 20,
              fontStyle: FontStyle.italic,
              color: Theme.of(context).primaryColorLight,
            ),
          ),
          subtitle: AutoSizeText(
            user.email,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.fade,
            minFontSize: 14,
          ),
          trailing: IconButton(
            icon: FaIcon(FontAwesomeIcons.userEdit),
            color: Theme.of(context).colorScheme.secondary,
            onPressed: () {
              provider.user!.type == UserType.Firm
                  ? Navigator.of(context)
                      .pushNamed(FirmEditProfileScreen.routeName)
                  : Navigator.of(context).pop();
            },
          ),
          onTap: () {
            provider.user!.type == UserType.PrivateUser
                ? Navigator.of(context)
                    .popAndPushNamed(UserEditProfileScreen.routeName)
                : Navigator.of(context).popAndPushNamed(
                    FirmProfileScreen.routeName,
                    arguments: FirmsAuth(userID),
                  );
          },
        ),
      ),
    ),
  );
}
