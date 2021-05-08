import 'package:flutter/material.dart';
import 'package:praca_inzynierska/widgets/messages/conversations_list.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({Key key}) : super(key: key);

  static const routeName = '/conversation';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Wiadomości")),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: ConversationsList(),
      ),
    );
  }
}
