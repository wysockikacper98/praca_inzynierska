import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/users.dart';

class NewMessage extends StatefulWidget {
  final chatsID;

  NewMessage(this.chatsID);

  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _controller = new TextEditingController();
  var _enterMessage = '';

  Future<void> _sendMessage(UserProvider provider) async {
    FocusScope.of(context).unfocus();
    final user = FirebaseAuth.instance.currentUser;
    final Users userData = provider.user;

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatsID)
        .collection('messages')
        .add({
      'text': _enterMessage,
      'createdAt': Timestamp.now(),
      'creatorID': user.uid,
      'userName': userData.firstName,
    });
    _controller.clear();
    setState(() {
      _enterMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context, listen: false);
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: 'Send a message...'),
              onChanged: (value) {
                setState(() {
                  _enterMessage = value;
                });
              },
            ),
          ),
          IconButton(
            color: Theme.of(context).primaryColor,
            icon: Icon(Icons.send),
            onPressed: _enterMessage.trim().isEmpty
                ? null
                : () => _sendMessage(provider),
          )
        ],
      ),
    );
  }
}
