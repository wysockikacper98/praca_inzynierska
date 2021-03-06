import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../screens/firm/firm_profile_screen.dart';
import '../../screens/user/user_profile_screen.dart';
import '../calculate_rating.dart';

ListTile buildFirmInfo(BuildContext context, firm, [bool disable = false]) {
  final double rating = calculateRating(
    firm.data()['rating'].toDouble(),
    firm.data()['ratingNumber'].toDouble(),
  );
  return ListTile(
    leading: CircleAvatar(
      radius: 30,
      backgroundColor: Colors.white,
      backgroundImage: AssetImage('assets/images/user.png'),
      foregroundImage: firm.data()['avatar'] != ''
          ? CachedNetworkImageProvider(firm.data()['avatar'])
          : null,
    ),
    title: AutoSizeText(
      firm.data()['firmName'],
      style: TextStyle(fontSize: 22),
      minFontSize: 15,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
    subtitle: Text(firm.data()['address']['city'] ?? ''),
    trailing: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        RatingBarIndicator(
          rating: rating,
          itemBuilder: (context, index) => Icon(
            Icons.star,
            color: Colors.amber,
          ),
          itemCount: 5,
          itemSize: 20.0,
          direction: Axis.horizontal,
        ),
        ratingNumbers(
          context,
          rating,
          firm.data()['ratingNumber'].round(),
        ),
      ],
    ),
    // isThreeLine: true,
    onTap: disable
        ? null
        : () {
            Navigator.of(context).pushNamed(
              FirmProfileScreen.routeName,
              arguments: FirmsAuth(firm.id),
            );
          },
  );
}
