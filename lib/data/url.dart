// const String tallyUrl = 'http://localhost:9000/';
Uri tallyUrl = Uri(
  scheme: 'http',
  host: 'localhost',
  port: 9000,
);

// const String mainUrl = 'http://localhost/';
// const String apiUrl = mainUrl + 'hawks-desktop-api/';
// const String mainUrl = 'https://hawks.nexinfosoft.com/';
// const String mainUrl = 'https://demo.hawksindia.in/';
const String mainUrl = 'https://hawksindia.in/';
const String apiUrl = mainUrl + 'desktop/';

// Updates
Uri versionUrl = Uri.parse(apiUrl + 'version.txt');

// User
Uri loginUrl = Uri.parse(apiUrl + 'user/login/');
Uri registerUrl = Uri.parse(apiUrl + 'user/register/');

// Tally to Server
Uri checkSynableUrl = Uri.parse(apiUrl + 'sync/');
Uri companyUrl = Uri.parse(apiUrl + 'sync/company/');
Uri masterUrl = Uri.parse(apiUrl + 'sync/master/');

// Financial Statements
Uri financialStatementsUrl =
    Uri.parse(apiUrl + 'sync/reports/financial_statements/');

// Financial Statements
Uri accountBooksUrl = Uri.parse(apiUrl + 'sync/reports/account_books/');

// Stock Reports
Uri reportDataUrl =
    Uri.parse(apiUrl + 'sync/reports/stock_reports/reports.php');
Uri stockReportUrl = Uri.parse(apiUrl + 'sync/reports/stock_reports/');

// Outstandings
Uri outstandingsUrl = Uri.parse(apiUrl + 'sync/outstandings/');
Uri ocountUrl = Uri.parse(apiUrl + 'sync/outstandings/count.php');

// Voucher
Uri vDetailsUrl = Uri.parse(apiUrl + 'sync/voucher/voucher.php');
Uri voucherRegisterPaymentUrl = Uri.parse(apiUrl + 'sync/voucher/payment/');
Uri voucherRegisterReceiptUrl = Uri.parse(apiUrl + 'sync/voucher/receipt/');
Uri voucherRegisterCreditUrl = Uri.parse(apiUrl + 'sync/voucher/credit_note/');
Uri voucherRegisterDebitUrl = Uri.parse(apiUrl + 'sync/voucher/debit_note/');
Uri voucherRegisterPurchaseUrl = Uri.parse(apiUrl + 'sync/voucher/purchase/');
Uri voucherRegisterPurchaseOrderUrl =
    Uri.parse(apiUrl + 'sync/voucher/purchase_order/');
Uri voucherRegisterSalesUrl = Uri.parse(apiUrl + 'sync/voucher/sales/');
Uri voucherRegisterSalesOrderUrl =
    Uri.parse(apiUrl + 'sync/voucher/sale_order/');
Uri voucherRegisterJournalUrl = Uri.parse(apiUrl + 'sync/voucher/journal/');

// Server To Tally
Uri detailsUrl = Uri.parse(apiUrl + 'tally/');
Uri updateUrl = Uri.parse(apiUrl + 'tally/update.php');
Uri compListUrl = Uri.parse(apiUrl + 'tally/company_list.php');
