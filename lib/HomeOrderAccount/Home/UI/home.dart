import 'dart:async';
import 'dart:convert';
import 'package:intl/intl_browser.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:user/bean/latlng.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:user/Components/card_content.dart';
import 'package:user/Components/custom_appbar.dart';
import 'package:user/Components/reusable_card.dart';
import 'package:user/HomeOrderAccount/Home/UI/Stores/stores.dart';
import 'package:user/HomeOrderAccount/searchproductstore.dart';
import 'package:user/Maps/UI/location_page.dart';
import 'package:user/Routes/routes.dart';
import 'package:user/Themes/colors.dart';
import 'package:user/baseurl/baseurl.dart';
import 'package:user/bean/bannerbean.dart';
import 'package:user/bean/venderbean.dart';
import 'package:user/databasehelper/dbhelper.dart';
import 'package:user/restaturantui/ui/resturanthome.dart';
import 'package:toast/toast.dart';
import 'package:user/pharmacy/pharmastore.dart';
import 'package:user/parcel/parcel_details.dart';
import 'package:user/parcel/parcalstorepage.dart';
import 'package:user/repository/repository.dart';

import 'package:get_version/get_version.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';


class HomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Home();
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String cityName = 'NO LOCATION SELECTED';
  var lat = 0.0;
  var lng = 0.0;
  bool isExpanded = false;
  final popularItems = FakeRepository.popularItems;

