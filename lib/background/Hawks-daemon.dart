import 'dart:async';
import 'dart:io';

import '../data/shared.dart';
import '../controller/Sync.dart';
import '../controller/ServerToTally.dart';
import '../controller/CompanyList.dart';
import '../data/url.dart';
import 'package:http/http.dart' as http;

List _companyList = [];
String version = '1.0.0';

class MyOverride extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main(List<String> args) async {
  HttpOverrides.global = MyOverride();
  var user = await ShareDData().getUserData();
  tallyUrl = Uri(
    scheme: 'http',
    host: 'localhost',
    port: int.parse(user['tallyPort'].toString()),
  );
  Timer.periodic(Duration(minutes: 15), (timer) async {
    if (await ShareDData().isSyncing()) {
      return;
    }

    var response = await http.get(
      Uri.parse('https://hawksindia.in/desktop/version.txt'),
    );
    if (response.statusCode == 200) {
      if (version != response.body.trim()) {
        return;
      }
    }

    await tallyCompanyList();
    for (var item in _companyList) {
      var data = ServerToTally(item['name']);
      await data.init();
    }
  });

  Timer.periodic(Duration(minutes: 35), (timer) async {
    if (await ShareDData().isSyncing()) {
      return;
    }

    var response = await http.get(
      Uri.parse('https://hawksindia.in/desktop/version.txt'),
    );
    if (response.statusCode == 200) {
      if (version != response.body.trim()) {
        return;
      }
    }

    await tallyCompanyList();
    var data = SyncTally(_companyList);
    await data.init();
  });
}

tallyCompanyList() async {
  try {
    var data = await TallyCompany().getCompanyList();
    _companyList.clear();

    if (data['LISTOFCOMPANIES']['NAME'] is Map) {
      _companyList.add({
        'name': data['LISTOFCOMPANIES']['NAME']['\$t'],
        'value': false,
        'data': {
          'name': data['LISTOFCOMPANIES']['NAME']['\$t'],
          'syncFromDate': data['LISTOFCOMPANIES']['THISYEARBEG']['\$t'],
          'syncToDate': data['LISTOFCOMPANIES']['THISYEAREND']['\$t'],
          'email': data['LISTOFCOMPANIES']['EMAIL']['\$t'] ?? '',
          'country': data['LISTOFCOMPANIES']['COUNTRYNAME']['\$t'] ?? '',
          'state': data['LISTOFCOMPANIES']['STATENAME']['\$t'] ?? '',
          'pincode': data['LISTOFCOMPANIES']['PINCODE']['\$t'] ?? '',
          'phone': data['LISTOFCOMPANIES']['PHONENUMBER']['\$t'] ?? '',
          'income': data['LISTOFCOMPANIES']['INCOMETAXNUMBER']['\$t'] ?? '',
          'vat': data['LISTOFCOMPANIES']['VATTINNUMBER']['\$t'] ?? '',
          'gst': data['LISTOFCOMPANIES']['GSTREGISTRATIONNUMBER']['\$t'] ?? '',
          'pan': data['LISTOFCOMPANIES']['PANNUMBER']['\$t'] ?? '',
          'cin': data['LISTOFCOMPANIES']['CINNUMBER']['\$t'] ?? '',
          'company': data['LISTOFCOMPANIES']['COMPANYNUMBER']['\$t'] ?? '',
          'address': (data['LISTOFCOMPANIES']['_ADDRESS1']['\$t'] ?? '') +
              (data['LISTOFCOMPANIES']['_ADDRESS2']['\$t'] ?? '') +
              (data['LISTOFCOMPANIES']['_ADDRESS3']['\$t'] ?? ''),
          'vatapplicable':
              data['LISTOFCOMPANIES']['VATAPPLICABLE']['\$t'] ?? '',
          'gstapplicable': data['LISTOFCOMPANIES']['ISGSTON']['\$t'] ?? '',
          'startfrom': data['LISTOFCOMPANIES']['STARTINGFROM']['\$t'] ?? '',
        },
      });
    } else if (data['LISTOFCOMPANIES']['NAME'] is List) {
      for (var i = 0; i < data['LISTOFCOMPANIES']['NAME'].length; i++) {
        _companyList.add({
          'name': data['LISTOFCOMPANIES']['NAME'][i]['\$t'],
          'value': false,
          'data': {
            'name': data['LISTOFCOMPANIES']['NAME'][i]['\$t'],
            'syncFromDate': data['LISTOFCOMPANIES']['THISYEARBEG'][i]['\$t'],
            'syncToDate': data['LISTOFCOMPANIES']['THISYEAREND'][i]['\$t'],
            'email': data['LISTOFCOMPANIES']['EMAIL'][i]['\$t'] ?? '',
            'country': data['LISTOFCOMPANIES']['COUNTRYNAME'][i]['\$t'] ?? '',
            'state': data['LISTOFCOMPANIES']['STATENAME'][i]['\$t'] ?? '',
            'pincode': data['LISTOFCOMPANIES']['PINCODE'][i]['\$t'] ?? '',
            'phone': data['LISTOFCOMPANIES']['PHONENUMBER'][i]['\$t'] ?? '',
            'income':
                data['LISTOFCOMPANIES']['INCOMETAXNUMBER'][i]['\$t'] ?? '',
            'vat': data['LISTOFCOMPANIES']['VATTINNUMBER'][i]['\$t'] ?? '',
            'gst': data['LISTOFCOMPANIES']['GSTREGISTRATIONNUMBER'][i]['\$t'] ??
                '',
            'pan': data['LISTOFCOMPANIES']['PANNUMBER'][i]['\$t'] ?? '',
            'cin': data['LISTOFCOMPANIES']['CINNUMBER'][i]['\$t'] ?? '',
            'company': data['LISTOFCOMPANIES']['COMPANYNUMBER'][i]['\$t'] ?? '',
            'address': (data['LISTOFCOMPANIES']['_ADDRESS1'][i]['\$t'] ?? '') +
                (data['LISTOFCOMPANIES']['_ADDRESS2'][i]['\$t'] ?? '') +
                (data['LISTOFCOMPANIES']['_ADDRESS3'][i]['\$t'] ?? ''),
            'vatapplicable':
                data['LISTOFCOMPANIES']['VATAPPLICABLE'][i]['\$t'] ?? '',
            'gstapplicable': data['LISTOFCOMPANIES']['ISGSTON'][i]['\$t'] ?? '',
            'startfrom':
                data['LISTOFCOMPANIES']['STARTINGFROM'][i]['\$t'] ?? '',
          },
        });
      }
    }
  } catch (e) {
    print(e);
  }
}
