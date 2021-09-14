import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'models/firm.dart';
import 'models/users.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
        // statusBarColor: Colors.transparent,
        // systemNavigationBarColor: Colors.transparent,
        ),
  );
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
      ],
      child: ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
          builder: (context, _) {
            final themeProvider = Provider.of<ThemeProvider>(context);

            return MaterialApp(
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
              },
            );
          }),
    );
  }
}