//  final List<dynamic> listImage = [
//    'images/demosliderimage/image1.jpg',
//    'images/demosliderimage/image1.jpg',
//    'images/demosliderimage/image3.jpg',
//    'images/demosliderimage/image4.jpg',
//    'images/demosliderimage/image4.jpg',
//  ];
  List<BannerDetails> listImage = [];
  List<VendorList> nearStores = [];
  List<VendorList> nearStoresShimmer = [
    VendorList("", "", "", ""),
    VendorList("", "", "", ""),
    VendorList("", "", "", ""),
    VendorList("", "", "", "")
  ];
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  List<String> listImages = ['', '', '', '', ''];
  List<String>images=['1','2','3','4','5'];
  int versioncode =0;
  int versioncodeapp=0;

  bool isCartCount = false;
  int cartCount = 0;

  bool isFetch = true;


  @override
  void initState() {
    _getLocation();
    // getCartCount();
    super.initState();
  }

  void _getLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      bool isLocationServiceEnableds =
          await Geolocator.isLocationServiceEnabled();
      if (isLocationServiceEnableds) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best);
       // double lat = position.latitude;
        double lat = double.parse(prefs.getString("lat"));
        // double lat = 28.570810039366947;
        //double lng = position.longitude;
        double lng = double.parse(prefs.getString("lng"));
        // 29.006057, 77.027535
        // prefs.setString("lat", "29.006057");
       /* prefs.setString("lat", lat.toStringAsFixed(8));
        // prefs.setString("lng", "77.027535");
        prefs.setString("lng", lng.toStringAsFixed(8));*/
        // lat = 29.006057;
        // lng = 77.027535;
        final coordinates = new Coordinates(lat, lng);
        await Geocoder.local
            .findAddressesFromCoordinates(coordinates)
            .then((value) {
//          print("${value[0].featureName} : ${value[0].countryName} : ${value[0].locality} : ${value[0].subAdminArea} : ${value[0].adminArea} : ${value[0].subLocality} : ${value[0].addressLine}");
          if (value[0].locality != null && value[0].locality.isNotEmpty) {
            setState(() {
              this.lat = lat;
              this.lng = lng;
              String city = '${value[0].locality}';
              cityName = '${city.toUpperCase()} (${value[0].subLocality})';
            });
          } else if (value[0].subAdminArea != null &&
              value[0].subAdminArea.isNotEmpty) {
            this.lat = lat;
            this.lng = lng;
            String city = '${value[0].subAdminArea}';
            cityName = '${city.toUpperCase()}';
          }
        }).catchError((e) {
          print(e);
        });
        hitforceupdate();
        /*hitService();
        hitBannerUrl();*/
      } else {
        await Geolocator.openLocationSettings().then((value) {
          if (value) {
            _getLocation();
          } else {
            Toast.show('Location permission is required!', context,
                duration: Toast.LENGTH_SHORT);
          }
        }).catchError((e) {
          Toast.show('Location permission is required!', context,
              duration: Toast.LENGTH_SHORT);
        });
      }
    } else if (permission == LocationPermission.denied) {
      LocationPermission permissiond = await Geolocator.requestPermission();
      if (permissiond == LocationPermission.whileInUse ||
          permissiond == LocationPermission.always) {
        _getLocation();
      } else {
        Toast.show('Location permission is required!', context,
            duration: Toast.LENGTH_SHORT);
      }
    } else if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings().then((value) {
        _getLocation();
      }).catchError((e) {
        Toast.show('Location permission is required!', context,
            duration: Toast.LENGTH_SHORT);
      });
    }
  }

  void getCartCount() {
    DatabaseHelper db = DatabaseHelper.instance;
    db.queryRowBothCount().then((value) {
      setState(() {
        if (value != null && value > 0) {
          cartCount = value;
          isCartCount = true;
        } else {
          cartCount = 0;
          isCartCount = false;
        }
      });
    });
  }

  // void getCartCount() {
  //   DatabaseHelper db = DatabaseHelper.instance;
  //   db.queryRowCount().then((value) {
  //     setState(() {
  //       if (value != null && value > 0) {
  //         cartCount = value;
  //         isCartCount = true;
  //       } else {
  //         cartCount = 0;
  //         isCartCount = false;
  //       }
  //     });
  //   });
  // }

  void getCurrency() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var currencyUrl = currencyuri;
    var client = http.Client();
    client.get(currencyUrl).then((value) {
      var jsonData = jsonDecode(value.body);
      if (value.statusCode == 200 && jsonData['status'] == "1") {
        print('${jsonData['data'][0]['currency_sign']}');
        preferences.setString(
            'curency', '${jsonData['data'][0]['currency_sign']}');
      }
    }).catchError((e) {
      print(e);
    });
  }



  @override
  Widget build(BuildContext context) {
   // FirebaseInAppMessaging.setAutomaticDataCollectionEnabled(true);
    Size size = MediaQuery.of(context).size;
    // var size = MediaQuery.of(context).size;
    // final double itemWidth = size.width / 4;
    // final double itemHeight = 1.77*itemWidth;
    // print('aspect ratio - ${itemWidth/itemHeight}');
    return Scaffold(
      //resizeToAvoidBottomPadding: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: CustomAppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Icon(
              Icons.location_on,
              color: kMainColor,
            ),
          ),
          titleWidget: GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return LocationPage(lat, lng);
              })).then((value) {
                if (value != null) {
                  print('${value.toString()}');
                  BackLatLng back = value;
                  getBackResult(back.lat, back.lng);
                }
              }).catchError((e) {
                print(e);
                // getBackResult();
              });
            },
            child:Row(

              children: [
                Text(
                  '${cityName}',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kMainTextColor),
                ),
                Row(
                  children: [
                    // Text(
                    //   'Tap to view..',
                    //   style: TextStyle(color: kMainTextColor),
                    // ),

                    Icon(

                      Icons.arrow_drop_down ,
                      color: kMainColor,
                    ),
                  ],
                )
              ],
            ),
          ),
          /*actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: Stack(
                children: [
                  IconButton(
                      icon: ImageIcon(
                        AssetImage('images/icons/ic_cart blk.png'),
                      ),
                      onPressed: () {
                        if (isCartCount) {
                          Navigator.pushNamed(context, PageRoutes.viewCart)
                              .then((value) {
                            getCartCount();
                          });
                        } else {
                          Toast.show('No Value in the cart!', context,
                              duration: Toast.LENGTH_SHORT);
                        }
//                        getCurrency();
                      }),
                  Positioned(
                      right: 5,
                      top: 2,
                      child: Visibility(
                        visible: isCartCount,
                        child: CircleAvatar(
                          minRadius: 4,
                          maxRadius: 8,
                          backgroundColor: kMainColor,
                          child: Text(
                            '$cartCount',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 7,
                                color: kWhiteColor,
                                fontWeight: FontWeight.w200),
                          ),
                        ),
                      ))
                ],
              ),
            ),
          ],*/
          bottom: PreferredSize(
              child: Visibility(
                visible: false,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return SearchStore();
                        }));
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        height: 52,
                        padding: EdgeInsets.only(left: 5),
                        decoration: BoxDecoration(
                            color: scaffoldBgColor,
                            borderRadius: BorderRadius.circular(50)),
                        child: TextFormField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            enabled: false,
                            prefixIcon: Icon(
                              Icons.search,
                              color: kHintColor,
                            ),
                            hintText: 'Search store',
                          ),
                          cursorColor: kMainColor,
                          autofocus: false,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ),
              preferredSize:
                  Size(MediaQuery.of(context).size.width * 0.85, 62)),
        ),
      ),

      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          // scrollDirection: Axis.vertical,
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              //_searchWidget(),
              _bigCategoryWidget(),
              //  CustomSearchBar(hint: 'Search item or store'),
              // Padding(
              //   padding: EdgeInsets.only(top: 16.0, left: 24.0),
              //   child: Row(
              //     children: <Widget>[
              //       Text(
              //         "Got Delivered",
              //         style: Theme
              //             .of(context)
              //             .textTheme
              //             .bodyText1,
              //       ),
              //       SizedBox(
              //         width: 5.0,
              //       ),
              //       Text(
              //         "everything you need",
              //         style: Theme
              //             .of(context)
              //             .textTheme
              //             .bodyText1
              //             .copyWith(fontWeight: FontWeight.normal),
              //       ),
              //     ],
              //   ),
              // ),
