import 'dart:convert';

import 'package:hawks/controller/DataClean.dart';
import 'package:hawks/data/url.dart';
import 'package:hawks/data/variables.dart';
import 'package:hawks/tdl/tdl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:xml2json/xml2json.dart';

class Master {
  Xml2Json jsonParse = Xml2Json();

  getMaster(String company) async {
    try {
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
                    <SVFROMDATE TYPE="Date">''' +
          Jiffy(syncFrom).format('dd-MMM-yyyy') +
          '''</SVFROMDATE>
                    <SVTODATE TYPE="Date">''' +
          Jiffy(syncTo).format('dd-MMM-yyyy') +
          '''</SVTODATE>
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
      data = DataClean(data);
      jsonParse.parse(data);
      var jsonData = jsonParse.toGData();
      return jsonData;
    } catch (e) {
      print(e);
    }
  }

  uploadMaster(String company, String data) async {
    try {
      var jsonData = jsonDecode(data);
      var keys = jsonData.keys.toList();
      var items = [];

      for (var item in keys) {
        List d = jsonData[item];
        var count = (d.length / defaultRequestSize).floor() + 1;
        int defaultValue = 0;

        for (var j = 0; j < count; j++) {
          for (var i = 0; i < defaultRequestSize; i++) {
            if (defaultValue >= d.length) {
              break;
            }

            items.add(d[defaultValue]);
            defaultValue++;
          }
          await TallyRequest().tallyToServer(
            masterUrl,
            company,
            jsonEncode({item: items}),
          );
          items.clear();
        }
      }
    } catch (e) {
      print(e);
    }
  }

