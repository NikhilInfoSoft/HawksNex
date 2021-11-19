import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:jiffy/jiffy.dart';

import '../controller/DataClean.dart';
import '../data/variables.dart';
import '../tdl/tdl.dart';
import 'package:intl/intl.dart';
import 'package:xml2json/xml2json.dart';

class VoucherRegister {
  Xml2Json jsonParse = Xml2Json();

  // Voucher Register
  getVoucherRegister(
    String company,
    String from,
    String to,
    String voucher,
  ) async {
    try {
      String tdl = '''
<ENVELOPE>
  <HEADER>
    <TALLYREQUEST>Export Data</TALLYREQUEST>
  </HEADER>
  <BODY>
    <EXPORTDATA>
      <REQUESTDESC>
        <REPORTNAME>Voucher Register</REPORTNAME>
        <STATICVARIABLES>
          <SVFROMDATE TYPE="Date">''' +
          from +
          '''</SVFROMDATE>
          <SVTODATE TYPE="Date">''' +
          to +
          '''</SVTODATE>
          <EXPLODEFLAG>Yes</EXPLODEFLAG>
          <PERSISTEDVIEW>Invoice Voucher View</PERSISTEDVIEW>
          <VOUCHERTYPENAME>''' +
          voucher +
          '''</VOUCHERTYPENAME>
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

  // Voucher Register
  getVoucherStats(String company, {bool daemon = false}) async {
    try {
      String from = '';
      String to = '';

      if (daemon) {
        from = DateFormat('dd-MMM-yyyy')
            .format(Jiffy(DateTime.now()).subtract(months: 3).dateTime);
        to = DateFormat('dd-MMM-yyyy')
            .format(Jiffy(DateTime.now()).add(months: 1).dateTime);
      } else {
        from = '''1-Apr-''' + syncFrom.year.toString();
        to = '''31-Mar-''' + syncTo.year.toString();
      }

      String tdl = '''
<ENVELOPE>
  <HEADER>
    <TALLYREQUEST>Export Data</TALLYREQUEST>
  </HEADER>
  <BODY>
    <EXPORTDATA>
      <REQUESTDESC>
        <REPORTNAME>Statistics</REPORTNAME>
        <STATICVARIABLES>
          <SVFROMDATE TYPE="Date">''' +
          from +
          '''</SVFROMDATE>
          <SVTODATE TYPE="Date">''' +
          to +
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
      return jsonDecode(jsonData);
    } catch (e) {
      print(e);
    }
  }

  // Parse Upload Data
  parseUploadData(String data, String type, String parent, Map sData) {
    var run = 0;
    List items = [];
    List ledgers = [];
    int bills = 0;

    try {
      var jsonData = jsonDecode(data)['ENVELOPE']['BODY']['IMPORTDATA']
          ['REQUESTDATA']['TALLYMESSAGE'];
      var ptype = sData['voucher'][type]['parentvoucher'];

      List _currentVouchers = [];

      if (jsonData == null) {
        return jsonEncode({'ledgers': ledgers, 'items': items, 'bills': 0});
      } else if (jsonData is Map) {
        jsonData = [jsonData];
      }

      if (ptype == 'Payment' || ptype == 'Receipt' || ptype == 'Contra') {
        for (var i = 0; i < jsonData.length; i++) {
          var keys = jsonData[i].keys.toList();
          if (!keys.contains('VOUCHER')) {
            continue;
          }

          var l = jsonData[i]['VOUCHER']['ALLLEDGERENTRIES.LIST'];

          if (jsonData[i]['VOUCHER']['ACTION'] == 'Cancel' ||
              l[0]['LEDGERNAME']['\$t'] == null) {
            continue;
          }

          if (sData['party']
                  [DataClean(l[0]['LEDGERNAME']['\$t'], quote: true)] ==
              null) {
            continue;
          }

          var voucher = jsonData[i]['VOUCHER']['VOUCHERNUMBER']['\$t'];
          if (voucher == '' || voucher == null) {
            if (jsonData[i]['VOUCHER']['REFERENCE']['\$t'] == null ||
                jsonData[i]['VOUCHER']['REFERENCE']['\$t'] == '') {
              voucher = 'PD-TALLY-' + getRandomString(10);
            } else {
              voucher = 'SIN-TALLY-' +
                  jsonData[i]['VOUCHER']['REFERENCE']['\$t'].toString();
            }
          }

          if (!_currentVouchers.contains(voucher)) bills++;

          var guid = jsonData[i]['VOUCHER']['GUID']['\$t'].toString();
          var date = jsonData[i]['VOUCHER']['DATE']['\$t'].toString();
          date = date.substring(0, 4) +
              '-' +
              date.substring(4, 6) +
              '-' +
              date.substring(6);

          for (var j = 0; j < l.length; j++) {
            var orderno = '';
            var against = '';
            if (l[j]['BILLALLOCATIONS.LIST'] != null &&
                l[j]['BILLALLOCATIONS.LIST'].isNotEmpty &&
                l[j]['BILLALLOCATIONS.LIST'] is Map &&
                l[j]['BILLALLOCATIONS.LIST']['NAME'] != null) {
              if (l[j]['BILLALLOCATIONS.LIST']['NAME'] == null) print('t');
              orderno = l[j]['BILLALLOCATIONS.LIST']['NAME']['\$t'] ?? '';
              against = l[j]['BILLALLOCATIONS.LIST']['BILLTYPE']['\$t'] ?? '';
            } else if (l[j]['BILLALLOCATIONS.LIST'] is List) {
              var bl = l[j]['BILLALLOCATIONS.LIST'];
              for (var b in bl) {
                if (b['NAME'] == null) {
                  continue;
                }
                if (orderno == '') {
                  orderno += b['NAME']['\$t'] ?? '';
                } else {
                  orderno += ',' + (b['NAME']['\$t'] ?? '');
                }
              }
              against = 'Agst Ref';
            }

            var ledgerName = sData['party']
                [DataClean(l[j]['LEDGERNAME']['\$t'], quote: true)];
            if (ledgerName == null) {
              ledgerName = sData['party'][capitalize(
                  DataClean(l[j]['LEDGERNAME']['\$t'], quote: true))];

              if (ledgerName == null)
                ledgerName = sData['party'][
                    DataClean(l[j]['LEDGERNAME']['\$t'], quote: true)
                        .toUpperCase()];

              if (ledgerName == null)
                ledgerName = sData['party'][
                    DataClean(l[j]['LEDGERNAME']['\$t'], quote: true)
                        .toLowerCase()];

              if (ledgerName == null) ledgerName = {'id': '0', 'code': ''};
            }

            var l1 = {
              'id': ledgerName['id'],
              'account': ledgerName['code'],
              'amountdr': double.parse(l[j]['AMOUNT']['\$t']) *
                  (ptype == 'Payment' ? -1 : 0),
              'amountcr': double.parse(l[j]['AMOUNT']['\$t']) *
                  (ptype == 'Payment' ? 0 : 1),
              'voucher': sData['voucher'][type]['id'],
              'date': date,
              'bill': voucher,
              'narration': '',
              'cancelled': 0,
              'deleted': 0,
              'drcr': ptype == 'Payment' ? 'Dr' : 'Cr',
              'contra': 0,
              'journal': 0,
              'guid': guid,
              'orderno': orderno,
              'against': against,
            };
            ledgers.add(l1);
          }

          if (_currentVouchers.contains(voucher)) {
            ledgers.removeLast();
            ledgers.removeLast();
          } else {
            _currentVouchers.add(voucher);
          }
        }
      } else if (ptype == 'Journal') {
        for (var i = 0; i < jsonData.length; i++) {
          var keys = jsonData[i].keys.toList();
          if (!keys.contains('VOUCHER')) {
            continue;
          }

          var l = jsonData[i]['VOUCHER']['ALLLEDGERENTRIES.LIST'];

          if (jsonData[i]['VOUCHER']['ACTION'] == 'Cancel' ||
              l[0]['LEDGERNAME']['\$t'] == null) {
            continue;
          }

          if (sData['party']
                  [DataClean(l[0]['LEDGERNAME']['\$t'], quote: true)] ==
              null) {
            continue;
          }

          var voucher = jsonData[i]['VOUCHER']['VOUCHERNUMBER']['\$t'];
          if (voucher == '' || voucher == null) {
            if (jsonData[i]['VOUCHER']['REFERENCE']['\$t'] == null ||
                jsonData[i]['VOUCHER']['REFERENCE']['\$t'] == '') {
              voucher = 'PD-TALLY-' + getRandomString(10);
            } else {
              voucher = 'SIN-TALLY-' +
                  jsonData[i]['VOUCHER']['REFERENCE']['\$t'].toString();
            }
          }

          if (!_currentVouchers.contains(voucher)) bills++;

          var guid = jsonData[i]['VOUCHER']['GUID']['\$t'].toString();
          var date = jsonData[i]['VOUCHER']['DATE']['\$t'].toString();
          date = date.substring(0, 4) +
              '-' +
              date.substring(4, 6) +
              '-' +
              date.substring(6);

          for (var j = 0; j < l.length; j++) {
            var ledgerName = sData['party']
                [DataClean(l[j]['LEDGERNAME']['\$t'], quote: true)];
            if (ledgerName == null) {
              ledgerName = sData['party'][capitalize(
                  DataClean(l[j]['LEDGERNAME']['\$t'], quote: true))];

              if (ledgerName == null)
                ledgerName = sData['party'][
                    DataClean(l[j]['LEDGERNAME']['\$t'], quote: true)
                        .toUpperCase()];

              if (ledgerName == null)
                ledgerName = sData['party'][
                    DataClean(l[j]['LEDGERNAME']['\$t'], quote: true)
                        .toLowerCase()];

              if (ledgerName == null) ledgerName = {'id': '0', 'code': ''};
            }

            var orderno = '';
            var against = '';
            if (l[j]['BILLALLOCATIONS.LIST'] != null &&
                l[j]['BILLALLOCATIONS.LIST'].isNotEmpty &&
                l[j]['BILLALLOCATIONS.LIST'] is Map &&
                l[j]['BILLALLOCATIONS.LIST']['NAME'] != null) {
              if (l[j]['BILLALLOCATIONS.LIST']['NAME'] == null) print('t');
              orderno = l[j]['BILLALLOCATIONS.LIST']['NAME']['\$t'] ?? '';
              against = l[j]['BILLALLOCATIONS.LIST']['BILLTYPE']['\$t'] ?? '';
            } else if (l[j]['BILLALLOCATIONS.LIST'] is List) {
              var bl = l[j]['BILLALLOCATIONS.LIST'];
              for (var b in bl) {
                if (b['NAME'] == null) {
                  continue;
                }
                if (orderno == '') {
                  orderno += b['NAME']['\$t'] ?? '';
                } else {
                  orderno += ',' + (b['NAME']['\$t'] ?? '');
                }
              }
              against = 'Agst Ref';
            }

            var l1 = {
              'id': ledgerName['id'],
              'account': ledgerName['code'],
              'amountdr': double.parse(l[j]['AMOUNT']['\$t']) *
                  (l[j]['ISDEEMEDPOSITIVE']['\$t'] == 'Yes' ? -1 : 0),
              'amountcr': double.parse(l[j]['AMOUNT']['\$t']) *
                  (l[j]['ISDEEMEDPOSITIVE']['\$t'] == 'Yes' ? 0 : 1),
              'voucher': sData['voucher'][type]['id'],
              'date': date,
              'bill': voucher,
              'narration': '',
              'cancelled': 0,
              'deleted': 0,
              'drcr': l[j]['ISDEEMEDPOSITIVE']['\$t'] == 'Yes' ? 'Dr' : 'Cr',
              'contra': 0,
              'journal': 1,
              'guid': guid,
              'orderno': orderno,
              'against': against,
            };

            ledgers.add(l1);
          }

          if (_currentVouchers.contains(voucher)) {
            ledgers.removeLast();
            ledgers.removeLast();
          } else {
            _currentVouchers.add(voucher);
          }
        }
      } else {
        for (var i = 0; i < jsonData.length; i++) {
          bool ledgerdone = false;
          int lcount = 0;
          int icount = 0;

          var keys = jsonData[i].keys.toList();
          if (!keys.contains('VOUCHER')) {
            continue;
          }

          if (sData['party'][DataClean(
                  jsonData[i]['VOUCHER']['PARTYLEDGERNAME']['\$t'],
                  quote: true)] ==
              null) {
            continue;
          }

          var l = jsonData[i]['VOUCHER']['LEDGERENTRIES.LIST'];

          if (l == null || l[0] == null) {
            var data = _otherTypeVoucher(
              jsonData[i],
              type,
              sData,
              _currentVouchers,
            );
            ledgers.addAll(data['ledgers']);
            items.addAll(data['items']);
            bills++;
            continue;
          }

          var s = jsonData[i]['VOUCHER']['ALLINVENTORYENTRIES.LIST'];

          if (s == null) {
            print(jsonEncode(jsonData[i]));
            return;
          }

          if (jsonData[i]['VOUCHER']['ACTION'] == 'Cancel' ||
              jsonData[i]['VOUCHER']['PARTYLEDGERNAME'] == null) {
            continue;
          }

          var voucher = jsonData[i]['VOUCHER']['VOUCHERNUMBER']['\$t'];
          if (voucher == '' || voucher == null) {
            if (jsonData[i]['VOUCHER']['REFERENCE']['\$t'] == null ||
                jsonData[i]['VOUCHER']['REFERENCE']['\$t'] == '') {
              voucher = 'PD-TALLY-' + getRandomString(10);
            } else {
              voucher = 'SIN-TALLY-' +
                  jsonData[i]['VOUCHER']['REFERENCE']['\$t'].toString();
            }
          }

          if (_currentVouchers.contains(voucher)) continue;
          if (!_currentVouchers.contains(voucher)) bills++;

          var guid = jsonData[i]['VOUCHER']['GUID']['\$t'].toString();
          var date = jsonData[i]['VOUCHER']['DATE']['\$t'].toString();
          date = date.substring(0, 4) +
              '-' +
              date.substring(4, 6) +
              '-' +
              date.substring(6);

          var ledgerName = sData['party'][DataClean(
              jsonData[i]['VOUCHER']['PARTYLEDGERNAME']['\$t'],
              quote: true)];
          if (ledgerName == null) {
            ledgerName = sData['party'][capitalize(DataClean(
                jsonData[i]['VOUCHER']['PARTYLEDGERNAME']['\$t'],
                quote: true))];

            if (ledgerName == null)
              ledgerName = sData['party'][DataClean(
                      jsonData[i]['VOUCHER']['PARTYLEDGERNAME']['\$t'],
                      quote: true)
                  .toUpperCase()];

            if (ledgerName == null)
              ledgerName = sData['party'][DataClean(
                      jsonData[i]['VOUCHER']['PARTYLEDGERNAME']['\$t'],
                      quote: true)
                  .toLowerCase()];

            if (ledgerName == null) ledgerName = {'id': '0', 'code': ''};
          }

          var orderno = '';
          var against = '';
          if (l[0]['BILLALLOCATIONS.LIST'] != null &&
              l[0]['BILLALLOCATIONS.LIST'].isNotEmpty &&
              l[0]['BILLALLOCATIONS.LIST'] is Map &&
              l[0]['BILLALLOCATIONS.LIST']['NAME'] != null) {
            if (l[0]['BILLALLOCATIONS.LIST']['NAME'] == null) print('t');
            orderno = l[0]['BILLALLOCATIONS.LIST']['NAME']['\$t'] ?? '';
            against = l[0]['BILLALLOCATIONS.LIST']['BILLTYPE']['\$t'] ?? '';
          } else if (l[0]['BILLALLOCATIONS.LIST'] is List) {
            var bl = l[0]['BILLALLOCATIONS.LIST'];
            for (var b in bl) {
              if (b['NAME'] == null) {
                continue;
              }
              if (orderno == '') {
                orderno += b['NAME']['\$t'] ?? '';
              } else {
                orderno += ',' + (b['NAME']['\$t'] ?? '');
              }
            }
            against = 'Agst Ref';
          }

          var deliveryNoteMap = jsonData[i]['VOUCHER']['INVOICEDELNOTES.LIST'];
          var deliveryNoteNo = '';
          var deliveryNoteDate = '';
          if (deliveryNoteMap != null) {
            deliveryNoteNo = deliveryNoteMap['BASICSHIPDELIVERYNOTE'] == null
                ? ''
                : (deliveryNoteMap['BASICSHIPDELIVERYNOTE']['\$t'] ?? '');
            deliveryNoteDate = deliveryNoteMap['BASICSHIPPINGDATE'] == null
                ? ''
                : (deliveryNoteMap['BASICSHIPPINGDATE']['\$t'] ?? '');
          }
          var dispatchDocNo = jsonData[i]['VOUCHER']['BASICSHIPDOCUMENTNO'] ==
                  null
              ? ''
              : (jsonData[i]['VOUCHER']['BASICSHIPDOCUMENTNO']['\$t'] ?? '');
          var dispatchThrough = jsonData[i]['VOUCHER']['BASICSHIPPEDBY'] == null
              ? ''
              : (jsonData[i]['VOUCHER']['BASICSHIPPEDBY']['\$t'] ?? '');
          var dispatchDestination = jsonData[i]['VOUCHER']
                      ['BASICFINALDESTINATION'] ==
                  null
              ? ''
              : (jsonData[i]['VOUCHER']['BASICFINALDESTINATION']['\$t'] ?? '');
          var dispatchAgent = jsonData[i]['VOUCHER']['EICHECKPOST'] == null
              ? ''
              : (jsonData[i]['VOUCHER']['EICHECKPOST']['\$t'] ?? '');
          var dispatchLanding = jsonData[i]['VOUCHER']['BILLOFLADINGNO'] == null
              ? ''
              : (jsonData[i]['VOUCHER']['BILLOFLADINGNO']['\$t'] ?? '');
          var dispatchVehicle =
              jsonData[i]['VOUCHER']['BASICSHIPVESSELNO'] == null
                  ? ''
                  : (jsonData[i]['VOUCHER']['BASICSHIPVESSELNO']['\$t'] ?? '');

          var l1 = {
            'id': ledgerName['id'],
            'account': ledgerName['code'],
            'amountdr': double.parse(l[0]['AMOUNT']['\$t']) *
                ((ptype == 'Debit Note' ||
                        ptype == 'Sales' ||
                        ptype == 'SALES' ||
                        ptype == 'Sales Order')
                    ? -1
                    : 0),
            'amountcr': double.parse(l[0]['AMOUNT']['\$t']) *
                ((ptype == 'Debit Note' ||
                        ptype == 'Sales' ||
                        ptype == 'SALES' ||
                        ptype == 'Sales Order')
                    ? 0
                    : 1),
            'voucher': sData['voucher'][type]['id'],
            'date': date,
            'bill': voucher,
            'reference': jsonData[i]['VOUCHER']['REFERENCE']['\$t'] ?? '',
            'narration': jsonData[i]['VOUCHER']['NARRATION']['\$t'] ?? '',
            'cancelled': 0,
            'deleted': 0,
            'drcr': (ptype == 'Debit Note' ||
                    ptype == 'Sales' ||
                    ptype == 'SALES' ||
                    ptype == 'Sales Order')
                ? 'Dr'
                : 'Cr',
            'contra': 0,
            'journal': 0,
            'guid': guid,
            'deliveryNoteNo': deliveryNoteNo,
            'deliveryNoteDate': deliveryNoteDate,
            'dispatchDocNo': dispatchDocNo,
            'dispatchThrough': dispatchThrough,
            'dispatchDestination': dispatchDestination,
            'dispatchAgent': dispatchAgent,
            'dispatchLanding': dispatchLanding,
            'dispatchVehicle': dispatchVehicle,
            'orderno': orderno,
            'against': against,
          };

          ledgers.add(l1);
          lcount++;

          for (var j = 1; j < l.length; j++) {
            if (sData['party']
                    [DataClean(l[j]['LEDGERNAME']['\$t'], quote: true)] ==
                null) continue;

            var taxtype = 'amount';
            double taxrate = 0;
            if (sData['party']
                        [DataClean(l[j]['LEDGERNAME']['\$t'], quote: true)]
                    ['code'] ==
                'Duties & Taxes') {
              taxtype = 'percentage';

              if (l[j]['BASICRATEOFINVOICETAX.LIST'] != null) {
                if (l[j]['BASICRATEOFINVOICETAX.LIST'] is Map) {
                  taxrate = double.parse((l[j]['BASICRATEOFINVOICETAX.LIST']
                                  ['BASICRATEOFINVOICETAX'] !=
                              null
                          ? (l[j]['BASICRATEOFINVOICETAX.LIST']
                                  ['BASICRATEOFINVOICETAX']['\$t'] ??
                              '0')
                          : '0')
                      .toString());
                }
              }
            }

            var ledgerName = sData['party']
                [DataClean(l[j]['LEDGERNAME']['\$t'], quote: true)];
            if (ledgerName == null) {
              ledgerName = sData['party'][capitalize(
                  DataClean(l[j]['LEDGERNAME']['\$t'], quote: true))];

              if (ledgerName == null)
                ledgerName = sData['party'][
                    DataClean(l[j]['LEDGERNAME']['\$t'], quote: true)
                        .toUpperCase()];

              if (ledgerName == null)
                ledgerName = sData['party'][
                    DataClean(l[j]['LEDGERNAME']['\$t'], quote: true)
                        .toLowerCase()];

              if (ledgerName == null) ledgerName = {'id': '0', 'code': ''};
            }
            var l2 = {
              'id': ledgerName['id'],
              'account': ledgerName['code'],
              'amountdr': double.parse(l[j]['AMOUNT']['\$t']) *
                  ((ptype == 'Debit Note' ||
                          ptype == 'Sales' ||
                          ptype == 'SALES' ||
                          ptype == 'Sales Order')
                      ? 0
                      : -1),
              'amountcr': double.parse(l[j]['AMOUNT']['\$t']) *
                  ((ptype == 'Debit Note' ||
                          ptype == 'Sales' ||
                          ptype == 'SALES' ||
                          ptype == 'Sales Order')
                      ? 1
                      : 0),
              'voucher': sData['voucher'][type]['id'],
              'date': date,
              'bill': voucher,
              'reference': jsonData[i]['VOUCHER']['REFERENCE']['\$t'] ?? '',
              'narration': jsonData[i]['VOUCHER']['NARRATION']['\$t'] ?? '',
              'cancelled': 0,
              'deleted': 0,
              'drcr': (ptype == 'Debit Note' ||
                      ptype == 'Sales' ||
                      ptype == 'SALES' ||
                      ptype == 'Sales Order')
                  ? 'Cr'
                  : 'Dr',
              'contra': 0,
              'journal': 0,
              'taxtype': taxtype,
              'taxrate': taxrate,
              'guid': guid,
              'deliveryNoteNo': deliveryNoteNo,
              'deliveryNoteDate': deliveryNoteDate,
              'dispatchDocNo': dispatchDocNo,
              'dispatchThrough': dispatchThrough,
              'dispatchDestination': dispatchDestination,
              'dispatchAgent': dispatchAgent,
              'dispatchLanding': dispatchLanding,
              'dispatchVehicle': dispatchVehicle,
            };

            ledgers.add(l2);
            lcount++;
          }

          // Items
          var iList = [];
          if (s is Map) {
            iList.add(s);
          } else {
            iList = s;
          }

          for (var j = 0; j < iList.length; j++) {
            if (iList[j]['STOCKITEMNAME'] == null) {
              continue;
            }

            var qty =
                iList[j]['ACTUALQTY'] != null || iList[j]['ACTUALQTY'] != ''
                    ? iList[j]['ACTUALQTY']['\$t']
                    : iList[j]['BILLEDQTY']['\$t'];
            if (qty != null) {
              qty = qty.replaceAll(RegExp('[a-zA-Z ]'), '');
              qty = qty.toString().split('=')[0];
            }

            double value = 0;
            if (iList[j]['ISDEEMEDPOSITIVE']['\$t'] == 'Yes') {
              value = double.parse(iList[j]['AMOUNT']['\$t'] ?? '0') * -1;
            } else {
              value = double.parse(iList[j]['AMOUNT']['\$t'] ?? '0');
            }

            if (sData['item'][
                    DataClean(iList[j]['STOCKITEMNAME']['\$t'], quote: true)] ==
                null) continue;

            var it = {
              'code': sData['item']
                      [DataClean(iList[j]['STOCKITEMNAME']['\$t'], quote: true)]
                  ['sku'],
              'name': DataClean(iList[j]['STOCKITEMNAME']['\$t'], quote: true),
              'godown': DataClean(
                      iList[j]['BATCHALLOCATIONS.LIST']['GODOWNNAME']['\$t'],
                      quote: true) ??
                  '',
              'unit': iList[j]['STOCKITEMNAME'] != null
                  ? sData['item'][DataClean(iList[j]['STOCKITEMNAME']['\$t'],
                      quote: true)]['unit']
                  : '',
              'rate': (iList[j]['RATE']['\$t'] ?? '0/').split('/')[0],
              'value': value,
              'gst': iList[j]['ACCOUNTINGALLOCATIONS.LIST']['GSTTAXRATE']
                      ['\$t'] ??
                  '0',
              'discount': iList[j]['DISCOUNT']['\$t'] ?? '0',
              'qty': qty ?? 0,
              'category': sData['item']
                      [DataClean(iList[j]['STOCKITEMNAME']['\$t'], quote: true)]
                  ['category'],
              'party': sData['party'][DataClean(
                  jsonData[i]['VOUCHER']['PARTYLEDGERNAME']['\$t'],
                  quote: true)]['id'],
              'date': date,
              'bill': voucher,
              'voucher': sData['voucher'][type]['id'],
              'hsncode': sData['item']
                      [DataClean(iList[j]['STOCKITEMNAME']['\$t'], quote: true)]
                  ['hsncode'],
              'accouting': {
                'id': sData['party'][DataClean(
                    iList[j]['ACCOUNTINGALLOCATIONS.LIST']['LEDGERNAME']['\$t'],
                    quote: true)]['id'],
                'name': DataClean(
                    iList[j]['ACCOUNTINGALLOCATIONS.LIST']['LEDGERNAME']['\$t'],
                    quote: true),
              },
              'guid': guid,
            };

            items.add(it);
            icount++;
          }
        }
      }

      return jsonEncode({'ledgers': ledgers, 'items': items, 'bills': bills});
    } catch (e) {
      print(e);
      return jsonEncode({'ledgers': ledgers, 'items': items, 'bills': bills});
    }
  }

  _otherTypeVoucher(Map jsonData, String type, Map sData, List vouchers) {
    var ptype = sData['voucher'][type]['parentvoucher'];
    List ledgers = [];
    List items = [];

    try {
      List l = [];

      if (jsonData['VOUCHER']['ALLLEDGERENTRIES.LIST'] is Map) {
        if (jsonData['VOUCHER']['ALLLEDGERENTRIES.LIST'].length == 0) {
          return {'ledgers': ledgers, 'items': items, 'bills': 0, 'c': 0};
        }

        l.add(jsonData['VOUCHER']['ALLLEDGERENTRIES.LIST']);
      } else {
        l = jsonData['VOUCHER']['ALLLEDGERENTRIES.LIST'] ??
            [jsonData['VOUCHER']['LEDGERENTRIES.LIST']];
      }

      if (sData['party'][DataClean(
              jsonData['VOUCHER']['PARTYLEDGERNAME']['\$t'],
              quote: true)] ==
          null) {
        return {'ledgers': ledgers, 'items': items, 'bills': 0, 'c': 0};
      }

      if (l.length == 0) {
        return {'ledgers': ledgers, 'items': items, 'bills': 0, 'c': 0};
      }

      var voucher = jsonData['VOUCHER']['VOUCHERNUMBER']['\$t'];
      if (voucher == '' || voucher == null) {
        if (jsonData['VOUCHER']['REFERENCE']['\$t'] == null ||
            jsonData['VOUCHER']['REFERENCE']['\$t'] == '') {
          voucher = 'PD-TALLY-' + getRandomString(10);
        } else {
          voucher =
              'SIN-TALLY-' + jsonData['VOUCHER']['REFERENCE']['\$t'].toString();
        }
      }
      if (vouchers.contains(voucher))
        return {'ledgers': ledgers, 'items': items, 'bills': 0, 'c': 1};

      var guid = jsonData['VOUCHER']['GUID']['\$t'].toString();
      var date = jsonData['VOUCHER']['DATE']['\$t'].toString();
      date = date.substring(0, 4) +
          '-' +
          date.substring(4, 6) +
          '-' +
          date.substring(6);

      var ledgerName =
          sData['party'][DataClean(l[0]['LEDGERNAME']['\$t'], quote: true)];
      if (ledgerName == null) {
        ledgerName = sData['party']
            [capitalize(DataClean(l[0]['LEDGERNAME']['\$t'], quote: true))];

        if (ledgerName == null)
          ledgerName = sData['party']
              [DataClean(l[0]['LEDGERNAME']['\$t'], quote: true).toUpperCase()];

        if (ledgerName == null)
          ledgerName = sData['party']
              [DataClean(l[0]['LEDGERNAME']['\$t'], quote: true).toLowerCase()];

        if (ledgerName == null) ledgerName = {'id': '0', 'code': ''};
      }

      var orderno = '';
      var against = '';
      if (l[0]['BILLALLOCATIONS.LIST'] != null &&
          l[0]['BILLALLOCATIONS.LIST'].isNotEmpty &&
          l[0]['BILLALLOCATIONS.LIST'] is Map &&
          l[0]['BILLALLOCATIONS.LIST']['NAME'] != null) {
        if (l[0]['BILLALLOCATIONS.LIST']['NAME'] == null) print('t');
        orderno = l[0]['BILLALLOCATIONS.LIST']['NAME']['\$t'] ?? '';
        against = l[0]['BILLALLOCATIONS.LIST']['BILLTYPE']['\$t'] ?? '';
      } else if (l[0]['BILLALLOCATIONS.LIST'] is List) {
        var bl = l[0]['BILLALLOCATIONS.LIST'];
        for (var b in bl) {
          if (b['NAME'] == null) {
            continue;
          }
          if (orderno == '') {
            orderno += b['NAME']['\$t'] ?? '';
          } else {
            orderno += ',' + (b['NAME']['\$t'] ?? '');
          }
        }
        against = 'Agst Ref';
      }

      var deliveryNoteMap = jsonData['VOUCHER']['INVOICEDELNOTES.LIST'];
      var deliveryNoteNo = '';
      var deliveryNoteDate = '';
      if (deliveryNoteMap != null) {
        deliveryNoteNo = deliveryNoteMap['BASICSHIPDELIVERYNOTE'] == null
            ? ''
            : (deliveryNoteMap['BASICSHIPDELIVERYNOTE']['\$t'] ?? '');
        deliveryNoteDate = deliveryNoteMap['BASICSHIPPINGDATE'] == null
            ? ''
            : (deliveryNoteMap['BASICSHIPPINGDATE']['\$t'] ?? '');
      }
      var dispatchDocNo = jsonData['VOUCHER']['BASICSHIPDOCUMENTNO'] == null
          ? ''
          : (jsonData['VOUCHER']['BASICSHIPDOCUMENTNO']['\$t'] ?? '');
      var dispatchThrough = jsonData['VOUCHER']['BASICSHIPPEDBY'] == null
          ? ''
          : (jsonData['VOUCHER']['BASICSHIPPEDBY']['\$t'] ?? '');
      var dispatchDestination =
          jsonData['VOUCHER']['BASICFINALDESTINATION'] == null
              ? ''
              : (jsonData['VOUCHER']['BASICFINALDESTINATION']['\$t'] ?? '');
      var dispatchAgent = jsonData['VOUCHER']['EICHECKPOST'] == null
          ? ''
          : (jsonData['VOUCHER']['EICHECKPOST']['\$t'] ?? '');
      var dispatchLanding = jsonData['VOUCHER']['BILLOFLADINGNO'] == null
          ? ''
          : (jsonData['VOUCHER']['BILLOFLADINGNO']['\$t'] ?? '');
      var dispatchVehicle = jsonData['VOUCHER']['BASICSHIPVESSELNO'] == null
          ? ''
          : (jsonData['VOUCHER']['BASICSHIPVESSELNO']['\$t'] ?? '');

      var l1 = {
        'id': ledgerName['id'],
        'account': ledgerName['code'],
        'amountdr': double.parse(l[0]['AMOUNT']['\$t']) *
            ((ptype == 'Debit Note' ||
                    ptype == 'Sales' ||
                    ptype == 'SALES' ||
                    ptype == 'Sales Order')
                ? -1
                : 0),
        'amountcr': double.parse(l[0]['AMOUNT']['\$t']) *
            ((ptype == 'Debit Note' ||
                    ptype == 'Sales' ||
                    ptype == 'SALES' ||
                    ptype == 'Sales Order')
                ? 0
                : 1),
        'voucher': sData['voucher'][type]['id'],
        'date': date,
        'bill': voucher,
        'narration': jsonData['VOUCHER']['NARRATION']['\$t'] ?? '',
        'cancelled': 0,
        'deleted': 0,
        'drcr': (ptype == 'Debit Note' ||
                ptype == 'Sales' ||
                ptype == 'SALES' ||
                ptype == 'Sales Order')
            ? 'Dr'
            : 'Cr',
        'contra': 0,
        'journal': 0,
        'guid': guid,
        'deliveryNoteNo': deliveryNoteNo,
        'deliveryNoteDate': deliveryNoteDate,
        'dispatchDocNo': dispatchDocNo,
        'dispatchThrough': dispatchThrough,
        'dispatchDestination': dispatchDestination,
        'dispatchAgent': dispatchAgent,
        'dispatchLanding': dispatchLanding,
        'dispatchVehicle': dispatchVehicle,
        'orderno': orderno,
        'against': against,
      };
      ledgers.add(l1);

      for (var j = 1; j < l.length; j++) {
        if (sData['party'][DataClean(l[j]['LEDGERNAME']['\$t'], quote: true)] ==
            null) continue;

        var taxtype = 'amount';
        double taxrate = 0;
        if (sData['party'][DataClean(l[j]['LEDGERNAME']['\$t'], quote: true)]
                ['code'] ==
            'Duties & Taxes') {
          taxtype = 'percentage';

          if (l[j]['BASICRATEOFINVOICETAX.LIST'] != null) {
            if (l[j]['BASICRATEOFINVOICETAX.LIST'] is Map) {
              taxrate = double.parse((l[j]['BASICRATEOFINVOICETAX.LIST']
                              ['BASICRATEOFINVOICETAX'] !=
                          null
                      ? (l[j]['BASICRATEOFINVOICETAX.LIST']
                              ['BASICRATEOFINVOICETAX']['\$t'] ??
                          '0')
                      : '0')
                  .toString());
            }
          }
        }

        var ledgerName =
            sData['party'][DataClean(l[j]['LEDGERNAME']['\$t'], quote: true)];
        if (ledgerName == null) {
          ledgerName = sData['party']
              [capitalize(DataClean(l[j]['LEDGERNAME']['\$t'], quote: true))];

          if (ledgerName == null)
            ledgerName = sData['party'][
                DataClean(l[j]['LEDGERNAME']['\$t'], quote: true)
                    .toUpperCase()];

          if (ledgerName == null)
            ledgerName = sData['party'][
                DataClean(l[j]['LEDGERNAME']['\$t'], quote: true)
                    .toLowerCase()];

          if (ledgerName == null) ledgerName = {'id': '0', 'code': ''};
        }
        var l2 = {
          'id': ledgerName['id'],
          'account': ledgerName['code'],
          'amountdr': double.parse(l[j]['AMOUNT']['\$t']) *
              ((ptype == 'Debit Note' ||
                      ptype == 'Sales' ||
                      ptype == 'SALES' ||
                      ptype == 'Sales Order')
                  ? 0
                  : -1),
          'amountcr': double.parse(l[j]['AMOUNT']['\$t']) *
              ((ptype == 'Debit Note' ||
                      ptype == 'Sales' ||
                      ptype == 'SALES' ||
                      ptype == 'Sales Order')
                  ? 1
                  : 0),
          'voucher': sData['voucher'][type]['id'],
          'date': date,
          'bill': voucher,
          'reference': jsonData['VOUCHER']['REFERENCE']['\$t'] ?? '',
          'narration': jsonData['VOUCHER']['NARRATION']['\$t'] ?? '',
          'cancelled': 0,
          'deleted': 0,
          'drcr': (ptype == 'Debit Note' ||
                  ptype == 'Sales' ||
                  ptype == 'SALES' ||
                  ptype == 'Sales Order')
              ? 'Cr'
              : 'Dr',
          'contra': 0,
          'journal': 0,
          'taxtype': taxtype,
          'taxrate': taxrate,
          'guid': guid,
          'deliveryNoteNo': deliveryNoteNo,
          'deliveryNoteDate': deliveryNoteDate,
          'dispatchDocNo': dispatchDocNo,
          'dispatchThrough': dispatchThrough,
          'dispatchDestination': dispatchDestination,
          'dispatchAgent': dispatchAgent,
          'dispatchLanding': dispatchLanding,
          'dispatchVehicle': dispatchVehicle,
        };

        ledgers.add(l2);
      }

      var s = jsonData['VOUCHER']['ALLINVENTORYENTRIES.LIST'] ?? [];
      List iList = [];
      if (s is Map) {
        iList.add(s);
      } else {
        iList = s;
      }

      for (var i = 0; i < iList.length; i++) {
        var qty = iList[i]['ACTUALQTY'] != null || iList[i]['ACTUALQTY'] != ''
            ? iList[i]['ACTUALQTY']['\$t']
            : iList[i]['BILLEDQTY']['\$t'];
        if (qty != null) {
          qty = qty.replaceAll(RegExp('[a-zA-Z ]'), '');
          qty = qty.toString().split('=')[0];
        }

        double value = 0;
        if (iList[i]['ISDEEMEDPOSITIVE']['\$t'] == 'Yes') {
          value = double.parse(iList[i]['AMOUNT']['\$t'] ?? '0') * -1;
        } else {
          value = double.parse(iList[i]['AMOUNT']['\$t'] ?? '0');
        }

        if (sData['item']
                [DataClean(iList[i]['STOCKITEMNAME']['\$t'], quote: true)] ==
            null) continue;

        var it = {
          'code': sData['item']
              [DataClean(iList[i]['STOCKITEMNAME']['\$t'], quote: true)]['sku'],
          'name': DataClean(iList[i]['STOCKITEMNAME']['\$t'], quote: true),
          'godown': DataClean(
                  iList[i]['BATCHALLOCATIONS.LIST']['GODOWNNAME']['\$t'],
                  quote: true) ??
              '',
          'unit': sData['item']
                  [DataClean(iList[i]['STOCKITEMNAME']['\$t'], quote: true)]
              ['unit'],
          'rate': (iList[i]['RATE']['\$t'] ?? '0/').split('/')[0],
          'value': value,
          'gst': 0,
          'discount': iList[i]['DISCOUNT']['\$t'] ?? '0',
          'qty': qty ?? 0,
          'category': sData['item']
                  [DataClean(iList[i]['STOCKITEMNAME']['\$t'], quote: true)]
              ['category'],
          'party': sData['party'][DataClean(
              jsonData['VOUCHER']['PARTYLEDGERNAME']['\$t'],
              quote: true)]['id'],
          'date': date,
          'bill': voucher,
          'voucher': sData['voucher'][type]['id'],
          'hsncode': sData['item']
                  [DataClean(iList[i]['STOCKITEMNAME']['\$t'], quote: true)]
              ['hsncode'],
          'accouting': {
            'id': sData['party'][DataClean(
                iList[i]['ACCOUNTINGALLOCATIONS.LIST']['LEDGERNAME']['\$t'],
                quote: true)]['id'],
            'name': DataClean(
                iList[i]['ACCOUNTINGALLOCATIONS.LIST']['LEDGERNAME']['\$t'],
                quote: true),
          },
          'guid': guid,
        };

        items.add(it);
      }

      return {'ledgers': ledgers, 'items': items, 'bills': 0, 'c': 0};
    } catch (e) {
      print(e);
      return {'ledgers': ledgers, 'items': items, 'bills': 0, 'c': 0};
    }
  }

  // Upload Voucher Register
  uploadVoucherRegister(
    Uri url,
    String company,
    String data, {
    bool debug = false,
  }) async {
    try {
      Map jsonData = jsonDecode(data);
      List l = jsonData['ledgers'];
      List s = jsonData['items'];
      String voucher = jsonData['voucher'];

      var lcount = (l.length / defaultRequestSize).floor() + 1;
      var scount = (s.length / defaultRequestSize).floor() + 1;
      int defaultValue = 0;

      var ledgers = [];
      var items = [];

      await TallyRequest().tallyToServer(
        url,
        company,
        jsonEncode({
          'ledgers': l,
          'items': [],
          'from': jsonData['from'],
          'to': jsonData['to'],
          'type': 'ledgers',
          'voucher': voucher,
        }),
        debug: debug,
      );
      await TallyRequest().tallyToServer(
        url,
        company,
        jsonEncode({
          'ledgers': [],
          'items': s,
          'from': jsonData['from'],
          'to': jsonData['to'],
          'type': 'items',
          'voucher': voucher,
        }),
        debug: debug,
      );
    } catch (e) {
      print(e);
    }
  }

  // Random Generator
  var _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  String capitalize(String s) =>
      s[0].toUpperCase() + s.substring(1).toLowerCase();
}
