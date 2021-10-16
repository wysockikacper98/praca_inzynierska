import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/comment.dart';
import '../../models/users.dart';
import '../../widgets/calculate_rating.dart';

class UserProfileScreen extends StatelessWidget {
  static const routeName = '/user-profile';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: Text('Profil użytkownika')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              _buildAvatar(provider, width),
              RatingBarIndicator(
                rating: calculateRating(
                    provider.user!.rating!, provider.user!.ratingNumber!),
                itemBuilder: (_, index) =>
                    Icon(Icons.star, color: Colors.amber),
                itemCount: 5,
                itemSize: 40.0,
              ),
              _ratingNumbers(provider, context),
              SizedBox(height: 8),
              _userInfo(provider.user!, context),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Komentarze:',
                    style: Theme.of(context).textTheme.headline5),
              ),
              SizedBox(height: 8),
              _buildCommentSection(),
            ],
          ),
        ),
      ),
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

  FutureBuilder<QuerySnapshot<Map<String, dynamic>>> _buildCommentSection() {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('comments')
          .get(),
      builder:
          (ctx, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (!snapshot.hasData || snapshot.data!.size == 0) {
            return Center(child: Text('Brak komentarzy'));
          } else {
            final data = snapshot.data!.docs;
            print(data.first.data().toString());
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.size,
              itemBuilder: (BuildContext ctx, int index) =>
                  _buildComment(Comment.fromJson(data[index].data())),
            );
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildComment(Comment comment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RatingBarIndicator(
              rating: comment.rating,
              itemBuilder: (_, index) => Icon(Icons.star, color: Colors.amber),
              itemCount: 5,
              itemSize: 20,
            ),
            Text(DateFormat.yMMMMd('pl_PL').format(comment.dateTime)),
          ],
        ),
        if (comment.comment != null) Text(comment.comment.toString()),
        Divider(
          height: 20,
        ),
      ],
    );
  }

  RichText _ratingNumbers(UserProvider provider, BuildContext context) {
    return RichText(
      text: TextSpan(
        text: calculateRating(
          provider.user!.rating!,
          provider.user!.ratingNumber!,
        ).toString(),
        style: Theme.of(context)
            .textTheme
            .subtitle1!
            .copyWith(fontWeight: FontWeight.bold),
        children: <TextSpan>[
          TextSpan(
            text: ' (${provider.user!.ratingNumber})',
            style: TextStyle(fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }

  CircleAvatar _buildAvatar(UserProvider provider, double width) {
    return CircleAvatar(
      backgroundImage: (provider.user!.avatar == ''
          ? AssetImage('assets/images/user.png')
          : NetworkImage(provider.user!.avatar!)) as ImageProvider<Object>?,
      backgroundColor: Colors.orangeAccent.shade100,
      radius: width * 0.15,
    );
  }
}
