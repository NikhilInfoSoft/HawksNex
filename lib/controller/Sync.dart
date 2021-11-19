import 'dart:convert';

import 'package:hawks/data/shared.dart';

import '../controller/AccountBooks.dart';
import '../controller/CompanyList.dart';
import '../controller/FinancialStatements.dart';
import '../controller/Master.dart';
import '../controller/Outstanding.dart';
import '../controller/StockReports.dart';
import '../controller/VoucherRegister.dart';
import '../data/url.dart';
import '../data/variables.dart';
import '../tdl/tdl.dart';
import 'package:jiffy/jiffy.dart';

class SyncTally {
  List companyListLocal = [];
  List companyListOnline = [];
  Map sData = {};
  String _companyName = '';

  SyncTally(List data) {
    companyListLocal = data;
  }

  init() async {
    try {
      if (await ShareDData().isSyncing()) {
        return;
      }

      var d = await TallyRequest().tallyToServer(
        compListUrl,
        '',
        '',
      );
      companyListOnline = d['data'];

      for (var item in companyListOnline) {
        for (var i in companyListLocal) {
          if (i['name'] == item['Name']) {
            await _data(i);
            companyListLocal.remove(i);
            break;
          }
        }
      }

      print('done');
    } catch (e) {
      print(e);
    }
  }

  // Sync Functions
  _companyData(var data) async {
    try {
      await TallyCompany().uploadCompany(jsonEncode(data));
    } catch (e) {
      print(e);
    }
  }

  _master(String item) async {
    try {
      var master = await Master().getMaster(item);

      master = Master().parseDataUpload(master);

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
    } catch (e) {
      print(e);
    }
  }

  _outStandingData(String item) async {
    try {
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

      //
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

      await Outstanding().uploadOutstandings(item, jsonEncode(data));
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

        await FinancialStatements().uploadFiancialStatements(
          item,
          jsonEncode(data),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  _accountBooks(String item) async {
    try {
      var purchaseRegister = await AccountBooks().getAccounts(
        item,
        'Purchase Register',
      );
      var salesRegister = await AccountBooks().getAccounts(
        item,
        'Sales Register',
      );

      purchaseRegister = await AccountBooks().parseDataUpload(purchaseRegister);
      salesRegister = await AccountBooks().parseDataUpload(salesRegister);

      var data = {
        'purchaseRegister': purchaseRegister,
        'salesRegister': salesRegister,
      };

      await AccountBooks().uploadAccountBooks(
        item,
        jsonEncode(data),
      );
    } catch (e) {
      print(e);
    }
  }

  _stockReports(String item) async {
    try {
      // Stock Summary

      var stockSummary = await StockReport().getStockReports(
        item,
        'Stock Summary',
      );

      var godownSummary = await StockReport().getStockReports(
        item,
        'Godown Summary',
      );

      var movementAnalysis = await StockReport().getStockReports(
        item,
        'Movement Analysis',
      );

      var reorderStatus = await StockReport().getStockReports(
        item,
        'Reorder Status',
      );

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
    } catch (e) {
      print(e);
    }
  }

  _voucherRegister(Map item) async {
    try {
      var stats = (await VoucherRegister().getVoucherStats(
        item['name'],
        daemon: true,
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

      // Data Retreiving
      for (var v in vouchers) {
        if (allowedVoucher.contains(v['parentvoucher'])) {
          var voucher = v['vouchername'];
          if (statData[voucher] == null) voucher = v['parentvoucher'];

          if (statData[voucher] > 0) {
            DateTime ct = Jiffy(DateTime.now()).subtract(months: 3).dateTime;
            int lCount = (Jiffy(DateTime.now())
                        .add(months: 1)
                        .dateTime
                        .difference(ct)
                        .inDays /
                    30)
                .round();

            for (var i = 0; i < lCount; i++) {
              var t1 = Jiffy(ct).format('dd-MMM-yyyy');
              var t2 = Jiffy(Jiffy(ct).add(months: 1).subtract(days: 1))
                  .format('dd-MMM-yyyy');

              if (statData[voucher] > currentData[voucher]) {
                var register = await VoucherRegister().getVoucherRegister(
                  item['name'],
                  t1,
                  t2,
                  voucher,
                );
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
      }
    } catch (e) {
      print(e);
    }
  }

  _data(Map item) async {
    try {
      if (await ShareDData().isSyncing()) {
        return;
      }

      for (var item in syncData) {
        item['status'] = 0;
      }

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
    } catch (e) {
      print(e);
    }
  }
}
