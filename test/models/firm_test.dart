import 'package:flutter_test/flutter_test.dart';
import 'package:praca_inzynierska/models/details.dart';
import 'package:praca_inzynierska/models/firm.dart';
import 'package:praca_inzynierska/models/users.dart';

void main() {
  group('Testing json converting', () {
    late Firm _firm;

    setUp(() {
      _firm = Firm(
        firmName: 'FirmNameTest',
        firstName: 'FirstNameTest',
        lastName: 'LastNameTest',
        telephone: '123123123',
        type: UserType.Firm,
        nip: '1231231231',
        rating: 3.5,
        avatar: 'string/array/to/avatar/link',
        email: 'firm@email.com',
        details: Details(
          description: 'Firm description',
          pictures: ['string', 'array', 'here'],
          prices: '123',
        ),
        range: '123',
        location: 'Rzeszow',
        category: ['here', 'some', 'category'],
      );
    });

    test('Firm to JSON', () {
      var testFirm = _firm.toJson();

      Firm matcherFirm = Firm.fromJson(testFirm);
      print(testFirm.toString());
      print(matcherFirm.toString());

      expect(_firm.toString(), matcherFirm.toString());
    });
  });
}
