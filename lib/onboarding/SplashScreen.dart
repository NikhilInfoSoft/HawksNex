import 'package:flutter/material.dart';
import 'package:hawks/data/shared.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:hawks/data/url.dart';
// import 'package:hawks/data/local.backup';

class SplashScreen extends StatelessWidget {
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
  _data() async {
    try {
      await DesktopWindow.setWindowSize(Size(300, 350));

      Future.delayed(Duration(seconds: 3), () async {
        var data = await ShareDData().userLogged();

        if (data != null && data == true) {
          var user = await ShareDData().getUserData();
          if (user['tallyPort'] != null) {
            tallyUrl = Uri(
              scheme: 'http',
              host: 'localhost',
              port: int.parse(user['tallyPort'].toString()),
            );
          }
          Navigator.pushReplacementNamed(context, '/dashboard');
          await DesktopWindow.setWindowSize(Size(1050, 750));
        } else {
          Navigator.pushReplacementNamed(context, '/login');
          await DesktopWindow.setWindowSize(Size(350, 450));
        }
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _data();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: Container(
              child: Image.asset('assets/images/logo-light.png'),
            ),
          ),
          LinearProgressIndicator(
            minHeight: 2,
            valueColor: AlwaysStoppedAnimation(Colors.blue),
            backgroundColor: Colors.white24,
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}
