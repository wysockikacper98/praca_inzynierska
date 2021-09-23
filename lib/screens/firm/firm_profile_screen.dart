import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../helpers/firebaseHelper.dart';
import '../../models/users.dart';
import '../../widgets/firm/build_firm_info.dart';
import '../full_screen_image.dart';

class FirmsAuth {
  final String firmID;

  FirmsAuth(this.firmID);
}

class FirmProfileScreen extends StatelessWidget {
  static const routeName = '/firm-profile';

  Future<DocumentSnapshot<Map<String, dynamic>>> getDataAboutFirm(
      firmID) async {
    return FirebaseFirestore.instance.collection('firms').doc(firmID).get();
  }

  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context).settings.arguments as FirmsAuth;
    final dateTime = DateTime.now();
    final userID = FirebaseAuth.instance.currentUser.uid;
    final userType =
        Provider.of<UserProvider>(context, listen: false).user.type;

    return Scaffold(
      appBar: AppBar(
        title: Text("Profil Wykonawcy"),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: getDataAboutFirm(data.firmID),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            var pictures = snapshot.data.data()['details']['pictures'];
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15),
                  buildFirmInfo(context, snapshot.data, true),
                  buildHeadline("O nas"),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 7.5),
                    child: Text(snapshot.data.data()['details']['description']),
                  ),
                  // TODO: Localization do not implemented yet
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7.5),
                  //   child: Text("Lokalizacja", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  // ),
                  buildHeadline("Zdjęcia:"),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: pictures.length > 0
                        ? CarouselSlider.builder(
                            options: CarouselOptions(
                              aspectRatio: 2.5,
                              disableCenter: true,
                              autoPlayInterval: const Duration(seconds: 8),
                              enlargeCenterPage: true,
                              autoPlay: true,
                            ),
                            itemCount: pictures.length,
                            itemBuilder: (ctx, index, tag) {
                              return GestureDetector(
                                child: Hero(
                                  tag: tag,
                                  child: Container(
                                    child: Image.asset(pictures[index]),
                                    color: Colors.white30,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) {
                                      return FullScreenImage(
                                          imageAssetsPath: pictures[index],
                                          tag: tag);
                                    }),
                                  );
                                },
                              );
                            },
                          )
                        : Center(
                            child: Text('Brak zdjęć.'),
                          ),
                  ),
                  buildHeadline("Kalendarz:"),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: SfCalendar(
                      view: CalendarView.month,
                      backgroundColor: Colors.white30,
                      firstDayOfWeek: 1,
                      minDate: DateTime.utc(dateTime.year, dateTime.month),
                      showDatePickerButton: true,
                    ),
                  ),
                  SizedBox(height: 50),
                  if (userType != UserType.Firm)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 7.5,
                      ),
                      child: AutoSizeText(
                        'Napisz do nas w razie pytań lub chęci współpracy',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline5,
                        maxLines: 2,
                      ),
                    ),
                  if (userType != UserType.Firm) SizedBox(height: 50),
                  if (userType != UserType.Firm)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: Icon(Icons.question_answer_outlined),
                          iconSize: 80,
                          color: Theme.of(context).primaryColor,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => buildConfirmNewMessageDialog(
                                context,
                                userID,
                                snapshot.data,
                              ),
                              barrierDismissible: true,
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.phone),
                          iconSize: 80,
                          color: Theme.of(context).primaryColor,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => buildConfirmPhoneCall(
                                context,
                                userID,
                                snapshot.data,
                              ),
                              barrierDismissible: true,
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.email_outlined),
                          iconSize: 80,
                          color: Theme.of(context).primaryColor,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => buildConfirmNewEmailDialog(
                                context,
                                userID,
                                snapshot.data,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  SizedBox(height: 50),
                ],
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  AlertDialog buildConfirmNewMessageDialog(
      BuildContext context, String userID, firm) {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    // print(firm.id);
    return userID != firm.id
        ? AlertDialog(
            title: Text('Nowa wiadomość?'),
            content: Text('Rozpocząć chat z ${firm.data()['firmName']}'),
            elevation: 24.0,
            actions: [
              TextButton(
                child: Text('Nie'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text('Tak'),
                onPressed: () {
                  Navigator.of(context).pop();
                  // createNewChat(context, getCurrentUser(), firm);
                  createNewChat(context, user, firm);
                },
              ),
            ],
          )
        : AlertDialog(
            title: Text('Nowa wiadomosć'),
            content: Text('Nie można rozpocząć czatu z samym sobą.'),
            elevation: 24,
            actions: [
              TextButton(
                child: Text('Wróć'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
  }

  AlertDialog buildConfirmNewEmailDialog(
      BuildContext context, String userID, firm) {
    return userID != firm.id
        ? AlertDialog(
            title: Text('Otowrzyć domyślną aplikację Email'),
            content: Text(
                'Czy chcesz utworzyć nową wiadomość do ${firm.data()['firmName']}'),
            elevation: 24.0,
            actions: [
              TextButton(
                child: Text('Nie'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text('Tak'),
                onPressed: () {
                  Navigator.of(context).pop();
                  final Uri _emailLaunchUri =
                      Uri(scheme: 'mailto', path: firm.data()['email']);
                  sendEmail(_emailLaunchUri.toString());
                },
              ),
            ],
          )
        : AlertDialog(
            title: Text('Nowa wiadomosć'),
            content:
                Text('Nie można wysłać wiadomości email do samego siebie.'),
            elevation: 24,
            actions: [
              TextButton(
                child: Text('Wróć'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
  }

  AlertDialog buildConfirmPhoneCall(BuildContext context, String userID, firm) {
    return userID != firm.id
        ? AlertDialog(
            title: Text('Nowe połączenie'),
            content: Text('Wybrać numer do ${firm.data()['firmName']}'),
            elevation: 24.0,
            actions: [
              TextButton(
                child: Text('Nie'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text('Tak'),
                onPressed: () {
                  Navigator.of(context).pop();
                  callPhone('tel:' + firm.data()['telephone'].toString());
                },
              ),
            ],
          )
        : AlertDialog(
            title: Text('Nowe połączenie'),
            content:
                Text('Nie można wysłać rozpocząć połączenia z samym sobą.'),
            elevation: 24,
            actions: [
              TextButton(
                child: Text('Wróć'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
  }

  Padding buildHeadline(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7.5),
      child: Text(
        text,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}

Future<void> sendEmail(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

Future<void> callPhone(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
