import 'dart:convert';

import '../controller/DataClean.dart';
import '../tdl/tdl.dart';
import '../data/url.dart';
import 'package:jiffy/jiffy.dart';
import 'package:xml2json/xml2json.dart';

class ServerToTally {
  String company = '';
  Map data = {};
  Xml2Json jsonParse = Xml2Json();
  Map created = {};

  ServerToTally(String name) {
    this.company = name;
  }

  init() async {
    try {
      var d = await TallyRequest().tallyToServer(
        detailsUrl,
        company,
        '',
      );
      data = d['data'];

      // Payment Voucher
      var payment = await _payment();
      created['payment'] = payment;

      // Receipt Voucher
      var receipt = await _receipt();
      created['receipt'] = receipt;

      // Purchase Order Voucher
      var pOrder = await _pOrder();
      created['pOrder'] = pOrder;

      // Sales Order Voucher
      var sOrder = await _sOrder();
      created['sOrder'] = sOrder;

      // Purchase Voucher
      var purchase = await _purchase();
      created['purchase'] = purchase;

      // Sales Voucher
      var sales = await _sales();
      created['sales'] = sales;

      // Debit Note Voucher
      var debit = await _debit();
      created['debit'] = debit;

      // Credit Note Voucher
      var credit = await _credit();
      created['credit'] = credit;

      // Journal Voucher
      var journal = await _journal();
      created['journal'] = journal;

      // Update Server
      await TallyRequest().tallyToServer(
        updateUrl,
        company,
        jsonEncode(created),
      );
      print('done');
    } catch (e) {
      print(e);
    }
  }

  _payment() async {
    try {
      var payment = data['payment'];
      var cList = [];

      for (var i = 0; i < payment.length; i++) {
        var date = Jiffy(payment[i]['date']).format('yyyyMMdd');
        var name1 = DataTally(payment[i]['name']);
        var name2 = DataTally(payment[i]['name2']);
        var voucher = payment[i]['voucher'];
        var amount = payment[i]['amount'];
        var bank = DataTally(payment[i]['isBank']);

        var tdl = '''
<ENVELOPE>
    <HEADER>
        <TALLYREQUEST>Import Data</TALLYREQUEST>
    </HEADER>
    <BODY>
        <IMPORTDATA>
            <REQUESTDESC>
                <REPORTNAME>Vouchers</REPORTNAME>
                <STATICVARIABLES>
                    <SVCURRENTCOMPANY>''' +
            company +
            '''</SVCURRENTCOMPANY>
                </STATICVARIABLES>
            </REQUESTDESC>
            <TALLYMESSAGE xmlns:UDF="TallyUDF">
                <VOUCHER VCHTYPE="Payment" ACTION="Create" OBJVIEW="Accounting Voucher View">
                    <OLDAUDITENTRYIDS.LIST TYPE="Number">
                        <OLDAUDITENTRYIDS>-1</OLDAUDITENTRYIDS>
                    </OLDAUDITENTRYIDS.LIST>
                    <DATE>''' +
            date +
            '''</DATE>
                    <PARTYLEDGERNAME>''' +
            name1 +
            '''</PARTYLEDGERNAME>
                    <VOUCHERTYPENAME>Payment</VOUCHERTYPENAME>
                    <VOUCHERNUMBER>''' +
            voucher +
            '''</VOUCHERNUMBER>
                    <FBTPAYMENTTYPE>Default</FBTPAYMENTTYPE>
                    <PERSISTEDVIEW>Accounting Voucher View</PERSISTEDVIEW>
                    <VOUCHERTYPEORIGNAME>Payment</VOUCHERTYPEORIGNAME>
                    <EFFECTIVEDATE>''' +
            date +
            '''</EFFECTIVEDATE>
                    <ALLLEDGERENTRIES.LIST>
                        <OLDAUDITENTRYIDS.LIST TYPE="Number">
                            <OLDAUDITENTRYIDS>-1</OLDAUDITENTRYIDS>
                        </OLDAUDITENTRYIDS.LIST>
                        <LEDGERNAME>''' +
            name1 +
            '''</LEDGERNAME>
                        <ISDEEMEDPOSITIVE>Yes</ISDEEMEDPOSITIVE>
                        <LEDGERFROMITEM>No</LEDGERFROMITEM>
                        <REMOVEZEROENTRIES>No</REMOVEZEROENTRIES>
                        <ISPARTYLEDGER>Yes</ISPARTYLEDGER>
                        <ISLASTDEEMEDPOSITIVE>Yes</ISLASTDEEMEDPOSITIVE>
                        <ISCAPVATTAXALTERED>No</ISCAPVATTAXALTERED>
                        <ISCAPVATNOTCLAIMED>No</ISCAPVATNOTCLAIMED>
                        <AMOUNT>-''' +
            amount +
            '''</AMOUNT>
                    </ALLLEDGERENTRIES.LIST>
                    <ALLLEDGERENTRIES.LIST>
                        <OLDAUDITENTRYIDS.LIST TYPE="Number">
                            <OLDAUDITENTRYIDS>-1</OLDAUDITENTRYIDS>
                        </OLDAUDITENTRYIDS.LIST>
                        <LEDGERNAME>''' +
            name2 +
            '''</LEDGERNAME>
                        <ISDEEMEDPOSITIVE>No</ISDEEMEDPOSITIVE>
                        <LEDGERFROMITEM>No</LEDGERFROMITEM>
                        <REMOVEZEROENTRIES>No</REMOVEZEROENTRIES>
                        <ISPARTYLEDGER>Yes</ISPARTYLEDGER>
                        <ISLASTDEEMEDPOSITIVE>No</ISLASTDEEMEDPOSITIVE>
                        <ISCAPVATTAXALTERED>No</ISCAPVATTAXALTERED>
                        <ISCAPVATNOTCLAIMED>No</ISCAPVATNOTCLAIMED>
                        <AMOUNT>''' +
            amount +
            '''</AMOUNT>
                    </ALLLEDGERENTRIES.LIST>
                </VOUCHER>
            </TALLYMESSAGE>
        </IMPORTDATA>
    </BODY>
</ENVELOPE>
''';

        var data = await TallyRequest().request(tdl);
        jsonParse.parse(data);
        var jsonData = jsonDecode(jsonParse.toGData());
        if (jsonData['RESPONSE']['CREATED'] != null &&
            jsonData['RESPONSE']['CREATED']['\$t'] != 0) {
          cList.add(voucher);
        }
      }

      return cList;
    } catch (e) {
      print(e);
    }
  }

