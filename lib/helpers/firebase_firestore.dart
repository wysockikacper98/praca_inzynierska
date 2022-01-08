import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/comment.dart';
import '../models/firm.dart';
import '../models/meeting.dart';
import '../models/notification.dart';
import '../models/order.dart';
import '../models/useful_data.dart';
import '../models/users.dart';
import '../screens/messages/messages.dart';
import 'colorful_print_messages.dart';

Future<void> loginUser(
  BuildContext context,
  String email,
  String password,
) async {
  UserCredential authResult;
  try {
    final _auth = FirebaseAuth.instance;
    authResult = await _auth.signInWithEmailAndPassword(
        email: email, password: password);

    var data = await FirebaseFirestore.instance
        .collection('users')
        .doc(authResult.user!.uid)
        .get();
    if (!data.exists) {
      data = await FirebaseFirestore.instance
          .collection('firms')
          .doc(authResult.user!.uid)
          .get();
    }
    // print("Login as User:" + authResult.user.uid);
    // print('Login helper:' + data.data().toString());
    Provider.of<UserProvider>(context, listen: false).user =
        Users.fromJson(data.data()!);
    // await saveUserInfo(Users.fromJson(data.data()));
  } on FirebaseAuthException catch (error) {
    handleFirebaseAuthError(context, error);
  } catch (error) {
    print(error);
  }
}

Future<bool> registerUser(
    BuildContext context, Users user, String userPassword) async {
  try {
    UserCredential authResult;
    final _auth = FirebaseAuth.instance;
    // print("Test Zapisu użytkownika: ${user.toJson()}");
    authResult = await _auth.createUserWithEmailAndPassword(
        email: user.email, password: userPassword);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(authResult.user!.uid)
        .set(user.toJson());

    Provider.of<UserProvider>(context, listen: false).user = user;
    // await saveUserInfo(user);
    return true;
  } on FirebaseAuthException catch (error) {
    handleFirebaseAuthError(context, error);
    return false;
  } catch (error) {
    print(error);
    return false;
  }
}

Future<bool> registerFirm(BuildContext context, Firm firm, String password,
    void Function(bool value) setLoading) async {
  late UserCredential authResult;
  final _auth = FirebaseAuth.instance;
  try {
    authResult = await _auth.createUserWithEmailAndPassword(
        email: firm.email, password: password);

    await FirebaseFirestore.instance
        .collection('firms')
        .doc(authResult.user!.uid)
        .set(firm.toJson());

    // print('Zapisana firma:\n' + firm.toString());
    Provider.of<UserProvider>(context, listen: false).user =
        Users.fromJson(firm.toJson());
    // await saveUserInfo(firm);
    return true;
  } on FirebaseAuthException catch (error) {
    handleFirebaseAuthError(context, error);
    authResult.user!.delete();
    setLoading(false);
    return false;
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.toString()),
        duration: Duration(seconds: 3),
        backgroundColor: Theme.of(context).errorColor,
      ),
    );
    authResult.user!.delete();
    setLoading(false);
    return false;
  }
}

void handleFirebaseAuthError(
    BuildContext context, FirebaseAuthException error) {
  String errorMessage = "Wystąpił błąd. Proszę sprawedzić dane logowania.";
  if (error.message != null) {
    errorMessage = error.message!;
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

void handleFirebaseException(BuildContext context, FirebaseException error) {
  String errorMessage = "Wystąpił błąd. Proszę sprawedzić dane logowania.";
  if (error.message != null) {
    errorMessage = error.message!;
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

Future<void> createNewChat(BuildContext context, Users user, firm,
    String userAvatar, String firmAvatar) async {
  CollectionReference chats = FirebaseFirestore.instance.collection('chats');
  String userID = FirebaseAuth.instance.currentUser!.uid;

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
  late var pickedChat;

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
      'users': [userID, firm.id],
      'latestMessage': '',
      'userAvatar': userAvatar,
      'firmAvatar': firmAvatar,
    }).then((value) {
      print('Added chat with id:${value.id}');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Message(
            chatID: value.id,
            chatName: chatName.last,
            addresseeID: firm.id,
          ),
        ),
      );
    }).catchError((error) {
      print('Failed to add user: $error');
    });
  } else {
    print('Otwieranie starego chatu');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Message(
          chatID: pickedChat.reference.id,
          chatName: pickedChat['chatName'][1],
          addresseeID: firm.id,
        ),
      ),
    );
  }
}

