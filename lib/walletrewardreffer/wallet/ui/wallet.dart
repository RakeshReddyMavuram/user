import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user/Themes/colors.dart';
import 'package:user/baseurl/baseurl.dart';
import 'package:user/bean/rewardvalue.dart';
import 'package:toast/toast.dart';

class Wallet extends StatefulWidget {
//  dynamic userId;
//
//  Wallet() {
//    getUserId();
//  }

  @override
  State<StatefulWidget> createState() {
    return WalletState();
  }

//  void getUserId() async {
//
//  }
}

class WalletState extends State<Wallet> {
  bool three_expandtrue = false;
  int style_selectedValue = 0;

  bool visible = false;

  int rs_selected = -1;

  String email = '';

  dynamic walletAmount = 0.0;
  dynamic currency = '';

  List<WalletHistory> history = [];

  bool isFetchStore = false;

  @override
  void initState() {
    super.initState();
getWalletAmount();
    getWalletHistory();
  }

  void getWalletAmount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic userId = prefs.getInt('user_id');
    setState(() {
      isFetchStore = true;
      currency = prefs.getString('curency');
    });
    var client = http.Client();
    var url = showWalletAmount;
    client.post(url, body: {
      'user_id': '${userId}',
    }).then((value) {
      print('${value.body}');
      if (value.statusCode == 200 && jsonDecode(value.body)['status'] == "1") {
        var jsonData = jsonDecode(value.body);
        var dataList = jsonData['data'] as List;
        setState(() {
          walletAmount = dataList[0]['wallet_credits'];
        });
      }
      setState(() {
        isFetchStore = false;
      });
    }).catchError((e) {
      setState(() {
        isFetchStore = false;
      });
      print(e);
    });
  }

  void getWalletHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic userId = prefs.getInt('user_id');
    var client = http.Client();
    var url = creditHistroy;
    client.post(url, body: {
      'user_id': '${userId}',
    }).then((value) {
      print('${value.statusCode} ${value.body}');
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonData['data'] as List;
          List<WalletHistory> tagObjs = tagObjsJson
              .map((tagJson) => WalletHistory.fromJson(tagJson))
              .toList();
          setState(() {
            history.clear();
            history = tagObjs;
          });
        } else {
          Toast.show(jsonData['message'], context,
              duration: Toast.LENGTH_SHORT);
        }
      } else {
        Toast.show('No history found!', context, duration: Toast.LENGTH_SHORT);
      }
    }).catchError((e) {
      Toast.show('No history found!', context, duration: Toast.LENGTH_SHORT);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCardBackgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(64.0),
        child: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: kWhiteColor,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'My Wallet',
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(color: kMainTextColor),
              ),
            ],
          ),
        ),
      ),
      body: (!isFetchStore)?SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Card(
              margin: EdgeInsets.only(top: 10, left: 10, right: 10),
              color: kWhiteColor,
              elevation: 10,
              child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width - 20,
                  height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text('Wallet Balance',
                          style: Theme.of(context).textTheme.caption.copyWith(
                              color: kDisabledColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              letterSpacing: 0.67)),
                      Text('$currency ${walletAmount}/-'),
                      Text('Minimum wallet balance $currency ${walletAmount}/-',
                          style: Theme.of(context).textTheme.caption.copyWith(
                              color: kDisabledColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              letterSpacing: 0.67)),
//                  SizedBox(height: 30,),
                    ],
                  )),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                  color: kMainColor, border: Border.all(color: kMainColor)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'S No.',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: kWhiteColor),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        'Type',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: kWhiteColor),
                      ),
                    ],
                  ),
//                Text('Date',style: TextStyle(
//                    fontSize: 14,
//                    fontWeight: FontWeight.bold,
//                    color: kWhiteColor),),
                  Text(
                    'Wallet Amount',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: kWhiteColor),
                  ),
                ],
              ),
            ),
            ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${index + 1}',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: kMainTextColor),
                            ),
                            SizedBox(
                              width: 35,
                            ),
                            Text(
                              '${history[index].type}',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: kMainTextColor),
                            ),
//                     SizedBox(width: 10,),
//                     Text('${history[index].created_at}',
//                            style: TextStyle(
//                                fontSize: 14,
//                                fontWeight: FontWeight.bold,
//                                color: kMainTextColor),
//                          ),
                          ],
                        ),
                        Text(
                          '$currency ${history[index].amount}',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: kMainTextColor),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return Container(
                    height: 2,
                    color: kCardBackgroundColor,
                  );
                },
                itemCount: history.length),