  _receipt() async {
    try {
      var receipt = data['receipt'];
      var cList = [];

      for (var i = 0; i < receipt.length; i++) {
        var date = Jiffy(receipt[i]['date']).format('yyyyMMdd');
        var name1 = DataTally(receipt[i]['name']);
        var name2 = DataTally(receipt[i]['name2']);
        var voucher = receipt[i]['voucher'];
        var amount = receipt[i]['amount'];
        var bank = DataTally(receipt[i]['isBank']);

        var tdl = '''
<ENVELOPE>
    <HEADER>
        <TALLYREQUEST>Import Data</TALLYREQUEST>
    </HEADER>
    <BODY>
        <IMPORTDATA>
            <REQUESTDESC>
                <REPORTNAME>Vouchers</REPORTNAME>
                <STATICVARIABLES>
                    <SVCURRENTCOMPANY>''' +
            company +
            '''</SVCURRENTCOMPANY>
                </STATICVARIABLES>
            </REQUESTDESC>
            <TALLYMESSAGE xmlns:UDF="TallyUDF">
                <VOUCHER VCHTYPE="Receipt" ACTION="Create" OBJVIEW="Accounting Voucher View">
                    <OLDAUDITENTRYIDS.LIST TYPE="Number">
                        <OLDAUDITENTRYIDS>-1</OLDAUDITENTRYIDS>
                    </OLDAUDITENTRYIDS.LIST>
                    <DATE>''' +
            date +
            '''</DATE>
                    <PARTYLEDGERNAME>''' +
            name1 +
            '''</PARTYLEDGERNAME>
                    <VOUCHERTYPENAME>Receipt</VOUCHERTYPENAME>
                    <VOUCHERNUMBER>''' +
            voucher +
            '''</VOUCHERNUMBER>
                    <FBTPAYMENTTYPE>Default</FBTPAYMENTTYPE>
                    <PERSISTEDVIEW>Accounting Voucher View</PERSISTEDVIEW>
                    <VOUCHERTYPEORIGNAME>Receipt</VOUCHERTYPEORIGNAME>
                    <EFFECTIVEDATE>''' +
            date +
            '''</EFFECTIVEDATE>
                    <ALLLEDGERENTRIES.LIST>
                        <OLDAUDITENTRYIDS.LIST TYPE="Number">
                            <OLDAUDITENTRYIDS>-1</OLDAUDITENTRYIDS>
                        </OLDAUDITENTRYIDS.LIST>
                        <LEDGERNAME>''' +
            name1 +
            '''</LEDGERNAME>
                        <ISDEEMEDPOSITIVE>No</ISDEEMEDPOSITIVE>
                        <LEDGERFROMITEM>No</LEDGERFROMITEM>
                        <REMOVEZEROENTRIES>No</REMOVEZEROENTRIES>
                        <ISPARTYLEDGER>Yes</ISPARTYLEDGER>
                        <ISLASTDEEMEDPOSITIVE>Yes</ISLASTDEEMEDPOSITIVE>
                        <ISCAPVATTAXALTERED>No</ISCAPVATTAXALTERED>
                        <ISCAPVATNOTCLAIMED>No</ISCAPVATNOTCLAIMED>
                        <AMOUNT>''' +
            amount +
            '''</AMOUNT>
                    </ALLLEDGERENTRIES.LIST>
                    <ALLLEDGERENTRIES.LIST>
                        <OLDAUDITENTRYIDS.LIST TYPE="Number">
                            <OLDAUDITENTRYIDS>-1</OLDAUDITENTRYIDS>
                        </OLDAUDITENTRYIDS.LIST>
                        <LEDGERNAME>''' +
            name2 +
            '''</LEDGERNAME>
                        <ISDEEMEDPOSITIVE>Yes</ISDEEMEDPOSITIVE>
                        <LEDGERFROMITEM>No</LEDGERFROMITEM>
                        <REMOVEZEROENTRIES>No</REMOVEZEROENTRIES>
                        <ISPARTYLEDGER>Yes</ISPARTYLEDGER>
                        <ISLASTDEEMEDPOSITIVE>No</ISLASTDEEMEDPOSITIVE>
                        <ISCAPVATTAXALTERED>No</ISCAPVATTAXALTERED>
                        <ISCAPVATNOTCLAIMED>No</ISCAPVATNOTCLAIMED>
                        <AMOUNT>-''' +
            amount +
            '''</AMOUNT>
                    </ALLLEDGERENTRIES.LIST>
                </VOUCHER>
            </TALLYMESSAGE>
        </IMPORTDATA>
    </BODY>
</ENVELOPE>
''';

        var data = await TallyRequest().request(tdl);
        jsonParse.parse(data);
        var jsonData = jsonDecode(jsonParse.toGData());
        if (jsonData['RESPONSE']['CREATED'] != null &&
            jsonData['RESPONSE']['CREATED']['\$t'] != 0) {
          cList.add(voucher);
        }
      }

      return cList;
    } catch (e) {
      print(e);
    }
  }

  _purchase() async {
    try {
      var purchase = data['purchase'];
      var cList = [];

      for (var i = 0; i < purchase.length; i++) {
        var voucher = purchase[i].keys.toList()[0];
        var date = Jiffy(purchase[i][voucher]['ledgers'][0]['date'])
            .format('yyyyMMdd');
        var sdate = Jiffy(purchase[i][voucher]['ledgers'][0]['sdate'])
            .format('yyyyMMdd');

        List ledgers = purchase[i][voucher]['ledgers'];
        List items = purchase[i][voucher]['items'];

        var tdl = '''
<ENVELOPE>
    <HEADER>
        <TALLYREQUEST>Import Data</TALLYREQUEST>
    </HEADER>
    <BODY>
        <IMPORTDATA>
            <REQUESTDESC>
                <REPORTNAME>All Masters</REPORTNAME>
                <STATICVARIABLES>
                    <SVCURRENTCOMPANY>''' +
            company +
            '''</SVCURRENTCOMPANY>
                </STATICVARIABLES>
            </REQUESTDESC>
            <REQUESTDATA>
                <TALLYMESSAGE xmlns:UDF="TallyUDF">
                    <VOUCHER VCHTYPE="Purchase" ACTION="Create" OBJVIEW="Invoice Voucher View">
                        <OLDAUDITENTRYIDS.LIST TYPE="Number">
                            <OLDAUDITENTRYIDS>-1</OLDAUDITENTRYIDS>
                        </OLDAUDITENTRYIDS.LIST>
                        <DATE>''' +
            date +
            '''</DATE>
                        <REFERENCEDATE>''' +
            sdate +
            '''</REFERENCEDATE>
                        <VATDEALERTYPE>Regular</VATDEALERTYPE>
                        <PARTYNAME>''' +
            DataTally(ledgers[0]['name']) +
            '''</PARTYNAME>
                        <PARTYLEDGERNAME>''' +
            DataTally(ledgers[0]['name']) +
            '''</PARTYLEDGERNAME>
                        <VOUCHERTYPENAME>Purchase</VOUCHERTYPENAME>
                        <REFERENCE>''' +
            ledgers[0]['supplier'] +
            '''</REFERENCE>
                        <VOUCHERNUMBER>''' +
            voucher +
            '''</VOUCHERNUMBER>
                        <BASICBASEPARTYNAME>''' +
            DataTally(ledgers[0]['name']) +
            '''</BASICBASEPARTYNAME>
                        <FBTPAYMENTTYPE>Default</FBTPAYMENTTYPE>
                        <PERSISTEDVIEW>Invoice Voucher View</PERSISTEDVIEW>
                        <BASICBUYERNAME>''' +
            company +
            '''</BASICBUYERNAME>
                        <PARTYMAILINGNAME>''' +
            DataTally(ledgers[0]['name']) +
            '''</PARTYMAILINGNAME>
                        <VCHENTRYMODE>Item Accounting</VCHENTRYMODE>
                        <EFFECTIVEDATE>''' +
            date +
            '''</EFFECTIVEDATE>''';

        for (var j = 0; j < items.length; j++) {
          tdl = tdl +
              '''<ALLINVENTORYENTRIES.LIST>
                    <STOCKITEMNAME>''' +
              DataTally(items[j]['name']) +
              '''</STOCKITEMNAME>
                    <ISDEEMEDPOSITIVE>Yes</ISDEEMEDPOSITIVE>
                    <ISLASTDEEMEDPOSITIVE>Yes</ISLASTDEEMEDPOSITIVE>
                    <ISAUTONEGATE>No</ISAUTONEGATE>
                    <ISCUSTOMSCLEARANCE>No</ISCUSTOMSCLEARANCE>
                    <ISTRACKCOMPONENT>No</ISTRACKCOMPONENT>
                    <ISTRACKPRODUCTION>No</ISTRACKPRODUCTION>
                    <ISPRIMARYITEM>No</ISPRIMARYITEM>
                    <ISSCRAP>No</ISSCRAP>
                    <RATE>''' +
              DataTally(items[j]['rate']) +
              '''</RATE>
                    <AMOUNT>-''' +
              DataTally(items[j]['amount']) +
              '''</AMOUNT>
                    <ACTUALQTY>''' +
              DataTally(items[j]['qty']) +
              '''</ACTUALQTY>
                    <BILLEDQTY>''' +
              DataTally(items[j]['qty']) +
              '''</BILLEDQTY>
                    <BATCHALLOCATIONS.LIST>
                        <GODOWNNAME>''' +
              DataTally(
                  items[j]['godown'] == 'NULL' || items[j]['godown'] == null
                      ? 'Main Location'
                      : items[j]['godown']) +
              '''</GODOWNNAME>
                        <BATCHNAME>Primary Batch</BATCHNAME>
                        <AMOUNT>-''' +
              DataTally(items[j]['amount']) +
              '''</AMOUNT>
                    </BATCHALLOCATIONS.LIST>
                    <ACCOUNTINGALLOCATIONS.LIST>
                        <OLDAUDITENTRYIDS.LIST TYPE="Number">
                            <OLDAUDITENTRYIDS>-1</OLDAUDITENTRYIDS>
                        </OLDAUDITENTRYIDS.LIST>
                        <LEDGERNAME>''' +
              DataTally(items[j]['account']) +
              '''</LEDGERNAME>
                        <GSTCLASS/>
                        <ISDEEMEDPOSITIVE>Yes</ISDEEMEDPOSITIVE>
                        <LEDGERFROMITEM>No</LEDGERFROMITEM>
                        <REMOVEZEROENTRIES>No</REMOVEZEROENTRIES>
                        <ISPARTYLEDGER>No</ISPARTYLEDGER>
                        <ISLASTDEEMEDPOSITIVE>Yes</ISLASTDEEMEDPOSITIVE>
                        <ISCAPVATTAXALTERED>No</ISCAPVATTAXALTERED>
                        <ISCAPVATNOTCLAIMED>No</ISCAPVATNOTCLAIMED>
                        <AMOUNT>-''' +
              DataTally(items[j]['amount']) +
              '''</AMOUNT>
                    </ACCOUNTINGALLOCATIONS.LIST>
                </ALLINVENTORYENTRIES.LIST>''';
        }

        for (var j = 0; j < ledgers.length; j++) {
          tdl = tdl +
              '''<LEDGERENTRIES.LIST>
                            <OLDAUDITENTRYIDS.LIST TYPE="Number">
                                <OLDAUDITENTRYIDS>-1</OLDAUDITENTRYIDS>
                            </OLDAUDITENTRYIDS.LIST>
                            <LEDGERNAME>''' +
              DataTally(ledgers[j]['name']) +
              '''</LEDGERNAME>''';

          if (ledgers[j]['against'] != 'On-Account' &&
              ledgers[j]['against'] != null) {
            tdl += '''<BILLALLOCATIONS.LIST>
                    <NAME>''' +
                DataTally(ledgers[j]['order']) +
                '''</NAME>
                    <BILLTYPE>''' +
                DataTally(ledgers[j]['against']) +
                '''</BILLTYPE>
                    <AMOUNT>''' +
                (j == 0 ? '' : '-') +
                DataTally(ledgers[j]['amount']) +
                '''</AMOUNT>
                </BILLALLOCATIONS.LIST>''';
          }

          tdl += '''<ISDEEMEDPOSITIVE>''' +
              (j == 0 ? 'No' : 'Yes') +
              '''</ISDEEMEDPOSITIVE>
                            <ISPARTYLEDGER>Yes</ISPARTYLEDGER>
                            <AMOUNT>''' +
              (j == 0 ? '' : '-') +
              DataTally(ledgers[j]['amount']) +
              '''</AMOUNT>
                        </LEDGERENTRIES.LIST>''';
        }

        tdl = tdl +
            '''</VOUCHER>
                </TALLYMESSAGE>
            </REQUESTDATA>
        </IMPORTDATA>
    </BODY>
</ENVELOPE>
''';

        var data = await TallyRequest().request(tdl);
        jsonParse.parse(data);
        var jsonData = jsonDecode(jsonParse.toGData());
        if (jsonData['RESPONSE']['CREATED'] != null &&
            jsonData['RESPONSE']['CREATED']['\$t'] != '0') {
          cList.add(voucher);
        } else {
          print(jsonEncode(jsonData));
        }
      }

      return cList;
    } catch (e) {
      print(e);
    }
  }

