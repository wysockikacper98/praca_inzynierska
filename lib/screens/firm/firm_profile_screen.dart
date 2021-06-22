import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:praca_inzynierska/helpers/firebaseHelper.dart';
import 'package:praca_inzynierska/providers/UserProvider.dart';
import 'package:praca_inzynierska/widgets/firm/build_firm_info.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:url_launcher/url_launcher.dart';

class FirmsAuth {
  final String firmID;

  FirmsAuth(this.firmID);
}

class FirmProfileScreen extends StatelessWidget {
  static const routeName = '/firm-profile';

  getDataAboutFirm(firmID) async {
    // await Future.delayed(Duration(seconds: 3));
    return FirebaseFirestore.instance.collection('firms').doc(firmID).get();
  }

  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context).settings.arguments as FirmsAuth;
    final dateTime = DateTime.now();
    final userID = FirebaseAuth.instance.currentUser.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text("Profil Wykonawcy"),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: getDataAboutFirm(data.firmID),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15),
                  buildFirmInfo(context, snapshot.data),
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
                  CarouselSlider(
                    options: CarouselOptions(
                      aspectRatio: 2.5,
                      disableCenter: true,
                      autoPlayInterval: Duration(seconds: 8),
                      enlargeCenterPage: true,
                      autoPlay: true,
                    ),
                    items: [
                      Container(
                        child: Image.asset('assets/images/tempPicture1.png'),
                        color: Colors.white30,
                      ),
                      Container(
                        child: Image.asset('assets/images/tempPicture2.png'),
                        color: Colors.white30,
                      ),
                      Container(
                        child: Image.asset('assets/images/tempPicture3.png'),
                        color: Colors.white30,
                      ),
                      Container(
                        child: Image.asset('assets/images/tempPicture4.png'),
                        color: Colors.white30,
                      ),
                      Container(
                        child: Image.asset('assets/images/tempPicture5.png'),
                        color: Colors.white30,
                      ),
                    ],
                  ),
                  buildHeadline("Kalendarz:"),
                  SfCalendar(
                    view: CalendarView.month,
                    backgroundColor: Colors.white30,
                    firstDayOfWeek: 1,
                    minDate: DateTime.utc(dateTime.year, dateTime.month),
                    showDatePickerButton: true,
                  ),
                  SizedBox(height: 50),
                  Container(
                    width: double.infinity,
                    color: Colors.white30,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 7.5),
                      child: AutoSizeText(
                        'Napisz do nas w razie pytań lub chęci współpracy',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20),
                        maxLines: 2,
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: Icon(Icons.question_answer_outlined),
                        iconSize: 80,
                        color: Colors.white,
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
                        icon: Icon(Icons.email_outlined),
                        iconSize: 80,
                        color: Colors.white,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => buildConfirmNewEmailDialog(
                              context,
                              snapshot.data.data()['email'],
                              snapshot.data.data()['firmName'],
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
    print(firm.id);
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
                  createNewChat(context, getCurrentUser(), firm);
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

  AlertDialog buildConfirmNewEmailDialog(BuildContext context, String email, String firmName) {
    print(firmName+' -> '+email);
    return AlertDialog(
      title: Text('Otowrzyć domyślną aplikację Email'),
      content: Text('Czy chcesz utworzyć nową wiadomość do $firmName'),
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
            final Uri _emailLaunchUri = Uri(scheme: 'mailto', path: email);
            sendEmail(_emailLaunchUri.toString());
          },
        ),
      ],
    );
  }

  Padding buildHeadline(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7.5),
      child: Text(text,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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