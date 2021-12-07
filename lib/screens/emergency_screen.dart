import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyScreen extends StatelessWidget {
  static const String routeName = '/emergency-screen';

  @override
  Widget build(BuildContext context) {
    const String bullet = '\u2022';

    List<Map<String, dynamic>> data = [
      {
        'icon': 'assets/icons/lightning.png',
        'title': 'Pogotowie elektryczne',
        'text': 'Kiedy dzwonić:',
        'subText':
            '''$bullet w przypadku uszkodzenia linii energetycznej lub uszkodzeń zamknięć do obiektów energetycznych (np. zerwana kłódka, otwarte drzwi do stacji transformatorowej)

$bullet gdy nie ma prądu w twojej okolicy, dzielnicy, miejscowości

$bullet gdy dostrzeżesz, że twój licznik nie działa prawidłowo, powoduje brak zasilania lub zagrożenie dla życia

$bullet zerwałeś plombę, wymieniając bezpiecznik przedlicznikowy''',
        'phone': 991,
      },
      {
        'icon': 'assets/icons/gas.png',
        'title': 'Pogotowie gazowe',
        'text': 'Kiedy dzwonić:',
        'subText': '''$bullet jeśli wyczuwasz ulatniający się gaz

$bullet jeśli przypuszczasz, że sieć lub instalacja gazowa mogła ulec uszkodzeniu

$bullet jeśli zauważyłeś znaczny spadek ciśnienia gazu lub jego całkowity brak''',
        'phone': 992,
      },
      {
        'icon': 'assets/icons/heating.png',
        'title': 'Pogotowie ciepłownicze',
        'text': 'Kiedy dzwonić:',
        'subText':
            '''$bullet w przypadku awarii sieci ciepłowniczej (np. wyciekach)
        
$bullet awariach w dostawie ciepła i ciepłej wody użytkowej

$bullet w przypadku chęci uzyskania informacji o stanie sieci i trwających oraz przyszłych naprawach''',
        'phone': 993,
      },
      {
        'icon': 'assets/icons/leak.png',
        'title': 'Pogotowie wodno-kanalizacyjne',
        'text': 'Kiedy dzwonić:',
        'subText': '''$bullet w awariach przyłączy wodociągowych
        
$bullet w awariach sieci wodociągowych
        
$bullet w przypadku niskiego ciśnienia na przyłączu wodociągowym
        
$bullet w przypadku uszkodzenia wodomierza głównego
        
$bullet w awaraich sieci kanalizacyjnej oraz zatorach kanalizacyjnych
        
$bullet w przypadku uszkodzenia studni kanalizacji sanitarnej i deszczowej
        
$bullet w awariach przydomowych przepompowni ścieków''',
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
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            leading: Image.asset(
              data[index]['icon'],
              height: 60,
              width: 60,
            ),
            title: buildTitleInExpansionTile(data[index]['title']),
            tilePadding: EdgeInsets.all(10),
            childrenPadding: EdgeInsets.all(20),
            children: [
              Text(
                data[index]['text'],
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 20),
              Text(
                data[index]['subText'],
                style: Theme.of(context).textTheme.subtitle1,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Center(child: Icon(Icons.call)),
                style: ElevatedButton.styleFrom(primary: Colors.green),
                onPressed: () {
                  callPhone('tel:' + data[index]['phone'].toString());
                },
              ),
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
