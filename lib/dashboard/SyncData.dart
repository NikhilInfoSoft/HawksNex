import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hawks/controller/AccountBooks.dart';
import 'package:hawks/controller/CompanyList.dart';
import 'package:hawks/controller/FinancialStatements.dart';
import 'package:hawks/controller/Master.dart';
import 'package:hawks/controller/Outstanding.dart';
import 'package:hawks/controller/ServerToTally.dart';
import 'package:hawks/controller/StockReports.dart';
import 'package:hawks/controller/VoucherRegister.dart';
import 'package:hawks/data/shared.dart';
import 'package:hawks/data/url.dart';
import 'package:hawks/data/variables.dart';
import 'package:hawks/tdl/tdl.dart';
import 'package:hawks/widgets/ConnectionState.dart';
import 'package:hawks/widgets/CustomToast.dart';
import 'package:hawks/widgets/WindowButtons.dart';
import 'package:jiffy/jiffy.dart';
import 'package:intl/intl.dart';

class SyncData extends StatelessWidget {
  List companies = [];
  SyncData({this.companies});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _mainBody(companies: companies),
    );
  }
}

class _mainBody extends StatefulWidget {
  List companies = [];
  _mainBody({this.companies});

  @override
  __mainBodyState createState() => __mainBodyState(companies: companies);
}

class __mainBodyState extends State<_mainBody> {
  int _currentFunction = 0;
  int _currentCompany = 0;
  double _progressValue = 0;
  var _companyName = '';
  List companies = [];
  Map sData = {};
  __mainBodyState({this.companies});

  _setProgress(double progress) {
    try {
      setState(() {
        _progressValue = progress;
      });
    } catch (e) {
      print(e);
    }
  }

  _setCurrent(int value) {
    try {
      setState(() {
        syncData[_currentFunction]['status'] = value;
        if (syncData[_currentFunction]['status'] == 4) {
          _currentFunction++;
        }
      });
    } catch (e) {
      print(e);
    }
  }

  // Sync Functions
  _companyData(var data) async {
    try {
      _setCurrent(1);
      _setCurrent(2);
      _setCurrent(3);
      await TallyCompany().uploadCompany(jsonEncode(data));
      _setCurrent(4);
      _setProgress(0.03);
    } catch (e) {
      print(e);
    }
  }

  _master(String item) async {
    try {
      _setCurrent(1);
      var master = await Master().getMaster(item);
      _setCurrent(2);
      master = Master().parseDataUpload(master);
      _setCurrent(3);

      // Godown Upload
      await Master().uploadMaster(
        item,
        jsonEncode({'godowns': jsonDecode(master)['godowns']}),
      );

      // Categories Upload
      await Master().uploadMaster(
        item,
        jsonEncode({'categories': jsonDecode(master)['categories']}),
      );

      // Voucher Type Upload
      await Master().uploadMaster(
        item,
        jsonEncode({'vouchers': jsonDecode(master)['vouchers']}),
      );

      // Unit Upload
      await Master().uploadMaster(
        item,
        jsonEncode({'units': jsonDecode(master)['units']}),
      );

      // Items Upload
      await Master().uploadMaster(
        item,
        jsonEncode({'itemsku': jsonDecode(master)['itemsku']}),
      );

      // Ledgers Upload
      await Master().uploadMaster(
        item,
        jsonEncode({'ledgers': jsonDecode(master)['ledgers']}),
      );

      // Tax Ledgers
      await Master().uploadMaster(
        item,
        jsonEncode({'tax': jsonDecode(master)['tax']}),
      );

      // Groups Upload
      await Master().uploadMaster(
        item,
        jsonEncode({'groups': jsonDecode(master)['groups']}),
      );

      _setCurrent(4);
      _setProgress(0.10);
    } catch (e) {
      print(e);
    }
  }

