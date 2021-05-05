import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user/Components/entry_field.dart';
import 'package:user/Themes/colors.dart';
import 'package:user/baseurl/baseurl.dart';
import 'package:toast/toast.dart';

import '../../login_navigator.dart';

//register page for registration of a new user
class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: kMainTextColor),
        title: Text(
          'Sign Up',
          style: TextStyle(
              fontSize: 18, color: kMainTextColor, fontWeight: FontWeight.w600),
        ),
      ),

      //this column contains 3 textFields and a bottom bar
      body: RegisterForm(),
    );
  }
}

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
//  final TextEditingController _phoneController = TextEditingController();
//  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _referalController = TextEditingController();
  var fullNameError = "";

  bool showDialogBox = false;
dynamic token = '';
  FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  // RegisterBloc _registerBloc;

  @override
  void initState() {
    super.initState();
    firebaseMessagingListner();
    // _registerBloc = BlocProvider.of<RegisterBloc>(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _referalController.dispose();
//    _phoneController.dispose();
//    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,
      children: <Widget>[
        Divider(
          color: kCardBackgroundColor,
          thickness: 8.0,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - 100,
          padding: EdgeInsets.only(right: 20, left: 20),
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 10.0,
                left: 2.0,
                right: 2.0,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            'Create New Account',
                            style: TextStyle(
                                color: kMainTextColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 25),
                          )),
                      EntryField(
                          textCapitalization: TextCapitalization.words,
                          controller: _nameController,
                          hint: 'Full Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.0),
                            borderSide: BorderSide(color: kHintColor, width: 1),
                          )),
                      //email textField
                      EntryField(
                          textCapitalization: TextCapitalization.none,
                          controller: _emailController,
                          hint: 'Email Address',
                          keyboardType: TextInputType.emailAddress,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.0),
                            borderSide: BorderSide(color: kHintColor, width: 1),
                          )),

                      //phone textField
//                      EntryField(
//                          hint: 'Phone Number',
//                          controller: _phoneController,
//                          keyboardType: TextInputType.number,
//                          maxLength: 10,
//                          border: OutlineInputBorder(
//                            borderRadius: BorderRadius.circular(50.0),
//                            borderSide: BorderSide(color: kHintColor, width: 1),
//                          )),
//                      EntryField(
//                          hint: 'Password',
//                          controller: _passwordController,
//                          keyboardType: TextInputType.visiblePassword,
//                          border: OutlineInputBorder(
//                            borderRadius: BorderRadius.circular(50.0),
//                            borderSide: BorderSide(color: kHintColor, width: 1),
//                          )),
                      EntryField(
                          hint: 'Apply Referral Code (Optional)',
                          controller: _referalController,
                          keyboardType: TextInputType.text,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.0),
                            borderSide: BorderSide(color: kHintColor, width: 1),
                          )),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                                text: "By siging up you accept the",
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: kMainTextColor,
                                  fontFamily: 'OpenSans',
                                  fontWeight: FontWeight.w500,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                      text:
                                          ' Terms of service and Privacy Policy',
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: appbar_color,
                                        fontFamily: 'OpenSans',
                                        fontWeight: FontWeight.w500,
                                      ))
                                ])),
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 20,
                right: 20.0,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      showDialogBox = true;
                    });
                    if (_nameController.text.isEmpty) {
                      Toast.show("Enter your full name", context,
                          gravity: Toast.BOTTOM);
                      setState(() {
                        showDialogBox = false;
                      });
                    } else if (_emailController.text.isEmpty ||
                        !_emailController.text.contains('@') ||
                        !_emailController.text.contains('.')) {
                      setState(() {
                        showDialogBox = false;
                      });
                      Toast.show("Enter valied Email address!", context,
                          gravity: Toast.BOTTOM);
                    }
//                    else if (_phoneController.text.isEmpty ||
//                        _phoneController.text.length < 10) {
//                      setState(() {
//                        showDialogBox = false;
//                      });
//                      Toast.show("Enter valied mobile number!", context,
//                          gravity: Toast.BOTTOM);
//                    }
//                    else if (_passwordController.text.isEmpty ||
//                        _passwordController.text.length < 6) {
//                      setState(() {
//                        showDialogBox = false;
//                      });
//                      Toast.show("Enter valid password!", context,
//                          gravity: Toast.BOTTOM);
//                    }
                    else {
                      hitService(
                          _nameController.text,
                          _emailController.text,
                          _referalController.text,
                          context);
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 52,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        color: kMainColor),
                    child: Text(
                      'Continue',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        color: kWhiteColor,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                  child: Visibility(
                visible: showDialogBox,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 100,
                    alignment: Alignment.center,
                    child: SizedBox(
                      height: 120,
                      width: MediaQuery.of(context).size.width*0.9,
                      child: Material(
                        elevation: 5,
                        borderRadius: BorderRadius.circular(20),
                        clipBehavior: Clip.hardEdge,
                        child: Container(
                          color: white_color,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              CircularProgressIndicator(),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                'Loading please wait!....',
                                style: TextStyle(
                                    color: kMainTextColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )),
            ],
          ),
        )
      ],
    );
  }

  void hitService(String name, String email, String referal, BuildContext context) async {
    if(token!=null && token.toString().length>0){
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var phoneNumber = prefs.getString('user_phone');

      print('$phoneNumber - $name - $email - $referal');

      var url = registerApi;
      http.post(url, body: {
        'user_name': name,
        'user_email': email,
        'user_phone': phoneNumber,
        'user_password': 'no',
        'device_id': '${token}',
        'user_image': 'usre.png',
        'referral_code': referal
      }).then((value) {
        print('Response Body: - ${value.body.toString()}');
        if (value.statusCode == 200) {
          setState(() {
            showDialogBox = false;
          });
          Navigator.pushNamed(context, LoginRoutes.verification);
        }
      });

    }else{
      firebaseMessaging.getToken().then((value){
        setState(() {
          token = value;
        });
        print('${value}');
        hitService(name, email, referal, context);
      });
    }
  }

  void firebaseMessagingListner() async{

    if(Platform.isIOS) iosPermission();
    firebaseMessaging.getToken().then((value){
      setState(() {
        token = value;
      });
      print('${value}');
    });

  }

  void iosPermission() {
    firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(sound: true,badge: true,alert: true));
    firebaseMessaging.onIosSettingsRegistered.listen((event) {
      print('${event.provisional}');
    });
  }
}
