import 'package:flutter/material.dart';

class ConversationItem extends StatelessWidget {
  ConversationItem(this.userID, this.lastMessage, {this.key});

  final Key key;
  final String userID;
  final String lastMessage;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
        ),
        title: Text('Nazwa Firmy'),
        subtitle: Text(lastMessage.length < 40
            ? lastMessage
            : lastMessage.substring(0, 40) + '...'),
        onTap: () {
          print('Pressed: ' + key.toString());
        },
      ),
    );

    return Text('UserID:' + userID + '\nLastMessage' + lastMessage);
  }
}