  _outStandingData(String item) async {
    try {
      _setCurrent(1);
      var cdata = await TallyRequest().tallyToServer(
        ocountUrl,
        _companyName,
        '',
      );
      var odata = cdata['data'];
      var groupList = odata['group'].keys.toList();

      var receivables = await Outstanding().getReceivables(item);
      var payables = await Outstanding().getPayables(item);
      var groupsList = [];

      for (var group in groupList) {
        var data = await Outstanding().getGroup(item, group);
        data = await Outstanding().parseDataUpload(data, 'group', group: group);
        groupsList.addAll(jsonDecode(data));
      }

      // _setCurrent(2);
      receivables = Outstanding().parseDataUpload(receivables, 'receivables');
      payables = Outstanding().parseDataUpload(payables, 'payables');

      var data = {
        'rcount': odata['count']['rcount'],
        'pcount': odata['count']['pcount'],
        'lcount': odata['count']['lcount'],
        'gcount': odata['count']['gcount'],
        'receivables': jsonDecode(receivables),
        'payables': jsonDecode(payables),
        'group': groupsList,
      };

      _setCurrent(3);
      await Outstanding().uploadOutstandings(item, jsonEncode(data));

      _setCurrent(4);
      _setProgress(0.23);
    } catch (e) {
      print(e);
    }
  }

  _financialStatements(String item) async {
    try {
      int count = 0;
      if (syncTo.month > 3) {
        count = syncTo.year - syncFrom.year + 1;
      } else {
        count = syncTo.year - syncFrom.year;
      }

      for (var i = 0; i < count; i++) {
        _setCurrent(1);
        var trialBalance = await FinancialStatements()
            .getTrialBalance(item, syncFrom.year + i);
        var profitLoss =
            await FinancialStatements().getProfitLoss(item, syncFrom.year + i);
        var balanceSheet = await FinancialStatements()
            .getBalanceSheet(item, syncFrom.year + i);
        var cashFlow =
            await FinancialStatements().getCashFlow(item, syncFrom.year + i);
        var fundFlow =
            await FinancialStatements().getFundFlow(item, syncFrom.year + i);

        var data = {
          'year': (syncFrom.year + i).toString(),
          'trialBalance': trialBalance,
          'profitLoss': profitLoss,
          'balanceSheet': balanceSheet,
          'cashFlow': cashFlow,
          'fundFlow': fundFlow,
        };
        _setCurrent(2);
        _setCurrent(3);
        await FinancialStatements().uploadFiancialStatements(
          item,
          jsonEncode(data),
        );
      }

      _setCurrent(4);
      _setProgress(0.30);
    } catch (e) {
      print(e);
    }
  }

  _accountBooks(String item) async {
    try {
      _setCurrent(1);
      var purchaseRegister = await AccountBooks().getAccounts(
        item,
        'Purchase Register',
      );
      var salesRegister = await AccountBooks().getAccounts(
        item,
        'Sales Register',
      );
      _setCurrent(2);

      purchaseRegister = await AccountBooks().parseDataUpload(purchaseRegister);
      salesRegister = await AccountBooks().parseDataUpload(salesRegister);

      var data = {
        'purchaseRegister': purchaseRegister,
        'salesRegister': salesRegister,
      };
      _setCurrent(3);
      await AccountBooks().uploadAccountBooks(
        item,
        jsonEncode(data),
      );
      _setCurrent(4);
      _setProgress(0.40);
    } catch (e) {
      print(e);
    }
  }

  _stockReports(String item) async {
    try {
      // Stock Summary
      _setCurrent(1);
      var stockSummary = await StockReport().getStockReports(
        item,
        'Stock Summary',
      );
      _setCurrent(2);

      _setCurrent(1);
      var godownSummary = await StockReport().getStockReports(
        item,
        'Godown Summary',
      );
      _setCurrent(2);

      _setCurrent(1);
      var movementAnalysis = await StockReport().getStockReports(
        item,
        'Movement Analysis',
      );
      _setCurrent(2);

      _setCurrent(1);
      var reorderStatus = await StockReport().getStockReports(
        item,
        'Reorder Status',
      );
      _setCurrent(2);

      // Upload Stock Reports
      var data = {
        'stockSummary': stockSummary,
        'godownSummary': godownSummary,
        'movementAnalysis': movementAnalysis,
        'reorderStatus': reorderStatus,
      };
      await StockReport().uploadStockReports(
        stockReportUrl,
        item,
        jsonEncode(data),
      );
      _setCurrent(3);
      _setCurrent(4);
      _setProgress(0.5);
    } catch (e) {
      print(e);
    }
  }

