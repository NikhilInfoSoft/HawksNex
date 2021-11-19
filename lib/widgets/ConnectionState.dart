import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hawks/data/shared.dart';
import 'package:hawks/data/url.dart';
import 'package:hawks/data/variables.dart';
import 'package:hawks/onboarding/SplashScreen.dart';
import 'package:hawks/widgets/CustomButton.dart';
import 'package:hawks/widgets/CustomTextField.dart';

ConnectionStateWidget(BuildContext context, Function updateFunction) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            tallyConnected
                ? FaIcon(
                    FontAwesomeIcons.wifi,
                    size: 14,
                    color: Colors.black,
                  )
                : Container(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.black),
                    ),
                  ),
            SizedBox(width: 10),
            Text(
              'Tally ' + (tallyConnected ? 'Connected' : 'Connecting'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          children: [
            internetConnected
                ? FaIcon(
                    FontAwesomeIcons.wifi,
                    size: 14,
                    color: Colors.black,
                  )
                : Container(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.black),
                    ),
                  ),
            SizedBox(width: 10),
            Text(
              'Internet ' + (internetConnected ? 'Connected' : 'Connecting'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: updateFunction,
          child: Row(
            children: [
              FaIcon(
                FontAwesomeIcons.cloud,
                size: 14,
                color: Colors.black,
              ),
              SizedBox(width: 10),
              Text(
                'Check for Updates   -  ' + version,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () async {
            var data = await ShareDData().getUserData();
            TextEditingController _port = TextEditingController(
              text: (data['tallyPort'] ?? '9000').toString(),
            );
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  'Update Port',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                content: CustomTextField(
                  controller: _port,
                  labelText: 'Enter Port Number',
                ),
                actions: [
                  CustomButton(
                    child: Text('Update'),
                    onPressed: () async {
                      data['tallyPort'] = _port.text;
                      await ShareDData().setUserData(data);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SplashScreen(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            );
          },
          child: Row(
            children: [
              FaIcon(
                FontAwesomeIcons.link,
                size: 14,
                color: Colors.black,
              ),
              SizedBox(width: 10),
              Text(
                'Port  -  ' + tallyUrl.port.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () async {
            exit(0);
          },
          child: Row(
            children: [
              FaIcon(
                FontAwesomeIcons.signOutAlt,
                size: 14,
                color: Colors.black,
              ),
              SizedBox(width: 10),
              Text(
                'Exit',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