  _pOrder() async {
    try {
      var pOrder = data['pOrder'];
      var cList = [];

      for (var i = 0; i < pOrder.length; i++) {
        var voucher = pOrder[i].keys.toList()[0];
        var date =
            Jiffy(pOrder[i][voucher]['ledgers'][0]['date']).format('yyyyMMdd');

        List ledgers = pOrder[i][voucher]['ledgers'];
        List items = pOrder[i][voucher]['items'];

        var tdl = '''
<ENVELOPE>
    <HEADER>
        <TALLYREQUEST>Import Data</TALLYREQUEST>
    </HEADER>
    <BODY>
        <IMPORTDATA>
            <REQUESTDESC>
                <REPORTNAME>All Masters</REPORTNAME>
                <STATICVARIABLES>
                    <SVCURRENTCOMPANY>''' +
            company +
            '''</SVCURRENTCOMPANY>
                </STATICVARIABLES>
            </REQUESTDESC>
            <REQUESTDATA>
                <TALLYMESSAGE xmlns:UDF="TallyUDF">
                    <VOUCHER VCHTYPE="Purchase Order" ACTION="Create" OBJVIEW="Invoice Voucher View">
                        <OLDAUDITENTRYIDS.LIST TYPE="Number">
                            <OLDAUDITENTRYIDS>-1</OLDAUDITENTRYIDS>
                        </OLDAUDITENTRYIDS.LIST>
                        <DATE>''' +
            date +
            '''</DATE>
                        <REFERENCEDATE>''' +
            date +
            '''</REFERENCEDATE>
                        <VATDEALERTYPE>Regular</VATDEALERTYPE>
                        <PARTYNAME>''' +
            DataTally(ledgers[0]['name']) +
            '''</PARTYNAME>
                        <PARTYLEDGERNAME>''' +
            DataTally(ledgers[0]['name']) +
            '''</PARTYLEDGERNAME>
                        <VOUCHERTYPENAME>Purchase ORder</VOUCHERTYPENAME>
                        <REFERENCE>''' +
            voucher +
            '''</REFERENCE>
                        <VOUCHERNUMBER>''' +
            voucher +
            '''</VOUCHERNUMBER>
                        <BASICBASEPARTYNAME>''' +
            DataTally(ledgers[0]['name']) +
            '''</BASICBASEPARTYNAME>
                        <FBTPAYMENTTYPE>Default</FBTPAYMENTTYPE>
                        <PERSISTEDVIEW>Invoice Voucher View</PERSISTEDVIEW>
                        <BASICBUYERNAME>''' +
            company +
            '''</BASICBUYERNAME>
                        <PARTYMAILINGNAME>''' +
            DataTally(ledgers[0]['name']) +
            '''</PARTYMAILINGNAME>
                        <EFFECTIVEDATE>''' +
            date +
            '''</EFFECTIVEDATE>''';

        for (var j = 0; j < items.length; j++) {
          tdl = tdl +
              '''<ALLINVENTORYENTRIES.LIST>
                    <STOCKITEMNAME>''' +
              DataTally(items[j]['name']) +
              '''</STOCKITEMNAME>
                    <ISDEEMEDPOSITIVE>Yes</ISDEEMEDPOSITIVE>
                    <ISLASTDEEMEDPOSITIVE>Yes</ISLASTDEEMEDPOSITIVE>
                    <ISAUTONEGATE>No</ISAUTONEGATE>
                    <ISCUSTOMSCLEARANCE>No</ISCUSTOMSCLEARANCE>
                    <ISTRACKCOMPONENT>No</ISTRACKCOMPONENT>
                    <ISTRACKPRODUCTION>No</ISTRACKPRODUCTION>
                    <ISPRIMARYITEM>No</ISPRIMARYITEM>
                    <RATE>''' +
              DataTally(items[j]['rate']) +
              '''</RATE>
                    <AMOUNT>-''' +
              DataTally(items[j]['amount']) +
              '''</AMOUNT>
                    <ACTUALQTY>''' +
              DataTally(items[j]['qty']) +
              '''</ACTUALQTY>
                    <BILLEDQTY>''' +
              DataTally(items[j]['qty']) +
              '''</BILLEDQTY>
                    <BATCHALLOCATIONS.LIST>
                        <GODOWNNAME>''' +
              DataTally(
                  items[j]['godown'] == 'NULL' || items[j]['godown'] == null
                      ? 'Main Location'
                      : items[j]['godown']) +
              '''</GODOWNNAME>
                        <BATCHNAME>Primary Batch</BATCHNAME>
                        <ORDERDUEDATE>''' +
              date +
              '''</ORDERDUEDATE>
                        <AMOUNT>-''' +
              DataTally(items[j]['amount']) +
              '''</AMOUNT>
                    </BATCHALLOCATIONS.LIST>
                    <ACCOUNTINGALLOCATIONS.LIST>
                        <OLDAUDITENTRYIDS.LIST TYPE="Number">
                            <OLDAUDITENTRYIDS>-1</OLDAUDITENTRYIDS>
                        </OLDAUDITENTRYIDS.LIST>
                        <LEDGERNAME>''' +
              DataTally(items[j]['account']) +
              '''</LEDGERNAME>
                        <GSTCLASS/>
                        <ISDEEMEDPOSITIVE>Yes</ISDEEMEDPOSITIVE>
                        <LEDGERFROMITEM>No</LEDGERFROMITEM>
                        <REMOVEZEROENTRIES>No</REMOVEZEROENTRIES>
                        <ISPARTYLEDGER>No</ISPARTYLEDGER>
                        <ISLASTDEEMEDPOSITIVE>Yes</ISLASTDEEMEDPOSITIVE>
                        <ISCAPVATTAXALTERED>No</ISCAPVATTAXALTERED>
                        <ISCAPVATNOTCLAIMED>No</ISCAPVATNOTCLAIMED>
                        <AMOUNT>-''' +
              DataTally(items[j]['amount']) +
              '''</AMOUNT>
                    </ACCOUNTINGALLOCATIONS.LIST>
                </ALLINVENTORYENTRIES.LIST>''';
        }

        for (var j = 0; j < ledgers.length; j++) {
          tdl = tdl +
              '''<LEDGERENTRIES.LIST>
                            <OLDAUDITENTRYIDS.LIST TYPE="Number">
                                <OLDAUDITENTRYIDS>-1</OLDAUDITENTRYIDS>
                            </OLDAUDITENTRYIDS.LIST>
                            <LEDGERNAME>''' +
              DataTally(ledgers[j]['name']) +
              '''</LEDGERNAME>
                            <ISDEEMEDPOSITIVE>''' +
              (j == 0 ? 'No' : 'Yes') +
              '''</ISDEEMEDPOSITIVE>
                            <ISPARTYLEDGER>Yes</ISPARTYLEDGER>
                            <AMOUNT>''' +
              (j == 0 ? '' : '-') +
              DataTally(ledgers[j]['amount']) +
              '''</AMOUNT>
                        </LEDGERENTRIES.LIST>''';
        }

        tdl = tdl +
            '''</VOUCHER>
                </TALLYMESSAGE>
            </REQUESTDATA>
        </IMPORTDATA>
    </BODY>
</ENVELOPE>
''';

        var data = await TallyRequest().request(tdl);
        jsonParse.parse(data);
        var jsonData = jsonDecode(jsonParse.toGData());
        if (jsonData['RESPONSE']['CREATED'] != null &&
            jsonData['RESPONSE']['CREATED']['\$t'] != '0') {
          cList.add(voucher);
        } else {
          print(jsonEncode(jsonData));
        }
      }

      return cList;
    } catch (e) {
      print(e);
    }
  }