  _voucherRegister(var item) async {
    try {
      _setCurrent(1);
      var stats = (await VoucherRegister().getVoucherStats(
        item['name'],
      ))['ENVELOPE'];
      var statData = {};
      var currentData = {};
      var allowedVoucher = [
        'Purchase',
        'Purchase Order',
        'Sales',
        'Sales Order',
        'Payment',
        'Receipt',
        'Debit Note',
        'Credit Note',
        'Journal',
        'Contra',
      ];

      for (var i = 0; i < stats['STATNAME'].length; i++) {
        var tempC = stats['STATVALUE'][i]['STATCANCELLED']['\$t'] != null
            ? stats['STATVALUE'][i]['STATCANCELLED']['\$t']
                .toString()
                .replaceAll(RegExp('[a-z)( ]'), '')
            : '0';
        statData[stats['STATNAME'][i]['\$t']] =
            int.parse(stats['STATVALUE'][i]['STATDIRECT']['\$t']) -
                int.parse(tempC);
      }

      var vouchers = sData['voucher'];
      var voucherMap = {};
      var vt = [];
      var sKeyList = statData.keys.toList();
      for (var v in vouchers) {
        var voucher = v['vouchername'];
        if (voucher == 'SALES') voucher = 'Sales';
        var data = {
          'id': v['id'],
          'vouchername': voucher,
          'parentvoucher': voucher == 'Sales'
              ? 'Sales'
              : (v['parentvoucher'] == 'SALES' ? 'Sales' : v['parentvoucher']),
          'tname': v['vouchername'],
        };
        voucherMap[voucher] = data;
        vt.add(data);

        if (!sKeyList.contains(voucher))
          voucher =
              v['parentvoucher'] == 'SALES' ? 'Sales' : v['parentvoucher'];
        currentData[voucher] = 0;
      }
      sData['voucher'] = voucherMap;
      vouchers = vt;

      double _progressValue = 0.5;

      // Data Retreiving
      for (var v in vouchers) {
        if (allowedVoucher.contains(v['parentvoucher'])) {
          var voucher = v['vouchername'];
          if (statData[voucher] == null) voucher = v['parentvoucher'];

          if (statData[voucher] > 0) {
            DateTime ct = syncFrom;
            int lCount = (syncTo.difference(ct).inDays / 30).round();

            for (var i = 0; i < lCount; i++) {
              var t1 = Jiffy(ct).format('dd-MMM-yyyy');
              var t2 = Jiffy(Jiffy(ct).add(months: 1).subtract(days: 1))
                  .format('dd-MMM-yyyy');

              if (statData[voucher] > currentData[voucher]) {
                _setCurrent(1);
                var register = await VoucherRegister().getVoucherRegister(
                  item['name'],
                  t1,
                  t2,
                  voucher,
                );
                _setCurrent(2);
                register = VoucherRegister().parseUploadData(
                  register,
                  voucher,
                  voucherMap[voucher]['parentvoucher'],
                  sData,
                );

                if (register.runtimeType == bool && !register) {
                  continue;
                }

                var temp = jsonDecode(register);
                temp['from'] = Jiffy(ct).format('yyyy-MM-dd');
                temp['to'] = Jiffy(Jiffy(ct).add(months: 1).subtract(days: 1))
                    .format('yyyy-MM-dd');
                temp['voucher'] = v['tname'];
                register = jsonEncode(temp);

                _setCurrent(3);
                Uri url = Uri();
                var vname = voucherMap[voucher]['parentvoucher'];
                if (vname == 'Payment') {
                  url = voucherRegisterPaymentUrl;
                } else if (vname == 'Receipt' || vname == 'Contra') {
                  url = voucherRegisterReceiptUrl;
                } else if (vname == 'Purchase') {
                  url = voucherRegisterPurchaseUrl;
                } else if (vname == 'Sales' || vname == 'SALES') {
                  url = voucherRegisterSalesUrl;
                } else if (vname == 'Purchase Order') {
                  url = voucherRegisterPurchaseOrderUrl;
                } else if (vname == 'Sales Order') {
                  url = voucherRegisterSalesOrderUrl;
                } else if (vname == 'Debit Note') {
                  url = voucherRegisterDebitUrl;
                } else if (vname == 'Credit Note') {
                  url = voucherRegisterCreditUrl;
                } else if (vname == 'Journal') {
                  url = voucherRegisterJournalUrl;
                }

                await VoucherRegister().uploadVoucherRegister(
                  url,
                  item['name'],
                  register,
                );
                currentData[voucher] += jsonDecode(register)['bills'];
              } else {
                break;
              }

              ct = Jiffy(ct).add(months: 1).dateTime;
            }
          }
        }

        _progressValue = _progressValue + 0.01;
        _setProgress(_progressValue);
      }

      _setCurrent(4);
      _setProgress(1);
    } catch (e) {
      print(e);
    }
  }

