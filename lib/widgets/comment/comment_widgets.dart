import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../../helpers/firebaseHelper.dart';
import '../../models/comment.dart';
import '../../models/users.dart';

Widget buildAlertDialogAddComment(
  BuildContext context,
  List<String> userAndFirmIds,
  String orderID,
  void Function() refreshWidget,
) {
  final userType = Provider.of<UserProvider>(context).user.type;
  final _controller = new TextEditingController();
  double rating = 0;

  return Dialog(
    backgroundColor: Colors.transparent,
    insetPadding: EdgeInsets.all(10),
    child: SizedBox(
      width: double.infinity,
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ocenianie',
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 16),
              RatingBar.builder(
                initialRating: rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (value) {
                  rating = value;
                },
              ),
              SizedBox(height: 16),
              TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 4,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  labelText: 'Komentarz (opcjonalne)',
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    child: Text('Anuluj'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  TextButton(
                    child: Text('Dodaj ocenę'),
                    onPressed: () {
                      Comment comment = Comment(
                        rating: rating,
                        comment: _controller.text,
                      );
                      addCommentToFirebase(
                        userType,
                        userAndFirmIds,
                        comment,
                        orderID,
                      ).then((value) {
                        refreshWidget();
                        Navigator.of(context).pop();
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );

  return AlertDialog(
    insetPadding: EdgeInsets.all(10),
    elevation: 24,
    title: Text('Dodawanie komentarza'),
    content: TextField(),
    actions: [
      TextButton(
        child: Text('Anuluj'),
        onPressed: () => Navigator.of(context).pop(),
      ),
      TextButton(
        child: Text('Dodaj komentarz'),
        onPressed: () {
          // addCommentToFirebase(
          //   userType,
          //   userAndFirmIds,
          //   comment,
          //   orderID,
          // ).then((value) => refreshWidget());
        },
      ),
    ],
  );
}
