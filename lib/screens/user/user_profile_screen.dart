import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../helpers/colorful_print_messages.dart';
import '../../models/users.dart';
import '../../widgets/calculate_rating.dart';
import '../comment/build_comment_section.dart';

class UserProfileScreen extends StatelessWidget {
  final String userID;

  UserProfileScreen(this.userID);

  @override
  Widget build(BuildContext context) {
    printColor(text: 'UserProfileScreen($userID)', color: PrintColor.cyan);

    final _future =
        FirebaseFirestore.instance.collection('users').doc(userID).get();

    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: Text('Profil użytkownika')),
      body: FutureBuilder(
          future: _future,
          builder: (_,
              AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                final Users user = Users.fromJson(snapshot.data!.data()!);
                final double calculatedRating =
                    calculateRating(user.rating!, user.ratingNumber!);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 20),
                        _buildAvatar(user.avatar ?? '', width),
                        RatingBarIndicator(
                          rating: calculatedRating,
                          itemBuilder: (_, index) =>
                              Icon(Icons.star, color: Colors.amber),
                          itemCount: 5,
                          itemSize: 40.0,
                        ),
                        ratingNumbers(context, calculatedRating,
                            user.ratingNumber!.round()),
                        SizedBox(height: 16),
                        _userInfo(user, context),
                        SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Komentarze:',
                              style: Theme.of(context).textTheme.headline5),
                        ),
                        SizedBox(height: 16),
                        BuildCommentSection(
                          userID,
                          calculateRating(
                              user.rating ?? 0, user.ratingNumber ?? 0),
                          isFirm: false,
                          padding: 0,
                        ),
                      ],
                    ),
                  ),
                );
              } else
                return Center(
                    child: Text(
                        'Brak danych.\nSprawdź połączenie z internetem i spróbuj ponownie.'));
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  Widget _userInfo(Users user, BuildContext context) {
    return Column(
      children: [
        Text('${user.firstName} ${user.lastName}',
            style: Theme.of(context).textTheme.headline5),
        Text(user.email, style: Theme.of(context).textTheme.subtitle1),
      ],
    );
  }

  CircleAvatar _buildAvatar(String avatar, double width) {
    return CircleAvatar(
      backgroundImage: (avatar == ''
          ? AssetImage('assets/images/user.png')
          : NetworkImage(avatar)) as ImageProvider<Object>?,
      backgroundColor: Colors.orangeAccent.shade100,
      radius: width * 0.15,
    );
  }
}

/// [rating] is calculatedRating value
///
/// [ratingNumber] is mound of all ratings
///
/// ### return [rating] ([ratingNumber])
RichText ratingNumbers(
  BuildContext context,
  double rating,
  int ratingNumber,
) {
  return RichText(
    text: TextSpan(
      text: rating.toString(),
      style: Theme.of(context)
          .textTheme
          .subtitle1!
          .copyWith(fontWeight: FontWeight.bold),
      children: <TextSpan>[
        TextSpan(
          text: ' ($ratingNumber)',
          style: TextStyle(fontWeight: FontWeight.normal),
        ),
      ],
    ),
  );
}