  _data() async {
    try {
      if (tallySyncing) {
        CustomToast(context, 'Please wait sync to complete');
        return;
      }

      setState(() {
        tallySyncing = true;
      });
      await ShareDData().setSyncing(true);

      for (var item in syncData) {
        item['status'] = 0;
      }
      _currentFunction = 0;
      _progressValue = 0;

      for (var item in companies) {
        setState(() {
          _currentFunction = 0;
          _progressValue = 0;
        });

        _companyName = item['name'];

        // Company Data
        await _companyData(item);

        // Master Data
        await _master(_companyName);

        // Master Info Get
        var cdata = await TallyRequest().tallyToServer(
          vDetailsUrl,
          _companyName,
          '',
        );
        sData = cdata['data'];

        // Outstandings
        await _outStandingData(_companyName);

        // Financial Statements
        await _financialStatements(_companyName);

        // Account Books
        await _accountBooks(_companyName);

        // Stock Reports
        await _stockReports(_companyName);

        // Voucher Register
        await _voucherRegister(item);
      }
      setState(() {
        tallySyncing = false;
      });
      await ShareDData().setSyncing(false);
    } catch (e) {
      print(e);
      setState(() {
        tallySyncing = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _data();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          color: Color(0xffE7E5FF),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: FaIcon(
                  Icons.keyboard_arrow_left,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  // _data();
                },
              ),
              Image.asset(
                'assets/images/logo-light.png',
                width: 100,
              ),
            ],
          ),
        ),
        LinearProgressIndicator(
          minHeight: 2,
          backgroundColor: Colors.white,
          valueColor: AlwaysStoppedAnimation(Colors.green.withOpacity(.65)),
          value: _progressValue,
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              (_progressValue * 100).toStringAsFixed(0) + ' %',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xff3B7FDC),
              ),
            ),
            SizedBox(width: 10),
          ],
        ),
        SizedBox(height: 20),
        Text(
          _companyName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 40),
            child: ListView(
              children: List.generate(syncData.length, (index) {
                return _tile(
                  id: index,
                  title: syncData[index]['name'],
                  status: syncData[index]['status'],
                  color: index % 2 == 0 ? Colors.white : Color(0xffF7F7F7),
                );
              }),
            ),
          ),
        ),
        ConnectionStateWidget(context, () {}),
      ],
    );
  }

  _tile({
    int id,
    String title,
    int status,
    Color color,
  }) {
    return ListTile(
      tileColor: color,
      title: Text(
        title,
        style: TextStyle(fontSize: 14),
      ),
      subtitle: Text(
        syncStatusList[status] + ' ' + title,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ),
      trailing: status == 0
          ? Text(
              'Waiting....',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            )
          : status == 4
              ? FaIcon(
                  FontAwesomeIcons.checkCircle,
                  color: Colors.green,
                  size: 16,
                )
              : Container(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
    );
  }
}
