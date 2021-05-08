import 'package:flutter/material.dart';

class ConversationItem extends StatelessWidget {
  ConversationItem(this.userID, this.lastMessage, {this.key});

  final Key key;
  final String userID;
  final String lastMessage;

  @override
  Widget build(BuildContext context) {
    return Text('UserID:' + userID + '\nLastMessage' + lastMessage);
  }
}
