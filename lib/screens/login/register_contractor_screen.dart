import 'package:flutter/material.dart';

class RegisterContractorScreen extends StatefulWidget {
  static const routeName = '/register-contractor';

  @override
  _RegisterContractorScreenState createState() =>
      _RegisterContractorScreenState();
}

class _RegisterContractorScreenState extends State<RegisterContractorScreen> {
  final Map<String, bool> _categoriesList = {
    'Budowa domu': false,
    'Elektryk': false,
    'Hydraulik': false,
    'Malarz': false,
    'Meble i zabudowa': false,
    'Montaż i naprawa': false,
    'Motoryzacja': false,
    'Ogród': false,
    'Organizacja imprez': false,
    'Projektowanie': false,
    'Remont': false,
    'Sprzątanie': false,
    'Szkolenia i języki obce': false,
    'Transport': false,
    'Usługi dla biznesu': false,
    'Usługi finansowe': false,
    'Usługi prawne i administracyjne': false,
    'Usługi zdalne': false,
    'Zdrowie i uroda': false,
    'Złota rączka': false,
  };

  var _countSelected = 0;

  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _pickCategory = true;

  void _trySubmit(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SafeArea(
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 20, horizontal: 5),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Rejestracja jako wykonawca',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 20),
                  if (_pickCategory)
                    Container(
                      width: double.infinity,
                      child: Text(
                        'Zaznacz, czym się zajmujesz:',
                        textAlign: TextAlign.start,
                      ),
                    ),
                  SizedBox(height: 20),
                  _pickCategory
                      ? Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _categoriesList.length,
                            itemBuilder: (context, index) {
                              String key =
                                  _categoriesList.keys.elementAt(index);
                              return CheckboxListTile(
                                  value: _categoriesList[key],
                                  title: Text("$key"),
                                  onChanged: (value) {
                                    setState(() {
                                      _categoriesList[key] = value;
                                      if (value) {
                                        _countSelected++;
                                      } else {
                                        _countSelected--;
                                      }
                                    });
                                  });
                            },
                          ),
                        )
                      : Form(
                        key: _formKey,
                          child: Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextFormField(
                                    decoration: InputDecoration(labelText: 'Nazwa firmy lub Wykonawcy'),
                                    validator: (value){
                                      if(value.isEmpty || value.length < 3){
                                        return 'Error message';
                                      }
                                      return null;
                                    },
                                  ),
                                  TextFormField(),
                                  TextFormField(),
                                  TextFormField(),
                                  TextFormField(),
                                  TextFormField(),
                                  TextFormField(),
                                  TextFormField(),
                                  TextFormField(),
                                  TextFormField(),
                                ],
                              ),
                            ),
                          ),
                        ),
                  SizedBox(height: 20),
                  if (!_isLoading)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          child: const Text("Cofnij"),
                          style:
                              ElevatedButton.styleFrom(primary: Colors.green),
                          onPressed: _pickCategory
                              ? () => Navigator.of(context).pop()
                              : () => setState(() {
                                    _pickCategory = !_pickCategory;
                                  }),
                        ),
                        if (_pickCategory)
                          ElevatedButton(
                            child: Text('Dalej ($_countSelected)'),
                            onPressed: _countSelected == 0
                                ? null
                                : () => setState(() {
                                      _pickCategory = !_pickCategory;
                                    }),
                          ),
                        if (!_pickCategory)
                          ElevatedButton(
                            child: Text("Zarejestruj"),
                            onPressed: () {},
                          )
                      ],
                    ),
                  if (_isLoading) CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