//            Padding(
//                padding: EdgeInsets.only(top: 10, left: 20),
//                child: Text('Rechager your wallet here...')),
//            SizedBox(
//              height: 30,
//            ),
//            Container(
//              width: MediaQuery.of(context).size.width,
//              child: Row(
//                children: <Widget>[
//                  Expanded(
//                      flex: 1,
//                      child: Container(
//                        margin: EdgeInsets.only(left: 5, right: 5),
//                        padding: EdgeInsets.only(left: 10, right: 5),
//                        decoration: BoxDecoration(
//                            shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(40), color: kMainColor),
//                        child: Row(
//                          mainAxisAlignment: MainAxisAlignment.end,
//                          children: <Widget>[
//                            Text('500'),
//                            Radio(
//                                activeColor: kWhiteColor,
//                                focusColor: kHintColor,
//                                value: 0,
//                                groupValue: rs_selected,
//                                onChanged: (val) {
//                                  print(val);
//                                  if (rs_selected == val) {
//                                    _rs_selected(-1);
//                                  } else {
//                                    _rs_selected(val);
//                                  }
//                                })
//                          ],
//                        ),
//                      )),
//                  Expanded(
//                      flex: 1,
//                      child: Container(
//                        margin: EdgeInsets.only(left: 5, right: 5),
//                        padding: EdgeInsets.only(left: 10, right: 5),
//                        decoration: BoxDecoration(
//                            shape: BoxShape.rectangle,borderRadius: BorderRadius.circular(40),color: kMainColor),
//                        child: Row(
//                          mainAxisAlignment: MainAxisAlignment.end,
//                          children: <Widget>[
//                            Text('5000'),
//                            Radio(
//                                activeColor: kWhiteColor,
//                                value: 1,
//                                autofocus: false,
//                                hoverColor: appbar_color,
//                                focusColor: appbar_color,
//                                groupValue: rs_selected,
//                                onChanged: (val) {
//                                  if (rs_selected == val) {
//                                    _rs_selected(-1);
//                                  } else {
//                                    _rs_selected(val);
//                                  }
//                                })
//                          ],
//                        ),
//                      )),
//                  Expanded(
//                      flex: 1,
//                      child: Container(
//                        margin: EdgeInsets.only(left: 5, right: 5),
//                        padding: EdgeInsets.only(left: 10, right: 1),
//                        decoration: BoxDecoration(
//                            shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(40),color: kMainColor),
//                        child: Row(
//                          mainAxisAlignment: MainAxisAlignment.end,
//                          children: <Widget>[
//                            Text('10000'),
//                            Radio(
//                                activeColor: kWhiteColor,
//                                value: 2,
//                                groupValue: rs_selected,
//                                onChanged: (val) {
//                                  if (rs_selected == val) {
//                                    _rs_selected(-1);
//                                  } else {
//                                    _rs_selected(val);
//                                  }
//                                })
//                          ],
//                        ),
//                      )),
//                ],
//              ),
//            ),
//            Container(
//              margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
//              padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
////              decoration: BoxDecoration(
////                boxShadow: [BoxShadow(color: kWhiteColor)],
////                borderRadius: BorderRadius.circular(30.0),
////                color: kIconColor,
////              ),
//              child:
////              TextField(
////                textCapitalization: TextCapitalization.sentences,
////                cursorColor: kMainColor,
////                decoration: InputDecoration(
////                  hintText: 'Enter your amount to be recharge.',
////                  hintStyle: Theme.of(context)
////                      .textTheme
////                      .headline6
////                      .copyWith(color: kWhiteColor),
////                  border: InputBorder.none,
////                ),
////                onTap: () {},
////              ),
//              TextFormField(
//                decoration: InputDecoration(
//                  labelText: "Enter your amount.",
//                  hintText: "Enter Your amount to be recharged..",
//                  fillColor: Colors.white,
//                  border: OutlineInputBorder(
//                    borderRadius: BorderRadius.circular(10.0),
//                    borderSide: BorderSide(color: kMainColor, width: 3),
//                  ),
//                  focusedBorder: OutlineInputBorder(
//                    borderRadius: BorderRadius.circular(10.0),
//                    borderSide: BorderSide(color: kMainColor, width: 3),
//                  ),
//                  enabledBorder: OutlineInputBorder(
//                    borderRadius: BorderRadius.circular(10.0),
//                    borderSide: BorderSide(color: kMainColor, width: 3),
//                  ),
//                ),
//                style: TextStyle(color: Colors.black, fontSize: 16),
//                cursorColor: kMainColor,
//                showCursor: false,
//                keyboardType: TextInputType.number,
//                onChanged: (val) {
//                  setState(() => email = val);
//                },
//              ),
//            ),
//            SizedBox(
//              height: 5.0,
//            ),
//            Padding(
//              padding: EdgeInsets.only(top: 5.0, right: 20.0, left: 20.0),
//              child: Card(
//                elevation: 5,
//                child: Container(
//                  decoration: BoxDecoration(
//                      borderRadius: BorderRadius.circular(20.0),
//                      color: kWhiteColor,
//                      border: Border.all(color: kWhiteColor, width: 2.0)),
//                  child: Column(
//                    children: <Widget>[
//                      InkWell(
//                        child: Container(
//                          width: MediaQuery.of(context).size.width,
//                          padding: EdgeInsets.only(
//                              left: 10.0, right: 10.0, top: 20.0, bottom: 20.0),
//                          child: Row(
//                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                            children: <Widget>[
//                              Text('Select your payment method'),
//                              Icon(visible
//                                  ? Icons.keyboard_arrow_down
//                                  : Icons.keyboard_arrow_right)
//                            ],
//                          ),
//                        ),
//                        onTap: () {
//                          setState(() {
//                            visible = !visible;
//                          });
//                        },
//                      ),
//                      Visibility(
//                          visible: visible,
//                          child: Container(
//                            padding: EdgeInsets.only(
//                                left: 10.0,
//                                right: 10.0,
//                                top: 10.0,
//                                bottom: 20.0),
//                            child: Column(
//                              children: <Widget>[
//                                Row(
//                                  mainAxisAlignment:
//                                      MainAxisAlignment.spaceBetween,
//                                  children: <Widget>[
//                                    Text('Razorpay'),
//                                    Radio(
//                                        value: 0,
//                                        activeColor: kMainColor,
//                                        groupValue: style_selectedValue,
//                                        onChanged: (val) {
//                                          print(val);
//                                          _setStyleSelectedValue(val);
//                                        }),
//                                  ],
//                                ),
//                                Row(
//                                  mainAxisAlignment:
//                                      MainAxisAlignment.spaceBetween,
//                                  children: <Widget>[
//                                    Text('Paypal'),
//                                    Radio(
//                                        value: 1,
//                                        activeColor: kMainColor,
//                                        groupValue: style_selectedValue,
//                                        onChanged: (val) {
//                                          print(val);
//                                          _setStyleSelectedValue(val);
//                                        }),
//                                  ],
//                                ),
//                              ],
//                            ),
//                          ))
//                    ],
//                  ),
//                ),
//              ),
//            ),
//            SizedBox(
//              height: 30,
//            ),
//            Container(
//              width: MediaQuery.of(context).size.width,
//              height: 52,
//              child: Row(
//                mainAxisAlignment: MainAxisAlignment.end,
//                children: <Widget>[
//                  Padding(
//                    padding: EdgeInsets.only(right: 20),
//                    child: Container(
//                      alignment: Alignment.centerRight,
//                      height: 52,
//                      decoration: BoxDecoration(
//                          borderRadius: BorderRadius.circular(60),
//                          color: kMainColor),
//                      child: Row(
//                        children: <Widget>[
//                          Padding(
//                              padding: EdgeInsets.only(left: 10, right: 20),
//                              child: Text(
//                                'Proceed to pay',
//                                style: TextStyle(fontWeight: FontWeight.bold),
//                              )),
//                          Container(
//                            height: 40,
//                            width: 40,
//                            margin: EdgeInsets.only(right: 10),
//                            decoration: BoxDecoration(
//                                shape: BoxShape.circle, color: kWhiteColor),
//                            child: Icon(Icons.keyboard_arrow_right),
//                          )
//                        ],
//                      ),
//                    ),
//                  ),
//                ],
//              ),
//            ),
//            SizedBox(
//              height: 30,
//            ),
          ],
        ),
      ):
      Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(
              width: 10,
            ),
            Text(
              'Fetching wallet amount',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: kMainTextColor),
            )
          ],
        ),
      ),
    );
  }

  void _setStyleSelectedValue(val) {
    setState(() {
      style_selectedValue = val;
    });
  }

  void _rs_selected(val) {
    setState(() {
      rs_selected = val;
    });
  }
}
