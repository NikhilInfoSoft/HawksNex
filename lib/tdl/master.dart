import 'dart:convert';

import 'package:hawks/data/url.dart';
import 'package:hawks/tdl/tdl.dart';
import 'package:xml2json/xml2json.dart';
import 'package:http/http.dart' as http;

class Master {
  String company = '';
  Xml2Json jsonParse = Xml2Json();

  init() async {
    String tdl = '''
<ENVELOPE>
  <HEADER>
    <TALLYREQUEST>Export Data</TALLYREQUEST>
  </HEADER>
  <BODY>
    <EXPORTDATA>
      <REQUESTDESC>
        <REPORTNAME>List of Accounts</REPORTNAME>
        <STATICVARIABLES>
          <ACCOUNTTYPE>All Masters</ACCOUNTTYPE>
          <SVCURRENTCOMPANY>''' +
        company +
        '''</SVCURRENTCOMPANY>
          <SVEXPORTFORMAT>\$\$SysName:XML</SVEXPORTFORMAT>
        </STATICVARIABLES>
      </REQUESTDESC>
    </EXPORTDATA>
  </BODY>
</ENVELOPE>
''';

    var data = await TallyRequest().request(tdl);
    // jsonParse.parse(data);
    // var jsonData = jsonParse.toGData();
    // _upload(jsonData);
    _upload(data);
  }

  Master(String company) {
    this.company = company;
  }

  _upload(String jsonData) async {
    try {
      var response = await http.post(masterUrl, body: {
        'id': '30',
        'company': company,
        'data': jsonData,
      });

      if (response.statusCode != 200) {
        print('Internal Server Error');
      } else if (response.body != '') {
        var data = response.body;

        print(data);
      }
    } catch (e) {
      print(e);
    }
  }
}
