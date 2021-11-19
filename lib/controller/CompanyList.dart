import 'dart:convert';

import '../controller/DataClean.dart';
import '../data/url.dart';
import '../tdl/tdl.dart';
import 'package:xml2json/xml2json.dart';

class TallyCompany {
  Xml2Json jsonParse = Xml2Json();

  getCompanyList() async {
    try {
      String tdl = '''
<ENVELOPE>
  <HEADER>
    <VERSION>1</VERSION>
    <TALLYREQUEST>Export</TALLYREQUEST>
    <TYPE>Data</TYPE>
    <ID>List of Companies</ID>
  </HEADER>
  <BODY>
    <DESC>
      <STATICVARIABLES>
        <SVEXPORTFORMAT>\$\$SysName:XML</SVEXPORTFORMAT>
      </STATICVARIABLES>
      <TDL>
        <TDLMESSAGE>
          <REPORT NAME="List of Companies" ISMODIFY="No" ISFIXED="No" ISINITIALIZE="No" ISOPTION="No" ISINTERNAL="No">
            <FORMS>List of Companies</FORMS>
          </REPORT>
          <FORM NAME="List of Companies" ISMODIFY="No" ISFIXED="No" ISINITIALIZE="No" ISOPTION="No" ISINTERNAL="No">
            <TOPPARTS>List of Companies</TOPPARTS>
            <XMLTAG>"List of Companies"</XMLTAG>
          </FORM>
          <PART NAME="List of Companies" ISMODIFY="No" ISFIXED="No" ISINITIALIZE="No" ISOPTION="No" ISINTERNAL="No">
            <TOPLINES>List of Companies</TOPLINES>
            <REPEAT>List of Companies : Collection of Companies</REPEAT>
            <SCROLLED>Vertical</SCROLLED>
          </PART>
          <LINE NAME="List of Companies" ISMODIFY="No" ISFIXED="No" ISINITIALIZE="No" ISOPTION="No" ISINTERNAL="No">
            <LEFTFIELDS>Name</LEFTFIELDS>
            <LEFTFIELDS>ThisYearBeg</LEFTFIELDS>
            <LEFTFIELDS>ThisYearEnd</LEFTFIELDS>
            <LEFTFIELDS>EMail</LEFTFIELDS>
            <LEFTFIELDS>CountryName</LEFTFIELDS>
            <LEFTFIELDS>StateName</LEFTFIELDS>
            <LEFTFIELDS>PinCode</LEFTFIELDS>
            <LEFTFIELDS>PhoneNumber</LEFTFIELDS>
            <LEFTFIELDS>IncomeTaxNumber</LEFTFIELDS>
            <LEFTFIELDS>VATTINNumber</LEFTFIELDS>
            <LEFTFIELDS>GSTRegistrationNumber</LEFTFIELDS>
            <LEFTFIELDS>CINNumber</LEFTFIELDS>
            <LEFTFIELDS>PANNumber</LEFTFIELDS>
            <LEFTFIELDS>CompanyNumber</LEFTFIELDS>
            <LEFTFIELDS>_Address1</LEFTFIELDS>
            <LEFTFIELDS>_Address2</LEFTFIELDS>
            <LEFTFIELDS>_Address3</LEFTFIELDS>
            <LEFTFIELDS>VATApplicable</LEFTFIELDS>
            <LEFTFIELDS>IsGSTOn</LEFTFIELDS>
            <LEFTFIELDS>StartingFrom</LEFTFIELDS>
          </LINE>
          <FIELD NAME="Name" ISMODIFY="No" ISFIXED="No" ISINITIALIZE="No" ISOPTION="No" ISINTERNAL="No">
            <SET>\$Name</SET>
            <XMLTAG>"NAME"</XMLTAG>
          </FIELD>
          <FIELD NAME="ThisYearBeg" ISMODIFY="No" ISFIXED="No" ISINITIALIZE="No" ISOPTION="No" ISINTERNAL="No">
            <SET>\$ThisYearBeg</SET>
            <XMLTAG>"ThisYearBeg"</XMLTAG>
          </FIELD>
          <FIELD NAME="ThisYearEnd" ISMODIFY="No" ISFIXED="No" ISINITIALIZE="No" ISOPTION="No" ISINTERNAL="No">
            <SET>\$ThisYearEnd</SET>
            <XMLTAG>"ThisYearEnd"</XMLTAG>
          </FIELD>
          <FIELD NAME="EMail" ISMODIFY="No" ISFIXED="No" ISINITIALIZE="No" ISOPTION="No" ISINTERNAL="No">
            <SET>\$EMail</SET>
            <XMLTAG>"EMail"</XMLTAG>
          </FIELD>
          <FIELD NAME="CountryName" ISMODIFY="No" ISFIXED="No" ISINITIALIZE="No" ISOPTION="No" ISINTERNAL="No">
            <SET>\$CountryName</SET>
            <XMLTAG>"CountryName"</XMLTAG>
          </FIELD>
          <FIELD NAME="StateName" ISMODIFY="No" ISFIXED="No" ISINITIALIZE="No" ISOPTION="No" ISINTERNAL="No">
            <SET>\$StateName</SET>
            <XMLTAG>"StateName"</XMLTAG>
          </FIELD>
          <FIELD NAME="PinCode" ISMODIFY="No" ISFIXED="No" ISINITIALIZE="No" ISOPTION="No" ISINTERNAL="No">
            <SET>\$PinCode</SET>
            <XMLTAG>"PinCode"</XMLTAG>
          </FIELD>
          <FIELD NAME="PhoneNumber" ISMODIFY="No" ISFIXED="No" ISINITIALIZE="No" ISOPTION="No" ISINTERNAL="No">
            <SET>\$PhoneNumber</SET>
            <XMLTAG>"PhoneNumber"</XMLTAG>
          </FIELD>
          <FIELD NAME="IncomeTaxNumber" ISMODIFY="No" ISFIXED="No" ISINITIALIZE="No" ISOPTION="No" ISINTERNAL="No">
            <SET>\$IncomeTaxNumber</SET>
            <XMLTAG>"IncomeTaxNumber"</XMLTAG>
          </FIELD>
          <FIELD NAME="VATTINNumber" ISMODIFY="No" ISFIXED="No" ISINITIALIZE="No" ISOPTION="No" ISINTERNAL="No">
            <SET>\$VATTINNumber</SET>
            <XMLTAG>"VATTINNumber"</XMLTAG>
          </FIELD>
          <FIELD NAME="GSTRegistrationNumber" ISMODIFY="No" ISFIXED="No" ISINITIALIZE="No" ISOPTION="No" ISINTERNAL="No">
            <SET>\$GSTRegistrationNumber</SET>
            <XMLTAG>"GSTRegistrationNumber"</XMLTAG>
          </FIELD>
          <FIELD NAME="CINNumber" ISMODIFY="No" ISFIXED="No" ISINITIALIZE="No" ISOPTION="No" ISINTERNAL="No">
            <SET>\$CINNumber</SET>
            <XMLTAG>"CINNumber"</XMLTAG>
          </FIELD>
          <FIELD NAME="PANNumber" ISMODIFY="No" ISFIXED="No" ISINITIALIZE="No" ISOPTION="No" ISINTERNAL="No">
            <SET>\$PANNumber</SET>
            <XMLTAG>"PANNumber"</XMLTAG>
          </FIELD>
          <FIELD NAME="CompanyNumber" ISMODIFY="No" ISFIXED="No" ISINITIALIZE="No" ISOPTION="No" ISINTERNAL="No">
            <SET>\$CompanyNumber</SET>
            <XMLTAG>"CompanyNumber"</XMLTAG>
          </FIELD>
          <FIELD NAME="_Address1" ISMODIFY="No" ISFIXED="No" ISINITIALIZE="No" ISOPTION="No" ISINTERNAL="No">
            <SET>\$_Address1</SET>
            <XMLTAG>"_Address1"</XMLTAG>
          </FIELD>
          <FIELD NAME="_Address2" ISMODIFY="No" ISFIXED="No" ISINITIALIZE="No" ISOPTION="No" ISINTERNAL="No">
            <SET>\$_Address2</SET>
            <XMLTAG>"_Address2"</XMLTAG>
          </FIELD>
          <FIELD NAME="_Address3" ISMODIFY="No" ISFIXED="No" ISINITIALIZE="No" ISOPTION="No" ISINTERNAL="No">
            <SET>\$_Address3</SET>
            <XMLTAG>"_Address3"</XMLTAG>
          </FIELD>
          <FIELD NAME="VATApplicable" ISMODIFY="No" ISFIXED="No" ISINITIALIZE="No" ISOPTION="No" ISINTERNAL="No">
            <SET>\$VATApplicable</SET>
            <XMLTAG>"VATApplicable"</XMLTAG>
          </FIELD>
          <FIELD NAME="IsGSTOn" ISMODIFY="No" ISFIXED="No" ISINITIALIZE="No" ISOPTION="No" ISINTERNAL="No">
            <SET>\$IsGSTOn</SET>
            <XMLTAG>"IsGSTOn"</XMLTAG>
          </FIELD>
          <FIELD NAME="StartingFrom" ISMODIFY="No" ISFIXED="No" ISINITIALIZE="No" ISOPTION="No" ISINTERNAL="No">
            <SET>\$StartingFrom</SET>
            <XMLTAG>"StartingFrom"</XMLTAG>
          </FIELD>
          <COLLECTION NAME="Collection of Companies" ISMODIFY="No" ISFIXED="No" ISINITIALIZE="No" ISOPTION="No" ISINTERNAL="No">
            <TYPE>Company</TYPE>
          </COLLECTION>
        </TDLMESSAGE>
      </TDL>
    </DESC>
  </BODY>
</ENVELOPE>
      ''';

      var data = await TallyRequest().request(tdl);
      data = DataClean(data);
      jsonParse.parse(data);
      var jsonData = jsonParse.toGData();
      return jsonDecode(jsonData);
    } catch (e) {
      print(e);
    }
  }

  uploadCompany(String data) async {
    try {
      await TallyRequest().tallyToServer(
        companyUrl,
        '',
        data,
      );
    } catch (e) {
      print(e);
    }
  }
}
