import 'dart:convert';

import 'package:hawks/controller/DataClean.dart';
import 'package:hawks/data/variables.dart';
import 'package:hawks/tdl/tdl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:xml2json/xml2json.dart';

class StockReport {
  Xml2Json jsonParse = Xml2Json();

  // Stock Summary
  getStockReports(String company, String report) async {
    try {
      String tdl = '''
<ENVELOPE>
  <HEADER>
    <TALLYREQUEST>Export Data</TALLYREQUEST>
  </HEADER>
  <BODY>
    <EXPORTDATA>
      <REQUESTDESC>
        <REPORTNAME>''' +
          report +
          '''</REPORTNAME>
        <STATICVARIABLES>
          <SVCURRENTCOMPANY>''' +
          company +
          '''</SVCURRENTCOMPANY>
          <SVFROMDATE TYPE="Date">''' +
          Jiffy(syncFrom).format('dd-MMM-yyyy') +
          '''</SVFROMDATE>
          <SVTODATE TYPE="Date">''' +
          Jiffy(syncTo).format('dd-MMM-yyyy') +
          '''</SVTODATE>
          <SVEXPORTFORMAT>\$\$SysName:XML</SVEXPORTFORMAT>
          <EXPLODEFLAG>Yes</EXPLODEFLAG>
        </STATICVARIABLES>
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
                <REPORTNAME>Ledger Analysis</REPORTNAME>
            </REQUESTDESC>
        </EXPORTDATA>
    </BODY>
</ENVELOPE>
      ''';

      var data = await TallyRequest().request(tdl);
      if (data == null || data == '') return false;
      jsonParse.parse(data);
      var jsonData = jsonParse.toGData();
      return jsonData;
    } catch (e) {
      print(e);
    }
  }

  // Parse Upload Data
  parseDataUpload(String data) {
    try {
      var jsonData = jsonDecode(data)['ENVELOPE'];
      double inward = 0;
      double outward = 0;

      if (jsonData['DSPACCNAME'] is List) {
        for (var i = 0; i < jsonData['DSPACCNAME'].length; i++) {
          inward += double.parse(
              jsonData['STKANALINFO'][i]['STKMIN']['STKINVALUE']['\$t'] ?? '0');
          outward += double.parse(jsonData['STKANALINFO'][i]['STKMOUT']
                  ['STKOUTVALUE']['\$t'] ??
              '0');
        }
      } else if (jsonData['DSPACCNAME'] is Map) {
        inward = double.parse(
            jsonData['STKANALINFO']['STKMIN']['STKINVALUE']['\$t'] ?? '0');
        outward = double.parse(
            jsonData['STKANALINFO']['STKMOUT']['STKOUTVALUE']['\$t'] ?? '0');
      }

      return {'inward': inward.toString(), 'outward': outward.toString()};
    } catch (e) {
      print(e);
    }
  }

  // Upload Voucher Register
  uploadStockReports(Uri url, String company, String data) async {
    try {
      await TallyRequest().tallyToServer(url, company, data);
    } catch (e) {
      print(e);
    }
  }
}
