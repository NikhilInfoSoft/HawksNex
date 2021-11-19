import 'package:flutter/material.dart';
import 'package:hawks/dashboard/Dashboard.dart';
import 'package:hawks/dashboard/Settings.dart';
import 'package:hawks/dashboard/SyncData.dart';
import 'package:hawks/onboarding/Login.dart';
import 'package:hawks/onboarding/Register.dart';
import 'package:hawks/onboarding/SplashScreen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    _changePage(Widget func) {
      return MaterialPageRoute(builder: (_) => func);
    }

    var args = settings.arguments;

    switch (settings.name) {
      case '/':
        return _changePage(SplashScreen());
      case '/login':
        return _changePage(LoginScreen());
      case '/register':
        return _changePage(RegisterScreen());
      case '/dashboard':
        return _changePage(Dashboard());
      case '/settings':
        return _changePage(SettingScreen());
      case '/syncdata':
        return _changePage(SyncData(companies: args));
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Invalid Route'),
            ),
          ),
        );
    }
  }
}