//               Visibility(
//                 visible: (!isFetch && listImage.length == 0)?false:true,
//                 child: Padding(
//                   padding: EdgeInsets.only(top: 10, bottom: 5),
//                   child: CarouselSlider(
//                       options: CarouselOptions(
//                         height: 170.0,
//                         autoPlay: true,
//                         initialPage: 0,
//                         viewportFraction: 0.9,
//                         enableInfiniteScroll: true,
//                         reverse: false,
//                         autoPlayInterval: Duration(seconds: 3),
//                         autoPlayAnimationDuration: Duration(milliseconds: 800),
//                         autoPlayCurve: Curves.fastOutSlowIn,
//                         scrollDirection: Axis.horizontal,
//                       ),
//                       items: (listImage != null && listImage.length > 0)
//                           ? listImage.map((e) {
//                         return Builder(
//                           builder: (context) {
//                             return InkWell(
//                               onTap: () {
//                                 print(e.toString());
//                               },
//                               child: Padding(
//                                 padding: EdgeInsets.symmetric(
//                                     horizontal: 5, vertical: 10),
//                                 child: Material(
//                                   elevation: 5,
//                                   borderRadius: BorderRadius.circular(20.0),
//                                   clipBehavior: Clip.hardEdge,
//                                   child: Container(
//                                     width:
//                                     MediaQuery
//                                         .of(context)
//                                         .size
//                                         .width *
//                                         0.90,
// //                                            padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 10.0),
//                                     decoration: BoxDecoration(
//                                       color: white_color,
//                                       borderRadius:
//                                       BorderRadius.circular(20.0),
//                                     ),
//                                     child:
//                                     Image.network(
//                                       imageBaseUrl + e.banner_image,
//                                       fit: BoxFit.fill,
//                                     ),
// //                                        CachedNetworkImage(imageUrl: '${imageBaseUrl+e.banner_image}'),
// //                                        CachedNetworkImage(
// //                                          fit: BoxFit.fill,
// //                                          imageUrl: imageBaseUrl + e.banner_image,
// ////                                          progressIndicatorBuilder: (context, url, downloadProgress) =>
// ////                                              CircularProgressIndicator(value: downloadProgress.progress),
// //                                          errorWidget: (context, url, error) => Image.asset('images/logos/logo_user.png'),
// //                                        ),
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         );
//                       }).toList()
//                           :listImages.map((e) {
//                         return Builder(builder: (context) {
//                           return Container(
//                             width: MediaQuery
//                                 .of(context)
//                                 .size
//                                 .width * 0.90,
//                             margin: EdgeInsets.symmetric(horizontal: 5.0),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(20.0),
//                             ),
//                             child: Shimmer(
//                               duration: Duration(seconds: 3),
//                               //Default value
//                               color: Colors.white,
//                               //Default value
//                               enabled: true,
//                               //Default value
//                               direction: ShimmerDirection.fromLTRB(),
//                               //Default Value
//                               child: Container(
//                                 color: kTransparentColor,
//                               ),
//                             ),
//                           );
//                         });
//                       }).toList()),
//                 ),
//               ),
              SizedBox(
                height: 20,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                child: Container(
                  height: isExpanded ? size.height /  1.9 : size.height / 3.75,
                  child: GridView.count(
                    crossAxisCount: 4,
                    //padding: const EdgeInsets.only(bottom: 5),
                    crossAxisSpacing: 0.0,
                    mainAxisSpacing: 0.0,
                    // childAspectRatio: itemWidth/(itemHeight),
                    controller: ScrollController(keepScrollOffset: false),
                   // shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    children: (nearStores != null && nearStores.length > 0)
                        ? List.generate(nearStores.length - 4, (index) {
                            index = index + 4;

                            return ReusableCard(

                              cardChild: CardContent(

                                image:
                                    '${imageBaseUrl}${nearStores[index].category_image}',
                                text: '${nearStores[index].category_name}' ,

                              ),

                              onPress: () => hitNavigator(
                                  context,
                                  nearStores[index].category_name,
                                  nearStores[index].ui_type,
                                  nearStores[index].vendor_category_id),
                            );
                          }).toList()
                        : nearStoresShimmer.map((e) {
                            return ReusableCard(
                                cardChild: Shimmer(
                                  duration: Duration(seconds: 2),
                                  //Default value
                                  color: kWhiteColor,
                                  //Default value
                                  enabled: true,
                                  //Default value
                                  direction: ShimmerDirection.fromLTRB(),
                                  //Default Value
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: kTransparentColor,
                                    ),
                                  ),

                                ),
                                onPress: () {});
                          }).toList(),
                  ),

                ),
              ),

              Container(
                  padding: const EdgeInsets.only(left: 9,top:0,bottom: 0),
                  child: IconButton(
                icon: isExpanded
                    ? Icon(Icons.keyboard_arrow_up_rounded)
                    : Icon(Icons.keyboard_arrow_down_rounded),
                onPressed: () {
                  setState(() {
                    isExpanded = !isExpanded;
                    print(isExpanded);
                  });
                },
              )),

            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                  Padding(
                  padding: const EdgeInsets.only(left: 9,top:12,bottom: 12),

                  child: Text(
                    "Coupon's",
                    textAlign: TextAlign.left,
                    style: TextStyle(

                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              ),
          ),



              Container(
                height: 200.0,
                child: ListView.builder(
                  // physics: ClampingScrollPhysics(),
                  // shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (BuildContext context, int index) => Padding(
                    padding: const EdgeInsets.all(8),
                    child: InkWell(
                      child: Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          image: DecorationImage(
                            image: NetworkImage(
                                imageBaseUrl+'images/coupons/coupon_'+images[index]+'.jpg'),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      onTap: () {
                        print("Pressed");
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 12,
              ),
            /*Container(

                child:  Padding(

                  padding: const EdgeInsets.only(left: 9 ,top: 12,bottom: 12),
                  child: Text(
                    "Coupon's",

                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
          ),*/
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 9,top:12,bottom: 12),

                      child: Text(
                        "Top picks for you",
                        textAlign: TextAlign.left,
                        style: TextStyle(

                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),


              Visibility(
                visible: (!isFetch && listImage.length == 0) ? false : true,
                child: Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 5),
                  child: CarouselSlider(
                      options: CarouselOptions(
                        height: 200.0,
                        autoPlay: true,
                        initialPage: 0,
                        viewportFraction: 0.9,
                        enableInfiniteScroll: true,
                        reverse: false,
                        autoPlayInterval: Duration(seconds: 3),
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                        autoPlayCurve: Curves.fastOutSlowIn,
                        scrollDirection: Axis.horizontal,
                      ),
                      items: (listImage != null && listImage.length > 0)
                          ? listImage.map((e) {
                              return Builder(
                                builder: (context) {
                                  return InkWell(
                                    onTap: () {
                                      print(e.toString());
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 10),
                                      child: Material(
                                        elevation: 3,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        clipBehavior: Clip.hardEdge,
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.90,
//                                            padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 10.0),
                                          decoration: BoxDecoration(
                                            color: white_color,
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: Image.network(
                                            imageBaseUrl + e.banner_image,
                                            fit: BoxFit.fill,
                                          ),
//                                        CachedNetworkImage(imageUrl: '${imageBaseUrl+e.banner_image}'),
//                                        CachedNetworkImage(
//                                          fit: BoxFit.fill,
//                                          imageUrl: imageBaseUrl + e.banner_image,
////                                          progressIndicatorBuilder: (context, url, downloadProgress) =>
////                                              CircularProgressIndicator(value: downloadProgress.progress),
//                                          errorWidget: (context, url, error) => Image.asset('images/logos/logo_user.png'),
//                                        ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList()
                          : listImages.map((e) {
                              return Builder(builder: (context) {
                                return Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.90,
                                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Shimmer(
                                    duration: Duration(seconds: 3),
                                    //Default value
                                    color: Colors.white,
                                    //Default value
                                    enabled: true,
                                    //Default value
                                    direction: ShimmerDirection.fromLTRB(),
                                    //Default Value
                                    child: Container(
                                      color: kTransparentColor,
                                    ),
                                  ),
                                );
                              });
                            }).toList()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void hitService() async {
    var url = vendorUrl;
    var response = await http.get(url);
    try {
      if (response.statusCode == 200) {
        print('Response Body: - ${response.body}');
        var jsonData = jsonDecode(response.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(response.body)['data'] as List;
          List<VendorList> tagObjs = tagObjsJson
              .map((tagJson) => VendorList.fromJson(tagJson))
              .toList();
          setState(() {
            nearStores.clear();
            nearStores = tagObjs;
          });
        }
      }
    } on Exception catch (_) {
      Timer(Duration(seconds: 5), () {
        hitService();
      });
    }
  }

  void hitforceupdate() async {

    /*if(2>1){
      showAlertDialog(context);
    }else{
      hitService();
      hitBannerUrl();
    }*/




    var url = forceudate;
    var response = await http.get(url);
    try {
      if (response.statusCode == 200) {

        var jsonData = jsonDecode(response.body);
        if (jsonData['status'] == "1") {

           String serverversion= '${jsonData['data'][0]['version']}' ;
           versioncode=int.parse(serverversion);

           String projectVersion="";

           PackageInfo.fromPlatform().then((pkgInfo) {

             projectVersion=pkgInfo.buildNumber;
             versioncodeapp= int.parse(projectVersion);
           });


          if(versioncode<=versioncodeapp){
            hitService();
            hitBannerUrl();
          }else{
            showAlertDialog(context);

          }

        }
      }
    } on Exception catch (_) {
      Timer(Duration(seconds: 5), () {
        hitService();
        hitBannerUrl();
      });
    }
  }


  void hitBannerUrl() async {
    setState(() {
      isFetch = true;
    });
    var url = bannerUrl;
    http.get(url).then((response) {
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        print('Response Body: - ${response.body}');
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(response.body)['data'] as List;
          List<BannerDetails> tagObjs = tagObjsJson
              .map((tagJson) => BannerDetails.fromJson(tagJson))
              .toList();
          if (tagObjs.isNotEmpty) {
            setState(() {
              listImage.clear();
              listImage = tagObjs;
            });
          } else {
            setState(() {
              isFetch = false;
            });
          }
        } else {
          setState(() {
            isFetch = false;
          });
        }
      } else {
        setState(() {
          isFetch = false;
        });
      }
    }).catchError((e) {
      print(e);
      setState(() {
        isFetch = false;
      });
    });
  }

//  Future<void> _onRefresh() {
//    hitBannerUrl();
//    hitService();
//    _refreshIndicatorKey.currentState.show();
//  }

  // void hitNavigator(context, category_name, ui_type, vendor_category_id) async {
  //   print('${ui_type}');
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   // if (ui_type == "grocery" || ui_type == "Grocery" || ui_type == "1") {
  //   //
  //   // }
  //   Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) =>
  //               StoresPage(category_name, vendor_category_id,ui_type))).then((value) {
  //     getCartCount();
  //   });
  //   // else if(ui_type == "resturant" || ui_type == "Resturant" || ui_type == "2"){
  //   //   Navigator.push(
  //   //       context,
  //   //       MaterialPageRoute(
  //   //           builder: (context) =>Restaurant("GoMarket Resturant"))).then((value) {
  //   //     getCartCount();
  //   //   });
  //   // }
  // }
  void hitNavigator(context, category_name, ui_type, vendor_category_id) async {
    print('${ui_type}');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (ui_type == "grocery" || ui_type == "Grocery" || ui_type == "1") {
      prefs.setString("vendor_cat_id", '${vendor_category_id}');
      prefs.setString("ui_type", '${ui_type}');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  StoresPage(category_name, vendor_category_id)));
    } else if (ui_type == "resturant" ||
        ui_type == "Resturant" ||
        ui_type == "2") {
      prefs.setString("vendor_cat_id", '${vendor_category_id}');
      prefs.setString("ui_type", '${ui_type}');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Restaurant("Urbanby Resturant"))
          // builder: (context) => ParcelDetails())
          );
    } else if (ui_type == "pharmacy" ||
        ui_type == "Pharmacy" ||
        ui_type == "3") {
      prefs.setString("vendor_cat_id", '${vendor_category_id}');
      prefs.setString("ui_type", '${ui_type}');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  StoresPharmaPage('${category_name}', vendor_category_id)));
    } else if (ui_type == "parcal" || ui_type == "Parcal" || ui_type == "4") {
      prefs.setString("vendor_cat_id", '${vendor_category_id}');
      prefs.setString("ui_type", '${ui_type}');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ParcalStoresPage('${vendor_category_id}')));
    }
  }

  void getBackResult(latss, lngss) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setString("lat", "29.006057");
    prefs.setString("lat", latss.toStringAsFixed(8));
    // prefs.setString("lng", "77.027535");
    prefs.setString("lng", lngss.toStringAsFixed(8));
    double lats = double.parse(prefs.getString('lat'));
    double lngs = double.parse(prefs.getString('lng'));
    // lats = 29.006057;
    // lngs = 77.027535;
    final coordinates = new Coordinates(lats, lngs);
    await Geocoder.local
        .findAddressesFromCoordinates(coordinates)
        .then((value) {
      print(
          "${value[0].featureName} : ${value[0].countryName} : ${value[0].locality} : ${value[0].subAdminArea} : ${value[0].adminArea} : ${value[0].subLocality} : ${value[0].addressLine}");
      if (value[0].locality != null && value[0].locality.isNotEmpty) {
        setState(() {
          this.lat = lat;
          this.lng = lng;
          String city = '${value[0].locality}';
          cityName = '${city.toUpperCase()} (${value[0].subLocality})';
        });
      } else if (value[0].subAdminArea != null &&
          value[0].subAdminArea.isNotEmpty) {
        this.lat = lat;
        this.lng = lng;
        String city = '${value[0].subAdminArea}';
        cityName = '${city.toUpperCase()}';
      }
      hitService();
      hitBannerUrl();
    });
  }

  Widget _searchWidget() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.1, .1), //(x,y)
              blurRadius: 3.0,
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: "Search",
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey,
            ),
            // suffixIcon: Icon(Icons.sort)
          ),
        ),
      ),
    );
  }

  Widget _bigCategoryWidget() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 9),
            child: Text(
              "Instant delivery to your doorstep.",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 12,
          ),
          MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 0.0,
              mainAxisSpacing: 0.0,
              childAspectRatio: 100 /80,
              controller: ScrollController(keepScrollOffset: false),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              children: (nearStores != null && nearStores.length > 0)
                  ? List.generate(4, (index) {
                      return Padding(
                        padding: const EdgeInsets.all(2),
                        child: InkWell(
                          child: Stack(
                            children: [
                              ReusableCard(
                                cardChild: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(3)),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        '${imageBaseUrl}${nearStores[index].category_image}',
                                      ),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                onPress: () {
                                  print("Pressed");
                                  hitNavigator(
                                      context,
                                      nearStores[index].category_name,
                                      nearStores[index].ui_type,
                                      nearStores[index].vendor_category_id);
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      '${nearStores[index].category_name}',
                                      style: TextStyle(
                                          color: kWhiteColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 19.0),
                                    )),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList()
                  : nearStoresShimmer.map((e) {
                      return ReusableCard(

                          cardChild: Shimmer(

                            duration: Duration(seconds: 2),
                            //Default value
                            color:kMainColor,

                            //Default value
                            enabled: true,

                            //Default value
                            direction: ShimmerDirection.fromLTRB(),
                            //Default Value
                            child: Container(
                              decoration: BoxDecoration(
                                color:kTransparentColor,

                                //color: Colors.transparent,
                              ),
                            ),
                          ),
                          onPress: () {});
                    }).toList(),
            ),

          ),



        ],

      ),

    );



  }
  showAlertDialog(BuildContext context, ) {
    // set up the buttons
    // Widget no = FlatButton(
    //   padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
    //   child: Text("OK"),
    //   onPressed: () {
    //     Navigator.of(context, rootNavigator: true).pop('dialog');
    //   },
    // );

    Widget clear = GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        deleteAllRestProduct(context);
      },
      child: Card(
        elevation: 2,
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(
              color: kGreenColor,
              borderRadius: BorderRadius.all(Radius.circular(8))),
          child: Text(
            'Update',
            style: TextStyle(fontSize: 13, color: kWhiteColor),
          ),
        ),
      ),
    );

   /* Widget no = GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
      child: Card(
        elevation: 2,
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(
              color: kGreenColor,
              borderRadius: BorderRadius.all(Radius.circular(8))),
          child: Text(
            'No',
            style: TextStyle(fontSize: 13, color: kWhiteColor),
          ),
        ),
      ),
    );*/

    // Widget yes = FlatButton(
    //   padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
    //   child: Text("OK"),
    //   onPressed: () {
    //     Navigator.of(context, rootNavigator: true).pop('dialog');
    //   },
    // );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("New update is available"),
      content: Text(
          "Hi, \n New update of this application is available on palystore, you can update the app by clicking Update"),
      actions: [clear],
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  void deleteAllRestProduct(
      BuildContext context) async {
    launch("https://play.google.com/store/apps/details?id=" + "com.urbanservyces.user");
    /*try {
      launch("market://details?id=" + appPackageName);
    } on PlatformException catch(e) {
      launch("https://play.google.com/store/apps/details?id=" + appPackageName);
    } finally {
      launch("https://play.google.com/store/apps/details?id=" + appPackageName);
    }*/
  }

}