  parseDataUpload(String data) {
    try {
      var jsonData = jsonDecode(data);
      jsonData = jsonData['ENVELOPE']['BODY']['IMPORTDATA']['REQUESTDATA']
          ['TALLYMESSAGE'];

      List groups = [];
      List vouchers = [];
      List units = [];
      List ledgers = [];
      List categories = [];
      List godowns = [];
      List itemsku = [];
      List tax = [];

      for (var item in jsonData) {
        var keys = item.keys.toList();

        if (keys[2] == 'GROUP') {
          var name = '';
          if (item['GROUP']['LANGUAGENAME.LIST']['NAME.LIST']['NAME'] is Map) {
            name = DataClean(
                item['GROUP']['LANGUAGENAME.LIST']['NAME.LIST']['NAME']['\$t'],
                quote: true);
          } else {
            name = DataClean(
                item['GROUP']['LANGUAGENAME.LIST']['NAME.LIST']['NAME'][0]
                    ['\$t'],
                quote: true);
          }

          var l = {
            'sortValue': item['GROUP']['SORTPOSITION']['\$t'],
            'nameValue': name,
            'parentValue':
                DataClean(item['GROUP']['PARENT']['\$t'], quote: true) ?? '',
          };

          groups.add(l);
        } else if (keys[2] == 'VOUCHERTYPE') {
          var name = '';
          if (item['VOUCHERTYPE']['LANGUAGENAME.LIST']['NAME.LIST']['NAME']
              is Map) {
            name = DataClean(
                item['VOUCHERTYPE']['LANGUAGENAME.LIST']['NAME.LIST']['NAME']
                    ['\$t'],
                quote: true);
          } else {
            name = DataClean(
                item['VOUCHERTYPE']['LANGUAGENAME.LIST']['NAME.LIST']['NAME'][0]
                    ['\$t'],
                quote: true);
          }

          var l = {
            'nameValue': name,
            'parentValue':
                DataClean(item['VOUCHERTYPE']['PARENT']['\$t'], quote: true) ??
                    '',
          };

          vouchers.add(l);
        } else if (keys[2] == 'UNIT') {
          var name = '';
          if (item['UNIT']['NAME'] is Map) {
            name = DataClean(item['UNIT']['NAME']['\$t'], quote: true);
          } else {
            name = DataClean(item['UNIT']['NAME'][0]['\$t'], quote: true);
          }

          var l = {
            'nameValue': name,
          };

          units.add(l);
        } else if (keys[2] == 'LEDGER') {
          var name = item['LEDGER']['NAME'];
          if (name == null &&
              item['LEDGER']['LANGUAGENAME.LIST']['NAME.LIST']['NAME'] is Map) {
            name = DataClean(
                item['LEDGER']['LANGUAGENAME.LIST']['NAME.LIST']['NAME']['\$t'],
                quote: true);
          } else if (name == null &&
              item['LEDGER']['LANGUAGENAME.LIST']['NAME.LIST']['NAME']
                  is List) {
            name = DataClean(
                item['LEDGER']['LANGUAGENAME.LIST']['NAME.LIST']['NAME'][0]
                    ['\$t'],
                quote: true);
          }

          var addressValue = '';
          if (item['LEDGER']['ADDRESS.LIST'] != null) {
            if (item['LEDGER']['ADDRESS.LIST']['ADDRESS'] is Map) {
              addressValue = item['LEDGER']['ADDRESS.LIST']['ADDRESS']['\$t'];
            } else if (item['LEDGER']['ADDRESS.LIST']['ADDRESS'] is List) {
              int aCount = 0;
              for (var i in item['LEDGER']['ADDRESS.LIST']['ADDRESS']) {
                if (aCount != 0) addressValue += ', ';

                addressValue += i['\$t'];
                aCount++;
              }
            }
          }

          var opening = '';
          if (item['LEDGER']['OPENINGBALANCE'] != null) {
            opening = item['LEDGER']['OPENINGBALANCE']['\$t'] ?? '0';
          }

          var l = {
            'nameValue': name,
            'stateValue':
                DataClean(item['LEDGER']['STATENAME']['\$t'], quote: true) ??
                    (DataClean(item['LEDGER']['LEDSTATENAME']['\$t'],
                            quote: true) ??
                        ''),
            'pincodeValue': item['LEDGER']['PINCODE']['\$t'] ?? '',
            'addressValue': addressValue,
            'accountValue':
                DataClean(item['LEDGER']['PARENT']['\$t'], quote: true) ?? '',
            'openingValue': opening,
            'mobileValue': item['LEDGER']['LEDGERMOBILE']['\$t'] ?? '',
            'emailValue': item['LEDGER']['EMAIL']['\$t'] ?? '',
            'panValue': item['LEDGER']['INCOMETAXNUMBER']['\$t'] ?? '',
            'gstValue': item['LEDGER']['PARTYGSTIN']['\$t'] ?? '',
          };

          if (item['LEDGER']['PARENT']['\$t'] == 'Duties & Taxes') {
            var t = {
              'nameValue': name,
              'taxValue': item['LEDGER']['RATEOFTAXCALCULATION']['\$t'] ?? 0,
              'parent': item['LEDGER']['GSTDUTYHEAD']['\$t'] ??
                  (item['LEDGER']['TAXTYPE']['\$t'] ?? ''),
            };

            tax.add(t);
          }

          ledgers.add(l);
        } else if (keys[2] == 'STOCKGROUP') {
          var name = '';
          if (item['STOCKGROUP']['LANGUAGENAME.LIST']['NAME.LIST']['NAME']
              is Map) {
            name = DataClean(
                item['STOCKGROUP']['LANGUAGENAME.LIST']['NAME.LIST']['NAME']
                    ['\$t'],
                quote: true);
          } else {
            name = DataClean(
                item['STOCKGROUP']['LANGUAGENAME.LIST']['NAME.LIST']['NAME'][0]
                    ['\$t'],
                quote: true);
          }

          var l = {
            'nameValue': name,
          };

          categories.add(l);
        } else if (keys[2] == 'GODOWN') {
          var name = '';
          if (item['GODOWN']['LANGUAGENAME.LIST']['NAME.LIST']['NAME'] is Map) {
            name = DataClean(
                item['GODOWN']['LANGUAGENAME.LIST']['NAME.LIST']['NAME']['\$t'],
                quote: true);
          } else {
            name = DataClean(
                item['GODOWN']['LANGUAGENAME.LIST']['NAME.LIST']['NAME'][0]
                    ['\$t'],
                quote: true);
          }

          var l = {
            'nameValue': name,
          };

          godowns.add(l);
        } else if (keys[2] == 'STOCKITEM') {
          var name = '';
          if (item['STOCKITEM']['LANGUAGENAME.LIST']['NAME.LIST']['NAME']
              is Map) {
            name = DataClean(
                item['STOCKITEM']['LANGUAGENAME.LIST']['NAME.LIST']['NAME']
                    ['\$t'],
                quote: true);
          } else {
            name = DataClean(
                item['STOCKITEM']['LANGUAGENAME.LIST']['NAME.LIST']['NAME'][0]
                    ['\$t'],
                quote: true);
          }
          var categoryValue =
              (DataClean(item['STOCKITEM']['PARENT']['\$t'], quote: true)) ??
                  DataClean(item['STOCKITEM']['PARENT']['\$t'], quote: true);
          var unitValue =
              (DataClean(item['STOCKITEM']['BASEUNITS']['\$t'], quote: true)) ??
                  DataClean(item['STOCKITEM']['BASEUNITS']['\$t'], quote: true);
          var minimumValue = 0;
          var safetyValue = 0;
          var overValue = 0;
          var unitpriceValue = 0;
          var ingrdiantValue = 0;
          var laborValue = 0;
          var energyValue = 0;
          var salemarginValue = 0;
          var sperValue = 0;
          var samtValue = 0;
          var marginamountValue = 'Amount';
          var mrpstatusValue = 'sale_by_mrp';
          var purchasegstValue = 0;
          var salegstValue = 0;
          var istaxincludedValue = 0;
          var dissalestatusValue = 'No';
          var disonmrpValue = 0;
          var disamountValue = 0;
          var salepriceigstValue = 0;
          var salepriceegstValue = 0;
          var salepriceValue = 0;
          var mrpdistypeValue = 0;
          var mrpdisValue = 0;
          var taxincludesaleValue = 0;
          var cessValue = 0;
          var cessamountValue = 0;
          var purcessValue = 0;
          var basepriceValue = 0;
          var basepricediscValue = 0;
          var gstperValue = 0;

          var gstDetails = item['STOCKITEM']['GSTDETAILS.LIST'];
          var hsnCode = '';

          if (gstDetails != null) {
            if (gstDetails is Map) {
              hsnCode = gstDetails['HSNCODE'] != null
                  ? (gstDetails['HSNCODE']['\$t'] ??
                      (gstDetails['HSN'] == null
                          ? ''
                          : (gstDetails['HSN']['\$t'] ?? '')))
                  : (gstDetails['HSN'] == null
                      ? ''
                      : (gstDetails['HSN']['\$t'] ?? ''));

              var stateDetails = gstDetails['STATEWISEDETAILS.LIST'];
              if (stateDetails != null &&
                  stateDetails['RATEDETAILS.LIST'] != null) {
                gstperValue = int.parse(
                    stateDetails['RATEDETAILS.LIST'][3]['GSTRATE']['\$t']);
              }
            } else {
              hsnCode = gstDetails[0]['HSNCODE'] != null
                  ? (gstDetails[0]['HSNCODE']['\$t'] ??
                      (gstDetails[0]['HSN'] == null
                          ? ''
                          : (gstDetails[0]['HSN']['\$t'] ?? '')))
                  : (gstDetails[0]['HSN'] == null
                      ? ''
                      : (gstDetails[0]['HSN']['\$t'] ?? ''));

              var stateDetails = gstDetails[0]['STATEWISEDETAILS.LIST'];
              if (stateDetails != null &&
                  stateDetails['RATEDETAILS.LIST'] != null) {
                gstperValue = int.parse(
                    stateDetails['RATEDETAILS.LIST'][3]['GSTRATE']['\$t']);
              }
            }
          }

          var l = {
            'nameValue': name,
            'categoryValue': categoryValue,
            'unitValue': unitValue,
            'minimumValue': minimumValue,
            'safetyValue': safetyValue,
            'overValue': overValue,
            'unitpriceValue': unitpriceValue,
            'ingrdiantValue': ingrdiantValue,
            'laborValue': laborValue,
            'energyValue': energyValue,
            'salemarginValue': salemarginValue,
            'sperValue': sperValue,
            'samtValue': samtValue,
            'marginamountValue': marginamountValue,
            'mrpstatusValue': mrpstatusValue,
            'purchasegstValue': purchasegstValue,
            'salegstValue': salegstValue,
            'istaxincludedValue': istaxincludedValue,
            'dissalestatusValue': dissalestatusValue,
            'disonmrpValue': disonmrpValue,
            'disamountValue': disamountValue,
            'salepriceigstValue': salepriceigstValue,
            'salepriceegstValue': salepriceegstValue,
            'salepriceValue': salepriceValue,
            'mrpdistypeValue': mrpdistypeValue,
            'mrpdisValue': mrpdisValue,
            'taxincludesaleValue': taxincludesaleValue,
            'cessValue': cessValue,
            'cessamountValue': cessamountValue,
            'purcessValue': purcessValue,
            'basepriceValue': basepriceValue,
            'basepricediscValue': basepricediscValue,
            'gstperValue': gstperValue,
            'hsncode': hsnCode,
          };

          itemsku.add(l);
        }
      }

      jsonData = {
        'groups': groups,
        'vouchers': vouchers,
        'units': units,
        'ledgers': ledgers,
        'categories': categories,
        'itemsku': itemsku,
        'godowns': godowns,
        'tax': tax,
      };
      return jsonEncode(jsonData);
    } catch (e) {
      print(e);
    }
  }
}
