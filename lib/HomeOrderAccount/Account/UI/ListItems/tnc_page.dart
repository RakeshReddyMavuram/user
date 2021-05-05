import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:user/Themes/colors.dart';
import 'package:user/baseurl/baseurl.dart';

class TncPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TncPageState();
  }
}

class TncPageState extends State<TncPage> {
  dynamic htmlString = '';

  @override
  void initState() {
    super.initState();
    getTnc();
  }

  void getTnc() async {
    var client = http.Client();
    var url = termcondition;
    client.get(url).then((value) {
      print('${value.body}');
      if (value.statusCode == 200 && jsonDecode(value.body)['status'] == "1") {
        var jsonData = jsonDecode(value.body);
        var dataList = jsonData['data'] as List;
//        print('${dataList.toString()}');
//        print('${dataList[0]['termcondition']}');
        setState(() {
          htmlString = dataList[0]['termcondition'];
        });
      }
    }).catchError((e) {
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: Text('Terms & Conditions',
            style: Theme.of(context).textTheme.bodyText1),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              /*Container(
                color: kCardBackgroundColor,
                child: Image(
                  image: AssetImage("images/logos/logo_user.png"),
                  centerSlice: Rect.largest,
                  fit: BoxFit.fill,
                  //gomarketdelivery logo
                  height: 220,
                ),
              ),*/
              Padding(
                padding: EdgeInsets.symmetric(vertical: 28.0, horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Terms of use',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    Text(
                      '\n${htmlString}',
                      style: Theme.of(context).textTheme.caption.copyWith(fontSize: 16),
                    ),
//                    Text(
//                      '\nCompany Policy',
//                      style: Theme.of(context).textTheme.bodyText1,
//                    ),
//                    Text(
//                      '\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque pulvinar porta sagittis. Sed id varius magna. Etiam felis neque, gravida vitae elementum non, consequat eu odio. Mauris cursus commodo nisi sed imperdiet. Fusce vitae vehicula ipsum, ut commodo lorem. Praesent interdum blandit condimentum. Curabitur vel orci vitae odio congue facilisis eget eget diam. Nam a arcu efficitur, ornare leo eu, euismod leo. Vestibulum porttitor varius leo, eget posuere felis congue vel. Sed sit amet erat quam. Mauris et ex sapien. Sed venenatis, felis sed eleifend vulputate, mauris libero pretium urna, non hendrerit urna quam vitae justo. Maecenas rhoncus lectus consectetur eros pretium feugiat.',
//                      style: Theme.of(context).textTheme.caption,
//                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
