import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:user/Themes/colors.dart';

class CardContent extends StatelessWidget {
  final String text;
  final String image;

  CardContent({this.text, this.image});

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: 4.0, top: 10.0),
          child: Image.network(
            image,
            height: 38,
            width: 40,
            //fit: BoxFit.fill,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 4.0, right: 4.0 ,bottom: 2),

          child: Text(
            text,
            textAlign: TextAlign.center,

            style: TextStyle(

                color: black_color, fontWeight: FontWeight.w600, fontSize: 10),
          ),

        ),
      ],
    );
  }
}
