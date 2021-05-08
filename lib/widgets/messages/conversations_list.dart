import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:praca_inzynierska/widgets/messages/conversation_item.dart';

class ConversationsList extends StatelessWidget {
  const ConversationsList({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    print("UserID:" + user.uid);
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('conversations')
          .where('userID', isEqualTo: user.uid.toString())
          .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final chatDocs = snapshot.data.docs;
        print("Ilość znalezionych konwersacji:" + chatDocs.length.toString());

        //Display response body
        // List<dynamic> list = chatDocs.map((DocumentSnapshot doc){
        //   return doc.reference.id;
        // }).toList();
        // print(list);

        return ListView.builder(
          itemCount: chatDocs.length,
          itemBuilder: (ctx, index) => GestureDetector(
            child: ConversationItem(
              chatDocs[index].data()['userID'],
              chatDocs[index].data()['messages'][0]['text'],
              key: ValueKey(chatDocs[index].reference.id),
            ),
            onTap: (){
              print('Pressed: ' + chatDocs[index].reference.id);
            },
          ),
        );
      },
    );
  }
}
