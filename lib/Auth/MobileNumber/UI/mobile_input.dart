import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:user/Auth/login_navigator.dart';
import 'package:user/Components/entry_field.dart';
import 'package:user/Locale/locales.dart';
import 'package:user/Themes/colors.dart';
import 'package:user/baseurl/baseurl.dart';
import 'package:toast/toast.dart';

class MobileInput extends StatefulWidget {
  @override
  _MobileInputState createState() => _MobileInputState();
}

class _MobileInputState extends State<MobileInput> {
  final TextEditingController _controller = TextEditingController();

  //MobileBloc _mobileBloc;
  String isoCode;

  @override
  void initState() {
    super.initState();
    //_mobileBloc = BlocProvider.of<MobileBloc>(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CountryCodePicker(
          onChanged: (value) {
            isoCode = value.code;
          },
          builder: (value) => buildButton(value),
          initialSelection: '+91',
          textStyle: Theme.of(context).textTheme.caption,
          showFlag: false,
          showFlagDialog: true,
          favorite: ['+91', 'US'],
        ),
        SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: EntryField(
            controller: _controller,
            keyboardType: TextInputType.number,
            readOnly: false,
            hint: AppLocalizations.of(context).mobileText,
            maxLength: 10,
            border: InputBorder.none,
          ),
        ),
        RaisedButton(
          child: Text(
            AppLocalizations.of(context).continueText,
            style: TextStyle(color: kWhiteColor,fontWeight: FontWeight.w400),
          ),
          color: kMainColor,
          highlightColor: kMainColor,
          focusColor: kMainColor,
          splashColor: kMainColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          onPressed: () {
            if(_controller.text.isEmpty || _controller.text.length<10){
              Toast.show("Enter valid mobile number!", context, gravity: Toast.BOTTOM);
            }else{
              hitService(isoCode,_controller.text);
            }

          },
        ),
      ],
    );
  }

  void hitService(String isoCode, String phoneNumber) async {
    var url = userRegistration;
    var response = await http.post(url, body: {
      'user_phone': phoneNumber});
    if (response.statusCode == 200) {
      print('Response Body: - ${response.body}');
//      var jsonData = jsonDecode(response.body);
//      SharedPreferences prefs = await SharedPreferences.getInstance();
//      prefs.setString("user_phone", jsonData['data']['user_phone']);
//      Navigator.pushNamed(context, LoginRoutes.registration,arguments: MobileNumberArg(isoCode,_controller.text));
    }
  }

  void goToNextScreen(
      bool isRegistered, String normalizedPhoneNumber, BuildContext context) {
    if (isRegistered) {
      Navigator.pushNamed(
        context,
        LoginRoutes.verification,
      );
    } else {
      Navigator.pushNamed(
        context,
        LoginRoutes.registration,
      );
    }
  }

  buildButton(CountryCode isoCode) {
    return Row(
      children: <Widget>[
        Text(
          '$isoCode',
          style: Theme.of(context).textTheme.caption,
        ),
//        IconButton(
//          icon: Icon(Icons.arrow_drop_down),
//        ),
      ],
    );
  }
}
