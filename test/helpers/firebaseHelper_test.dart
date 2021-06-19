import 'package:flutter_test/flutter_test.dart';
import 'package:praca_inzynierska/helpers/sharedPreferences.dart';
import 'package:praca_inzynierska/models/details.dart';
import 'package:praca_inzynierska/models/firm.dart';
import 'package:praca_inzynierska/models/users.dart';
import 'package:praca_inzynierska/providers/UserProvider.dart';

void main() {
  group('Testing Shared Preferences', () {
    setUpAll(() async {
      print("SetUp");
      await clearUserInfo();
    });

    tearDown(() async {
      print("TearDown");
      await clearUserInfo();
    });

    test("Saving user data for Users class", () async {
      final user = Users(
          firstName: 'Imie',
          lastName: 'Nazwisko',
          email: 'email@email.com',
          telephone: '102945643',
          rating: '2.3',
          avatar: 'someString',
          type: UserType.PrivateUser);

      await saveUserInfo(user);

      expect(getCurrentUser().toString(), user.toString());
    });

    test("Saving user data for Firm class", () async {
      final details = Details(
        prices: 'Prices',
        calendar: 'Calendar',
        pictures: ['picutre1', 'picture2'],
        description: 'Description',
      );

      final firm = Firm(
        firstName: 'Imie',
        lastName: 'Nazwisko',
        email: 'email@email.com',
        telephone: '102945643',
        rating: '2.3',
        avatar: 'someString',
        category: ['Malarz', 'Ogród', 'Projektowanie'],
        firmName: 'TestFirmName',
        location: 'TestLocation',
        nip: '9829384756',
        range: '23.5',
        type: UserType.Firm,
        details: details,
      );
      await saveUserInfo(firm);
      expect(
          getCurrentUser().toString(),
          Users(
                  firstName: firm.firstName,
                  lastName: firm.lastName,
                  email: firm.email,
                  telephone: firm.telephone,
                  rating: firm.rating,
                  avatar: firm.avatar,
                  type: firm.type)
              .toString());
    });

    test("Decoding user info from Firm", () async {
      final details = Details(
        prices: 'Prices',
        calendar: 'Calendar',
        pictures: ['picutre1', 'picture2'],
        description: 'Description',
      );

      final firm = Firm(
        firstName: 'Imie',
        lastName: 'Nazwisko',
        email: 'email@email.com',
        telephone: '102945643',
        rating: '2.3',
        avatar: 'someString',
        category: ['Malarz', 'Ogród', 'Projektowanie'],
        firmName: 'TestFirmName',
        location: 'TestLocation',
        nip: '9829384756',
        range: '23.5',
        type: UserType.Firm,
        details: details,
      );
      saveUserInfo(firm);

      Users user = await getUserInfo();

      Users usersExpected = Users(
          firstName: firm.firstName,
          lastName: firm.lastName,
          email: firm.email,
          telephone: firm.telephone,
          rating: firm.rating,
          avatar: firm.avatar,
          type: firm.type);

      expect(usersExpected.toJson(), user.toJson());
    });
    test("Decoding user info from User", () async {
      final userExpected = Users(
          firstName: 'Imie',
          lastName: 'Nazwisko',
          email: 'email@email.com',
          telephone: '102945643',
          rating: '2.3',
          avatar: 'someString',
          type: UserType.PrivateUser);

      saveUserInfo(userExpected);

      Users user = await getUserInfo();


      expect(userExpected.toJson(), user.toJson());
    });
  });
}
