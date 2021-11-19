import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hawks/controller/CompanyList.dart';
import 'package:hawks/controller/ServerToTally.dart';
import 'package:hawks/controller/Sync.dart';
import 'package:hawks/data/shared.dart';
import 'package:hawks/data/url.dart';
import 'package:hawks/data/variables.dart';
import 'package:hawks/tdl/tdl.dart';
import 'package:hawks/widgets/ConnectionState.dart';
import 'package:hawks/widgets/CustomToast.dart';
import 'package:hawks/widgets/WindowButtons.dart';
import 'package:http/http.dart' as http;

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _mainBody(),
    );
  }
}

class _mainBody extends StatefulWidget {
  @override
  __mainBodyState createState() => __mainBodyState();
}

class __mainBodyState extends State<_mainBody> {
  bool _updates = true;
  bool _needUpdate = false;
  bool _companyLoading = false;
  bool _allSelected = false;
  bool _syncClicked = false;

  String username = '';
  String email = '';

  Timer _internetListener;
  Timer _tallyListener;

  List _companyList = [];

  _data() async {
    try {
      var data = await TallyCompany().getCompanyList();
      _companyList.clear();

      if (data['LISTOFCOMPANIES']['NAME'] is Map) {
        _companyList.add({
          'name': data['LISTOFCOMPANIES']['NAME']['\$t'],
          'value': false,
          'data': {
            'name': data['LISTOFCOMPANIES']['NAME']['\$t'],
            'syncFromDate': data['LISTOFCOMPANIES']['THISYEARBEG']['\$t'],
            'syncToDate': data['LISTOFCOMPANIES']['THISYEAREND']['\$t'],
            'email': data['LISTOFCOMPANIES']['EMAIL']['\$t'] ?? '',
            'country': data['LISTOFCOMPANIES']['COUNTRYNAME']['\$t'] ?? '',
            'state': data['LISTOFCOMPANIES']['STATENAME']['\$t'] ?? '',
            'pincode': data['LISTOFCOMPANIES']['PINCODE']['\$t'] ?? '',
            'phone': data['LISTOFCOMPANIES']['PHONENUMBER']['\$t'] ?? '',
            'income': data['LISTOFCOMPANIES']['INCOMETAXNUMBER']['\$t'] ?? '',
            'vat': data['LISTOFCOMPANIES']['VATTINNUMBER']['\$t'] ?? '',
            'gst':
                data['LISTOFCOMPANIES']['GSTREGISTRATIONNUMBER']['\$t'] ?? '',
            'pan': data['LISTOFCOMPANIES']['PANNUMBER']['\$t'] ?? '',
            'cin': data['LISTOFCOMPANIES']['CINNUMBER']['\$t'] ?? '',
            'company': data['LISTOFCOMPANIES']['COMPANYNUMBER']['\$t'] ?? '',
            'address': (data['LISTOFCOMPANIES']['_ADDRESS1']['\$t'] ?? '') +
                (data['LISTOFCOMPANIES']['_ADDRESS2']['\$t'] ?? '') +
                (data['LISTOFCOMPANIES']['_ADDRESS3']['\$t'] ?? ''),
            'vatapplicable':
                data['LISTOFCOMPANIES']['VATAPPLICABLE']['\$t'] ?? '',
            'gstapplicable': data['LISTOFCOMPANIES']['ISGSTON']['\$t'] ?? '',
            'startfrom': data['LISTOFCOMPANIES']['STARTINGFROM']['\$t'] ?? '',
          },
        });
      } else if (data['LISTOFCOMPANIES']['NAME'] is List) {
        for (var i = 0; i < data['LISTOFCOMPANIES']['NAME'].length; i++) {
          _companyList.add({
            'name': data['LISTOFCOMPANIES']['NAME'][i]['\$t'],
            'value': false,
            'data': {
              'name': data['LISTOFCOMPANIES']['NAME'][i]['\$t'],
              'syncFromDate': data['LISTOFCOMPANIES']['THISYEARBEG'][i]['\$t'],
              'syncToDate': data['LISTOFCOMPANIES']['THISYEAREND'][i]['\$t'],
              'email': data['LISTOFCOMPANIES']['EMAIL'][i]['\$t'] ?? '',
              'country': data['LISTOFCOMPANIES']['COUNTRYNAME'][i]['\$t'] ?? '',
              'state': data['LISTOFCOMPANIES']['STATENAME'][i]['\$t'] ?? '',
              'pincode': data['LISTOFCOMPANIES']['PINCODE'][i]['\$t'] ?? '',
              'phone': data['LISTOFCOMPANIES']['PHONENUMBER'][i]['\$t'] ?? '',
              'income':
                  data['LISTOFCOMPANIES']['INCOMETAXNUMBER'][i]['\$t'] ?? '',
              'vat': data['LISTOFCOMPANIES']['VATTINNUMBER'][i]['\$t'] ?? '',
              'gst': data['LISTOFCOMPANIES']['GSTREGISTRATIONNUMBER'][i]
                      ['\$t'] ??
                  '',
              'pan': data['LISTOFCOMPANIES']['PANNUMBER'][i]['\$t'] ?? '',
              'cin': data['LISTOFCOMPANIES']['CINNUMBER'][i]['\$t'] ?? '',
              'company':
                  data['LISTOFCOMPANIES']['COMPANYNUMBER'][i]['\$t'] ?? '',
              'address':
                  (data['LISTOFCOMPANIES']['_ADDRESS1'][i]['\$t'] ?? '') +
                      (data['LISTOFCOMPANIES']['_ADDRESS2'][i]['\$t'] ?? '') +
                      (data['LISTOFCOMPANIES']['_ADDRESS3'][i]['\$t'] ?? ''),
              'vatapplicable':
                  data['LISTOFCOMPANIES']['VATAPPLICABLE'][i]['\$t'] ?? '',
              'gstapplicable':
                  data['LISTOFCOMPANIES']['ISGSTON'][i]['\$t'] ?? '',
              'startfrom':
                  data['LISTOFCOMPANIES']['STARTINGFROM'][i]['\$t'] ?? '',
            },
          });
        }
      }

      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  _internetConnection() async {
    try {
      var data = await InternetAddress.lookup('google.com');
      if (!mounted) return;

      if (data.isNotEmpty && data[0].rawAddress.isNotEmpty) {
        setState(() {
          internetConnected = true;
        });
      }
    } on SocketException catch (e) {
      setState(() {
        internetConnected = false;
      });
    }
  }

  _tallyConnection() async {
    try {
      var data = await Socket.connect(tallyUrl.host, tallyUrl.port);
      if (_companyList.length == 0) _data();
      if (!mounted) return;

      setState(() {
        tallyConnected = true;
      });
    } on SocketException catch (e) {
      setState(() {
        _companyList.clear();
        tallyConnected = false;
      });
    }
  }

  _userData() async {
    try {
      var data = await ShareDData().getUserData();

      username = data['UserName'];
      email = data['UserId'];
    } catch (e) {
      print(e);
    }
  }

  _checkUpdates() async {
    try {
      setState(() {
        _updates = true;
      });
      var response = await http.get(versionUrl);
      if (response.statusCode == 200) {
        if (version != response.body.trim()) {
          _needUpdate = true;
        }
      }
      setState(() {
        _updates = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _checkUpdates();
    _userData();
    _internetConnection();
    _tallyConnection();
    _internetListener = Timer.periodic(
      Duration(seconds: 10),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        _internetConnection();
      },
    );
    _tallyListener = Timer.periodic(
      Duration(seconds: 10),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        _tallyConnection();
      },
    );
    _data();
  }

  @override
  void dispose() {
    _internetListener?.cancel();
    _tallyListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          child: Column(
            children: [
              WindowButtons(),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 320,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/images/dashboard.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20),
                    ),
                    Expanded(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xffE7E5FF),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Available Companies',
                                        style: TextStyle(),
                                      ),
                                      SizedBox(width: 20),
                                      GestureDetector(
                                        onTap: _data,
                                        child: FaIcon(
                                          FontAwesomeIcons.syncAlt,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  _syncClicked
                                      ? Container(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                              Color(0xff655AFF),
                                            ),
                                            padding: MaterialStateProperty.all(
                                              EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 10,
                                              ),
                                            ),
                                          ),
                                          onPressed: () async {
                                            // ServerToTally tally =
                                            //     ServerToTally('900 Entries Only');
                                            // await tally.init();
                                            // return;
                                            // _serverToTally();
                                            // return;
                                            if (tallySyncing) {
                                              CustomToast(
                                                context,
                                                'Please wait sync to complete',
                                              );
                                              return;
                                            }

                                            List _list = [];
                                            List _syncList = [];
                                            for (var item in _companyList) {
                                              if (item['value'] == true) {
                                                _list.add(item['data']);
                                                _syncList.add(item['name']);
                                              }
                                            }

                                            if (_list.length == 0) {
                                              CustomToast(
                                                context,
                                                'Please select atleast one company to sync',
                                              );
                                              return;
                                            }

                                            if (_list.length > 3) {
                                              CustomToast(
                                                context,
                                                'Only 3 Companies are allowed to sync',
                                              );
                                              return;
                                            }

                                            setState(() {
                                              _syncClicked = true;
                                            });

                                            var data = await TallyRequest()
                                                .tallyToServer(
                                              checkSynableUrl,
                                              '',
                                              jsonEncode(_syncList),
                                            );

                                            if (data['syncable'] > 0) {
                                              Navigator.pushNamed(
                                                context,
                                                '/syncdata',
                                                arguments: _list,
                                              );
                                            } else {
                                              CustomToast(
                                                context,
                                                'Only 3 Companies are allowed to sync',
                                              );
                                            }

                                            setState(() {
                                              _syncClicked = false;
                                            });
                                          },
                                          child: Text('Sync Data'),
                                        ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    for (var i = 0;
                                        i < _companyList.length;
                                        i++) {
                                      if (_allSelected) {
                                        _companyList[i]['value'] = false;
                                      } else {
                                        _companyList[i]['value'] = true;
                                      }
                                    }

                                    setState(() {
                                      _allSelected = !_allSelected;
                                    });
                                  },
                                  child: Text(
                                    _allSelected
                                        ? 'Unselect All'
                                        : 'Select All',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            Expanded(
                              child: _companyLoading
                                  ? Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : ListView(
                                      children: List.generate(
                                        _companyList.length,
                                        (index) {
                                          return ListTile(
                                            tileColor: _companyList[index]
                                                    ['value']
                                                ? Color(0xffF7F7F7)
                                                : Colors.white,
                                            leading: Text(
                                              _companyList[index]['name'],
                                            ),
                                            onTap: () {
                                              setState(() {
                                                _companyList[index]['value'] =
                                                    !_companyList[index]
                                                        ['value'];
                                              });
                                            },
                                            trailing: Checkbox(
                                              value: _companyList[index]
                                                  ['value'],
                                              onChanged: (value) {
                                                setState(() {
                                                  _companyList[index]['value'] =
                                                      value;
                                                });
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Email : ',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      email,
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ConnectionStateWidget(context, _checkUpdates),
            ],
          ),
        ),
        Visibility(
          visible: _updates,
          maintainState: true,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(.7),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 25,
                    height: 25,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Checking for updates',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
        Visibility(
          visible: _needUpdate,
          maintainState: true,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(.7),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'You are using an outdated desktop client..!! Please download and update to new version..!!',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
