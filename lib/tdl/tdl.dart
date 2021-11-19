import 'dart:convert';
import '../data/shared.dart';
import '../data/url.dart';
import 'package:http/http.dart' as http;

class TallyRequest {
  request(String tdl) async {
    try {
      var response = await http.post(
        tallyUrl,
        body: tdl,
        headers: {
          'Content-type': 'text/xml',
        },
      );

      if (response.statusCode != 200) {
        print('Internal Server Error');
      } else if (response.body != '') {
        return response.body;
      }
    } catch (e) {
      print(e);
    }
  }

  tallyToServer(
    Uri url,
    String company,
    String data, {
    bool debug = false,
  }) async {
    try {
      if (!(await ShareDData().userLogged())) {
        return false;
      }

      Map user = await ShareDData().getUserData();
      var response = await http.post(url, body: {
        'id': user['Id'].toString(),
        'company': company,
        'data': data,
      });

      if (debug) {
        print(response.body);
      }

      if (response.statusCode != 200) {
        print('Internal Server Error');
      } else if (response.body != '') {
        var data = jsonDecode(response.body);

        if (data['status'] != 200) {
          print(data['message']);
        } else {
          return data;
        }
      }
    } catch (e) {
      print(e);
    }
  }
}
