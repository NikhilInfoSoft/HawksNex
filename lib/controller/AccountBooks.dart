import 'dart:convert';

import 'package:hawks/controller/DataClean.dart';
import 'package:hawks/data/variables.dart';
import 'package:hawks/tdl/tdl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:xml2json/xml2json.dart';
import 'package:hawks/data/url.dart';

class AccountBooks {
  Xml2Json jsonParse = Xml2Json();

  // Accounts
  getAccounts(String company, String type) async {
    try {
      String tdl = '''
<ENVELOPE>
    <HEADER>
        <TALLYREQUEST>Export Data</TALLYREQUEST>
    </HEADER>
    <BODY>
        <EXPORTDATA>
            <REQUESTDESC>
                <STATICVARIABLES>
                    <SVEXPORTFORMAT>\$\$SysName:XML</SVEXPORTFORMAT>
                    <SVFROMDATE TYPE="Date">''' +
          Jiffy(syncFrom).format('dd-MMM-yyyy') +
          '''</SVFROMDATE>
                    <SVTODATE TYPE="Date">''' +
          Jiffy(syncTo).format('dd-MMM-yyyy') +
          '''</SVTODATE>
                    <SVCURRENTCOMPANY>''' +
          company +
          '''</SVCURRENTCOMPANY>
                    <EXPLODEFLAG>Yes</EXPLODEFLAG>
                </STATICVARIABLES>
                <REPORTNAME>''' +
          type +
          '''</REPORTNAME>
            </REQUESTDESC>
        </EXPORTDATA>
    </BODY>
</ENVELOPE>
      ''';

      var data = await TallyRequest().request(tdl);
      data = DataClean(data);
      jsonParse.parse(data);
      var jsonData = jsonParse.toGData();
      return jsonData;
    } catch (e) {
      print(e);
    }
  }

  parseDataUpload(String data) {
    try {
      var jsonData = jsonDecode(data)['ENVELOPE'];
      var list = [];

      for (var i = 0; i < jsonData['DSPPERIOD'].length; i++) {
        var d = {
          'nameValue': DataClean(jsonData['DSPPERIOD'][i]['\$t'], quote: true),
          'drValue':
              jsonData['DSPACCINFO'][i]['DSPDRAMT']['DSPDRAMTA']['\$t'] ?? 0,
          'crValue':
              jsonData['DSPACCINFO'][i]['DSPCRAMT']['DSPCRAMTA']['\$t'] ?? 0,
          'closingValue':
              jsonData['DSPACCINFO'][i]['DSPCLAMT']['DSPCLAMTA']['\$t'] ?? 0,
        };
        list.add(d);
      }

      return jsonEncode(list);
    } catch (e) {
      print(e);
    }
  }

  // Upload Fiancial Statements
  uploadAccountBooks(String company, String data) async {
    try {
      await TallyRequest().tallyToServer(accountBooksUrl, company, data);
    } catch (e) {
      print(e);
    }
  }
}
