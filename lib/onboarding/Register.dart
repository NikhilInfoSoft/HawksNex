import 'dart:convert';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hawks/data/unfocus.dart';
import 'package:hawks/data/url.dart';
import 'package:hawks/onboarding/termsandconditions.dart';
import 'package:hawks/widgets/AppBar.dart';
import 'package:hawks/widgets/CustomButton.dart';
import 'package:hawks/widgets/CustomDropdown.dart';
import 'package:hawks/widgets/CustomTextField.dart';
import 'package:hawks/widgets/CustomToast.dart';
import 'package:hawks/widgets/CutsomCheckBox.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Unfocus(context);
      },
      child: Scaffold(
        appBar: CustomAppBar(
          context: context,
          title: 'Register',
        ),
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
  bool _agreed = false;
  int _licenseTypeValue = 0;
  List _licenseTypeList = [
    {
      'name': 'Select Tally License Type',
      'value': 'NULL',
    },
    {
      'name': 'Silver',
      'value': 'Silver',
    },
    {
      'name': 'Gold',
      'value': 'Gold',
    },
  ];

  TextEditingController _username = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _mobile = TextEditingController();
  TextEditingController _companyName = TextEditingController();
  TextEditingController _companyAddress = TextEditingController();
  TextEditingController _tallySerialNumber = TextEditingController();
  TextEditingController _natureBusiness = TextEditingController();
  TextEditingController _numberOfEmployees = TextEditingController();
  TextEditingController _contactPerson = TextEditingController();
  TextEditingController _designation = TextEditingController();

  _register() async {
    try {
      var username = _username.text;
      var email = _email.text;
      var password = _password.text;
      var mobile = _mobile.text;
      var companyName = _companyName.text;
      var companyAddress = _companyAddress.text;
      var tallySerialNumber = _tallySerialNumber.text;
      var tallyLicenseValue = _licenseTypeList[_licenseTypeValue]['value'];
      var natureBusiness = _natureBusiness.text;
      var noEmployees = _numberOfEmployees.text;
      var contactPerson = _contactPerson.text;
      var designation = _designation.text;

      if (username == '' ||
          email == '' ||
          password == '' ||
          mobile == '' ||
          companyName == '' ||
          companyAddress == '' ||
          tallySerialNumber == '' ||
          natureBusiness == '' ||
          noEmployees == '' ||
          contactPerson == '') {
        CustomToast(context, 'Please fill all the fields..!!');
        return;
      } else if (_licenseTypeValue == 0) {
        CustomToast(context, 'Please select valid license type value..!!');
        return;
      } else if (!_agreed) {
        CustomToast(context, 'Please select agreed..!!');
        return;
      }

      setState(() {
        _buttonClicked = true;
      });

      var response = await http.post(registerUrl, body: {
        'email': email,
        'password': password,
        'mobile': mobile,
        'username': username,
        'companyName': companyName,
        'companyAddress': companyAddress,
        'tallySerialNumber': tallySerialNumber,
        'tallyLicenseValue': tallyLicenseValue,
        'natureBusiness': natureBusiness,
        'noEmployees': noEmployees,
        'contactPerson': contactPerson,
        'contactNumber': mobile,
        'contactMail': email,
        'designation': designation,
      });

      if (response.statusCode != 200) {
        CustomToast(context, 'Internal Server Error');
      } else if (response.body != '') {
        var data = jsonDecode(response.body);

        if (data['status'] == 200) {
          CustomToast(context, 'Registration Successful..!! Please login..!!');
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
          await DesktopWindow.setWindowSize(Size(350, 450));
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
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 30),
            color: Colors.grey.withOpacity(.2),
            child: Center(
              child: Container(
                width: 650,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.grey,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Register New User',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 30),
                    CustomTextField(
                      labelText: 'Username',
                      controller: _username,
                      color: Colors.black,
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Flexible(
                          child: CustomTextField(
                            labelText: 'Email',
                            controller: _email,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 10),
                        Flexible(
                          child: CustomTextField(
                            labelText: 'Password',
                            obscureText: true,
                            controller: _password,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Flexible(
                          child: CustomTextField(
                            labelText: 'Company Name',
                            controller: _companyName,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 10),
                        Flexible(
                          child: CustomTextField(
                            labelText: 'Company Adddress',
                            controller: _companyAddress,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Flexible(
                          child: CustomTextField(
                            labelText: 'Contact Person',
                            controller: _contactPerson,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 10),
                        Flexible(
                          child: CustomTextField(
                            labelText: 'Designation',
                            controller: _designation,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Flexible(
                          child: CustomTextField(
                            labelText: 'Mobile',
                            controller: _mobile,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 10),
                        Flexible(
                          child: CustomTextField(
                            labelText: 'Tally Serial Number',
                            controller: _tallySerialNumber,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    CustomDropdown(
                      value: _licenseTypeValue,
                      items: _licenseTypeList,
                      onChange: (value) {
                        setState(() {
                          _licenseTypeValue = value;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Flexible(
                          child: CustomTextField(
                            labelText: 'Nature of Business',
                            controller: _natureBusiness,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 10),
                        Flexible(
                          child: CustomTextField(
                            labelText: 'Number of Total Employees',
                            controller: _numberOfEmployees,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    CustomCheckBox(
                      value: _agreed,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'I agree to the ',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: 'Terms & Conditions',
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TermsAndConditions(),
                                      ),
                                    ),
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _agreed = value;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    CustomButton(
                      child: Text('Register'),
                      onPressed: _register,
                      buttonClicked: _buttonClicked,
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
