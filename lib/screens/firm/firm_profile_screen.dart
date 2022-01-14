import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../helpers/colorful_print_messages.dart';
import '../../helpers/firebase_firestore.dart';
import '../../models/meeting.dart';
import '../../models/users.dart';
import '../../widgets/calculate_rating.dart';
import '../../widgets/firm/build_firm_info.dart';
import '../../widgets/theme/theme_Provider.dart';
import '../calendar/meeting_data_source.dart';
import '../comment/build_comment_section.dart';
import '../full_screen_image.dart';
import 'firm_edit_profile_screen.dart';

class FirmsAuth {
  final String firmID;

  FirmsAuth(this.firmID);
}

class FirmProfileScreen extends StatelessWidget {
  static const routeName = '/firm-profile';
  bool _initialize = false;
  late Future<DocumentSnapshot<Map<String, dynamic>>> _future;
  late Future<QuerySnapshot<Map<String, dynamic>>> _futureMeeting;

  Future<QuerySnapshot<Map<String, dynamic>>> getFirmMeeting(firmID) async {
    printColor(text: 'getFirmMeeting', color: PrintColor.cyan);
    return FirebaseFirestore.instance
        .collection('firms')
        .doc(firmID)
        .collection('meetings')
        .get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getFirmData(
      String firmID) async {
    printColor(text: 'getDataAboutFirm', color: PrintColor.magenta);
    return FirebaseFirestore.instance.collection('firms').doc(firmID).get();
  }

  initialize(String firmID) {
    if (!_initialize) {
      _future = getFirmData(firmID);
      _futureMeeting = getFirmMeeting(firmID);
      _initialize = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final FirmsAuth data =
        ModalRoute.of(context)!.settings.arguments as FirmsAuth;

    initialize(data.firmID);

    final String userID = FirebaseAuth.instance.currentUser!.uid;
    final UserType userType =
        Provider.of<UserProvider>(context, listen: false).user!.type;
    final bool _isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText('Profil Wykonawcy', maxLines: 1),
        centerTitle: true,
        actions: [
          if (data.firmID == userID)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => Navigator.of(context).pushNamed(
                FirmEditProfileScreen.routeName,
              ),
            ),
        ],
      ),
      body: FutureBuilder(
        future: _future,
        builder: (ctx,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            var pictures = snapshot.data!.data()!['details']['pictures'];
            final String firmAvatar = snapshot.data?.data()?['avatar'] ?? '';
            final String userAvatar =
                Provider.of<UserProvider>(context).user?.avatar ?? '';

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
                  buildHeadline("Zdjęcia:"),
                  buildPictures(pictures, context),
                  buildHeadline("Kalendarz:"),
                  buildCalendar(_isDarkMode),
                  buildCalendarLegend(),
                  SizedBox(height: 50),
                  if (userType != UserType.Firm)
                    buildContactIcons(
                      context,
                      userID,
                      snapshot,
                      _isDarkMode,
                      userAvatar,
                      firmAvatar,
                    ),
                  buildHeadline('Punktualność:'),
                  buildPunctuality(_isDarkMode, snapshot.data!.data()!),
                  SizedBox(height: 16),
                  BuildCommentSection(
                    data.firmID,
                    calculateRating(
                      snapshot.data!.data()!['rating'].toDouble(),
                      snapshot.data!.data()!['ratingNumber'].toDouble(),
                    ),
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

  Column buildContactIcons(
    BuildContext context,
    String userID,
    AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot,
    bool _isDarkMode,
    String userAvatar,
    String firmAvatar,
  ) {
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
              icon: Icon(
                Icons.question_answer_outlined,
                color:
                    _isDarkMode ? Colors.white : Theme.of(context).primaryColor,
              ),
              iconSize: 80,
              color: Theme.of(context).primaryColor,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => buildConfirmNewMessageDialog(
                    context,
                    userID,
                    snapshot.data,
                    userAvatar,
                    firmAvatar,
                  ),
                  barrierDismissible: true,
                );
              },
            ),
            IconButton(
              icon: Icon(
                Icons.phone,
                color:
                    _isDarkMode ? Colors.white : Theme.of(context).primaryColor,
              ),
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
              icon: Icon(
                Icons.email_outlined,
                color:
                    _isDarkMode ? Colors.white : Theme.of(context).primaryColor,
              ),
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

  Padding buildCalendar(bool _isDarkMode) {
    final DateTime date = DateTime.now();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: FutureBuilder(
        future: _futureMeeting,
        builder: (
          BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            return SfCalendar(
              view: CalendarView.month,
              backgroundColor: Colors.white30,
              firstDayOfWeek: 1,
              showCurrentTimeIndicator: false,
              minDate: DateTime.utc(date.year, date.month - 1),
              selectionDecoration: BoxDecoration(
                border: Border.all(
                  color: _isDarkMode
                      ? const Color(0xFF3F577B)
                      : const Color(0xFF6D80A5),
                  width: 2,
                ),
              ),
              showDatePickerButton: true,
              showNavigationArrow: true,
              todayHighlightColor: _isDarkMode
                  ? const Color(0xFF3F577B)
                  : const Color(0xFF6D80A5),
              todayTextStyle:
                  TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              viewHeaderStyle: ViewHeaderStyle(
                dayTextStyle: TextStyle(
                  color: _isDarkMode ? Colors.white : Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
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
                    border: Border.all(
                      color: Colors.black12,
                    ),
                  ),
                  child: _isDateNow(details.date)
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: _isDarkMode
                                    ? const Color(0xFF3F577B)
                                    : const Color(0xFF6D80A5),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Text(
                              details.date.day.toString(),
                              style: TextStyle(color: _textColor),
                            ),
                          ],
                        )
                      : Center(
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

  bool _isDateNow(DateTime date) {
    final dateNow = DateTime.now();
    if (dateNow.day == date.day &&
        dateNow.month == date.month &&
        dateNow.year == date.year) return true;
    return false;
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
                      // color: Colors.white30,
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
    BuildContext context,
    String userID,
    firm,
    String userAvatar,
    String firmAvatar,
  ) {
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
                  createNewChat(context, user!, firm, userAvatar, firmAvatar);
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

  Widget buildCalendarLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: EdgeInsets.all(10.0),
        color: Colors.white30,
        child: Column(
          children: [
            Container(
              height: 20,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0x8039D353),
                    const Color(0x80FF4D1A),
                  ],
                ),
              ),
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dostępny'),
                Text('Niedostępny'),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Container(
                  height: 20,
                  width: 20,
                  color: Colors.orange.shade100,
                ),
                SizedBox(width: 10),
                Text('Dnie wolne od pracy'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget buildPunctuality(bool _isDarkMode, Map<String, dynamic> data) {
    final Color color100To80 = const Color(0x80FF4D1A);
    final Color color80To60 = const Color(0x80FF9933);
    final Color color60To40 = const Color(0x80CEA83B);
    final Color color40To20 = const Color(0x809CB643);
    final Color color20To0 = const Color(0x8039D353);

    late final Color _iconColor;

    final double lateAmount =
        data['late'] == null ? 0 : data['late'] / data['ordersAmount'];
    final double extendedAmount =
        data['extended'] == null ? 0 : data['extended'] / data['ordersAmount'];
    final double averageAmount = (lateAmount + extendedAmount) / 2;

    if (averageAmount >= 0.8) {
      _iconColor = color100To80;
    } else if (averageAmount >= 0.6) {
      _iconColor = color80To60;
    } else if (averageAmount >= 0.4) {
      _iconColor = color60To40;
    } else if (averageAmount >= 0.2) {
      _iconColor = color40To20;
    } else {
      _iconColor = color20To0;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Spóźnionych:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '${(lateAmount * 100).round()}%',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Przedłużonych:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '${(extendedAmount * 100).round()}%',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                VerticalDivider(width: 32.0),
                Expanded(
                  flex: 1,
                  child: Icon(Icons.watch_later, size: 48, color: _iconColor),
                ),
              ],
            ),
          ),
        ],
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
