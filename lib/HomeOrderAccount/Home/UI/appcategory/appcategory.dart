import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:user/Components/card_content.dart';
import 'package:user/Components/custom_appbar.dart';
import 'package:user/Components/reusable_card.dart';
import 'package:user/Pages/items.dart';
import 'package:user/Routes/routes.dart';
import 'package:user/Themes/colors.dart';
import 'package:user/baseurl/baseurl.dart';
import 'package:user/bean/categorylist.dart';
import 'package:user/databasehelper/dbhelper.dart';
import 'package:user/dealofferpack/dealproduct.dart';
import 'package:toast/toast.dart';
import 'package:user/bean/vendorbanner.dart';
import 'package:carousel_slider/carousel_slider.dart';

class AppCategory extends StatefulWidget {
  final String pageTitle;
  final dynamic vendor_id;
  final dynamic distance;

  AppCategory(this.pageTitle, this.vendor_id, this.distance) {
    setStoreName(pageTitle);
  }

  void setStoreName(pageTitle) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("store_name", pageTitle);
  }

  @override
  State<StatefulWidget> createState() {
    return AppCategoryState(pageTitle, vendor_id);
  }
}

class AppCategoryState extends State<AppCategory> {
  final String pageTitle;
  final dynamic vendor_id;
  bool isCartCount = false;
  bool isFetch = false;
  int cartCount = 0;

  bool isNoCategoryTrue = false;

  AppCategoryState(this.pageTitle, this.vendor_id);
  List<VendorBanner> listImage = [];
  List<String> listImages = ['', '', '', '', ''];
  List<CategoryList> categoryLists = [];
  List<CategoryList> categoryListsSearch = [];
  List<CategoryList> categoryListsDemo = [
    CategoryList('', '', '', '', '', '', '', ''),
    CategoryList('', '', '', '', '', '', '', ''),
    CategoryList('', '', '', '', '', '', '', ''),
    CategoryList('', '', '', '', '', '', '', ''),
    CategoryList('', '', '', '', '', '', '', ''),
    CategoryList('', '', '', '', '', '', '', '')
  ];

  @override
  void initState() {
    super.initState();
    hitBannerUrl();
    Timer(Duration(seconds: 1), () {
      hitServices();
    });
    getCartCount();
  }