  _sales() async {
    try {
      var sales = data['sales'];
      var cList = [];

      for (var i = 0; i < sales.length; i++) {
        var voucher = sales[i].keys.toList()[0];
        var date =
            Jiffy(sales[i][voucher]['ledgers'][0]['date']).format('yyyyMMdd');
        var sdate =
            Jiffy(sales[i][voucher]['ledgers'][0]['sdate']).format('yyyyMMdd');

        List ledgers = sales[i][voucher]['ledgers'];
        List items = sales[i][voucher]['items'];

        var tdl = '''
<ENVELOPE>
    <HEADER>
        <TALLYREQUEST>Import Data</TALLYREQUEST>
    </HEADER>
    <BODY>
        <IMPORTDATA>
            <REQUESTDESC>
                <REPORTNAME>All Masters</REPORTNAME>
                <STATICVARIABLES>
                    <SVCURRENTCOMPANY>''' +
            company +
            '''</SVCURRENTCOMPANY>
                </STATICVARIABLES>
            </REQUESTDESC>
            <REQUESTDATA>
                <TALLYMESSAGE xmlns:UDF="TallyUDF">
                    <VOUCHER VCHTYPE="Sales" ACTION="Create" OBJVIEW="Invoice Voucher View">
                        <OLDAUDITENTRYIDS.LIST TYPE="Number">
                            <OLDAUDITENTRYIDS>-1</OLDAUDITENTRYIDS>
                        </OLDAUDITENTRYIDS.LIST>
                        <DATE>''' +
            date +
            '''</DATE>
                        <REFERENCEDATE>''' +
            sdate +
            '''</REFERENCEDATE>
                        <VATDEALERTYPE>Regular</VATDEALERTYPE>
                        <PARTYNAME>''' +
            DataTally(ledgers[0]['name']) +
            '''</PARTYNAME>
                        <PARTYLEDGERNAME>''' +
            DataTally(ledgers[0]['name']) +
            '''</PARTYLEDGERNAME>
                        <VOUCHERTYPENAME>Sales</VOUCHERTYPENAME>
                        <REFERENCE>''' +
            ledgers[0]['supplier'] +
            '''</REFERENCE>
                        <VOUCHERNUMBER>''' +
            voucher +
            '''</VOUCHERNUMBER>
                        <BASICBASEPARTYNAME>''' +
            DataTally(ledgers[0]['name']) +
            '''</BASICBASEPARTYNAME>
                        <FBTPAYMENTTYPE>Default</FBTPAYMENTTYPE>
                        <PERSISTEDVIEW>Invoice Voucher View</PERSISTEDVIEW>
                        <BASICBUYERNAME>''' +
            company +
            '''</BASICBUYERNAME>
                        <PARTYMAILINGNAME>''' +
            DataTally(ledgers[0]['name']) +
            '''</PARTYMAILINGNAME>
                        <VCHENTRYMODE>Item Invoice</VCHENTRYMODE>
                        <EFFECTIVEDATE>''' +
            date +
            '''</EFFECTIVEDATE>''';

        for (var j = 0; j < items.length; j++) {
          tdl = tdl +
              '''<ALLINVENTORYENTRIES.LIST>
                    <STOCKITEMNAME>''' +
              DataTally(items[j]['name']) +
              '''</STOCKITEMNAME>
                    <ISDEEMEDPOSITIVE>No</ISDEEMEDPOSITIVE>
                    <ISLASTDEEMEDPOSITIVE>No</ISLASTDEEMEDPOSITIVE>
                    <ISAUTONEGATE>No</ISAUTONEGATE>
                    <ISCUSTOMSCLEARANCE>No</ISCUSTOMSCLEARANCE>
                    <ISTRACKCOMPONENT>No</ISTRACKCOMPONENT>
                    <ISTRACKPRODUCTION>No</ISTRACKPRODUCTION>
                    <ISPRIMARYITEM>No</ISPRIMARYITEM>
                    <ISSCRAP>No</ISSCRAP>
                    <RATE>''' +
              DataTally(items[j]['rate']) +
              '''</RATE>
                    <AMOUNT>''' +
              DataTally(items[j]['amount']) +
              '''</AMOUNT>
                    <ACTUALQTY>''' +
              DataTally(items[j]['qty']) +
              '''</ACTUALQTY>
                    <BILLEDQTY>''' +
              DataTally(items[j]['qty']) +
              '''</BILLEDQTY>
                    <BATCHALLOCATIONS.LIST>
                        <GODOWNNAME>''' +
              DataTally(
                  items[j]['godown'] == 'NULL' || items[j]['godown'] == null
                      ? 'Main Location'
                      : items[j]['godown']) +
              '''</GODOWNNAME>
                        <BATCHNAME>Primary Batch</BATCHNAME>
                        <AMOUNT>''' +
              DataTally(items[j]['amount']) +
              '''</AMOUNT>
                    </BATCHALLOCATIONS.LIST>
                    <ACCOUNTINGALLOCATIONS.LIST>
                        <OLDAUDITENTRYIDS.LIST TYPE="Number">
                            <OLDAUDITENTRYIDS>-1</OLDAUDITENTRYIDS>
                        </OLDAUDITENTRYIDS.LIST>
                        <LEDGERNAME>''' +
              DataTally(items[j]['account']) +
              '''</LEDGERNAME>
                        <GSTCLASS/>
                        <ISDEEMEDPOSITIVE>No</ISDEEMEDPOSITIVE>
                        <LEDGERFROMITEM>No</LEDGERFROMITEM>
                        <REMOVEZEROENTRIES>No</REMOVEZEROENTRIES>
                        <ISPARTYLEDGER>No</ISPARTYLEDGER>
                        <ISLASTDEEMEDPOSITIVE>No</ISLASTDEEMEDPOSITIVE>
                        <ISCAPVATTAXALTERED>No</ISCAPVATTAXALTERED>
                        <ISCAPVATNOTCLAIMED>No</ISCAPVATNOTCLAIMED>
                        <AMOUNT>''' +
              DataTally(items[j]['amount']) +
              '''</AMOUNT>
                    </ACCOUNTINGALLOCATIONS.LIST>
                </ALLINVENTORYENTRIES.LIST>''';
        }

        for (var j = 0; j < ledgers.length; j++) {
          tdl = tdl +
              '''<LEDGERENTRIES.LIST>
                            <OLDAUDITENTRYIDS.LIST TYPE="Number">
                                <OLDAUDITENTRYIDS>-1</OLDAUDITENTRYIDS>
                            </OLDAUDITENTRYIDS.LIST>
                            <LEDGERNAME>''' +
              DataTally(ledgers[j]['name']) +
              '''</LEDGERNAME>''';

          if (ledgers[j]['against'] != 'On-Account' &&
              ledgers[j]['against'] != null) {
            tdl += '''<BILLALLOCATIONS.LIST>
                    <NAME>''' +
                DataTally(ledgers[j]['order']) +
                '''</NAME>
                    <BILLTYPE>''' +
                DataTally(ledgers[j]['against']) +
                '''</BILLTYPE>
                    <AMOUNT>''' +
                (j != 0 ? '' : '-') +
                DataTally(ledgers[j]['amount']) +
                '''</AMOUNT>
                </BILLALLOCATIONS.LIST>''';
          }

          tdl += '''<ISDEEMEDPOSITIVE>''' +
              (j != 0 ? 'No' : 'Yes') +
              '''</ISDEEMEDPOSITIVE>
                            <ISPARTYLEDGER>Yes</ISPARTYLEDGER>
                            <AMOUNT>''' +
              (j != 0 ? '' : '-') +
              DataTally(ledgers[j]['amount']) +
              '''</AMOUNT>
                        </LEDGERENTRIES.LIST>''';
        }

        tdl = tdl +
            '''</VOUCHER>
                </TALLYMESSAGE>
            </REQUESTDATA>
        </IMPORTDATA>
    </BODY>
</ENVELOPE>
''';
        // print(tdl);
        // return;

        var data = await TallyRequest().request(tdl);
        jsonParse.parse(data);
        var jsonData = jsonDecode(jsonParse.toGData());
        if (jsonData['RESPONSE']['CREATED'] != null &&
            jsonData['RESPONSE']['CREATED']['\$t'] != '0') {
          cList.add(voucher);
        } else {
          print(jsonEncode(jsonData));
        }
      }

      return cList;
    } catch (e) {
      print(e);
    }
  }

