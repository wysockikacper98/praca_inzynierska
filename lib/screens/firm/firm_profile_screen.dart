import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:praca_inzynierska/helpers/colorfull_print_messages.dart';
import 'package:praca_inzynierska/models/meeting.dart';
import 'package:praca_inzynierska/screens/calendar/meeting_data_source.dart';
import 'package:praca_inzynierska/screens/comment/build_comment_section.dart';
import 'package:praca_inzynierska/widgets/calculate_rating.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../helpers/firebase_firestore.dart';
import '../../models/users.dart';
import '../../widgets/firm/build_firm_info.dart';
import '../full_screen_image.dart';

class FirmsAuth {
  final String firmID;

  FirmsAuth(this.firmID);
}

class FirmProfileScreen extends StatelessWidget {
  static const routeName = '/firm-profile';

  Future<QuerySnapshot<Map<String, dynamic>>> getFirmMeeting(firmID) async {
    printColor(text: 'getFirmMeeting', color: PrintColor.cyan);
    return FirebaseFirestore.instance
        .collection('firms')
        .doc(firmID)
        .collection('meetings')
        .get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getFirmData(firmID) async {
    printColor(text: 'getDataAboutFirm', color: PrintColor.magenta);
    return FirebaseFirestore.instance.collection('firms').doc(firmID).get();
  }

  @override
  Widget build(BuildContext context) {
    final FirmsAuth data =
        ModalRoute.of(context)!.settings.arguments as FirmsAuth;
    final String userID = FirebaseAuth.instance.currentUser!.uid;
    final UserType userType =
        Provider.of<UserProvider>(context, listen: false).user!.type;

    return Scaffold(
      appBar: AppBar(
        title: Text("Profil Wykonawcy"),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: getFirmData(data.firmID),
        builder: (ctx,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            var pictures = snapshot.data!.data()!['details']['pictures'];
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15),
                  buildFirmInfo(context, snapshot.data, true),
                  buildHeadline("Kategorie"),
                  buildChips(snapshot.data!.data()!['category'].cast<String>()),
                  buildHeadline("O nas"),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 7.5),
                    child:
                        Text(snapshot.data!.data()!['details']['description']),
                  ),
                  // TODO: Localization do not implemented yet
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7.5),
                  //   child: Text("Lokalizacja", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  // ),
                  buildHeadline("Zdjęcia:"),
                  buildPictures(pictures, context),
                  buildHeadline("Kalendarz:"),
                  buildCalendar(getFirmMeeting(data.firmID)),
                  SizedBox(height: 50),
                  if (userType != UserType.Firm)
                    buildContactIcons(context, userID, snapshot),
                  BuildCommentSection(
                      data.firmID,
                      calculateRating(
                        snapshot.data!.data()!['rating'].toDouble(),
                        snapshot.data!.data()!['ratingNumber'].toDouble(),
                      )),
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

  Column buildContactIcons(BuildContext context, String userID,
      AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
    return Column(
      children: [
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
        SizedBox(height: 50),
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
      ],
    );
  }

  Padding buildCalendar(Future<QuerySnapshot<Map<String, dynamic>>> _future) {
    final DateTime date = DateTime.now();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: FutureBuilder(
        future: _future,
        builder: (
          BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SfCalendar(
              view: CalendarView.month,
              backgroundColor: Colors.white30,
              firstDayOfWeek: 1,
              minDate: DateTime.utc(date.year, date.month),
              showDatePickerButton: true,
            );
          } else {
            return SfCalendar(
              view: CalendarView.month,
              backgroundColor: Colors.white30,
              firstDayOfWeek: 1,
              minDate: DateTime.utc(date.year, date.month),
              showDatePickerButton: true,
              monthViewSettings: MonthViewSettings(
                showTrailingAndLeadingDates: false,
                appointmentDisplayMode: MonthAppointmentDisplayMode.none,
              ),
              dataSource: MeetingDataSource(snapshot.data!.docs
                  .map((e) => Meeting.fromJson(e.data()))
                  .toList()),
              monthCellBuilder:
                  (BuildContext context, MonthCellDetails details) {
                final Color _background = getDayColor(context, details);
                final Color _textColor = Colors.black;
                return Container(
                  decoration: BoxDecoration(
                    color: _background,
                    border: Border.all(color: Colors.transparent, width: 0.5),
                  ),
                  child: Center(
                    child: Text(
                      details.date.day.toString(),
                      style: TextStyle(color: _textColor),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Color getDayColor(BuildContext context, MonthCellDetails currentDay) {
    if (currentDay.appointments.length == 0 &&
        (DateTime.sunday == currentDay.date.weekday ||
            DateTime.saturday == currentDay.date.weekday))
      return Colors.orange.shade100;

    int test = 0;
    currentDay.appointments.cast<Meeting>().forEach((meeting) {
      if (meeting.isAllDay) test = 100;
    });

    if (test > 0) return const Color(0x80FF4D1A);

    switch (currentDay.appointments.length) {
      case 0:
        return const Color(0x8039D353);
      case 1:
        return const Color(0x809CB643);
      case 2:
        return const Color(0x80CEA83B);
      case 3:
        return const Color(0x80FF9933);
      case 4:
      default:
        return const Color(0x80FF4D1A);
    }
  }

  Padding buildPictures(pictures, BuildContext context) {
    return Padding(
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
                      child: Image.network(pictures[index]),
                      color: Colors.white30,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) {
                        return FullScreenImage(
                            imageURLPath: pictures[index], tag: tag);
                      }),
                    );
                  },
                );
              },
            )
          : Center(
              child: Text('Brak zdjęć.'),
            ),
    );
  }

  Widget buildChips(List<String> _categories) {
    List<InputChip> list = [];

    _categories.forEach((value) {
      list.add(
        InputChip(
          showCheckmark: false,
          selected: true,
          label: Text(value),
          onSelected: (_) {},
        ),
      );
    });
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 5.0,
        children: list,
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
                  createNewChat(context, user!, firm);
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