Future<void> getUserInfoFromFirebase(
  BuildContext context,
  String userID,
) async {
  final provider = Provider.of<UserProvider>(context, listen: false);
  var data =
      await FirebaseFirestore.instance.collection('users').doc(userID).get();
  if (!data.exists) {
    data =
        await FirebaseFirestore.instance.collection('firms').doc(userID).get();
  }

  provider.user = Users.fromJson(data.data()!);
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

  provider.firm = Firm.fromJson(data.data()!);
  providerUser.user = Users.fromJson(data.data()!);
}

Future<QuerySnapshot<Map<String, dynamic>>> getFirmList() async {
  return FirebaseFirestore.instance.collection('firms').get();
}

Future<void> updateUserInFirebase(
  BuildContext context,
  String firstName,
  String lastName,
  String telephone,
) async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  await FirebaseFirestore.instance.collection('users').doc(userId).update(
      {'firstName': firstName, 'lastName': lastName, 'telephone': telephone});

  await getUserInfoFromFirebase(context, userId);
}

Future<void> updateFirmInFirebase(
  BuildContext context,
  Firm firm,
) async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  await FirebaseFirestore.instance.collection('firms').doc(userId).update({
    'firmName': firm.firmName,
    'firstName': firm.firstName,
    'lastName': firm.lastName,
    'telephone': firm.telephone,
    'category': firm.category,
    'address': firm.address!.toJson(),
    'details.description': firm.details!.description,
  });

  await getFirmInfoFromFirebase(context, userId);
}

Future<DocumentReference<Map<String, dynamic>>> addOrderInFirebase(
  Order order,
) async {
  return await FirebaseFirestore.instance
      .collection('orders')
      .add(order.toJson());
}

/// ## Create or Open chat
/// Function create new or open existing chat
/// just give [context], [loggedUser] and [addressee]
Future<void> createOrOpenChat(
  BuildContext context,
  Users loggedUser,
  String addressee,
  List<String> chatName,
  List<String> listID,
) async {
  CollectionReference chats = FirebaseFirestore.instance.collection('chats');
  String loggedUserID = FirebaseAuth.instance.currentUser!.uid;

  final chatData =
      await chats.where('users', arrayContains: loggedUserID).get();

  bool ifChatExist = false;
  late QueryDocumentSnapshot<Map<String, dynamic>> pickedChat;

  for (final element in chatData.docs) {
    if (element['users'].contains(addressee)) {
      pickedChat = element as QueryDocumentSnapshot<Map<String, dynamic>>;
      ifChatExist = true;
      break;
    }
  }

  if (!ifChatExist) {
    print('Dodawanie nowego czatu');

    chats.add({
      'chatName': chatName,
      'updateAt': DateTime.now(),
      'users': listID,
    }).then((value) {
      print('Added chat with id:${value.id}');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Message(
            chatID: value.id,
            chatName: loggedUser.type == UserType.Firm
                ? chatName.first
                : chatName.last,
            addresseeID: addressee,
          ),
        ),
      );
    });
  } else {
    print('Otwieranie starego chatu');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Message(
          chatID: pickedChat.reference.id,
          chatName: loggedUser.type == UserType.Firm
              ? pickedChat['chatName'].first
              : pickedChat['chatName'].last,
          addresseeID: addressee,
        ),
      ),
    );
  }
}