  _sOrder() async {
    try {
      var sOrder = data['sOrder'];
      var cList = [];

      for (var i = 0; i < sOrder.length; i++) {
        var voucher = sOrder[i].keys.toList()[0];
        var date =
            Jiffy(sOrder[i][voucher]['ledgers'][0]['date']).format('yyyyMMdd');

        List ledgers = sOrder[i][voucher]['ledgers'];
        List items = sOrder[i][voucher]['items'];

        var tdl = '''
<ENVELOPE>
    <HEADER>
        <TALLYREQUEST>Import Data</TALLYREQUEST>
    </HEADER>
    <BODY>
        <IMPORTDATA>
            <REQUESTDESC>
                <REPORTNAME>All Masters</REPORTNAME>
                <STATICVARIABLES>
                    <SVCURRENTCOMPANY>''' +
            company +
            '''</SVCURRENTCOMPANY>
                </STATICVARIABLES>
            </REQUESTDESC>
            <REQUESTDATA>
                <TALLYMESSAGE xmlns:UDF="TallyUDF">
                    <VOUCHER VCHTYPE="Sales Order" ACTION="Create" OBJVIEW="Invoice Voucher View">
                        <OLDAUDITENTRYIDS.LIST TYPE="Number">
                            <OLDAUDITENTRYIDS>-1</OLDAUDITENTRYIDS>
                        </OLDAUDITENTRYIDS.LIST>
                        <DATE>''' +
            date +
            '''</DATE>
                        <REFERENCEDATE>''' +
            date +
            '''</REFERENCEDATE>
                        <VATDEALERTYPE>Regular</VATDEALERTYPE>
                        <PARTYNAME>''' +
            DataTally(ledgers[0]['name']) +
            '''</PARTYNAME>
                        <PARTYLEDGERNAME>''' +
            DataTally(ledgers[0]['name']) +
            '''</PARTYLEDGERNAME>
                        <VOUCHERTYPENAME>Sales Order</VOUCHERTYPENAME>
                        <REFERENCE>''' +
            voucher +
            '''</REFERENCE>
                        <VOUCHERNUMBER>''' +
            voucher +
            '''</VOUCHERNUMBER>
                        <BASICBASEPARTYNAME>''' +
            DataTally(ledgers[0]['name']) +
            '''</BASICBASEPARTYNAME>
                        <FBTPAYMENTTYPE>Default</FBTPAYMENTTYPE>
                        <PERSISTEDVIEW>Invoice Voucher View</PERSISTEDVIEW>
                        <BASICBUYERNAME>''' +
            company +
            '''</BASICBUYERNAME>
                        <PARTYMAILINGNAME>''' +
            DataTally(ledgers[0]['name']) +
            '''</PARTYMAILINGNAME>
                        <EFFECTIVEDATE>''' +
            date +
            '''</EFFECTIVEDATE>''';

        for (var j = 0; j < items.length; j++) {
          tdl = tdl +
              '''<ALLINVENTORYENTRIES.LIST>
                    <STOCKITEMNAME>''' +
              DataTally(items[j]['name']) +
              '''</STOCKITEMNAME>
                    <ISDEEMEDPOSITIVE>No</ISDEEMEDPOSITIVE>
                    <ISLASTDEEMEDPOSITIVE>No</ISLASTDEEMEDPOSITIVE>
                    <ISAUTONEGATE>No</ISAUTONEGATE>
                    <ISCUSTOMSCLEARANCE>No</ISCUSTOMSCLEARANCE>
                    <ISTRACKCOMPONENT>No</ISTRACKCOMPONENT>
                    <ISTRACKPRODUCTION>No</ISTRACKPRODUCTION>
                    <ISPRIMARYITEM>No</ISPRIMARYITEM>
                    <RATE>''' +
              DataTally(items[j]['rate']) +
              '''</RATE>
                    <AMOUNT>''' +
              DataTally(items[j]['amount']) +
              '''</AMOUNT>
                    <ACTUALQTY>''' +
              DataTally(items[j]['qty']) +
              '''</ACTUALQTY>
                    <BILLEDQTY>''' +
              DataTally(items[j]['qty']) +
              '''</BILLEDQTY>
                    <BATCHALLOCATIONS.LIST>
                        <GODOWNNAME>''' +
              DataTally(
                  items[j]['godown'] == 'NULL' || items[j]['godown'] == null
                      ? 'Main Location'
                      : items[j]['godown']) +
              '''</GODOWNNAME>
                        <BATCHNAME>Primary Batch</BATCHNAME>
                        <ORDERDUEDATE>''' +
              date +
              '''</ORDERDUEDATE>
                        <AMOUNT>''' +
              DataTally(items[j]['amount']) +
              '''</AMOUNT>
                    </BATCHALLOCATIONS.LIST>
                    <ACCOUNTINGALLOCATIONS.LIST>
                        <OLDAUDITENTRYIDS.LIST TYPE="Number">
                            <OLDAUDITENTRYIDS>-1</OLDAUDITENTRYIDS>
                        </OLDAUDITENTRYIDS.LIST>
                        <LEDGERNAME>''' +
              DataTally(items[j]['account']) +
              '''</LEDGERNAME>
                        <GSTCLASS/>
                        <ISDEEMEDPOSITIVE>No</ISDEEMEDPOSITIVE>
                        <LEDGERFROMITEM>No</LEDGERFROMITEM>
                        <REMOVEZEROENTRIES>No</REMOVEZEROENTRIES>
                        <ISPARTYLEDGER>No</ISPARTYLEDGER>
                        <ISLASTDEEMEDPOSITIVE>No</ISLASTDEEMEDPOSITIVE>
                        <ISCAPVATTAXALTERED>No</ISCAPVATTAXALTERED>
                        <ISCAPVATNOTCLAIMED>No</ISCAPVATNOTCLAIMED>
                        <AMOUNT>''' +
              DataTally(items[j]['amount']) +
              '''</AMOUNT>
                    </ACCOUNTINGALLOCATIONS.LIST>
                </ALLINVENTORYENTRIES.LIST>''';
        }

        for (var j = 0; j < ledgers.length; j++) {
          tdl = tdl +
              '''<LEDGERENTRIES.LIST>
                            <OLDAUDITENTRYIDS.LIST TYPE="Number">
                                <OLDAUDITENTRYIDS>-1</OLDAUDITENTRYIDS>
                            </OLDAUDITENTRYIDS.LIST>
                            <LEDGERNAME>''' +
              DataTally(ledgers[j]['name']) +
              '''</LEDGERNAME>
                            <ISDEEMEDPOSITIVE>''' +
              (j != 0 ? 'No' : 'Yes') +
              '''</ISDEEMEDPOSITIVE>
                            <ISPARTYLEDGER>Yes</ISPARTYLEDGER>
                            <AMOUNT>''' +
              (j != 0 ? '' : '-') +
              DataTally(ledgers[j]['amount']) +
              '''</AMOUNT>
                        </LEDGERENTRIES.LIST>''';
        }

        tdl = tdl +
            '''</VOUCHER>
                </TALLYMESSAGE>
            </REQUESTDATA>
        </IMPORTDATA>
    </BODY>
</ENVELOPE>
''';

        var data = await TallyRequest().request(tdl);
        jsonParse.parse(data);
        var jsonData = jsonDecode(jsonParse.toGData());
        if (jsonData['RESPONSE']['CREATED'] != null &&
            jsonData['RESPONSE']['CREATED']['\$t'] != '0') {
          cList.add(voucher);
        } else {
          print(jsonEncode(jsonData));
        }
      }

      return cList;
    } catch (e) {
      print(e);
    }
  }

