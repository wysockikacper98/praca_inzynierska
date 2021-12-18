import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'register_contractor_screen.dart';
import 'register_user_screen.dart';

class PickRegisterScreen extends StatelessWidget {
  static const routerName = '/pick-register';

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    print('build -> pick_register_screen');

    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Zarejestruj jako:'),
      //   elevation: 0.0,
      //   automaticallyImplyLeading: false,
      // ),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            SvgPicture.asset(
              'assets/svg/choose_no_person.svg',
              alignment: Alignment.bottomCenter,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Zarejestruj jako:",
                  style: TextStyle(fontSize: 24.0),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).colorScheme.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(30),
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            SvgPicture.asset(
                              'assets/svg/private_user.svg',
                              width: width * 0.2,
                            ),
                            Text("Użytkownik"),
                          ],
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(RegisterUserScreen.routerName);
                      },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(30),
                          ),
                        ),
                        primary: Theme.of(context).colorScheme.surface,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            SvgPicture.asset(
                              'assets/svg/worker.svg',
                              width: width * 0.2,
                            ),
                            Text("Wykonawca"),
                          ],
                        ),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterContractorScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
