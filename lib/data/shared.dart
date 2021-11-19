import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:dart_app_data/src/locator.dart';

class ShareDData {
  File file;

  ShareDData() {
    try {
      // var data = Platform.resolvedExecutable;
      // var data = path.current + '\\user_data.json';
      var data =
          Locator.getPlatformSpecificCachePath() + '\\hawks\\user_data.json';
      file = File(data);
    } catch (e) {
      print(e);
    }
  }

  userLogged() async {
    try {
      if (await file.exists()) {
        return true;
      }

      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  getUserData() async {
    try {
      if (!(await userLogged())) {
        return {};
      }

      var data = await file.readAsString();
      return jsonDecode(data);
    } catch (e) {
      print(e);
    }
  }

  setUserData(Map data) async {
    try {
      if (!file.existsSync()) {
        file.createSync(recursive: true);
      }

      await file.writeAsString(jsonEncode(data));
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  setSyncing(bool isSync) async {
    try {
      if (!file.existsSync()) {
        file.createSync(recursive: true);
      }

      var data = await file.readAsString();
      var jsonData = jsonDecode(data);
      jsonData['isSync'] = isSync;
      await file.writeAsString(jsonEncode(jsonData));
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  isSyncing() async {
    try {
      if (!file.existsSync()) {
        file.createSync(recursive: true);
      }

      var data = await file.readAsString();
      var jsonData = jsonDecode(data);
      if (jsonData['isSync'] == null || !jsonData['isSync']) {
        return false;
      }

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  logout() async {
    try {
      await file.delete();
      return true;
    } catch (e) {
      print(e);
    }
  }
}
