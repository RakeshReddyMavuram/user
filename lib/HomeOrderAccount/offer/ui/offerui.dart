import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:user/Themes/colors.dart';
import 'package:user/baseurl/baseurl.dart';
import 'package:user/bean/notification_bean.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
class OfferScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return OfferScreenState();
  }

}

class OfferScreenState extends State<OfferScreen>{

  List<Notificationd> notificationList =[];

  @override
  void initState() {
    setNotificationListner();
    super.initState();
    getNotificationList();
  }

  void setNotificationListner() async{
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
    AndroidInitializationSettings('logo_store');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
    FirebaseMessaging firebaseMessaging = FirebaseMessaging();
    firebaseMessagingListner(firebaseMessaging);
  }

  void firebaseMessagingListner(firebaseMessaging) async {
    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) async {
      print('fcm 1 ${message.toString()}');
      _showNotification(flutterLocalNotificationsPlugin,'${message['notification']['title']}','${message['notification']['body']}');
    getNotificationList();
    }, onResume: (Map<String, dynamic> message) async {
      print('fcm - 2 ${message.toString()}');
    }, onLaunch: (Map<String, dynamic> message) async {
      _showNotification(flutterLocalNotificationsPlugin,'${message['notification']['title']}','${message['notification']['body']}');
      print('fcm -  3 ${message.toString()}');
    });
  }

  void getNotificationList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('user_id');
    var url = notificationlist;
    http.post(url, body: {
      'user_id': '${userId}',
    }).then((value) {
      print('${value.statusCode} ${value.body}');
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(value.body)['data'] as List;
          List<Notificationd> tagObjs = tagObjsJson.map((tagJson) => Notificationd.fromJson(tagJson)).toList();
//          for(Notificationd dd in tagObjs){
//            print(dd.image);
//          }
          setState(() {
            notificationList.clear();
            notificationList = tagObjs;
          });
        } else {
          Toast.show(jsonData['message'], context,
              duration: Toast.LENGTH_SHORT);
        }
      } else {
        Toast.show('No Notification found!', context, duration: Toast.LENGTH_SHORT);
      }
    }).catchError((e) {
      Toast.show('Please try again!', context, duration: Toast.LENGTH_SHORT);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCardBackgroundColor,
      body: (notificationList!=null && notificationList.length>0)?SingleChildScrollView(
        primary: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 20,),
            ListView.separated(
                shrinkWrap: true,
                primary: false,
                itemBuilder: (context,index){
                  var str = notificationList[index].noti_message;
                  var parts = str.split('contains');
                  var prefix = parts[0].trim();
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    color: white_color,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,


                      children: [
                        Text('${notificationList[index].noti_title}',style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: kMainTextColor
                        ),),
                        SizedBox(height: 6,),

                        Text(prefix,style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: kHintColor
                        ),),
                        SizedBox(height: 6,),
                        (notificationList[index].image!=null && notificationList[index].image != 'N/A')?Image.network('${imageBaseUrl+notificationList[index].image}',height: 150,width: MediaQuery.of(context).size.width,fit: BoxFit.fitWidth,):Container(
                          height: 0.0,
                        )
                      ],
                    ),
                  );
                }, separatorBuilder: (context,index){
              return Divider(
                height: 8,
                color: Colors.transparent,
              );
            }, itemCount: notificationList.length)
          ],
        ),
      ):Center(
        child: Text('No offer available....',style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w400,
            color: kMainTextColor
        ),),
      ),
    );
  }



}

Future onDidReceiveLocalNotification(int id, String title, String body, String payload) async {
  debugPrint('notification payload: ' + title+body);
}

Future<void> _showNotification(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,dynamic title,dynamic body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '7458', 'Notify', 'Notify On Shopping',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker');
  const IOSNotificationDetails iOSPlatformChannelSpecifics =
  IOSNotificationDetails(presentSound: false);
  // const MacOSNotificationDetails macOSPlatformChannelSpecifics =
  // MacOSNotificationDetails(presentSound: false);
  IOSNotificationDetails iosDetail = IOSNotificationDetails(presentAlert: true);

  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android:androidPlatformChannelSpecifics,iOS: iOSPlatformChannelSpecifics);
  // await flutterLocalNotificationsPlugin.show(
  //     0, 'plain title', 'plain body', platformChannelSpecifics,
  //     payload: 'item x');
  await flutterLocalNotificationsPlugin.show(
      0, '${title}', '${body}', platformChannelSpecifics,
      payload: 'item x');
}

Future selectNotification(String payload) async {
  if (payload != null) {
    debugPrint('notification payload: ' + payload);
  }
}

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  debugPrint('ob notification payload:');
  _showNotification(flutterLocalNotificationsPlugin,'${message['notification']['title']}','${message['notification']['body']}');
}