  _debit() async {
    try {
      var debit = data['debit'];
      var cList = [];

      for (var i = 0; i < debit.length; i++) {
        var voucher = debit[i].keys.toList()[0];
        var date =
            Jiffy(debit[i][voucher]['ledgers'][0]['date']).format('yyyyMMdd');

        List ledgers = debit[i][voucher]['ledgers'];
        List items = debit[i][voucher]['items'];

        var tdl = '''
<ENVELOPE>
    <HEADER>
        <TALLYREQUEST>Import Data</TALLYREQUEST>
    </HEADER>
    <BODY>
        <IMPORTDATA>
            <REQUESTDESC>
                <REPORTNAME>All Masters</REPORTNAME>
                <STATICVARIABLES>
                    <SVCURRENTCOMPANY>''' +
            company +
            '''</SVCURRENTCOMPANY>
                </STATICVARIABLES>
            </REQUESTDESC>
            <REQUESTDATA>
                <TALLYMESSAGE xmlns:UDF="TallyUDF">
                    <VOUCHER VCHTYPE="Debit Note" ACTION="Create" OBJVIEW="Invoice Voucher View">
                        <OLDAUDITENTRYIDS.LIST TYPE="Number">
                            <OLDAUDITENTRYIDS>-1</OLDAUDITENTRYIDS>
                        </OLDAUDITENTRYIDS.LIST>
                        <DATE>''' +
            date +
            '''</DATE>
                        <REFERENCEDATE>''' +
            date +
            '''</REFERENCEDATE>
                        <VATDEALERTYPE>Regular</VATDEALERTYPE>
                        <PARTYNAME>''' +
            DataTally(ledgers[0]['name']) +
            '''</PARTYNAME>
                        <PARTYLEDGERNAME>''' +
            DataTally(ledgers[0]['name']) +
            '''</PARTYLEDGERNAME>
                        <VOUCHERTYPENAME>Debit Note</VOUCHERTYPENAME>
                        <REFERENCE>''' +
            voucher +
            '''</REFERENCE>
                        <VOUCHERNUMBER>''' +
            voucher +
            '''</VOUCHERNUMBER>
                        <BASICBASEPARTYNAME>''' +
            DataTally(ledgers[0]['name']) +
            '''</BASICBASEPARTYNAME>
                        <FBTPAYMENTTYPE>Default</FBTPAYMENTTYPE>
                        <PERSISTEDVIEW>Invoice Voucher View</PERSISTEDVIEW>
                        <BASICBUYERNAME>''' +
            company +
            '''</BASICBUYERNAME>
                        <PARTYMAILINGNAME>''' +
            DataTally(ledgers[0]['name']) +
            '''</PARTYMAILINGNAME>
                        <VCHENTRYMODE>Item Accounting</VCHENTRYMODE>
                        <EFFECTIVEDATE>''' +
            date +
            '''</EFFECTIVEDATE>''';

        for (var j = 0; j < items.length; j++) {
          tdl = tdl +
              '''<ALLINVENTORYENTRIES.LIST>
                    <STOCKITEMNAME>''' +
              DataTally(items[j]['name']) +
              '''</STOCKITEMNAME>
                    <ISDEEMEDPOSITIVE>No</ISDEEMEDPOSITIVE>
                    <ISLASTDEEMEDPOSITIVE>No</ISLASTDEEMEDPOSITIVE>
                    <ISAUTONEGATE>No</ISAUTONEGATE>
                    <ISCUSTOMSCLEARANCE>No</ISCUSTOMSCLEARANCE>
                    <ISTRACKCOMPONENT>No</ISTRACKCOMPONENT>
                    <ISTRACKPRODUCTION>No</ISTRACKPRODUCTION>
                    <ISPRIMARYITEM>No</ISPRIMARYITEM>
                    <ISSCRAP>No</ISSCRAP>
                    <RATE>''' +
              DataTally(items[j]['rate']) +
              '''</RATE>
                    <AMOUNT>''' +
              DataTally(items[j]['amount']) +
              '''</AMOUNT>
                    <ACTUALQTY>''' +
              DataTally(items[j]['qty']) +
              '''</ACTUALQTY>
                    <BILLEDQTY>''' +
              DataTally(items[j]['qty']) +
              '''</BILLEDQTY>
                    <BATCHALLOCATIONS.LIST>
                        <GODOWNNAME>''' +
              DataTally(
                  items[j]['godown'] == 'NULL' || items[j]['godown'] == null
                      ? 'Main Location'
                      : items[j]['godown']) +
              '''</GODOWNNAME>
                        <BATCHNAME>Primary Batch</BATCHNAME>
                        <AMOUNT>''' +
              DataTally(items[j]['amount']) +
              '''</AMOUNT>
                    </BATCHALLOCATIONS.LIST>
                    <ACCOUNTINGALLOCATIONS.LIST>
                        <OLDAUDITENTRYIDS.LIST TYPE="Number">
                            <OLDAUDITENTRYIDS>-1</OLDAUDITENTRYIDS>
                        </OLDAUDITENTRYIDS.LIST>
                        <LEDGERNAME>''' +
              DataTally(items[j]['account']) +
              '''</LEDGERNAME>
                        <GSTCLASS/>
                        <ISDEEMEDPOSITIVE>No</ISDEEMEDPOSITIVE>
                        <LEDGERFROMITEM>No</LEDGERFROMITEM>
                        <REMOVEZEROENTRIES>No</REMOVEZEROENTRIES>
                        <ISPARTYLEDGER>No</ISPARTYLEDGER>
                        <ISLASTDEEMEDPOSITIVE>No</ISLASTDEEMEDPOSITIVE>
                        <ISCAPVATTAXALTERED>No</ISCAPVATTAXALTERED>
                        <ISCAPVATNOTCLAIMED>No</ISCAPVATNOTCLAIMED>
                        <AMOUNT>''' +
              DataTally(items[j]['amount']) +
              '''</AMOUNT>
                    </ACCOUNTINGALLOCATIONS.LIST>
                </ALLINVENTORYENTRIES.LIST>''';
        }

        for (var j = 0; j < ledgers.length; j++) {
          tdl = tdl +
              '''<LEDGERENTRIES.LIST>
                            <OLDAUDITENTRYIDS.LIST TYPE="Number">
                                <OLDAUDITENTRYIDS>-1</OLDAUDITENTRYIDS>
                            </OLDAUDITENTRYIDS.LIST>
                            <LEDGERNAME>''' +
              DataTally(ledgers[j]['name']) +
              '''</LEDGERNAME>''';

          if (ledgers[j]['against'] != 'On-Account' &&
              ledgers[j]['against'] != null) {
            tdl += '''<BILLALLOCATIONS.LIST>
                    <NAME>''' +
                DataTally(ledgers[j]['order']) +
                '''</NAME>
                    <BILLTYPE>''' +
                DataTally(ledgers[j]['against']) +
                '''</BILLTYPE>
                    <AMOUNT>''' +
                (j != 0 ? '' : '-') +
                DataTally(ledgers[j]['amount']) +
                '''</AMOUNT>
                </BILLALLOCATIONS.LIST>''';
          }

          tdl += '''<ISDEEMEDPOSITIVE>''' +
              (j != 0 ? 'No' : 'Yes') +
              '''</ISDEEMEDPOSITIVE>
                            <ISPARTYLEDGER>Yes</ISPARTYLEDGER>
                            <AMOUNT>''' +
              (j != 0 ? '' : '-') +
              DataTally(ledgers[j]['amount']) +
              '''</AMOUNT>
                        </LEDGERENTRIES.LIST>''';
        }

        tdl = tdl +
            '''</VOUCHER>
                </TALLYMESSAGE>
            </REQUESTDATA>
        </IMPORTDATA>
    </BODY>
</ENVELOPE>
''';

        var data = await TallyRequest().request(tdl);
        jsonParse.parse(data);
        var jsonData = jsonDecode(jsonParse.toGData());
        if (jsonData['RESPONSE']['CREATED'] != null &&
            jsonData['RESPONSE']['CREATED']['\$t'] != '0') {
          cList.add(voucher);
        } else {
          print(jsonEncode(jsonData));
        }
      }

      return cList;
    } catch (e) {
      print(e);
    }
  }

