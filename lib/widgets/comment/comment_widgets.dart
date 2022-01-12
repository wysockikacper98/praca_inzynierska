import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../../helpers/firebase_firestore.dart';
import '../../models/comment.dart';
import '../../models/users.dart';
import '../theme/theme_Provider.dart';

class BuildAlertDialogAddComment extends StatefulWidget {
  final List<String> userAndFirmIds;
  final String orderID;
  final void Function() refreshWidget;

  BuildAlertDialogAddComment(
    this.userAndFirmIds,
    this.orderID,
    this.refreshWidget,
  );

  @override
  _BuildAlertDialogAddCommentState createState() =>
      _BuildAlertDialogAddCommentState();
}

class _BuildAlertDialogAddCommentState
    extends State<BuildAlertDialogAddComment> {
  final _controller = new TextEditingController();
  double rating = 0;

  @override
  Widget build(BuildContext context) {
    final userType = Provider.of<UserProvider>(context).user!.type;
    final bool _isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(10),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          color: _isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
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
                  maxRating: 5,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (value) {
                    setState(() {
                      rating = value;
                    });
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
                      child: Text(
                        'Anuluj',
                        style: TextStyle(
                          color: _isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    TextButton(
                      child: Text('Dodaj ocenę'),
                      onPressed: rating == 0
                          ? null
                          : () {
                              Comment comment = Comment(
                                rating: rating.round(),
                                comment: _controller.text,
                                dateTime: DateTime.now(),
                              );
                              addCommentToFirebase(
                                userType,
                                widget.userAndFirmIds,
                                comment,
                                widget.orderID,
                              ).then((value) {
                                widget.refreshWidget();
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
  }
}
