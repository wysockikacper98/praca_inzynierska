import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/colorfull_print_messages.dart';
import '../../models/users.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/new_message.dart';
import '../firm/firm_profile_screen.dart';
import '../orders/create_order_screen.dart';
import '../user/user_profile_screen.dart';

class Message extends StatelessWidget {
  final String chatID;
  final String chatName;
  final String addresseeID;

  Message(
      {required this.chatID,
      required this.chatName,
      required this.addresseeID});

  @override
  Widget build(BuildContext context) {
    printColor(text: 'Message', color: PrintColor.yellow);

    final userID = FirebaseAuth.instance.currentUser!.uid;
    final Users user = Provider.of<UserProvider>(context).user!;

    return Scaffold(
      appBar: AppBar(
        title: Text(this.chatName),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profil użytkownika'),
                  onTap: () {
                    print('$addresseeID');
                    user.type == UserType.Firm
                        ? Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UserProfileScreen(addresseeID),
                            ),
                          )
                        : Navigator.of(context).pushReplacementNamed(
                            FirmProfileScreen.routeName,
                            arguments: FirmsAuth(addresseeID),
                          );
                  },
                ),
              ),
              if (user.type == UserType.Firm)
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.post_add),
                    title: Text('Utwórz zamówienie'),
                    onTap: () {
                      print('$addresseeID');
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateOrderScreen(addresseeID),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(chatID)
                    .collection('messages')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (ctx,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        messageSnapshot) {
                  if (messageSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (!messageSnapshot.hasData) {
                    return Center(child: Text("Brak wiadomości tekstowych"));
                  } else {
                    final messageDoc = messageSnapshot.data!.docs;

                    return ListView.builder(
                      reverse: true,
                      itemCount: messageDoc.length,
                      itemBuilder: (ctx, index) => MessageBubble(
                        messageDoc[index].data()['text'],
                        messageDoc[index].data()['userName'],
                        messageDoc[index].data()['creatorID'] == userID,
                      ),
                    );
                  }
                },
              ),
            ),
            NewMessage(chatID),
          ],
        ),
      ),
    );
  }
}
