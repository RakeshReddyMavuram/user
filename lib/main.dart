import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user/Auth/login_navigator.dart';

import 'package:user/HomeOrderAccount/home_order_account.dart';
import 'package:user/Locale/locales.dart';
import 'package:user/Routes/routes.dart';
import 'package:user/Themes/colors.dart';
import 'package:user/Themes/style.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setFirebase();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool result = prefs.getBool('islogin');
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: kMainTextColor.withOpacity(0.5),
  ));
  runApp(
      Phoenix(child: (result != null && result) ? GoMarketHome() : GoMarket()));
}

// if (Platform.isIOS) iosPermission(firebaseMessaging);
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void setFirebase() async {
  FirebaseMessaging messaging = FirebaseMessaging();
  iosPermission(messaging);
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  var initializationSettingsAndroid =
      AndroidInitializationSettings('logo_store');
  var initializationSettingsIOS = IOSInitializationSettings(
      onDidReceiveLocalNotification: onDidReceiveLocalNotification);
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: selectNotification);
  messaging.getToken().then((value) {
    debugPrint('token: $value');
  });
  messaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        debugPrint('om notification payload: ${message['notification']}');
        _showNotification(
            flutterLocalNotificationsPlugin,
            '${message['notification']['title']}',
            '${message['notification']['body']}');
        // if (message.containsKey('data')) {
        //   // Handle data message
        //   final dynamic data = message['data'];
        //   debugPrint('om notification payload: ' + data);
        // }
        //
        // if (message.containsKey('notification')) {
        //   // Handle notification message
        //   debugPrint('notification payload: ' + message['notification']);
        //   final dynamic notification = message['notification'];
        // }
      },
      onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        debugPrint('od notification payload: ${message['notification']}');
        // if (message.containsKey('data')) {
        //   // Handle data message
        //   final dynamic data = message['data'];
        //   debugPrint('notification payload: ' + data);
        // }
        //
        // if (message.containsKey('notification')) {
        //   // Handle notification message
        //   debugPrint('notification payload: ' + message['notification']);
        //   final dynamic notification = message['notification'];
        // }
      },
      onResume: (Map<String, dynamic> message) async {
        debugPrint('of notification payload: ${message['notification']}');
        // if (message.containsKey('data')) {
        //   // Handle data message
        //   final dynamic data = message['data'];
        //   debugPrint('notification payload: ' + data);
        // }
        //
        // if (message.containsKey('notification')) {
        //   // Handle notification message
        //   debugPrint('notification payload: ' + message['notification']);
        //   final dynamic notification = message['notification'];
        // }
      });
}

Future onDidReceiveLocalNotification(
    int id, String title, String body, String payload) async {
  debugPrint('notification payload: ' + title + body);
}

Future<void> _showNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    dynamic title,
    dynamic body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('7458', 'Notify', 'Notify On Shopping',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker');
  const IOSNotificationDetails iOSPlatformChannelSpecifics =
      IOSNotificationDetails(presentSound: false);
  // const MacOSNotificationDetails macOSPlatformChannelSpecifics =
  // MacOSNotificationDetails(presentSound: false);
  IOSNotificationDetails iosDetail = IOSNotificationDetails(presentAlert: true);

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);
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
  _showNotification(
      flutterLocalNotificationsPlugin,
      '${message['notification']['title']}',
      '${message['notification']['body']}');
// if (message.containsKey('data')) {
//   // Handle data message
//   final dynamic data = message['data'];
//   debugPrint('notification payload: ' + data);
// }
//
// if (message.containsKey('notification')) {
//   // Handle notification message
//   debugPrint('notification payload: ' + message['notification']);
//   final dynamic notification = message['notification'];
// }

// Or do other work.
}

void iosPermission(firebaseMessaging) {
  firebaseMessaging.requestNotificationPermissions(
      IosNotificationSettings(sound: true, badge: true, alert: true));
  firebaseMessaging.onIosSettingsRegistered.listen((event) {
    print('${event.provisional}');
  });
}

class GoMarket extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        const AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'),
        const Locale('hi'),
      ],
      theme: appTheme,
      home: LoginNavigator(),
      routes: PageRoutes().routes(),
    );
  }
}

class GoMarketHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        const AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'),
        const Locale('hi'),
      ],
      theme: appTheme,
      home: HomeStateless(),
      routes: PageRoutes().routes(),
    );
  }
}


// (nearStores != null && nearStores.length > 0)
// ? nearStores.map((e)
// {
// return
// // Container(
// //   height: itemHeight,
// //   child: Column(
// //     children: <Widget>[
// //       Padding(
// //           padding: EdgeInsets.only(bottom: 12.0),
// //           child: Image.network('${imageBaseUrl}${e.category_image}',height: 40,width: 40,fit: BoxFit.fill,)),
// //       Text(
// //         '${e.category_name}',
// //         textAlign: TextAlign.center,
// //         style: TextStyle(
// //             color: black_color,
// //             fontWeight: FontWeight.w500,
// //             fontSize: 12
// //         ),
// //       ),
// //     ],
// //   ),
// // );
// ReusableCard(
// cardChild: CardContent(
// image: '${imageBaseUrl}${e.category_image}',
// text: '${e.category_name}',
// ),
// onPress: () =>
// hitNavigator(
// context,
// e.category_name,
// e.ui_type,
// e.vendor_category_id),
// );
// }).toList()
//     : nearStoresShimmer.map((e) {
// return ReusableCard(
// cardChild: Shimmer(
// duration: Duration(seconds: 3),
// //Default value
// color: Colors.white,
// //Default value
// enabled: true,
// //Default value
// direction: ShimmerDirection.fromLTRB(),
// //Default Value
// child: Container(
// decoration: BoxDecoration(
// color: kTransparentColor,
// ),
//
// ),
// ),
// onPress: () {});
// }).toList(),