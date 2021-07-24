import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:praca_inzynierska/models/firm.dart';
import 'package:praca_inzynierska/models/users.dart';
import 'package:praca_inzynierska/screens/messages/messages.dart';
import 'package:provider/provider.dart';

Future<void> loginUser(
  BuildContext context,
  String email,
  String password,
) async {
  //TODO: Delete delay after testing
  print("Star of delay");
  await Future.delayed(const Duration(seconds: 3), () {
    print("End of delay");
  });
  UserCredential authResult;
  try {
    final _auth = FirebaseAuth.instance;
    authResult = await _auth.signInWithEmailAndPassword(
        email: email, password: password);

    var data = await FirebaseFirestore.instance
        .collection('users')
        .doc(authResult.user.uid)
        .get();
    if (!data.exists) {
      data = await FirebaseFirestore.instance
          .collection('firms')
          .doc(authResult.user.uid)
          .get();
    }
    // print("Login as User:" + authResult.user.uid);
    // print('Login helper:' + data.data().toString());
    Provider.of<UserProvider>(context, listen: false).user =
        Users.fromJson(data.data());
    // await saveUserInfo(Users.fromJson(data.data()));
  } on FirebaseAuthException catch (error) {
    handleFirebaseError(context, error);
  } catch (error) {
    print(error);
  }
}

Future<bool> registerUser(
    BuildContext context, Users user, String userPassword) async {
  //TODO: Delete after testing
  print("Start delay");
  await Future.delayed(Duration(seconds: 3), () {
    print("Stop delay");
  });

  try {
    UserCredential authResult;
    final _auth = FirebaseAuth.instance;
    // print("Test Zapisu użytkownika: ${user.toJson()}");
    authResult = await _auth.createUserWithEmailAndPassword(
        email: user.email, password: userPassword);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(authResult.user.uid)
        .set(user.toJson());

    Provider.of<UserProvider>(context, listen: false).user = user;
    // await saveUserInfo(user);
    return true;
  } on FirebaseAuthException catch (error) {
    handleFirebaseError(context, error);
    return false;
  } catch (error) {
    print(error);
    return false;
  }
}

Future<bool> registerFirm(
    BuildContext context, Firm firm, String password) async {
  //TODO: Delete after testing
  print("Start delay");
  await Future.delayed(Duration(seconds: 3), () {
    print("Stop delay");
  });
  UserCredential authResult;
  final _auth = FirebaseAuth.instance;
  // print("Test Zapisu Firmy: ${firm.toJson()}");
  // print("Test Zapisu szczegółów: ${firm.details.toJson()}");

  try {
    authResult = await _auth.createUserWithEmailAndPassword(
        email: firm.email, password: password);

    await FirebaseFirestore.instance
        .collection('firms')
        .doc(authResult.user.uid)
        .set(firm.toJson());

    // print('Zapisana firma:\n' + firm.toString());
    Provider.of<UserProvider>(context, listen: false).user =
        Users.fromJson(firm.toJson());
    // await saveUserInfo(firm);
    return true;
  } on FirebaseAuthException catch (error) {
    handleFirebaseError(context, error);
    authResult.user.delete();
    return false;
  } catch (error) {
    print(error);
    authResult.user.delete();
    return false;
  }
}

void handleFirebaseError(BuildContext context, FirebaseAuthException error) {
  String errorMessage = "Wystąpił błąd. Proszę sprawedzić dane logowania.";
  if (error.message != null) {
    errorMessage = error.message;
  }
  print(errorMessage);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(errorMessage),
      duration: Duration(seconds: 3),
      backgroundColor: Theme.of(context).errorColor,
    ),
  );
}

Future<void> createNewChat(BuildContext context, Users user, firm) async {
  CollectionReference chats = FirebaseFirestore.instance.collection('chats');
  String userID = FirebaseAuth.instance.currentUser.uid;

  final List<String> chatName = [
    user.lastName + ' ' + user.firstName,
    firm.data()['lastName'] +
        ' ' +
        firm.data()['firstName'] +
        ', ' +
        firm.data()['firmName']
  ];

  final chatData = await chats.where('users', arrayContains: userID).get();
  bool ifChatExist = false;
  var pickedChat;

  for (int i = 0; i < chatData.docs.length; i++) {
    if (chatData.docs[i]['users'].contains(firm.id)) {
      pickedChat = chatData.docs[i];
      ifChatExist = true;
      break;
    }
  }

  if (!ifChatExist) {
    print('Dodawanie nowego chatu');

    chats.add({
      'chatName': chatName,
      'updatedAt': DateTime.now(),
      'users': [userID, firm.id]
    }).then((value) {
      print('Added chat with id:${value.id}');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Message(
            chatID: value.id,
            chatName: chatName.last,
          ),
        ),
      );
    }).catchError((error) => print("Failed to add user: $error"));
  } else {
    print('Otwieranie starego chatu');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Message(
          chatID: pickedChat.reference.id,
          chatName: pickedChat['users'][0] == userID
              ? pickedChat['chatName'][1]
              : pickedChat['chatName'][0],
        ),
      ),
    );
  }
}

Future<void> getUserInfoFromFirebase(
  BuildContext context,
  String userID,
) async {
  // await Future.delayed(Duration(seconds: 2));
  final provider = Provider.of<UserProvider>(context, listen: false);
  var data =
      await FirebaseFirestore.instance.collection('users').doc(userID).get();
  if (!data.exists) {
    data =
        await FirebaseFirestore.instance.collection('firms').doc(userID).get();
  }
  provider.user = Users.fromJson(data.data());
}

Future<void> getFirmInfoFromFirebase(
  BuildContext context,
  String userID,
) async {
  // Future.delayed(Duration(seconds: 2));
  // print("czy to działa");
  final provider = Provider.of<FirmProvider>(context, listen: false);
  final providerUser = Provider.of<UserProvider>(context, listen: false);
  final data =
      await FirebaseFirestore.instance.collection('firms').doc(userID).get();

  // print("Data:" + data.data().toString());

  provider.firm = Firm.fromJson(data.data());
  providerUser.user = Users.fromJson(data.data());
}

Future<QuerySnapshot> getFirmList() async {
  final data = await FirebaseFirestore.instance.collection('firms').get();
  return data;
}

Future<void> updateUserInFirebase(
  BuildContext context,
  String firstName,
  String lastName,
  String telephone,
) async {
  final userId = FirebaseAuth.instance.currentUser.uid;
  await FirebaseFirestore.instance.collection('users').doc(userId).update(
      {'firstName': firstName, 'lastName': lastName, 'telephone': telephone});

  await getUserInfoFromFirebase(context, userId);
}

Future<void> updateFirmInFirebase(
  BuildContext context,
  Firm firm,
) async {
  final userId = FirebaseAuth.instance.currentUser.uid;
  await FirebaseFirestore.instance.collection('firms').doc(userId).update({
    'firmName': firm.firmName,
    'firstName': firm.firstName,
    'lastName': firm.lastName,
    'telephone': firm.telephone,
    'location': firm.location,
  });

  await getFirmInfoFromFirebase(context, userId);
}
