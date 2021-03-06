import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../helpers/firebase_firestore.dart';
import '../../helpers/regex_patterns.dart';
import '../../widgets/theme/theme_Provider.dart';
import 'pick_register_screen.dart';

class LoginFormScreen extends StatefulWidget {
  @override
  _LoginFormScreenState createState() => _LoginFormScreenState();
}

class _LoginFormScreenState extends State<LoginFormScreen> {
  late final Future<void> _future;

  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  late String _userEmail;
  late String _userPassword;
  bool _isLoading = false;
  bool _passwordVisible = false;

  Future<void> _trySubmit() async {
    setState(() {
      _isLoading = true;
    });

    final _isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (_isValid) {
      _formKey.currentState!.save();

      await loginUser(context, _userEmail.trim(), _userPassword.trim())
          .then((value) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _passwordController.text = '';
        }
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _future = getCategories(context);
  }

  @override
  Widget build(BuildContext context) {
    print('build -> login_form');
    final double _windowWith = MediaQuery.of(context).size.width;
    final double _logoWidth = _windowWith * 0.30;
    return Scaffold(
      appBar: AppBar(
        title: Text('Zaloguj'),
        elevation: 0.0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator());
            else
              return Center(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: _logoWidth * 1.3),
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: -_logoWidth * 1.3,
                          child: Align(
                            alignment: Alignment.center,
                            child: SvgPicture.asset(
                              'assets/svg/fix_it_logo.svg',
                              width: _logoWidth,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: buildLoginForm(context),
                        ),
                      ],
                    ),
                  ),
                ),
              );
          }),
    );
  }

  Form buildLoginForm(BuildContext context) {
    final Color _textFormFieldColor =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode
            ? const Color(0xFF353535)
            : const Color(0xFFF6F8F7);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(left: 24.0),
            decoration: BoxDecoration(
              color: _textFormFieldColor,
              borderRadius: BorderRadius.all(
                Radius.circular(40.0),
              ),
            ),
            child: TextFormField(
              key: ValueKey('email'),
              decoration: InputDecoration(
                hintText: 'Email',
                border: InputBorder.none,
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Prosz?? poda?? adres email.';
                } else if (!RegExp(RegexPatterns.emailPattern)
                    .hasMatch(value)) {
                  return 'Prosz?? poda?? poprawny adres email.';
                }
                return null;
              },
              onSaved: (value) {
                _userEmail = value!;
              },
            ),
          ),
          SizedBox(height: 16.0),
          Container(
            padding: EdgeInsets.only(
              left: 24.0,
            ),
            decoration: BoxDecoration(
              color: _textFormFieldColor,
              borderRadius: BorderRadius.all(
                Radius.circular(40.0),
              ),
            ),
            child: TextFormField(
              key: ValueKey('password'),
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: 'Has??o',
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() {
                    _passwordVisible = !_passwordVisible;
                  }),
                ),
              ),
              obscureText: !_passwordVisible,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Prosz?? poda?? has??o';
                } else if (value.length < 7) {
                  return 'Has??o musi mie?? przynajmniej 7 znak??w.';
                }
                return null;
              },
              onSaved: (value) {
                _userPassword = value!;
              },
            ),
          ),
          SizedBox(height: 20),
          if (!_isLoading)
            Container(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                child: Text(
                  'Zaloguj si??',
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  _trySubmit();
                },
              ),
            ),
          if (!_isLoading) SizedBox(height: 16.0),
          if (!_isLoading)
            TextButton(
              child: Text(
                'Zarejestruj si??',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                FocusScope.of(context).unfocus();
                Navigator.of(context).pushNamed(PickRegisterScreen.routerName);
              },
            ),
          if (_isLoading) CircularProgressIndicator(),
        ],
      ),
    );
  }
}
