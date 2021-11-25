import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';

import 'models/firm.dart';
import 'models/useful_data.dart';
import 'models/users.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/firm/firm_edit_profile_screen.dart';
import 'screens/firm/firm_profile_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/login/pick_register_screen.dart';
import 'screens/login/register_user_screen.dart';
import 'screens/orders/create_order_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/user/user_edit_profile_screen.dart';
import 'widgets/theme/theme_Provider.dart';
import 'widgets/theme/theme_dark.dart';
import 'widgets/theme/theme_light.dart';

///Receive message when app is in background solution for on message
Future<void> backgroundHandler(RemoteMessage message) async {
  print(message.data.toString());
  print(message.notification!.title);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  SharedPreferences.getInstance();
  // SystemChrome.setSystemUIOverlayStyle(
  //   SystemUiOverlayStyle(
  // statusBarColor: Colors.transparent,
  // systemNavigationBarColor: Colors.transparent,
  //       ),
  // );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("build -> main.dart");

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => UserProvider()),
        ChangeNotifierProvider(create: (ctx) => FirmProvider()),
        ChangeNotifierProvider(create: (ctx) => UsefulData()),
      ],
      child: ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
          builder: (context, _) {
            final themeProvider = Provider.of<ThemeProvider>(context);

            return MaterialApp(
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                SfGlobalLocalizations.delegate
              ],
              supportedLocales: [
                const Locale('pl'),
                const Locale('en'),
              ],
              // locale: const Locale('en'),
              locale: const Locale('pl'),
              title: 'FixIT!',
              debugShowCheckedModeBanner: false,
              themeMode: themeProvider.themeMode,
              darkTheme: themeDark(),
              theme: themeLight(),
              initialRoute: '/',
              routes: {
                '/': (ctx) => LoginScreen(),
                HomeScreen.routeName: (ctx) => HomeScreen(),
                LoginScreen.routeName: (ctx) => LoginScreen(),
                PickRegisterScreen.routerName: (ctx) => PickRegisterScreen(),
                RegisterUserScreen.routerName: (ctx) => RegisterUserScreen(),
                FirmProfileScreen.routeName: (ctx) => FirmProfileScreen(),
                EmergencyScreen.routeName: (ctx) => EmergencyScreen(),
                UserEditProfileScreen.routeName: (ctx) =>
                    UserEditProfileScreen(),
                FirmEditProfileScreen.routeName: (ctx) =>
                    FirmEditProfileScreen(),
                SearchScreen.routeName: (ctx) => SearchScreen(),
                SettingsScreen.routeName: (ctx) => SettingsScreen(),
                OrdersScreen.routeName: (ctx) => OrdersScreen(),
                CreateOrderScreen.routeName: (ctx) => CreateOrderScreen(),
                CalendarScreen.routeName: (ctx) => CalendarScreen(),
              },
            );
          }),
    );
  }
}
