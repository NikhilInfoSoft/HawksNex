import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hawks/data/shared.dart';
import 'package:hawks/widgets/WindowButtons.dart';

class SettingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _mainBody(),
    );
  }
}

class _mainBody extends StatefulWidget {
  @override
  __mainBodyState createState() => __mainBodyState();
}

class __mainBodyState extends State<_mainBody> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          WindowButtons(back: true, context: context),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 320,
                  height: double.infinity,
                  child: Column(
                    children: [
                      SizedBox(height: 100),
                      ListTile(
                        onTap: () {
                          // Navigator.pushNamed(context, '/settings');
                        },
                        title: Text('Companies'),
                        trailing: FaIcon(
                          FontAwesomeIcons.syncAlt,
                          size: 14,
                          color: Colors.black,
                        ),
                      ),
                      ListTile(
                        onTap: () async {
                          // if (await ShareDData().logout()) {
                          //   Navigator.pushNamedAndRemoveUntil(
                          //     context,
                          //     '/login',
                          //     (route) => false,
                          //   );
                          //   return;
                          // }
                        },
                        title: Text('Logout'),
                        trailing: FaIcon(
                          FontAwesomeIcons.signOutAlt,
                          size: 14,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
