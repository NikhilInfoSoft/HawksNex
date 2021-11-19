import 'dart:convert';

import 'package:hawks/controller/DataClean.dart';
import 'package:hawks/data/url.dart';
import 'package:hawks/data/variables.dart';
import 'package:hawks/tdl/tdl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:xml2json/xml2json.dart';

class Outstanding {
  Xml2Json jsonParse = Xml2Json();

  // Receivables Outstandings
  getReceivables(String company) async {
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
                </STATICVARIABLES>
                <REPORTNAME>Bills Receivable</REPORTNAME>
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

  // Payables Outstandings
  getPayables(String company) async {
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
                </STATICVARIABLES>
                <REPORTNAME>Bills Payable</REPORTNAME>
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

  // Ledger Outstandings
  getLedgers(String company, String ledger) async {
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
                    <LEDGERNAME>''' +
          ledger +
          '''</LEDGERNAME>
                    <SVEXPORTFORMAT>\$\$SysName:XML</SVEXPORTFORMAT>
                    <EXPLODEFLAG>No</EXPLODEFLAG>
                    <SVFROMDATE TYPE="Date">''' +
          Jiffy(syncFrom).format('dd-MMM-yyyy') +
          '''</SVFROMDATE>
                    <SVTODATE TYPE="Date">''' +
          Jiffy(syncTo).format('dd-MMM-yyyy') +
          '''</SVTODATE>
                    <SVCURRENTCOMPANY>''' +
          company +
          '''</SVCURRENTCOMPANY>
                </STATICVARIABLES>
                <REPORTNAME>Ledger Outstandings</REPORTNAME>
            </REQUESTDESC>
        </EXPORTDATA>
    </BODY>
</ENVELOPE>
      ''';

      var data = await TallyRequest().request(tdl);
      if (data == null || data == '') return false;
      data = DataClean(data);
      jsonParse.parse(data);
      var jsonData = jsonParse.toGData();
      return jsonData;
    } catch (e) {
      print(e);
    }
  }

  // Group Outstandings
  getGroup(String company, String group) async {
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
                    <GROUPNAME>''' +
          group +
          '''</GROUPNAME>
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
                </STATICVARIABLES>
                <REPORTNAME>Group Outstandings</REPORTNAME>
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

  // Upload Outstandings
  uploadOutstandings(String company, String data, {bool debug = false}) async {
    try {
      await TallyRequest().tallyToServer(
        outstandingsUrl,
        company,
        data,
        debug: debug,
      );
    } catch (e) {
      print(e);
    }
  }

  // Parsing Data
  parseDataUpload(String data, String type, {Map groups, String group}) {
    try {
      var jsonData = jsonDecode(data);
      if (jsonData['ENVELOPE'] == null) return jsonEncode([]);
      jsonData = jsonData['ENVELOPE'];
      List values = [];

      if (type == 'receivables' || type == 'payables') {
        if (jsonData['BILLFIXED'] == null) return jsonEncode(values);

        if (jsonData['BILLFIXED'] is List) {
          for (var i = 0; i < jsonData['BILLFIXED'].length; i++) {
            var l = {
              'partyValue': DataClean(
                  jsonData['BILLFIXED'][i]['BILLPARTY']['\$t'],
                  quote: true),
              'refValue': DataClean(jsonData['BILLFIXED'][i]['BILLREF']['\$t'],
                  quote: true),
              'dateValue': jsonData['BILLFIXED'][i]['BILLDATE']['\$t'],
              'amountValue': jsonData['BILLCL'][i]['\$t'] ?? '',
              'dueonValue': jsonData['BILLDUE'][i]['\$t'] ?? '',
              'overdueValue': jsonData['BILLOVERDUE'][i]['\$t'] ?? '',
            };

            values.add(l);
          }
        } else if (jsonData['BILLFIXED'] is Map) {
          var l = {
            'partyValue': DataClean(jsonData['BILLFIXED']['BILLPARTY']['\$t'],
                quote: true),
            'refValue':
                DataClean(jsonData['BILLFIXED']['BILLREF']['\$t'], quote: true),
            'dateValue': jsonData['BILLFIXED']['BILLDATE']['\$t'],
            'amountValue': jsonData['BILLCL']['\$t'] ?? '',
            'dueonValue': jsonData['BILLDUE']['\$t'] ?? '',
            'overdueValue': jsonData['BILLOVERDUE']['\$t'] ?? '',
          };

          values.add(l);
        }
      } else if (type == 'group') {
        if (jsonData['DSPACCNAME'] != null && jsonData != null) {
          if (jsonData['DSPACCNAME'] is Map) {
            var l = {
              'parentValue': group,
              'nameValue': DataClean(
                  jsonData['DSPACCNAME']['DSPDISPNAME']['\$t'],
                  quote: true),
              'drValue': jsonData['DSPACCINFO']['DSPCLDRAMT']['DSPCLDRAMTA']
                          ['\$t'] ==
                      null
                  ? 0
                  : (double.parse(jsonData['DSPACCINFO']['DSPCLDRAMT']
                          ['DSPCLDRAMTA']['\$t']) *
                      -1),
              'crValue': jsonData['DSPACCINFO']['DSPCLCRAMT']['DSPCLCRAMTA']
                          ['\$t'] ==
                      null
                  ? 0
                  : jsonData['DSPACCINFO']['DSPCLCRAMT']['DSPCLCRAMTA']['\$t'],
            };

            values.add(l);
          } else if (jsonData['DSPACCNAME'] is List) {
            for (var i = 0; i < jsonData['DSPACCNAME'].length; i++) {
              var l = {
                'parentValue': group,
                'nameValue': DataClean(
                    jsonData['DSPACCNAME'][i]['DSPDISPNAME']['\$t'],
                    quote: true),
                'drValue': jsonData['DSPACCINFO'][i]['DSPCLDRAMT']
                            ['DSPCLDRAMTA']['\$t'] ==
                        null
                    ? 0
                    : (double.parse(jsonData['DSPACCINFO'][i]['DSPCLDRAMT']
                            ['DSPCLDRAMTA']['\$t']) *
                        -1),
                'crValue': jsonData['DSPACCINFO'][i]['DSPCLCRAMT']
                            ['DSPCLCRAMTA']['\$t'] ==
                        null
                    ? 0
                    : jsonData['DSPACCINFO'][i]['DSPCLCRAMT']['DSPCLCRAMTA']
                        ['\$t'],
              };

              values.add(l);
            }
          }
        }
      } else if (type == 'ledger') {
        double open = 0;
        double close = 0;

        if (jsonData['BILLFIXED'] is List) {
          for (var i = 0; i < jsonData['BILLFIXED'].length; i++) {
            open += double.parse(jsonData['BILLOP'][i]['\$t'] ?? '0');
            close += double.parse(jsonData['BILLCL'][i]['\$t'] ?? '0');
          }
        } else if (jsonData['BILLFIXED'] is Map) {
          open += double.parse(jsonData['BILLOP']['\$t'] ?? '0');
          close += double.parse(jsonData['BILLCL']['\$t'] ?? '0');
        }

        return {'opening': open.toString(), 'closing': close.toString()};
      }

      return jsonEncode(values);
    } catch (e) {
      print(e);
    }
  }
}
