import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyScreen extends StatelessWidget {
  static const String routeName = '/emergency-screen';

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> data = [
      {
        'icon': 'assets/icons/lightning.png',
        'title': 'Pogotowie elektryczne',
        'text':
            'Informacje w jakich przypadkach dzwonić pod pogotowie elektryczne',
        'phone': 991,
      },
      {
        'icon': 'assets/icons/gas.png',
        'title': 'Pogotowie gazowe',
        'text': 'Informacje w jakich przypadkach dzwonić pod pogotowie gazowe',
        'phone': 992,
      },
      {
        'icon': 'assets/icons/heating.png',
        'title': 'Pogotowie ciepłownicze',
        'text':
            'Informacje w jakich przypadkach dzwonić pod pogotowie ciepłownicze',
        'phone': 993,
      },
      {
        'icon': 'assets/icons/leak.png',
        'title': 'Pogotowie wodno-kanalizacyjne',
        'text':
            'Informacje w jakich przypadkach dzwonić pod pogotowie wodno-kanalizacyjne',
        'phone': 994,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Awarie"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (ctx, index) {
          return ExpansionTile(
            leading: Image.asset(
              data[index]['icon'],
              height: 60,
              width: 60,
            ),
            title: buildTitleInExpansionTile(data[index]['title']),
            tilePadding: EdgeInsets.all(10),
            childrenPadding: EdgeInsets.all(20),
            children: [
              Text(data[index]['text']),
              SizedBox(height: 20),
              ElevatedButton(
                child: Center(child: Icon(Icons.call)),
                style: ElevatedButton.styleFrom(primary: Colors.green),
                onPressed: () {
                  callPhone('tel:' + data[index]['phone'].toString());
                },
              )
            ],
          );
        },
      ),
    );
  }

  AutoSizeText buildTitleInExpansionTile(String text) => AutoSizeText(
        text,
        maxLines: 1,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20),
      );

  Future<void> callPhone(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
