import 'package:hawks/tdl/tdl.dart';
import 'package:xml2json/xml2json.dart';
import 'package:hawks/data/url.dart';

class FinancialStatements {
  Xml2Json jsonParse = Xml2Json();

  // Trial Balance
  getTrialBalance(String company, int year) async {
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
                    <SVFROMDATE>1-Apr-''' +
          year.toString() +
          '''</SVFROMDATE>
                    <SVTODATE>31-Mar-''' +
          (year + 1).toString() +
          '''</SVTODATE>
                    <SVEXPORTFORMAT>\$\$SysName:XML</SVEXPORTFORMAT>
                    <SVCURRENTCOMPANY>''' +
          company +
          '''</SVCURRENTCOMPANY>
                    <EXPLODEFLAG>Yes</EXPLODEFLAG>
                </STATICVARIABLES>
                <REPORTNAME>Trial Balance</REPORTNAME>
            </REQUESTDESC>
        </EXPORTDATA>
    </BODY>
</ENVELOPE>
      ''';

      var data = await TallyRequest().request(tdl);
      jsonParse.parse(data);
      var jsonData = jsonParse.toGData();
      return jsonData;
    } catch (e) {
      print(e);
    }
  }

  // Trial Balance
  getProfitLoss(String company, int year) async {
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
                    <SVFROMDATE>1-Apr-''' +
          year.toString() +
          '''</SVFROMDATE>
                    <SVTODATE>31-Mar-''' +
          (year + 1).toString() +
          '''</SVTODATE>
                    <SVEXPORTFORMAT>\$\$SysName:XML</SVEXPORTFORMAT>
                    <SVCURRENTCOMPANY>''' +
          company +
          '''</SVCURRENTCOMPANY>
                    <EXPLODEFLAG>Yes</EXPLODEFLAG>
                </STATICVARIABLES>
                <REPORTNAME>Profit and Loss</REPORTNAME>
            </REQUESTDESC>
        </EXPORTDATA>
    </BODY>
</ENVELOPE>
      ''';

      var data = await TallyRequest().request(tdl);
      jsonParse.parse(data);
      var jsonData = jsonParse.toGData();
      return jsonData;
    } catch (e) {
      print(e);
    }
  }

  // Balance Sheet
  getBalanceSheet(String company, int year) async {
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
                    <SVFROMDATE>1-Apr-''' +
          year.toString() +
          '''</SVFROMDATE>
                    <SVTODATE>31-Mar-''' +
          (year + 1).toString() +
          '''</SVTODATE>
                    <SVEXPORTFORMAT>\$\$SysName:XML</SVEXPORTFORMAT>
                    <SVCURRENTCOMPANY>''' +
          company +
          '''</SVCURRENTCOMPANY>
                    <EXPLODEFLAG>Yes</EXPLODEFLAG>
                </STATICVARIABLES>
                <REPORTNAME>Balance Sheet</REPORTNAME>
            </REQUESTDESC>
        </EXPORTDATA>
    </BODY>
</ENVELOPE>
      ''';

      var data = await TallyRequest().request(tdl);
      jsonParse.parse(data);
      var jsonData = jsonParse.toGData();
      return jsonData;
    } catch (e) {
      print(e);
    }
  }

  // Cash Flow
  getCashFlow(String company, int year) async {
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
                    <SVFROMDATE>1-Apr-''' +
          year.toString() +
          '''</SVFROMDATE>
                    <SVTODATE>31-Mar-''' +
          (year + 1).toString() +
          '''</SVTODATE>
                    <SVEXPORTFORMAT>\$\$SysName:XML</SVEXPORTFORMAT>
                    <SVCURRENTCOMPANY>''' +
          company +
          '''</SVCURRENTCOMPANY>
                    <EXPLODEFLAG>Yes</EXPLODEFLAG>
                </STATICVARIABLES>
                <REPORTNAME>Cash Flow</REPORTNAME>
            </REQUESTDESC>
        </EXPORTDATA>
    </BODY>
</ENVELOPE>
      ''';

      var data = await TallyRequest().request(tdl);
      jsonParse.parse(data);
      var jsonData = jsonParse.toGData();
      return jsonData;
    } catch (e) {
      print(e);
    }
  }

  // Fund Flow
  getFundFlow(String company, int year) async {
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
                    <SVFROMDATE>1-Apr-''' +
          year.toString() +
          '''</SVFROMDATE>
                    <SVTODATE>31-Mar-''' +
          (year + 1).toString() +
          '''</SVTODATE>
                    <SVEXPORTFORMAT>\$\$SysName:XML</SVEXPORTFORMAT>
                    <SVCURRENTCOMPANY>''' +
          company +
          '''</SVCURRENTCOMPANY>
                    <EXPLODEFLAG>Yes</EXPLODEFLAG>
                </STATICVARIABLES>
                <REPORTNAME>Funds Flow</REPORTNAME>
            </REQUESTDESC>
        </EXPORTDATA>
    </BODY>
</ENVELOPE>
      ''';

      var data = await TallyRequest().request(tdl);
      jsonParse.parse(data);
      var jsonData = jsonParse.toGData();
      return jsonData;
    } catch (e) {
      print(e);
    }
  }

  // Upload Fiancial Statements
  uploadFiancialStatements(String company, String data) async {
    try {
      await TallyRequest().tallyToServer(financialStatementsUrl, company, data);
    } catch (e) {
      print(e);
    }
  }
}
