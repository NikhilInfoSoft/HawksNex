bool tallyConnected = false;
bool internetConnected = false;
bool tallySyncing = false;
bool autoSyncStarted = false;
bool autoLocalStarted = false;
int defaultRequestSize = 990;
String version = '1.0.0';
int tallyConnectionPort = 9000;

// Sync Settings
DateTime syncFrom = DateTime(2020, 4);
DateTime syncTo = DateTime(2023, 3);

// 0 --> Waiting
// 1 --> Fetching
// 2 --> Uploading
List syncStatusList = [
  'Waiting',
  'Fetching',
  'Parsing',
  'Uploading',
  'Completed',
];
List syncData = [
  {
    'name': 'Company',
    'status': 0,
    'func': (value) {
      print(value);
    },
  },
  {
    'name': 'Master',
    'status': 0,
    'func': (value) {
      print(value);
    },
  },
  {
    'name': 'Outstandings',
    'status': 0,
    'func': (value) {
      print(value);
    },
  },
  {
    'name': 'Financial Statements',
    'status': 0,
    'func': (value) {
      print(value);
    },
  },
  {
    'name': 'Account Books',
    'status': 0,
    'func': (value) {
      print(value);
    },
  },
  {
    'name': 'Reports',
    'status': 0,
    'func': (value) {
      print(value);
    },
  },
  {
    'name': 'Voucher',
    'status': 0,
    'func': (value) {
      print(value);
    },
  },
];
