import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:user/Components/custom_appbar.dart';
import 'package:user/Components/search_bar.dart';
import 'package:user/Routes/routes.dart';
import 'package:user/Themes/colors.dart';
import 'package:user/Themes/style.dart';
import 'package:user/baseurl/baseurl.dart';
import 'package:user/bean/productlistvarient.dart';
import 'package:user/bean/subcategorylist.dart';
import 'package:user/databasehelper/dbhelper.dart';
import 'package:user/singleproductpage/singleproductpage.dart';
import 'package:user/pharmacy/pharmabean/pharmahomecategory.dart';

//List<String> list = ['1 kg', '500 g', '250 g'];

class PharmaItemPage extends StatefulWidget {
  final dynamic vendorName;
  final dynamic vendor_id;
  final dynamic deliveryRange;
  final dynamic distance;

  PharmaItemPage(
      this.vendorName, this.vendor_id, this.deliveryRange, this.distance);

  @override
  _ItemsPharmaPageState createState() => _ItemsPharmaPageState();
}

class _ItemsPharmaPageState extends State<PharmaItemPage>
    with SingleTickerProviderStateMixin {
  List<Tab> tabs = <Tab>[];
  dynamic currency = '';
  bool isCartCount = false;
  var cartCount = 0;
  dynamic totalAmount = 0.0;
  TabController tabController;
  bool addMinus = false;
  bool isFetchList = false;
  bool isFetch = false;
  List<CategoryPharmacy> categoryList = [];
  List<CategoryPharmacy> categoryList2 = [];
  List<CategoryPharmacy> categoryList3 = [];
  List<CategoryPharmacy> categoryList3Search = [];

  @override
  void initState() {
    super.initState();
    hitPharmacyItem();
    getCartCount();
  }

  @override
  void dispose() {
    super.dispose();
  }


  //
  void hitPharmacyItem() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      isFetch = true;
      currency = preferences.getString("curency");
    });
    // print('${widget.item.vendor_id}');
    var url = pharmacy_homecategory;
    http.post(url, body: {
      'vendor_id': '${widget.vendor_id}'
      // 'vendor_id': '24'
    }).then((response) {
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        print('Response Body: - ${response.body}');
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(response.body)['data'] as List;
          List<CategoryPharmacy> tagObjs = tagObjsJson
              .map((tagJson) => CategoryPharmacy.fromJson(tagJson))
              .toList();
          if (tagObjs != null && tagObjs.length > 0) {
            setState(() {
              isFetch = false;
              tabs.clear();
              categoryList.clear();
              categoryList2.clear();
              categoryList3.clear();
              categoryList3Search.clear();
              categoryList = List.from(tagObjs);
              List<CategoryPharmacy> categoryListNew = List.from(tagObjs);
              categoryList2 = categoryListNew.toSet().toList();
              List<Tab> tabss = <Tab>[];
              for(CategoryPharmacy parh in categoryList2){
                tabss.add(Tab(
                  text: parh.cat_name,
                ));
              }
              tabs = tabss;
              tabController = TabController(length: tabs.length, vsync: this);
              tabController.addListener(() {
                if(!tabController.indexIsChanging){
                  setState(() {
                    categoryList3 = [];
                    categoryList3Search = [];
                    categoryList3 = categoryList.where((element) => element.resturant_cat_id == categoryList2[tabController.index].resturant_cat_id && element.product_name!=null).toList();
                    categoryList3Search = List.from(categoryList3);
                    setList(categoryList3);
                  });
                }
              });
              // categoryList3 = [];
              // categoryList3Search = [];
              categoryList3 = categoryList.where((element) => element.resturant_cat_id == categoryList2[0].resturant_cat_id).toList();
              categoryList3Search = List.from(categoryList3);
              setList(categoryList3);
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

  void getCartCount() {
    DatabaseHelper db = DatabaseHelper.instance;
    db.queryRowPharmaCount().then((value) {
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

    getCatC();
  }


  void getCatC() async {
    DatabaseHelper db = DatabaseHelper.instance;
    db.calculateTotalpharma().then((value) {
      db.calculateTotalPharmaAdon().then((valued){
        var tagObjsJson = value as List;
        var tagObjsJsond = valued as List;
        setState(() {
          if (value != null) {
            dynamic totalAmount_1 = tagObjsJson[0]['Total'];
            print('T--${totalAmount_1}');
            if(valued!=null){
              dynamic totalAmount_2 = tagObjsJsond[0]['Total'];
              print('T--${totalAmount_2}');
              if (totalAmount_2 == null) {
                if (totalAmount_1 == null) {
                  totalAmount = 0.0;
                } else {
                  totalAmount = double.parse('${totalAmount_1}');
                }
              } else {
                totalAmount = double.parse('${totalAmount_1}')+double.parse('${totalAmount_2}');
              }
            }else{
              if (totalAmount_1 == null) {
                totalAmount = 0.0;
              } else {
                totalAmount = double.parse('${totalAmount_1}');
              }
            }

          } else {
            totalAmount = 0.0;
//          deliveryCharge = 0.0;
          }
        });
      });


    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(196.0),
          child: CustomAppBar(
            titleWidget: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('${widget.vendorName}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .copyWith(color: kMainTextColor)),
                  SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.location_on,
                        color: kIconColor,
                        size: 10,
                      ),
                      SizedBox(width: 10.0),
                      Text(
                          '${double.parse('${widget.distance}').toStringAsFixed(2)} km ',
                          style: Theme.of(context).textTheme.overline),
                      Text('|', style: Theme.of(context).textTheme.overline),
                      Text('Delivery range - ${widget.deliveryRange} km',
                          style: Theme.of(context).textTheme.overline),
                      Spacer(),
                    ],
                  ),
                ],
              ),
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
                            // Navigator.pushNamed(context, PageRoutes.pharmacart)
                            //     .then((value) {
                            //   // setList(productVarientList);
                            //   getCartCount();
                            // });
                            hitViewCart(context);
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
              preferredSize: Size.fromHeight(0.0),
              child: Column(
                children: <Widget>[
                  CustomSearchBar(
                    hint: 'Search item...',
                    onChanged: (value) {
                      setState(() {
                        categoryList3 = categoryList3Search
                            .where((element) => element.product_name
                                .toString()
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TabBar(
                    tabs: tabs,
                    isScrollable: true,
                    labelColor: kMainColor,
                    unselectedLabelColor: kLightTextColor,
                    controller: tabController,
                    indicatorPadding: EdgeInsets.symmetric(horizontal: 24.0),
                  ),
                  Divider(
                    color: kCardBackgroundColor,
                    thickness: 8.0,
                  )
                ],
              ),
            ),
          ),
        ),
        body: DefaultTabController(
          length: tabs.length,
          child: TabBarView(
            controller: tabController,
            children: tabs.map((Tab tab) {
              return Stack(
                children: <Widget>[
                  Positioned(
                      top: 0.0,
                      width: MediaQuery.of(context).size.width,
                      height: isCartCount
                          ? (MediaQuery.of(context).size.height - 280)
                          : (MediaQuery.of(context).size.height - 220),
                      child: (!isFetchList &&
                              categoryList3 != null &&
                          categoryList3.length > 0)
                          ? ListView.separated(
                              itemCount: categoryList3.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    // Navigator.of(context).push(
                                    //     MaterialPageRoute(builder: (context) {
                                    //   return SingleProductPage(
                                    //       productVarientList[index], currency);
                                    // })).then((value) {
                                    //   setList(productVarientList);
                                    //   getCartCount();
                                    // });
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Stack(
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 20.0,
                                                    top: 30.0,
                                                    right: 14.0),
                                                child:
                                                (categoryList3 != null &&
                                                    categoryList3.length >
                                                        0)
                                                    ? Image.network( '${Uri.parse('${imageBaseUrl}${categoryList3[index].product_image}')}',
//                                scale: 2.5,
                                                  height: 93.3,
                                                  width: 93.3,
                                                )
                                                    : Image(
                                                  image: AssetImage(
                                                      'images/logos/logo_user.png'),
                                                  height: 93.3,
                                                  width: 93.3,
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Container(
                                                      padding: EdgeInsets.only(
                                                          right: 20),
                                                      child: Text(
                                                          categoryList3[index]
                                                              .product_name,
                                                          style:
                                                          bottomNavigationTextStyle
                                                              .copyWith(
                                                              fontSize:
                                                              15)),
                                                    ),
                                                    SizedBox(
                                                      height: 8.0,
                                                    ),
                                                    Text(
                                                        '$currency ${(categoryList3[index].variant.length > 0) ? categoryList3[index].variant[categoryList3[
                                                        index].selectPos].price : 0}',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .caption),
                                                    SizedBox(
                                                      height: 20.0,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Positioned(
                                            left: 120,
                                            bottom: 5,
                                            child: Container(
                                              height: 30.0,
                                              padding:
                                              EdgeInsets.symmetric(horizontal: 12.0),
                                              decoration: BoxDecoration(
                                                color: kCardBackgroundColor,
                                                borderRadius: BorderRadius.circular(30.0),
                                              ),
                                              child: (categoryList3[index].variant!=null && categoryList3[index].variant.length>0)?DropdownButton<MedeniniVarient>(
                                                  underline: Container(
                                                    height: 0.0,
                                                    color: kCardBackgroundColor,
                                                  ),
                                                  value: categoryList3[index].variant[
                                                  categoryList3[index].selectPos],
                                                  items: categoryList3[index].variant.map((e) {
                                                    return DropdownMenuItem<MedeniniVarient>(
                                                      child: Text(
                                                        '${e.quantity} ${e.unit}',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .caption,
                                                      ),
                                                      value: e,
                                                    );
                                                  }).toList(),
                                                  onChanged: (vale) {
                                                    setState(() {
                                                      int indexd = categoryList3[index].variant.indexOf(vale);
                                                      if (indexd != -1) {
                                                        categoryList3[index].selectPos = indexd;
                                                        DatabaseHelper db = DatabaseHelper.instance;
                                                        db.getVarientPharmaCount( categoryList3[index].variant[categoryList3[index].selectPos].variant_id).then((value) {
                                                          print('print t val $value');
                                                          if (value == null) {
                                                            setState(() {
                                                              categoryList3[index].addOnQty = 0;
                                                            });
                                                          } else {
                                                            setState(() {
                                                              categoryList3[index].addOnQty = value;
                                                              isCartCount = true;
                                                            });
                                                          }
                                                        });
                                                        for(int j=0;j<categoryList3[index].addons.length;j++){
                                                          db.getPharmaCountAddon(categoryList3[index].addons[j].addon_id,categoryList3[index].variant[categoryList3[index].selectPos].variant_id).then((valued){
                                                            if(valued!=null && valued>0){
                                                              setState(() {
                                                                categoryList3[index].addons[j].isAdd = true;
                                                              });
                                                            }else{
                                                              setState(() {
                                                                categoryList3[index].addons[j].isAdd = false;
                                                              });
                                                            }
                                                          });
                                                        }
                                                      }
                                                    });
                                                  }):Text(''),
                                              // Row(
                                              //   children: <Widget>[
                                              //     Text(
                                              //       '${(productList[index].varient_details.length>0)?productList[index].varient_details[0].quantity:''} ${(productList[index].varient_details.length>0)?productList[index].varient_details[0].unit:''}',
                                              //       style: Theme.of(context)
                                              //           .textTheme
                                              //           .caption,
                                              //     ),
                                              //     SizedBox(
                                              //       width: 8.0,
                                              //     ),
                                              //     Icon(
                                              //       Icons.keyboard_arrow_down,
                                              //       color: kMainColor,
                                              //     ),
                                              //   ],
                                              // ),
                                            ),
                                          ),
                                          Positioned(
                                            height: 30,
                                            right: 20.0,
                                            bottom: 5,
                                            child:
                                            (categoryList3[index].addOnQty== 0 ? Container(
                                              height: 30.0,
                                              child: FlatButton(
                                                child: Text(
                                                  'Add',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .caption
                                                      .copyWith(
                                                      color:
                                                      kMainColor,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold),
                                                ),
                                                textTheme: ButtonTextTheme
                                                    .accent,
                                                onPressed: () {
                                                  setState(() {
                                                    categoryList3[index].addOnQty++;
                                                    print('${categoryList3[index].addOnQty}');
                                                    addOrMinusProduct(
                                                        categoryList3[
                                                        index].product_name,
                                                        categoryList3[
                                                        index].variant[categoryList3[
                                                        index].selectPos]
                                                            .unit,
                                                        double.parse(
                                                            '${categoryList3[index].variant[categoryList3[
                                                            index].selectPos].price}'),
                                                        int.parse(
                                                            '${categoryList3[index].variant[categoryList3[
                                                            index].selectPos].quantity}'),
                                                        categoryList3[index].addOnQty,
                                                        categoryList3[index].product_image,
                                                        categoryList3[index].variant[categoryList3[
                                                        index].selectPos].variant_id);
                                                  });
                                                },
                                              ),
                                            )
                                                : Container(
                                              height: 30.0,
                                              padding:
                                              EdgeInsets.symmetric(
                                                  horizontal: 11.0),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: kMainColor),
                                                borderRadius:
                                                BorderRadius.circular(
                                                    30.0),
                                              ),
                                              child: Row(
                                                children: <Widget>[
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        categoryList3[index]
                                                            .addOnQty--;
                                                        addOrMinusProduct(
                                                            categoryList3[
                                                            index]
                                                                .product_name,
                                                            categoryList3[
                                                            index]
                                                                .variant[categoryList3[
                                                            index].selectPos]
                                                                .unit,
                                                            double.parse(
                                                                '${categoryList3[index]
                                                                    .variant[categoryList3[
                                                                index].selectPos]
                                                                    .price}'),
                                                            int.parse(
                                                                '${categoryList3[index]
                                                                    .variant[categoryList3[
                                                                index].selectPos]
                                                                    .quantity}'),
                                                            categoryList3[index]
                                                                .addOnQty,
                                                            categoryList3[index]
                                                                .product_image,
                                                            categoryList3[index]
                                                                .variant[categoryList3[
                                                            index].selectPos]
                                                                .variant_id);
                                                      });
                                                    },
                                                    child: Icon(
                                                      Icons.remove,
                                                      color: kMainColor,
                                                      size: 20.0,
                                                      //size: 23.3,
                                                    ),
                                                  ),
                                                  SizedBox(width: 8.0),
                                                  Text(
                                                      categoryList3[index].addOnQty
                                                          .toString(),
                                                      style: Theme.of(
                                                          context)
                                                          .textTheme
                                                          .caption),
                                                  SizedBox(width: 8.0),
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        categoryList3[index]
                                                            .addOnQty++;
                                                        addOrMinusProduct(
                                                            categoryList3[
                                                            index]
                                                                .product_name,
                                                            categoryList3[
                                                            index]
                                                                .variant[categoryList3[
                                                            index].selectPos]
                                                                .unit,
                                                            double.parse(
                                                                '${categoryList3[index]
                                                                    .variant[categoryList3[
                                                                index].selectPos]
                                                                    .price}'),
                                                            int.parse(
                                                                '${categoryList3[index]
                                                                    .variant[categoryList3[
                                                                index].selectPos]
                                                                    .quantity}'),
                                                            categoryList3[index]
                                                                .addOnQty,
                                                            categoryList3[index]
                                                                .product_image,
                                                            categoryList3[index]
                                                                .variant[categoryList3[
                                                            index].selectPos]
                                                                .variant_id);
                                                      });
                                                    },
                                                    child: Icon(
                                                      Icons.add,
                                                      color: kMainColor,
                                                      size: 20.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                            // : Container(
                                            //     child: Text(
                                            //       'Out off stock',
                                            //       style: Theme.of(context)
                                            //           .textTheme
                                            //           .caption
                                            //           .copyWith(
                                            //               color: kMainColor,
                                            //               fontWeight:
                                            //                   FontWeight.bold),
                                            //     ),
                                            //   ),
//                          upDataView(productVarientList[index].data[0].varient_id, index, context)
                                          ),
                                        ],
                                      ),
                                      Visibility(
                                        visible:(categoryList3[index].addons!=null && categoryList3[index].addons.length>0)?true:false,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(left: 30,bottom: 20,top: 20),
                                              child: Text(
                                                'Addons',
                                                style: headingStyle,
                                              ),
                                            ),
                                            ListView.separated(
                                              itemCount:categoryList3[index].addons.length,
                                              shrinkWrap:true,
                                              primary:false,
                                              itemBuilder: (context,i){
                                                return Padding(
                                                  padding: EdgeInsets.only(right: 30, left: 30),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: <Widget>[
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: <Widget>[
                                                          InkWell(
                                                            onTap: () async {
                                                              print('${categoryList3[index].addOnQty}');
                                                              if (categoryList3[index].addOnQty > 0) {
                                                                DatabaseHelper db = DatabaseHelper.instance;
                                                                db.getPharmaCountAddon('${categoryList3[index].addons[i].addon_id}','${categoryList3[index].variant[categoryList3[index].selectPos].variant_id}').then((value) {
                                                                  print('addon countv $value');
                                                                  if (value != null && value > 0) {
                                                                    deleteAddOn(index,i,db);
                                                                  } else {
                                                                    var vae = {
                                                                      DatabaseHelper.varientId: '${categoryList3[index].variant[categoryList3[index].selectPos].variant_id}',
                                                                      DatabaseHelper.addonid: '${categoryList3[index].addons[i].addon_id}',
                                                                      DatabaseHelper.price: categoryList3[index].addons[i].addon_price,
                                                                      DatabaseHelper.addonName: categoryList3[index].addons[i].addon_name
                                                                    };
                                                                    db.insertPharmaAddOn(vae).then((value) {
                                                                      print('addon add $value');
                                                                      if (value != null && value>0) {
                                                                        setState((){
                                                                          categoryList3[index].addons[i].isAdd = true;
                                                                        });
                                                                        getCatC();
                                                                      }
                                                                      else {
                                                                        setState((){
                                                                          categoryList3[index].addons[i].isAdd = false;
                                                                        });
                                                                        getCatC();
                                                                      }
                                                                      return value;
                                                                    }).catchError((e) {
                                                                      return null;
                                                                    });
                                                                  }
                                                                }).catchError((e) {
                                                                  print(e);
                                                                });
                                                              } else {
                                                                Toast.show(
                                                                    'Add first product to add addon!', context,
                                                                    duration: Toast.LENGTH_SHORT);
                                                              }
                                                            },
                                                            child: Container(
                                                              width: 26.0,
                                                              height: 26.0,
                                                              decoration: BoxDecoration(
                                                                  color: (categoryList3[index].addons[i].isAdd) ? kMainColor : kWhiteColor,
                                                                  borderRadius: BorderRadius.circular(13.0),
                                                                  border: Border.all(
                                                                      width: 1.0,
                                                                      color: kHintColor.withOpacity(0.7))),
                                                              child: Icon(Icons.check,
                                                                  color: kWhiteColor, size: 15.0),
                                                            ),
                                                          ),
                                                          // widthSpace,
                                                          // Text(
                                                          //   'Size $size',
                                                          //   style: listItemTitleStyle,
                                                          // ),
                                                          // widthSpace,
                                                          SizedBox(width: 10.0),
                                                          Text(
                                                            '${categoryList3[index].addons[i].addon_name}',
                                                            style: listItemTitleStyle,
                                                          ),
                                                        ],
                                                      ),
                                                      Text(
                                                        '${currency} ${categoryList3[index].addons[i].addon_price}',
                                                        style: listItemTitleStyle,
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              separatorBuilder: (context,d){
                                                return Divider(
                                                  color: kCardBackgroundColor,
                                                  thickness: 6.7,
                                                );
                                              },
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return SizedBox(
                                  height: 5,
                                );
                              },
                            )
                          : Container(
                              height: MediaQuery.of(context).size.height / 2,
                              width: MediaQuery.of(context).size.width,
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  isFetchList
                                      ? CircularProgressIndicator()
                                      : Container(
                                          width: 0.5,
                                        ),
                                  isFetchList
                                      ? SizedBox(
                                          width: 10,
                                        )
                                      : Container(
                                          width: 0.5,
                                        ),
                                  Text(
                                    (!isFetchList)
                                        ? 'No product available for this category'
                                        : 'Fetching Products..',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: kMainTextColor),
                                  )
                                ],
                              ),
                            )
                      // (!isFetchList)?Container(
                      //         alignment: Alignment.center,
                      //         padding: EdgeInsets.symmetric(horizontal: 30),
                      //         child: Text(
                      //           'No Data available for this category',
                      //           textAlign: TextAlign.center,
                      //           style: TextStyle(
                      //               fontSize: 25,
                      //               color: kMainColor,
                      //               fontWeight: FontWeight.w600),
                      //         ),
                      //       ):,
                      ),
                  Positioned(
                    bottom: 0.0,
                    width: MediaQuery.of(context).size.width,
                    child: Visibility(
                      visible: isCartCount,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            children: <Widget>[
                              Image.asset(
                                'images/icons/ic_cart wt.png',
                                height: 19.0,
                                width: 18.3,
                              ),
                              SizedBox(width: 20.7),
                              Text(
                                '$cartCount items | $currency $totalAmount',
                                style: bottomBarTextStyle.copyWith(
                                    fontSize: 15, fontWeight: FontWeight.w500),
                              ),
                              Spacer(),
                              FlatButton(
                                color: Colors.white,
                                onPressed: () => hitViewCart(context),
                                child: Text(
                                  'View Cart',
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption
                                      .copyWith(
                                          color: kMainColor,
                                          fontWeight: FontWeight.bold),
                                ),
                                textTheme: ButtonTextTheme.accent,
                                disabledColor: Colors.white,
                              ),
                            ],
                          ),
                          color: kMainColor,
                          height: 60.0,
                        ),
                      ),
                    ),
                  )
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void deleteAddOn(parentindex,childindex,DatabaseHelper db) async {
    await db.deleteAddOnIdPharmaWithVid('${categoryList3[parentindex].addons[childindex].addon_id}','${categoryList3[parentindex].variant[categoryList3[parentindex].selectPos].variant_id}').then((value) {
      print('addon delete $value');
      if (value != null && value>0) {
        setState((){
          categoryList3[parentindex].addons[childindex].isAdd = false;
        });
      }
      else {
        setState((){
          categoryList3[parentindex].addons[childindex].isAdd = true;
        });
      }
      getCatC();
    }).catchError((e) {
      print(e);
    });
  }

  void addOrMinusProduct(product_name, unit, price, quantity, itemCount,
      varient_image, varient_id) async {
    DatabaseHelper db = DatabaseHelper.instance;
    db.getPharmaCount(varient_id).then((value) {
      print('value d - $value');
      var vae = {
        DatabaseHelper.productId: '1',
        DatabaseHelper.productName: product_name,
        DatabaseHelper.price: (double.parse('${price}') * itemCount),
        DatabaseHelper.unit: unit,
        DatabaseHelper.quantitiy: int.parse('${quantity}'),
        DatabaseHelper.addQnty: itemCount,
        DatabaseHelper.varientId: varient_id
      };
      if (value == 0) {
        db.insertPharmaOrder(vae);
      } else {
        if (itemCount == 0) {
          db.deletePharmaProduct(varient_id).then((value) {
            db.deletePharmaAddOn(varient_id);
          });
        } else {
          db.updatePharmaProductData(vae, varient_id).then((vay) {
            print('vay - $vay');
            getCatC();
          });
        }
      }
      getCartCount();
    }).catchError((e) {
      print(e);
    });
  }



  hitViewCart(BuildContext context) {
    if (isCartCount) {
      Navigator.pushNamed(context, PageRoutes.pharmacart).then((value) {
        setList(categoryList3);
        getCartCount();
      });
    } else {
      Toast.show('No Value in the cart!', context,
          duration: Toast.LENGTH_SHORT);
    }
  }

  void setList(List<CategoryPharmacy> tagObjs) {
    for (int i = 0; i < tagObjs.length; i++) {
      if (tagObjs[i].variant.length > 0) {
        DatabaseHelper db = DatabaseHelper.instance;
        db.getVarientPharmaCount(tagObjs[i].variant[tagObjs[i].selectPos].variant_id).then((value) {
          print('print t val $value');
          if (value == null) {
            setState(() {
              tagObjs[i].addOnQty = 0;
            });
          } else {
            setState(() {
              tagObjs[i].addOnQty = value;
              isCartCount = true;
            });
            for(int j=0;j<tagObjs[i].addons.length;j++){
              db.getPharmaCountAddon(tagObjs[i].addons[j].addon_id,tagObjs[i].variant[tagObjs[i].selectPos].variant_id).then((valued){
                if(valued!=null && valued>0){
                  setState(() {
                    tagObjs[i].addons[j].isAdd = true;
                  });
                }else{
                  setState(() {
                    tagObjs[i].addons[j].isAdd = false;
                  });
                }
              });
            }
          }
        });
      }
    }
    // productVarientListSearch = List.from(productVarientList);
  }
}

// class BottomSheetWidget extends StatefulWidget {
//   final String product_name;
//   final String category_name;
//   final dynamic currency;
//   final List<MedeniniVarient> datas;
//   List<MedeniniVarient> newdatas = [];
//
//   BottomSheetWidget(
//       this.product_name, this.datas, this.category_name, this.currency) {
//     newdatas.clear();
//     newdatas.addAll(datas);
//     newdatas.removeAt(0);
//   }
//
//   @override
//   State<StatefulWidget> createState() {
//     return BottomSheetWidgetState(product_name, newdatas);
//   }
// }
//
// class BottomSheetWidgetState extends State<BottomSheetWidget> {
//   final String product_name;
//   final List<MedeniniVarient> data;
//
//   BottomSheetWidgetState(this.product_name, this.data);
//   // {
//   //   setList(data);
//   // }
//
//   // void setList(List<VarientList> tagObjs) {
//   //   for (int i = 0; i < tagObjs.length; i++) {
//   //     DatabaseHelper db = DatabaseHelper.instance;
//   //     db.getVarientCount(int.parse('${tagObjs[i].varient_id}')).then((value) {
//   //       print('print val $value');
//   //       if (value == null) {
//   //         setState(() {
//   //           tagObjs[i].add_qnty = 0;
//   //         });
//   //       } else {
//   //         setState(() {
//   //           tagObjs[i].add_qnty = value;
//   //         });
//   //       }
//   //     });
//   //   }
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       children: <Widget>[
//         Container(
//           height: 80.7,
//           color: kCardBackgroundColor,
//           padding: EdgeInsets.all(10.0),
//           child: ListTile(
//             title: Text(product_name,
//                 style: Theme.of(context)
//                     .textTheme
//                     .caption
//                     .copyWith(fontSize: 15, fontWeight: FontWeight.w500)),
//             subtitle: Text('${widget.category_name}',
//                 style:
//                     Theme.of(context).textTheme.caption.copyWith(fontSize: 15)),
//           ),
//         ),
//         ListView.separated(
//           shrinkWrap: true,
//           primary: true,
//           itemCount: data.length,
//           itemBuilder: (context, index) {
//             return Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     SizedBox(
//                       width: 20,
//                     ),
//                     Text(
//                       '${data[index].quantity} ${data[index].unit}  ${widget.currency} ${data[index].price}',
//                       style: Theme.of(context)
//                           .textTheme
//                           .caption
//                           .copyWith(fontSize: 16.7),
//                     )
//                   ],
//                 ),
//                 data[index].addOnQty == 0
//                     ? Container(
//                         height: 30.0,
//                         child: FlatButton(
//                           child: Text(
//                             'Add',
//                             style: Theme.of(context).textTheme.caption.copyWith(
//                                 color: kMainColor, fontWeight: FontWeight.bold),
//                           ),
//                           textTheme: ButtonTextTheme.accent,
//                           onPressed: () {
//                             // setState(() {
//                             //   var stock = int.parse('${data[index].stock}');
//                             //   if (stock > data[index].add_qnty) {
//                             //     data[index].add_qnty++;
//                             //     addOrMinusProduct(
//                             //         product_name,
//                             //         data[index].unit,
//                             //         double.parse('${data[index].price}'),
//                             //         int.parse('${data[index].quantity}'),
//                             //         data[index].add_qnty,
//                             //         data[index].varient_image,
//                             //         data[index].varient_id);
//                             //   } else {
//                             //     Toast.show("No more stock available!", context,
//                             //         gravity: Toast.BOTTOM);
//                             //   }
//                             // });
//                           },
//                         ),
//                       )
//                     : Container(
//                         height: 30.0,
//                         padding: EdgeInsets.symmetric(horizontal: 11.0),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: kMainColor),
//                           borderRadius: BorderRadius.circular(30.0),
//                         ),
//                         child: Row(
//                           children: <Widget>[
//                             InkWell(
//                               onTap: () {
//                                 // setState(() {
//                                 //   data[index].add_qnty--;
//                                 // });
//                                 // addOrMinusProduct(
//                                 //     product_name,
//                                 //     data[index].unit,
//                                 //     double.parse('${data[index].price}'),
//                                 //     int.parse('${data[index].quantity}'),
//                                 //     data[index].add_qnty,
//                                 //     data[index].varient_image,
//                                 //     data[index].varient_id);
//                               },
//                               child: Icon(
//                                 Icons.remove,
//                                 color: kMainColor,
//                                 size: 20.0,
//                                 //size: 23.3,
//                               ),
//                             ),
//                             SizedBox(width: 8.0),
//                             Text(data[index].addOnQty.toString(),
//                                 style: Theme.of(context).textTheme.caption),
//                             SizedBox(width: 8.0),
//                             InkWell(
//                               onTap: () {
//                                 // setState(() {
//                                 //   var stock = int.parse('${data[index].stock}');
//                                 //   if (stock > data[index].add_qnty) {
//                                 //     data[index].add_qnty++;
//                                 //     addOrMinusProduct(
//                                 //         product_name,
//                                 //         data[index].unit,
//                                 //         double.parse('${data[index].price}'),
//                                 //         int.parse('${data[index].quantity}'),
//                                 //         data[index].add_qnty,
//                                 //         data[index].varient_image,
//                                 //         data[index].varient_id);
//                                 //   } else {
//                                 //     Toast.show(
//                                 //         "No more stock available!", context,
//                                 //         gravity: Toast.BOTTOM);
//                                 //   }
//                                 // });
//                               },
//                               child: Icon(
//                                 Icons.add,
//                                 color: kMainColor,
//                                 size: 20.0,
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
//               ],
//             );
//           },
//           separatorBuilder: (context, index) {
//             return Divider(
//               height: 20,
//               color: Colors.transparent,
//             );
//           },
//         ),
// //        CheckboxGroup(
// //          labelStyle:
// //              Theme.of(context).textTheme.caption.copyWith(fontSize: 16.7),
// //          labels: list,
// //        ),
//       ],
//     );
//   }
//
//   void addOrMinusProduct(product_name, unit, price, quantity, itemCount,
//       varient_image, varient_id) async {
// //    addMinus = true;
//     DatabaseHelper db = DatabaseHelper.instance;
//     Future<int> existing = db.getcount(int.parse('${varient_id}'));
//     existing.then((value) {
//       print('value d - $value');
//       var vae = {
//         DatabaseHelper.productName: product_name,
//         DatabaseHelper.price: (price * itemCount),
//         DatabaseHelper.unit: unit,
//         DatabaseHelper.quantitiy: quantity,
//         DatabaseHelper.addQnty: itemCount,
//         DatabaseHelper.productImage: varient_image,
//         DatabaseHelper.varientId: varient_id
//       };
//       if (value == 0) {
//         db.insert(vae);
//       } else {
//         if (itemCount == 0) {
//           db.delete(int.parse('${varient_id}'));
//         } else {
//           db.updateData(vae, int.parse('${varient_id}')).then((vay) {
//             print('vay - $vay');
//           });
//         }
//       }
//     });
//   }
// }