Future<QuerySnapshot<Map<String, dynamic>>> getFirmComments(
    String firmID) async {
  return FirebaseFirestore.instance
      .collection('firms')
      .doc(firmID)
      .collection('comments')
      .get();
}

Future<QuerySnapshot<Map<String, dynamic>>> getUserComments(
    String userID) async {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userID)
      .collection('comments')
      .get();
}

Future<void> addCommentToFirebase(
  UserType userType,
  List<String> userAndFirmIds,
  Comment comment,
  String orderID,
) async {
  print('Dodawanie komentarza:\n${comment.toString()}');
  final String collection = userType == UserType.Firm ? 'users' : 'firms';
  final String docID =
      userType == UserType.Firm ? userAndFirmIds.first : userAndFirmIds.last;
  final String updateField =
      userType == UserType.Firm ? 'canFirmComment' : 'canUserComment';

  return FirebaseFirestore.instance
      .collection('orders')
      .doc(orderID)
      .update({updateField: false}).then(
    (value) => FirebaseFirestore.instance
        .collection(collection)
        .doc(docID)
        .collection('comments')
        .add(comment.toJson())
        .then(
      (_) async {
        final DocumentSnapshot<Map<String, dynamic>> data =
            await FirebaseFirestore.instance
                .collection(collection)
                .doc(docID)
                .get();
        final Users users = Users.fromJson(data.data()!);
        FirebaseFirestore.instance.collection(collection).doc(docID).update({
          'rating': (comment.rating + users.rating!),
          'ratingNumber': (users.ratingNumber! + 1),
        });
      },
    ),
  );
}

Future<void> addMeetingToUser({
  required Meeting meeting,
  required UserType userType,
  required String userID,
}) async {
  String collectionName = userType == UserType.Firm ? 'firms' : 'users';
  FirebaseFirestore.instance
      .collection(collectionName)
      .doc(userID)
      .collection('meetings')
      .add(meeting.toJson());
}

Future<void> getCategories(BuildContext context) async {
  final data = await FirebaseFirestore.instance
      .collection('usefulData')
      .doc('mKT6HCrf066qkE3MTNL0')
      .get();

  Provider.of<UsefulData>(context, listen: false).categoriesList =
      data.data()!['categoryListPL'].cast<String>();
}

Future<void> saveTokenToDatabase(UserType userType, String token) async {
  // Assume user is logged in for this example
  String userId = FirebaseAuth.instance.currentUser!.uid;

  String collection = userType == UserType.Firm ? 'firms' : 'users';

  await FirebaseFirestore.instance.collection(collection).doc(userId).update({
    'tokens': FieldValue.arrayUnion([token]),
  });
}

Future<void> sendPushMessage(
  String userID,
  NotificationData notification,
  NotificationDetails notificationDetails,
) async {
  DocumentSnapshot<Map<String, dynamic>> user =
      await FirebaseFirestore.instance.collection('users').doc(userID).get();
  List<String>? _userTokens = user.data()!['tokens'].cast<String>();

  if (_userTokens != null) {
    try {
      HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('sendNewTripNotification');
      callable(constructFCMPayload(
              _userTokens, notification, notificationDetails))
          .then(
            (value) => printColor(
              text: 'Udało sie wysłać powiadomienie',
              color: PrintColor.cyan,
            ),
          )
          .catchError(
            (e) => printColor(
              text: e.toString(),
              color: PrintColor.red,
            ),
          );
    } catch (e) {
      printColor(
        text: 'Nie udało się',
        color: PrintColor.red,
      );
      print(e);
    }
  }
}

String constructFCMPayload(List<String> token, NotificationData notification,
    NotificationDetails details) {
  return jsonEncode({
    'tokens': token,
    'data': {
      'name': details.name,
      'details': details.details,
    },
    'notification': {
      'title': notification.title,
      'body': notification.body,
    },
  });
}
