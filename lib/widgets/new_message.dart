import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/users.dart';
import 'theme/theme_Provider.dart';

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
    final user = FirebaseAuth.instance.currentUser!;
    final Users userData = provider.user!;

    _controller.clear();

    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatsID)
          .collection('messages')
          .add({
        'text': _enterMessage,
        'createdAt': Timestamp.now(),
        'creatorID': user.uid,
        'userName': userData.firstName,
      }).then((_) {
        FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.chatsID)
            .update({
          'updatedAt': DateTime.now(),
          'latestMessage': _enterMessage,
        });
      });
      setState(() {
        _enterMessage = '';
      });
    } catch (e) {
      _controller.text = _enterMessage;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context, listen: false);
    final bool isDarkTheme =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: EdgeInsets.only(left: 24.0),
        decoration: BoxDecoration(
            color: isDarkTheme
                ? Colors.grey.shade700
                : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.all(Radius.circular(60.0))),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                style:
                    TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Wyślij wiadomość...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _enterMessage = value;
                  });
                },
              ),
            ),
            IconButton(
              color: Theme.of(context).colorScheme.secondary,
              icon: Icon(
                Icons.send,
                color: isDarkTheme
                    ? const Color(0xFFBF5AF2)
                    : const Color(0xFFFFBC92),
              ),
              onPressed: _enterMessage.trim().isEmpty
                  ? null
                  : () => _sendMessage(provider),
            )
          ],
        ),
      ),
    );
  }
}
