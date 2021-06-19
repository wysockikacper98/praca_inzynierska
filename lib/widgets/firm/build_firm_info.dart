import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:praca_inzynierska/screens/firm/firm_profile_screen.dart';

ListTile buildFirmInfo(BuildContext context, firm) {
  return ListTile(
    leading: CircleAvatar(
      radius: 30,
      backgroundColor: Colors.white,
      backgroundImage: firm.data()['avatar'] == ''
          ? AssetImage('assets/images/fileNotFound.png')
          : NetworkImage(firm.data()['avatar']),
    ),
    title: AutoSizeText(
      firm.data()['firmName'],
      style: TextStyle(fontSize: 22),
      minFontSize: 15,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
    subtitle: Text(firm.data()['location']),
    trailing: RatingBarIndicator(
      rating: double.tryParse(firm.data()['rating']) != null
          ? double.parse(firm.data()['rating'])
          : 0,
      itemBuilder: (context, index) => Icon(
        Icons.star,
        color: Colors.amber,
      ),
      itemCount: 5,
      itemSize: 20.0,
      direction: Axis.horizontal,
    ),
    // isThreeLine: true,
    onTap: () {
      Navigator.of(context).pushNamed(
        FirmProfileScreen.routeName,
        arguments: FirmsAuth(firm.id),
      );
    },
  );
}