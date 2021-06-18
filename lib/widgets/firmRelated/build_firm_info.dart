import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

ListTile buildFirmInfo(BuildContext context, firm) {
  return ListTile(
    leading: CircleAvatar(
      child: firm['avatar'] == ''
          ? Image(image: AssetImage('assets/images/fileNotFound.png'))
          : Image.network(firm['avatar']),
    ),
    title: Text(
      firm['firmName'],
      style: TextStyle(fontSize: 20),
    ),
    subtitle: Text(firm['location']),
    trailing: RatingBarIndicator(
      rating: double.tryParse(firm['rating']) != null
          ? double.parse(firm['rating'])
          : 0,
      itemBuilder: (context, index) => Icon(
        Icons.star,
        color: Colors.amber,
      ),
      itemCount: 5,
      itemSize: 25.0,
      direction: Axis.horizontal,
    ),
    // isThreeLine: true,
    onTap: () {
      print("Kliknięto:${firm['firmName']}");
    },
  );
}
