import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

import '../../helpers/colorful_print_messages.dart';
import '../../helpers/firebase_firestore.dart';
import '../../models/comment.dart';

class BuildCommentSection extends StatefulWidget {
  final String _userID;
  final bool isFirm;
  final double _calculateRating;
  final double padding;

  BuildCommentSection(this._userID, this._calculateRating,
      {this.isFirm = true, this.padding = 16.0});

  @override
  _BuildCommentSectionState createState() => _BuildCommentSectionState();
}

class _BuildCommentSectionState extends State<BuildCommentSection> {
  late final Future<QuerySnapshot<Map<String, dynamic>>> _future;
  late ThemeData _theme;

  @override
  void initState() {
    super.initState();

    _future = widget.isFirm
        ? getFirmComments(widget._userID)
        : getUserComments(widget._userID);
  }

  @override
  Widget build(BuildContext context) {
    _theme = Theme.of(context);

    return FutureBuilder(
      future: _future,
      builder: (
        _,
        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) return buildCommentSection(snapshot);
          return Center(
            child: Text('Brak komentarzy'),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Padding buildCommentSection(
    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
  ) {
    printColor(text: 'buildCommentSection', color: PrintColor.yellow);

    int _numberOfReviews = 0;
    int _numberOfRatings = 0;
    List<Comment> _commentList = [];
    Map<int, int> _numberOfRatingsMap = {
      5: 0,
      4: 0,
      3: 0,
      2: 0,
      1: 0,
    };

    snapshot.data!.docs.forEach((element) {
      _numberOfRatingsMap.update(
        element.data()['rating'].toInt(),
        (value) => ++value,
      );

      if (element.data()['comment'] == '' ||
          element.data()['comment'] == null) {
        _numberOfRatings++;
      } else {
        _numberOfReviews++;
        _commentList.add(Comment.fromJson(element.data()));
      }
    });

    return Padding(
      padding: EdgeInsets.all(widget.padding),
      child: Column(
        children: [
          Divider(height: 32.0),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: widget._calculateRating.toString(),
                          style: _theme.textTheme.headline4!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _theme.colorScheme.onSurface),
                          children: [
                            TextSpan(
                              text: '/5',
                              style: _theme.textTheme.caption,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '$_numberOfRatings oceny i $_numberOfReviews recenzji',
                        style: _theme.textTheme.caption,
                      ),
                    ],
                  ),
                ),
                VerticalDivider(width: 32.0),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: _numberOfRatingsMap.entries
                        .map((e) => buildRatings(
                            e, _numberOfReviews + _numberOfRatings))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 32.0),
          ..._commentList.map((e) => buildCommentPreview(e)).toList(),
        ],
      ),
    );
  }

  ListTile buildCommentPreview(Comment e) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: RatingBarIndicator(
        unratedColor: Colors.amber,
        rating: e.rating.toDouble(),
        itemCount: 5,
        itemSize: 20,
        itemBuilder: (_, index) => Icon(
          index >= e.rating ? Icons.star_outline : Icons.star,
          color: Colors.amber,
        ),
      ),
      subtitle: Text(
        e.comment!,
        style: Theme.of(context).textTheme.subtitle1,
      ),
      trailing: Text(
        DateFormat.yMMMMd('pl_PL').format(e.dateTime),
      ),
    );
  }

  Widget buildRatings(MapEntry<int, int> e, int allRatings) {
    return Row(
      children: [
        Text(e.key.toString()),
        SizedBox(width: 5),
        RatingBarIndicator(
          unratedColor: Colors.amber,
          rating: e.key.toDouble(),
          itemCount: 5,
          itemSize: 15,
          itemBuilder: (_, index) => Icon(
            index >= e.key ? Icons.star_outline : Icons.star,
            color: Colors.amber,
          ),
        ),
        SizedBox(width: 5),
        Expanded(
          key: GlobalKey(),
          child: LinearProgressIndicator(
            value: allRatings == 0 ? 0 : e.value / allRatings,
            color: Color(0xFFff5a00),
            backgroundColor: Color(0xFFDDDDDD),
          ),
        ),
      ],
    );
  }
}