  _credit() async {
    try {
      var credit = data['credit'];
      var cList = [];

      for (var i = 0; i < credit.length; i++) {
        var voucher = credit[i].keys.toList()[0];
        var date =
            Jiffy(credit[i][voucher]['ledgers'][0]['date']).format('yyyyMMdd');

        List ledgers = credit[i][voucher]['ledgers'];
        List items = credit[i][voucher]['items'];

        var tdl = '''
<ENVELOPE>
    <HEADER>
        <TALLYREQUEST>Import Data</TALLYREQUEST>
    </HEADER>
    <BODY>
        <IMPORTDATA>
            <REQUESTDESC>
                <REPORTNAME>All Masters</REPORTNAME>
                <STATICVARIABLES>
                    <SVCURRENTCOMPANY>''' +
            company +
            '''</SVCURRENTCOMPANY>
                </STATICVARIABLES>
            </REQUESTDESC>
            <REQUESTDATA>
                <TALLYMESSAGE xmlns:UDF="TallyUDF">
                    <VOUCHER VCHTYPE="Credit Note" ACTION="Create" OBJVIEW="Invoice Voucher View">
                        <OLDAUDITENTRYIDS.LIST TYPE="Number">
                            <OLDAUDITENTRYIDS>-1</OLDAUDITENTRYIDS>
                        </OLDAUDITENTRYIDS.LIST>
                        <DATE>''' +
            date +
            '''</DATE>
                        <REFERENCEDATE>''' +
            date +
            '''</REFERENCEDATE>
                        <VATDEALERTYPE>Regular</VATDEALERTYPE>
                        <PARTYNAME>''' +
            DataTally(ledgers[0]['name']) +
            '''</PARTYNAME>
                        <PARTYLEDGERNAME>''' +
            DataTally(ledgers[0]['name']) +
            '''</PARTYLEDGERNAME>
                        <VOUCHERTYPENAME>Credit Note</VOUCHERTYPENAME>
                        <VOUCHERNUMBER>''' +
            voucher +
            '''</VOUCHERNUMBER>
                        <REFERENCE>''' +
            voucher +
            '''</REFERENCE>
                        <BASICBASEPARTYNAME>''' +
            DataTally(ledgers[0]['name']) +
            '''</BASICBASEPARTYNAME>
                        <FBTPAYMENTTYPE>Default</FBTPAYMENTTYPE>
                        <PERSISTEDVIEW>Invoice Voucher View</PERSISTEDVIEW>
                        <BASICBUYERNAME>''' +
            company +
            '''</BASICBUYERNAME>
                        <PARTYMAILINGNAME>''' +
            DataTally(ledgers[0]['name']) +
            '''</PARTYMAILINGNAME>
                        <VCHENTRYMODE>Item Accounting</VCHENTRYMODE>
                        <EFFECTIVEDATE>''' +
            date +
            '''</EFFECTIVEDATE>''';

        for (var j = 0; j < items.length; j++) {
          tdl = tdl +
              '''<ALLINVENTORYENTRIES.LIST>
                    <STOCKITEMNAME>''' +
              DataTally(items[j]['name']) +
              '''</STOCKITEMNAME>
                    <ISDEEMEDPOSITIVE>Yes</ISDEEMEDPOSITIVE>
                    <ISLASTDEEMEDPOSITIVE>Yes</ISLASTDEEMEDPOSITIVE>
                    <ISAUTONEGATE>No</ISAUTONEGATE>
                    <ISCUSTOMSCLEARANCE>No</ISCUSTOMSCLEARANCE>
                    <ISTRACKCOMPONENT>No</ISTRACKCOMPONENT>
                    <ISTRACKPRODUCTION>No</ISTRACKPRODUCTION>
                    <ISPRIMARYITEM>No</ISPRIMARYITEM>
                    <ISSCRAP>No</ISSCRAP>
                    <RATE>''' +
              DataTally(items[j]['rate']) +
              '''</RATE>
                    <AMOUNT>-''' +
              DataTally(items[j]['amount']) +
              '''</AMOUNT>
                    <ACTUALQTY>''' +
              DataTally(items[j]['qty']) +
              '''</ACTUALQTY>
                    <BILLEDQTY>''' +
              DataTally(items[j]['qty']) +
              '''</BILLEDQTY>
                    <BATCHALLOCATIONS.LIST>
                        <GODOWNNAME>''' +
              DataTally(
                  items[j]['godown'] == 'NULL' || items[j]['godown'] == null
                      ? 'Main Location'
                      : items[j]['godown']) +
              '''</GODOWNNAME>
                        <BATCHNAME>Primary Batch</BATCHNAME>
                        <AMOUNT>-''' +
              DataTally(items[j]['amount']) +
              '''</AMOUNT>
                    </BATCHALLOCATIONS.LIST>
                    <ACCOUNTINGALLOCATIONS.LIST>
                        <OLDAUDITENTRYIDS.LIST TYPE="Number">
                            <OLDAUDITENTRYIDS>-1</OLDAUDITENTRYIDS>
                        </OLDAUDITENTRYIDS.LIST>
                        <LEDGERNAME>''' +
              DataTally(items[j]['account']) +
              '''</LEDGERNAME>
                        <GSTCLASS/>
                        <ISDEEMEDPOSITIVE>Yes</ISDEEMEDPOSITIVE>
                        <LEDGERFROMITEM>No</LEDGERFROMITEM>
                        <REMOVEZEROENTRIES>No</REMOVEZEROENTRIES>
                        <ISPARTYLEDGER>No</ISPARTYLEDGER>
                        <ISLASTDEEMEDPOSITIVE>Yes</ISLASTDEEMEDPOSITIVE>
                        <ISCAPVATTAXALTERED>No</ISCAPVATTAXALTERED>
                        <ISCAPVATNOTCLAIMED>No</ISCAPVATNOTCLAIMED>
                        <AMOUNT>-''' +
              DataTally(items[j]['amount']) +
              '''</AMOUNT>
                    </ACCOUNTINGALLOCATIONS.LIST>
                </ALLINVENTORYENTRIES.LIST>''';
        }

        for (var j = 0; j < ledgers.length; j++) {
          tdl = tdl +
              '''<LEDGERENTRIES.LIST>
                            <OLDAUDITENTRYIDS.LIST TYPE="Number">
                                <OLDAUDITENTRYIDS>-1</OLDAUDITENTRYIDS>
                            </OLDAUDITENTRYIDS.LIST>
                            <LEDGERNAME>''' +
              DataTally(ledgers[j]['name']) +
              '''</LEDGERNAME>''';

          if (ledgers[j]['against'] != 'On-Account' &&
              ledgers[j]['against'] != null) {
            tdl += '''<BILLALLOCATIONS.LIST>
                    <NAME>''' +
                DataTally(ledgers[j]['order']) +
                '''</NAME>
                    <BILLTYPE>''' +
                DataTally(ledgers[j]['against']) +
                '''</BILLTYPE>
                    <AMOUNT>''' +
                (j == 0 ? '' : '-') +
                DataTally(ledgers[j]['amount']) +
                '''</AMOUNT>
                </BILLALLOCATIONS.LIST>''';
          }

          tdl += '''<ISDEEMEDPOSITIVE>''' +
              (j == 0 ? 'No' : 'Yes') +
              '''</ISDEEMEDPOSITIVE>
                            <ISPARTYLEDGER>Yes</ISPARTYLEDGER>
                            <AMOUNT>''' +
              (j == 0 ? '' : '-') +
              DataTally(ledgers[j]['amount']) +
              '''</AMOUNT>
                        </LEDGERENTRIES.LIST>''';
        }

        tdl = tdl +
            '''</VOUCHER>
                </TALLYMESSAGE>
            </REQUESTDATA>
        </IMPORTDATA>
    </BODY>
</ENVELOPE>
''';

        var data = await TallyRequest().request(tdl);
        jsonParse.parse(data);
        var jsonData = jsonDecode(jsonParse.toGData());
        if (jsonData['RESPONSE']['CREATED'] != null &&
            jsonData['RESPONSE']['CREATED']['\$t'] != '0') {
          cList.add(voucher);
        } else {
          print(jsonEncode(jsonData));
        }
      }

      return cList;
    } catch (e) {
      print(e);
    }
  }