  void hitBannerUrl() async {
    setState(() {
      isFetch = true;
    });
    var url = vendorBanner;
    http.post(url, body: {'vendor_id': '$vendor_id'}).then((value) {
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
        print('Response Body: - ${value.body}');
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(value.body)['data'] as List;
          List<VendorBanner> tagObjs = tagObjsJson
              .map((tagJson) => VendorBanner.fromJson(tagJson))
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
      }
    }).catchError((e) {
      setState(() {
        isFetch = false;
      });
      print(e);
    });
  }

  void getCartCount() {
    DatabaseHelper db = DatabaseHelper.instance;
    db.queryRowCount().then((value) {
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

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(190.0),
        child: CustomAppBar(
          titleWidget: Text(
            pageTitle,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          actions: [
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
          ],
          bottom: PreferredSize(
              child: Column(
                children: [
                  // MediaQuery.of(context).size.width * 0.85
                  Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: 52,
                    padding: EdgeInsets.only(left: 5),
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                        color: scaffoldBgColor,
                        borderRadius: BorderRadius.circular(50)),
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.search,
                          color: kHintColor,
                        ),
                        hintText: 'Search category...',
                      ),
                      cursorColor: kMainColor,
                      autofocus: false,
                      onChanged: (value) {
                        setState(() {
                          categoryLists = categoryListsSearch
                              .where((element) => element.category_name
                              .toString()
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 5,),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DealProducts(pageTitle, '', '',
                                  widget.distance, widget.vendor_id))).then((value) {
                        getCartCount();
                      });
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Card(
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      elevation: 0.1,
                      child: Container(
                        height: 90,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(3)),
                          image: DecorationImage(
                            image: NetworkImage(
                                imageBaseUrl+'images/storbanners/banner.jpg'),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      ),
                    ),

                ],
              ),
              preferredSize:
                  Size(MediaQuery.of(context).size.width, 120)),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height-190,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          primary: true,
          child: Column(
            children: [
              Visibility(
                visible: (!isFetch && listImage.length == 0) ? false : true,
                child: Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 5),
                  child: CarouselSlider(
                      options: CarouselOptions(
                        height: 170.0,
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
                                  elevation: 5,
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
//                                child: CachedNetworkImage(
//                                  fit: BoxFit.fill,
//                                  imageUrl: imageBaseUrl + e.banner_image,
//                                  progressIndicatorBuilder: (context, url, downloadProgress) =>
//                                      CircularProgressIndicator(value: downloadProgress.progress),
//                                  errorWidget: (context, url, error) => Image.asset('images/logos/logo_user.png'),
//                                ),
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
              (categoryLists != null && categoryLists.length > 0)
                  ? Padding(
                padding: EdgeInsets.only(top: 10,left: 5,right: 5),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 2.0,
                  mainAxisSpacing: 2.0,
                  controller: ScrollController(keepScrollOffset: false),
                  shrinkWrap: true,
                  primary: false,
                  scrollDirection: Axis.vertical,
                  children: categoryLists.map((e) {
                    return GestureDetector(
                      onTap: () {
                        hitNavigator(context, pageTitle, e.category_name,
                            e.category_id, widget.distance);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 3,horizontal: 3),
                        color: kCardBackgroundColor,
                        alignment: Alignment.center,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: kWhiteColor
                          ),
                          // child: Column(
                          //   // alignment: Alignment.center,
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   crossAxisAlignment: CrossAxisAlignment.center,
                          //   children: <Widget>[
                          //     SizedBox(
                          //       child: Image.network('${imageBaseUrl+e.category_image}',height: 70.3,width: 80,),
                          //       height: 70.3,
                          //       width: 80,
                          //     ),
                          //     SizedBox(
                          //       height: 5,
                          //     ),
                          //     Align(
                          //       alignment: Alignment.bottomCenter,
                          //       child: Text(
                          //         e.category_name,
                          //         textAlign: TextAlign.center,
                          //         style: TextStyle(
                          //             color: black_color,
                          //             fontWeight: FontWeight.w200,
                          //             fontSize: 13
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(top: 10,bottom: 10.0),
                                child: Image.network('${imageBaseUrl}${e.category_image}',height: 100,width: 120,),
                              ),
                              Expanded(
                                child: Text(
                                  e.category_name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: black_color,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  //     : categoryListsDemo.map((e) {
                  //   return ReusableCard(
                  //       cardChild: Shimmer(
                  //         duration: Duration(seconds: 3),
                  //         //Default value
                  //         color: Colors.white,
                  //         //Default value
                  //         enabled: true,
                  //         //Default value
                  //         direction: ShimmerDirection.fromLTRB(),
                  //         //Default Value
                  //         child: Container(
                  //           color: kTransparentColor,
                  //         ),
                  //       ),
                  //       onPress: () {});
                  // }).toList(),
                ),
              )
                  : (isNoCategoryTrue != true)
                  ? Padding(
                  padding: EdgeInsets.only(
                      left: 10, right: 10, top: 20, bottom: 30),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 2.0,
                    mainAxisSpacing: 2.0,
                    controller: ScrollController(keepScrollOffset: false),
                    shrinkWrap: true,
                    primary: false,
                    scrollDirection: Axis.vertical,
                    children: categoryListsDemo.map((e) {
                      return Container(
                        padding: EdgeInsets.symmetric(vertical: 3,horizontal: 3),
                        color: kCardBackgroundColor,
                        alignment: Alignment.center,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: kWhiteColor
                          ),
                          child: Container(
                            color: white_color,
                            height: 120,
                            child: Shimmer(
                              duration: Duration(seconds: 2),
                              //Default value
                              color: kMainColor,
                              //Default value
                              enabled: true,
                              //Default value
                              direction: ShimmerDirection.fromLTRB(),
                              //Default Value
                              child: Container(
                                height: 120,
                                color: kTransparentColor,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  )
              )
                  : Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 120,
                alignment: Alignment.center,
                child: Text(
                  'No category found for this store ${widget.pageTitle}',
                  style: TextStyle(
                      color: kMainColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void hitServices() async {
    var url = categoryList;
    var response =
        await http.post(url, body: {'vendor_id': vendor_id.toString()});
    print("appcat : ${response.body.toString()}");
    try {
      if (response.statusCode == 200) {
        print('Response Body: - ${response.body}');
        var jsonData = jsonDecode(response.body);
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(response.body)['data'] as List;
          List<CategoryList> tagObjs = tagObjsJson
              .map((tagJson) => CategoryList.fromJson(tagJson))
              .toList();
          setState(() {
            isNoCategoryTrue = false;
            categoryLists.clear();
            categoryListsSearch.clear();
            categoryLists = tagObjs;
            categoryListsSearch = List.from(categoryLists);
          });
        } else {
          setState(() {
            isNoCategoryTrue = true;
            categoryLists.clear();
            categoryLists = [];
          });
          Toast.show('No Category found!', context,
              duration: Toast.LENGTH_LONG);
        }
      }
    } on Exception catch (_) {
      Toast.show('No Category found!', context, duration: Toast.LENGTH_LONG);
      Timer(Duration(seconds: 5), () {
        hitServices();
      });
    }
  }

  void hitNavigator(context, pageTitle, category_name, category_id, distance) {
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ItemsPage(pageTitle, category_name, category_id, distance)))
        .then((value) {
      getCartCount();
    });
  }
}
