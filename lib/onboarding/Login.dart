import 'dart:convert';
import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hawks/data/shared.dart';
import 'package:hawks/data/unfocus.dart';
import 'package:hawks/data/url.dart';
import 'package:hawks/onboarding/termsandconditions.dart';
import 'package:hawks/widgets/AppBar.dart';
import 'package:hawks/widgets/CustomButton.dart';
import 'package:hawks/widgets/CustomTextField.dart';
import 'package:hawks/widgets/CustomToast.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Unfocus(context);
      },
      child: Scaffold(
        body: _mainBody(),
      ),
    );
  }
}

class _mainBody extends StatefulWidget {
  @override
  __mainBodyState createState() => __mainBodyState();
}

class __mainBodyState extends State<_mainBody> {
  bool _buttonClicked = false;

  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();

  _login() async {
    try {
      var email = _email.text;
      var password = _password.text;

      if (email == '' || password == '') {
        CustomToast(context, 'Please enter all fields..!!');
        return;
      }

      setState(() {
        _buttonClicked = true;
      });

      var response = await http.post(loginUrl, body: {
        'email': email,
        'password': password,
      });

      if (response.statusCode != 200) {
        CustomToast(context, 'Internal Server Error');
      } else if (response.body != '') {
        var data = jsonDecode(response.body);

        if (data['status'] == 200) {
          data['data']['tallyPort'] = 9000;
          if (await ShareDData().setUserData(data['data'])) {
            await DesktopWindow.setWindowSize(Size(1050, 750));
            tallyUrl = Uri(
              scheme: 'http',
              host: 'localhost',
              port: 9000,
            );
            Navigator.pushNamed(context, '/dashboard');
          }
        } else {
          CustomToast(context, data['message']);
        }
      }

      setState(() {
        _buttonClicked = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        _buttonClicked = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Container(
              width: 350,
              height: 450,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              decoration: BoxDecoration(
                color: Color(0xff655AFF),
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.grey,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/logo-light.png',
                        height: 80,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Login with your credentials',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 30),
                      CustomTextField(
                        labelText: 'Enter Email',
                        controller: _email,
                        color: Colors.white,
                      ),
                      SizedBox(height: 10),
                      CustomTextField(
                        labelText: 'Enter Password',
                        controller: _password,
                        obscureText: true,
                        color: Colors.white,
                      ),
                      SizedBox(height: 30),
                      CustomButton(
                        child: Text(
                          'Login',
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: _login,
                        buttonClicked: _buttonClicked,
                        color: Colors.white,
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await DesktopWindow.setWindowSize(
                                  Size(1050, 750));
                              Navigator.pushNamed(context, '/register');
                            },
                            child: Text(
                              'Register New User',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