  _journal() async {
    try {
      var journal = data['journal'];
      var cList = [];

      for (var i = 0; i < journal.length; i++) {
        var voucher = journal[i].keys.toList()[0];
        var date =
            Jiffy(journal[i][voucher]['ledgers'][0]['date']).format('yyyyMMdd');

        List ledgers = journal[i][voucher]['ledgers'];

        var tdl = '''
<ENVELOPE>
    <HEADER>
        <TALLYREQUEST>Import Data</TALLYREQUEST>
    </HEADER>
    <BODY>
        <IMPORTDATA>
            <REQUESTDESC>
                <REPORTNAME>All Masters</REPORTNAME>
                <STATICVARIABLES>
                    <SVCURRENTCOMPANY>''' +
            company +
            '''</SVCURRENTCOMPANY>
                </STATICVARIABLES>
            </REQUESTDESC>
            <REQUESTDATA>
                <TALLYMESSAGE xmlns:UDF="TallyUDF">
                    <VOUCHER VCHTYPE="Journal" ACTION="Create" OBJVIEW="Accounting Voucher View">
                        <OLDAUDITENTRYIDS.LIST TYPE="Number">
                            <OLDAUDITENTRYIDS>-1</OLDAUDITENTRYIDS>
                        </OLDAUDITENTRYIDS.LIST>
                        <DATE>''' +
            date +
            '''</DATE>
                        <VOUCHERTYPENAME>Journal</VOUCHERTYPENAME>
                        <VOUCHERTYPEORIGNAME>Journal</VOUCHERTYPEORIGNAME>
                        <VOUCHERNUMBER>''' +
            voucher +
            '''</VOUCHERNUMBER>
                        <FBTPAYMENTTYPE>Default</FBTPAYMENTTYPE>
                        <PERSISTEDVIEW>Accounting Voucher View</PERSISTEDVIEW>
                        <EFFECTIVEDATE>''' +
            date +
            '''</EFFECTIVEDATE>''';

        for (var j = 0; j < ledgers.length; j++) {
          tdl = tdl +
              '''<ALLLEDGERENTRIES.LIST>
                            <OLDAUDITENTRYIDS.LIST TYPE="Number">
                                <OLDAUDITENTRYIDS>-1</OLDAUDITENTRYIDS>
                            </OLDAUDITENTRYIDS.LIST>
                            <LEDGERNAME>''' +
              DataTally(ledgers[j]['name']) +
              '''</LEDGERNAME>
                            <ISDEEMEDPOSITIVE>''' +
              (ledgers[j]['drcr'] == 'Dr' ? 'Yes' : 'No') +
              '''</ISDEEMEDPOSITIVE>
                            <ISPARTYLEDGER>Yes</ISPARTYLEDGER>
                            <AMOUNT>''' +
              ledgers[j]['amount'].toString() +
              '''</AMOUNT>
                            <VATEXPAMOUNT>''' +
              ledgers[j]['amount'].toString() +
              '''</VATEXPAMOUNT>
                        </ALLLEDGERENTRIES.LIST>''';
        }

        tdl = tdl +
            '''</VOUCHER>
                </TALLYMESSAGE>
            </REQUESTDATA>
        </IMPORTDATA>
    </BODY>
</ENVELOPE>
''';

        var data = await TallyRequest().request(tdl);
        jsonParse.parse(data);
        var jsonData = jsonDecode(jsonParse.toGData());
        if (jsonData['RESPONSE']['CREATED'] != null &&
            jsonData['RESPONSE']['CREATED']['\$t'] != '0') {
          cList.add(voucher);
        } else {
          print(jsonEncode(jsonData));
        }
      }

      return cList;
    } catch (e) {
      print(e);
    }
  }
}
