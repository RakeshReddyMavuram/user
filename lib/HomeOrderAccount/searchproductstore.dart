import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:user/Components/custom_appbar.dart';
import 'package:user/HomeOrderAccount/Home/UI/appcategory/appcategory.dart';
import 'package:user/Pages/items.dart';
import 'package:user/Routes/routes.dart';
import 'package:user/Themes/colors.dart';
import 'package:user/Themes/style.dart';
import 'package:user/baseurl/baseurl.dart';
import 'package:user/bean/searchlist.dart';
import 'package:user/databasehelper/dbhelper.dart';
import 'package:user/singleproductpage/singleproduct2.dart';

class SearchStore extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SearchStoreState();
  }
}

class SearchStoreState extends State<SearchStore> {
  var isCartCount = false;

  var cartCount = 0;
  double userLat = 0.0;
  double userLng = 0.0;
  List<SearchList> nearStores = [];
  List<CategoryList> categoryList = [];

//  List<SubCategoryList> subCategoryList = [];
  List<ProductVarient> productVarient = [];

//  List<SearchProduct> nearStores = [];
  SearchProduct nearStoresd;

  String searchString = '';

  dynamic currencyda = '';

  @override
  void initState() {
    super.initState();
    getCartCount();
  }

  getShareValue() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userLat = double.parse('${prefs.getString('lat')}');
      userLng = double.parse('${prefs.getString('lng')}');
    });
  }

  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

  String calculateTime(lat1, lon1, lat2, lon2){
    double kms = calculateDistance(lat1, lon1, lat2, lon2);
    double kms_per_min = 0.5;
    double mins_taken = kms / kms_per_min;
    double min = mins_taken;
    if (min<60) {
      return ""+'${min.toInt()}'+" mins";
    }else {
      double tt = min % 60;
      String minutes = '${tt.toInt()}';
      minutes = minutes.length == 1 ? "0" + minutes : minutes;
      return '${(min.toInt() / 60)}' + " hour " + minutes +"mins";
    }
  }

  void getCartCount() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      currencyda = preferences.getString('curency');
    });
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(110.0),
        child: CustomAppBar(
          titleWidget: Text(
            'Search Product or Store..',
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
                    prefixIcon: Icon(
                      Icons.search,
                      color: kHintColor,
                    ),
                    hintText: 'Search....',
                  ),
                  cursorColor: kMainColor,
                  autofocus: false,
                  onEditingComplete: () {
                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                    hitSearch(searchString);
                  },
                  onChanged: (value) {
                    searchString = value;
//                   nearStores = nearStoresSearch.where((element) => element.vendor_name.toString().toLowerCase().contains(value.toLowerCase())).toList();
                  },
                ),
              ),
              preferredSize:
                  Size(MediaQuery.of(context).size.width * 0.85, 52)),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height - 110,
        child: SingleChildScrollView(
          primary: true,
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Visibility(
                  visible: (nearStores != null && nearStores.length > 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 20.0, top: 20.0),
                        child: Text(
                          '${nearStores.length} Store found',
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(color: kHintColor, fontSize: 18),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: (nearStores != null && nearStores.length > 0)
                            ? ListView.separated(
                                shrinkWrap: true,
                                primary: false,
                                scrollDirection: Axis.vertical,
                                itemCount: nearStores.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () =>
//                            Navigator.pushNamed(context, PageRoutes.items),
                                        hitNavigator(
                                            context,
                                            nearStores[index].vendor_name,
                                            nearStores[index].vendor_id,
                                            nearStores[index].distance),
                                    child: Material(
                                      elevation: 2,
                                      shadowColor: white_color,
                                      clipBehavior: Clip.hardEdge,
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        color: white_color,
                                        padding: EdgeInsets.only(
                                            left: 20.0, top: 15, bottom: 15),
                                        child: Row(
                                          children: <Widget>[
                                            Image.network(
                                              imageBaseUrl +
                                                  nearStores[index].vendor_logo,
                                              width: 93.3,
                                              height: 93.3,
                                            ),
                                            SizedBox(width: 13.3),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                      nearStores[index]
                                                          .vendor_name,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .subtitle2
                                                          .copyWith(
                                                              color:
                                                                  kMainTextColor,
                                                              fontSize: 18)),
                                                  SizedBox(height: 8.0),
                                                  Row(
                                                    children: <Widget>[
                                                      Icon(
                                                        Icons.location_on,
                                                        color: kIconColor,
                                                        size: 15,
                                                      ),
                                                      SizedBox(width: 10.0),
                                                      Text(
                                                          '${double.parse('${nearStores[index].distance}').toStringAsFixed(2)} km ',
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .caption
                                                              .copyWith(
                                                                  color:
                                                                      kLightTextColor,
                                                                  fontSize:
                                                                      13.0)),
                                                      Text('| ',
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .caption
                                                              .copyWith(
                                                                  color:
                                                                      kMainColor,
                                                                  fontSize:
                                                                      13.0)),
                                                      Expanded(
                                                        child: Text(
                                                            nearStores[index]
                                                                .vendor_name,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .caption
                                                                .copyWith(
                                                                    color:
                                                                        kLightTextColor,
                                                                    fontSize:
                                                                        13.0)),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 6),
                                                  Row(
                                                    children: <Widget>[
                                                      Icon(
                                                        Icons.access_time,
                                                        color: kIconColor,
                                                        size: 15,
                                                      ),
                                                      SizedBox(width: 10.0),
                                                      Text('${calculateTime(double.parse('${nearStores[index].lat}'), double.parse('${nearStores[index].lng}'), userLat, userLng)}',
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .caption
                                                              .copyWith(
                                                              color:
                                                              kLightTextColor,
                                                              fontSize: 13.0)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return SizedBox(
                                    height: 10,
                                  );
                                })
                            : Container(),
                      )
                    ],
                  )),
              Visibility(
                  visible: (categoryList != null && categoryList.length > 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 20.0, top: 5),
                        child: Text(
                          '${categoryList.length} Category found',
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(color: kHintColor, fontSize: 18),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 10, right: 10, top: 20, bottom: 30),
                        child: ListView.separated(
                            shrinkWrap: true,
                            primary: false,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  hitNavigators(
                                      context,
                                      categoryList[index].vendor_name,
                                      categoryList[index].category_name,
                                      categoryList[index].category_id,
                                      categoryList[index].distance,
                                      categoryList[index].vendor_id);
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Material(
                                  elevation: 2,
                                  borderRadius: BorderRadius.circular(10),
                                  clipBehavior: Clip.antiAlias,
                                  child: Container(
                                    color: white_color,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 20),
                                    child: Row(
                                      children: [
                                        Image.network(
                                          imageBaseUrl +
                                              categoryList[index]
                                                  .category_image,
                                          height: 80,
                                          width: 90,
                                        ),
//                                CachedNetworkImage(
//                                  height: 80,
//                                  width: 90,
//                                  fit: BoxFit.fill,
//                                  imageUrl: imageBaseUrl +
//                                      categoryLists[index].category_image,
//                                  progressIndicatorBuilder:
//                                      (context, url, downloadProgress) =>
//                                          CircularProgressIndicator(
//                                              value: downloadProgress.progress),
//                                  errorWidget: (context, url, error) =>
//                                      Image.asset('images/logos/logo_user.png'),
//                                ),
                                        SizedBox(
                                          width: 13.5,
                                        ),
                                        Expanded(
                                            child: Text(
                                          categoryList[index].category_name,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 18,
                                              color: kMainTextColor),
                                        )),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Icon(
                                            Icons.keyboard_arrow_right,
                                            size: 30,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return SizedBox(
                                height: 5,
                              );
                            },
                            itemCount: categoryList.length),
                      )
                    ],
                  )),
              Visibility(
                  visible:
                      (productVarient != null && productVarient.length > 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 20.0),
                        child: Text(
                          '${productVarient.length} Product found',
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(color: kHintColor, fontSize: 18),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child:
                            (productVarient != null &&
                                    productVarient.length > 0)
                                ? ListView.separated(
                                    itemCount: productVarient.length,
                                    shrinkWrap: true,
                                    primary: false,
                                    scrollDirection: Axis.vertical,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return SingleProductPage_2(
                                                productVarient[index],
                                                currencyda);
                                          })).then((value) {
//                                 setList(productVarientList);
                                            getCartCount();
                                          });
                                        },
                                        behavior: HitTestBehavior.deferToChild,
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Stack(
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
                                                    child: (productVarient !=
                                                                null &&
                                                            productVarient
                                                                    .length >
                                                                0)
                                                        ? Image.network(
                                                            '${imageBaseUrl + productVarient[index].data[0].varient_image}',
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
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: 20),
                                                          child: Text(
                                                              productVarient[
                                                                      index]
                                                                  .product_name,
                                                              style: bottomNavigationTextStyle
                                                                  .copyWith(
                                                                      fontSize:
                                                                          15)),
                                                        ),
                                                        SizedBox(
                                                          height: 8.0,
                                                        ),
                                                        Text(
                                                            '${currencyda} ${productVarient[index].data[0].price}',
                                                            style: Theme.of(
                                                                    context)
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
                                                child: InkWell(
                                                  onTap: () {
                                                    (productVarient[index]
                                                                .data
                                                                .length >
                                                            1)
                                                        ? showModalBottomSheet(
                                                            context: context,
                                                            builder: (context) {
                                                              return BottomSheetWidget(
                                                                  productVarient[
                                                                          index]
                                                                      .product_name,
                                                                  productVarient[
                                                                          index]
                                                                      .data,
                                                                  productVarient[
                                                                          index]
                                                                      .product_name,
                                                                  productVarient[
                                                                          index]
                                                                      .vendor_id,
                                                                  productVarient[
                                                                          index]
                                                                      .vendor_name,
                                                                  isCartCount);
                                                            },
                                                          ).then((value) {
                                                            getCartCount();
                                                          })
                                                        : Toast.show(
                                                            'No varient available for this product!',
                                                            context,
                                                            duration: Toast
                                                                .LENGTH_SHORT);
                                                  },
                                                  child: Container(
                                                    height: 30.0,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 12.0),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          kCardBackgroundColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30.0),
                                                    ),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Text(
                                                          '${productVarient[index].data[0].quantity} ${productVarient[index].data[0].unit}',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .caption,
                                                        ),
                                                        SizedBox(
                                                          width: 8.0,
                                                        ),
                                                        Icon(
                                                          Icons
                                                              .keyboard_arrow_down,
                                                          color: kMainColor,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                  height: 30,
                                                  right: 20.0,
                                                  bottom: 5,
                                                  child:
                                                      productVarient[index]
                                                                  .add_qnty ==
                                                              0
                                                          ? Container(
                                                              height: 30.0,
                                                              child: FlatButton(
                                                                child: Text(
                                                                  'Add',
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .caption
                                                                      .copyWith(
                                                                          color:
                                                                              kMainColor,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                ),
                                                                textTheme:
                                                                    ButtonTextTheme
                                                                        .accent,
                                                                onPressed:
                                                                    () async {
                                                                  SharedPreferences
                                                                      prefs =
                                                                      await SharedPreferences
                                                                          .getInstance();
                                                                  if (isCartCount &&
                                                                      prefs.getString(
                                                                              "vendor_id") !=
                                                                          null &&
                                                                      prefs.getString(
                                                                              "vendor_id") !=
                                                                          "" &&
                                                                      prefs.getString(
                                                                              "vendor_id") !=
                                                                          '${productVarient[index].vendor_id}') {
                                                                    showAlertDialogitem(
                                                                        context);
                                                                  } else {
                                                                    setState(
                                                                        () {
                                                                      if (productVarient[index]
                                                                              .data[0]
                                                                              .stock >
                                                                          productVarient[index].add_qnty) {
                                                                        productVarient[index]
                                                                            .add_qnty++;
                                                                        addOrMinusProduct(
                                                                            productVarient[index].product_name,
                                                                            productVarient[index].data[0].unit,
                                                                            double.parse('${productVarient[index].data[0].price}'),
                                                                            int.parse('${productVarient[index].data[0].quantity}'),
                                                                            productVarient[index].add_qnty,
                                                                            productVarient[index].data[0].varient_image,
                                                                            productVarient[index].data[0].varient_id);
                                                                      } else {
                                                                        Toast.show(
                                                                            "No more stock available!",
                                                                            context,
                                                                            gravity:
                                                                                Toast.BOTTOM);
                                                                      }
                                                                    });
                                                                  }
                                                                },
                                                              ),
                                                            )
                                                          : Container(
                                                              height: 30.0,
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          11.0),
                                                              decoration:
                                                                  BoxDecoration(
                                                                border: Border.all(
                                                                    color:
                                                                        kMainColor),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30.0),
                                                              ),
                                                              child: Row(
                                                                children: <
                                                                    Widget>[
                                                                  InkWell(
                                                                    onTap:
                                                                        () async {
                                                                      SharedPreferences
                                                                          prefs =
                                                                          await SharedPreferences
                                                                              .getInstance();
                                                                      if (isCartCount &&
                                                                          prefs.getString("vendor_id") !=
                                                                              null &&
                                                                          prefs.getString("vendor_id") !=
                                                                              "" &&
                                                                          prefs.getString("vendor_id") !=
                                                                              '${productVarient[index].vendor_id}') {
                                                                        showAlertDialogitem(
                                                                            context);
                                                                      } else {
                                                                        setState(
                                                                            () {
                                                                          productVarient[index]
                                                                              .add_qnty--;
                                                                        });
                                                                        addOrMinusProduct(
                                                                            productVarient[index].product_name,
                                                                            productVarient[index].data[0].unit,
                                                                            double.parse('${productVarient[index].data[0].price}'),
                                                                            int.parse('${productVarient[index].data[0].quantity}'),
                                                                            productVarient[index].add_qnty,
                                                                            productVarient[index].data[0].varient_image,
                                                                            productVarient[index].data[0].varient_id);
                                                                      }
                                                                    },
                                                                    child: Icon(
                                                                      Icons
                                                                          .remove,
                                                                      color:
                                                                          kMainColor,
                                                                      size:
                                                                          20.0,
                                                                      //size: 23.3,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      width:
                                                                          8.0),
                                                                  Text(
                                                                      productVarient[
                                                                              index]
                                                                          .add_qnty
                                                                          .toString(),
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .caption),
                                                                  SizedBox(
                                                                      width:
                                                                          8.0),
                                                                  InkWell(
                                                                    onTap:
                                                                        () async {
                                                                      SharedPreferences
                                                                          prefs =
                                                                          await SharedPreferences
                                                                              .getInstance();
                                                                      if (isCartCount &&
                                                                          prefs.getString("vendor_id") !=
                                                                              null &&
                                                                          prefs.getString("vendor_id") !=
                                                                              "" &&
                                                                          prefs.getString("vendor_id") !=
                                                                              '${productVarient[index].vendor_id}') {
                                                                        showAlertDialogitem(
                                                                            context);
                                                                      } else {
                                                                        setState(
                                                                            () {
                                                                          if (productVarient[index].data[0].stock >
                                                                              productVarient[index].add_qnty) {
                                                                            productVarient[index].add_qnty++;
                                                                            addOrMinusProduct(
                                                                                productVarient[index].product_name,
                                                                                productVarient[index].data[0].unit,
                                                                                double.parse('${productVarient[index].data[0].price}'),
                                                                                int.parse('${productVarient[index].data[0].quantity}'),
                                                                                productVarient[index].add_qnty,
                                                                                productVarient[index].data[0].varient_image,
                                                                                productVarient[index].data[0].varient_id);
                                                                          } else {
                                                                            Toast.show("No more stock available!",
                                                                                context,
                                                                                gravity: Toast.BOTTOM);
                                                                          }
                                                                        });
                                                                      }
                                                                    },
                                                                    child: Icon(
                                                                      Icons.add,
                                                                      color:
                                                                          kMainColor,
                                                                      size:
                                                                          20.0,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
//                          upDataView(productVarientList[index].data[0].varient_id, index, context)

                                                  ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    separatorBuilder: (context, index) {
                                      return SizedBox(
                                        height: 5,
                                      );
                                    },
                                  )
                                : Container(),
                      )
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context, vendor_name, vendor_id, distance) {
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
        deleteAllRestProduct(context, vendor_name, vendor_id, distance);
      },
      child: Material(
        elevation: 2,
        clipBehavior: Clip.hardEdge,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Text(
            'Clear',
            style: TextStyle(fontSize: 13, color: kWhiteColor),
          ),
        ),
      ),
    );

    Widget no = GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        clipBehavior: Clip.hardEdge,
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Text(
            'No',
            style: TextStyle(fontSize: 13, color: kWhiteColor),
          ),
        ),
      ),
    );

    // Widget yes = FlatButton(
    //   padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
    //   child: Text("OK"),
    //   onPressed: () {
    //     Navigator.of(context, rootNavigator: true).pop('dialog');
    //   },
    // );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      title: Text("Inconvenience Notice"),
      content: Text(
          "Order from different store in single order is not allowed. Sorry for inconvenience"),
      actions: [clear, no],
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

  showAlertDialogitem(BuildContext context) {
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
        deleteAllRestProductItem(context);
      },
      child: Material(
        elevation: 2,
        clipBehavior: Clip.hardEdge,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Text(
            'Clear',
            style: TextStyle(fontSize: 13, color: kWhiteColor),
          ),
        ),
      ),
    );

    Widget no = GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        clipBehavior: Clip.hardEdge,
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Text(
            'No',
            style: TextStyle(fontSize: 13, color: kWhiteColor),
          ),
        ),
      ),
    );

    // Widget yes = FlatButton(
    //   padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
    //   child: Text("OK"),
    //   onPressed: () {
    //     Navigator.of(context, rootNavigator: true).pop('dialog');
    //   },
    // );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      title: Text("Inconvenience Notice"),
      content: Text(
          "Order from different store in single order is not allowed. Sorry for inconvenience"),
      actions: [clear, no],
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

  void deleteAllRestProductItem(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("vendor_id", '');
    DatabaseHelper db = DatabaseHelper.instance;
    db.deleteAll();
  }

  hitNavigator(BuildContext context, vendor_name, vendor_id, distance) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (isCartCount &&
        prefs.getString("vendor_id") != null &&
        prefs.getString("vendor_id") != "" &&
        prefs.getString("vendor_id") != '${vendor_id}') {
      showAlertDialog(context, vendor_name, vendor_id, distance);
    } else {
      prefs.setString("vendor_id", '${vendor_id}');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  AppCategory(vendor_name, vendor_id, distance))).then((value) {
        getCartCount();
      });
    }
  }

  void deleteAllRestProduct(
      BuildContext context, vendor_name, vendor_id, distance) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DatabaseHelper db = DatabaseHelper.instance;
    db.deleteAll().then((value) {
      prefs.setString("vendor_id", '${vendor_id}');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  AppCategory(vendor_name, vendor_id, distance))).then((value) {
        getCartCount();
      });
    });
  }

  // hitNavigator(BuildContext context, vendor_name, vendor_id, distance) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setString("vendor_id", vendor_id.toString());
  //   Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //           builder: (context) =>
  //               AppCategory(vendor_name, vendor_id, distance))).then((value) {
  //     getCartCount();
  //   });
  // }

  void addOrMinusProduct(product_name, unit, price, quantity, itemCount,
      varient_image, varient_id) async {
//    addMinus = true;
    DatabaseHelper db = DatabaseHelper.instance;
    db.getcount(int.parse('${varient_id}')).then((value) {
      print('value d - $value');
      var vae = {
        DatabaseHelper.productName: product_name,
        DatabaseHelper.price: (price * itemCount),
        DatabaseHelper.unit: unit,
        DatabaseHelper.quantitiy: quantity,
        DatabaseHelper.addQnty: itemCount,
        DatabaseHelper.productImage: varient_image,
        DatabaseHelper.varientId: int.parse('${varient_id}')
      };
      if (value == 0) {
        db.insert(vae);
      } else {
        if (itemCount == 0) {
          db.delete(int.parse('${varient_id}'));
        } else {
          db.updateData(vae, int.parse('${varient_id}')).then((vay) {
            print('vay - $vay');
          });
        }
      }
      getCartCount();
    }).catchError((e) {
      print(e);
    });
  }

  void hitSearch(String searchString) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('${searchString}');
    var client = http.Client();
    var url = search_keyword;
    client.post(url, body: {
      'prod_name': '${searchString}',
      'lat': '${prefs.getString('lat')}',
      'lng': '${prefs.getString('lng')}',
//      'lat': '29.0064741',
//      'lng': '77.0205907',
    }).then((value) {
      if (value.statusCode == 200) {
        var jsonData = jsonDecode(value.body);
//        print('Response Body: - ${jsonData.toString()}');
        if (jsonData['status'] == "1") {
          Toast.show(jsonData['message'], context,
              duration: Toast.LENGTH_SHORT);
          var tagObjsJsonStore = jsonData['stores'] as List;
          var tagObjsJsonCategory = jsonData['category'] as List;
//          var tagObjsJsonSub = jsonData['subcat'] as List;
          var tagObjsJsonProd = jsonData['products'] as List;
          print(tagObjsJsonProd.toString());
          List<SearchList> _tags = tagObjsJsonStore
              .map((tagJson) => SearchList.fromJson(tagJson))
              .toList();
          List<CategoryList> _tags2 = tagObjsJsonCategory
              .map((tagJson) => CategoryList.fromJson(tagJson))
              .toList();
//          List<SubCategoryList> _tags3 = tagObjsJsonSub.map((tagJson) => SubCategoryList.fromJson(tagJson)).toList();
          List<ProductVarient> _tags4 = tagObjsJsonProd
              .map((tagJson) => ProductVarient.fromJson(tagJson))
              .toList();
          print('${_tags4.toString()}');
          setState(() {
            nearStores.clear();
            productVarient.clear();
            categoryList.clear();
            nearStores = _tags;
            categoryList = _tags2;
            productVarient = _tags4;
            setList(productVarient);
          });
        } else {
          Toast.show('Store not found', context, duration: Toast.LENGTH_SHORT);
        }
      }
    }).catchError((e) {
      Toast.show('Store not found', context, duration: Toast.LENGTH_SHORT);
    });
  }

  void setList(List<ProductVarient> tagObjs) {
    for (int i = 0; i < tagObjs.length; i++) {
      DatabaseHelper db = DatabaseHelper.instance;
      db.getVarientCount(tagObjs[i].data[0].varient_id).then((value) {
        print('print val $value');
        if (value == null) {
          setState(() {
            tagObjs[i].add_qnty = 0;
          });
        } else {
          setState(() {
            tagObjs[i].add_qnty = value;
            isCartCount = true;
          });
        }
      });
    }
  }

  showAlertDialogs(BuildContext context, vendor_name, vendor_id, distance,
      category_name, category_id) {
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
        deleteAllRestProducts(context, vendor_name, vendor_id, distance,
            category_name, category_id);
      },
      child: Material(
        elevation: 2,
        clipBehavior: Clip.hardEdge,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Text(
            'Clear',
            style: TextStyle(fontSize: 13, color: kWhiteColor),
          ),
        ),
      ),
    );

    Widget no = GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        clipBehavior: Clip.hardEdge,
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Text(
            'No',
            style: TextStyle(fontSize: 13, color: kWhiteColor),
          ),
        ),
      ),
    );

    // Widget yes = FlatButton(
    //   padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
    //   child: Text("OK"),
    //   onPressed: () {
    //     Navigator.of(context, rootNavigator: true).pop('dialog');
    //   },
    // );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      title: Text("Inconvenience Notice"),
      content: Text(
          "Order from different store in single order is not allowed. Sorry for inconvenience"),
      actions: [clear, no],
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

  void deleteAllRestProducts(BuildContext context, vendor_name, vendor_id,
      distance, category_name, category_id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DatabaseHelper db = DatabaseHelper.instance;
    db.deleteAll().then((value) {
      prefs.setString("vendor_id", '${vendor_id}');
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ItemsPage(
                      vendor_name, category_name, category_id, distance)))
          .then((value) {
        getCartCount();
      });
    });
  }

  void hitNavigators(context, vendor_name, category_name, category_id, distance,
      vendor_id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (isCartCount &&
        prefs.getString("vendor_id") != null &&
        prefs.getString("vendor_id") != "" &&
        prefs.getString("vendor_id") != '${vendor_id}') {
      showAlertDialogs(context, vendor_name, vendor_id, distance, category_name,
          category_id);
    } else {
      prefs.setString("vendor_id", '${vendor_id}');
      Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ItemsPage(
                      vendor_name, category_name, category_id, distance)))
          .then((value) {
        getCartCount();
      });
    }
  }
}

class BottomSheetWidget extends StatefulWidget {
  final String product_name;
  final String category_name;
  final dynamic vendor_id;
  final dynamic vendor_name;
  final bool isCartCount;
  final List<VarientList> datas;
  List<VarientList> newdatas = [];

  BottomSheetWidget(this.product_name, this.datas, this.category_name,
      this.vendor_id, this.vendor_name, this.isCartCount) {
    newdatas.clear();
    newdatas.addAll(datas);
    newdatas.removeAt(0);
  }

  @override
  State<StatefulWidget> createState() {
    return BottomSheetWidgetState(
        product_name, newdatas, vendor_id, vendor_name, isCartCount);
  }
}

class BottomSheetWidgetState extends State<BottomSheetWidget> {
  final String product_name;
  final dynamic vendor_id;
  final dynamic vendor_name;
  final bool isCartCount;
  final List<VarientList> data;

  // bool isCartCount = false;

  BottomSheetWidgetState(this.product_name, this.data, this.vendor_id,
      this.vendor_name, this.isCartCount) {
    setList(data);
  }

  void setList(List<VarientList> tagObjs) {
    for (int i = 0; i < tagObjs.length; i++) {
      DatabaseHelper db = DatabaseHelper.instance;
      db.getVarientCount(tagObjs[i].varient_id).then((value) {
        print('print val $value');
        if (value == null) {
          setState(() {
            tagObjs[i].add_qnty = 0;
          });
        } else {
          setState(() {
            tagObjs[i].add_qnty = value;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Container(
          height: 80.7,
          color: kCardBackgroundColor,
          padding: EdgeInsets.all(10.0),
          child: ListTile(
            title: Text(product_name,
                style: Theme.of(context)
                    .textTheme
                    .caption
                    .copyWith(fontSize: 15, fontWeight: FontWeight.w500)),
            subtitle: Text('${widget.category_name}',
                style:
                    Theme.of(context).textTheme.caption.copyWith(fontSize: 15)),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          primary: true,
          itemCount: data.length,
          itemBuilder: (context, index) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      '${data[index].quantity} ${data[index].unit}',
                      style: Theme.of(context)
                          .textTheme
                          .caption
                          .copyWith(fontSize: 16.7),
                    )
                  ],
                ),
                data[index].add_qnty == 0
                    ? Container(
                        height: 30.0,
                        child: FlatButton(
                          child: Text(
                            'Add',
                            style: Theme.of(context).textTheme.caption.copyWith(
                                color: kMainColor, fontWeight: FontWeight.bold),
                          ),
                          textTheme: ButtonTextTheme.accent,
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            if (isCartCount &&
                                prefs.getString("vendor_id") != null &&
                                prefs.getString("vendor_id") != "" &&
                                prefs.getString("vendor_id") !=
                                    '${data[index].vendor_id}') {
                              showAlertDialogitem(context);
                            } else {
                              setState(() {
                                if (data[index].stock > data[index].add_qnty) {
                                  data[index].add_qnty++;
                                  addOrMinusProduct(
                                      product_name,
                                      data[index].unit,
                                      data[index].price,
                                      data[index].quantity,
                                      data[index].add_qnty,
                                      data[index].varient_image,
                                      data[index].varient_id);
                                } else {
                                  Toast.show(
                                      "No more stock available!", context,
                                      gravity: Toast.BOTTOM);
                                }
                              });
                            }
                          },
                        ),
                      )
                    : Container(
                        height: 30.0,
                        padding: EdgeInsets.symmetric(horizontal: 11.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: kMainColor),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Row(
                          children: <Widget>[
                            InkWell(
                              onTap: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                if (isCartCount &&
                                    prefs.getString("vendor_id") != null &&
                                    prefs.getString("vendor_id") != "" &&
                                    prefs.getString("vendor_id") !=
                                        '${data[index].vendor_id}') {
                                  showAlertDialogitem(context);
                                } else {
                                  setState(() {
                                    data[index].add_qnty--;
                                  });
                                  addOrMinusProduct(
                                      product_name,
                                      data[index].unit,
                                      data[index].price,
                                      data[index].quantity,
                                      data[index].add_qnty,
                                      data[index].varient_image,
                                      data[index].varient_id);
                                }
                              },
                              child: Icon(
                                Icons.remove,
                                color: kMainColor,
                                size: 20.0,
                                //size: 23.3,
                              ),
                            ),
                            SizedBox(width: 8.0),
                            Text(data[index].add_qnty.toString(),
                                style: Theme.of(context).textTheme.caption),
                            SizedBox(width: 8.0),
                            InkWell(
                              onTap: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                if (isCartCount &&
                                    prefs.getString("vendor_id") != null &&
                                    prefs.getString("vendor_id") != "" &&
                                    prefs.getString("vendor_id") !=
                                        '${data[index].vendor_id}') {
                                  showAlertDialogitem(context);
                                } else {
                                  setState(() {
                                    if (data[index].stock >
                                        data[index].add_qnty) {
                                      data[index].add_qnty++;
                                      addOrMinusProduct(
                                          product_name,
                                          data[index].unit,
                                          data[index].price,
                                          data[index].quantity,
                                          data[index].add_qnty,
                                          data[index].varient_image,
                                          data[index].varient_id);
                                    } else {
                                      Toast.show(
                                          "No more stock available!", context,
                                          gravity: Toast.BOTTOM);
                                    }
                                  });
                                }
                              },
                              child: Icon(
                                Icons.add,
                                color: kMainColor,
                                size: 20.0,
                              ),
                            ),
                          ],
                        ),
                      )
              ],
            );
          },
          separatorBuilder: (context, index) {
            return Divider(
              height: 20,
              color: Colors.transparent,
            );
          },
        ),
//        CheckboxGroup(
//          labelStyle:
//              Theme.of(context).textTheme.caption.copyWith(fontSize: 16.7),
//          labels: list,
//        ),
      ],
    );
  }

  void addOrMinusProduct(product_name, unit, price, quantity, itemCount,
      varient_image, varient_id) async {
//    addMinus = true;
    DatabaseHelper db = DatabaseHelper.instance;
    Future<int> existing = db.getcount(varient_id);
    existing.then((value) {
      print('value d - $value');
      var vae = {
        DatabaseHelper.productName: product_name,
        DatabaseHelper.price: (price * itemCount),
        DatabaseHelper.unit: unit,
        DatabaseHelper.quantitiy: quantity,
        DatabaseHelper.addQnty: itemCount,
        DatabaseHelper.productImage: varient_image,
        DatabaseHelper.varientId: varient_id
      };
      if (value == 0) {
        db.insert(vae);
      } else {
        if (itemCount == 0) {
          db.delete(varient_id);
        } else {
          db.updateData(vae, varient_id).then((vay) {
            print('vay - $vay');
//            getCatC();
          });
        }
      }
//      getCartCount();
    });
  }

  showAlertDialogitem(BuildContext context) {
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
        deleteAllRestProductItem(context);
      },
      child: Material(
        elevation: 2,
        clipBehavior: Clip.hardEdge,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Text(
            'Clear',
            style: TextStyle(fontSize: 13, color: kWhiteColor),
          ),
        ),
      ),
    );

    Widget no = GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).pop('dialog');
      },
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        clipBehavior: Clip.hardEdge,
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Text(
            'No',
            style: TextStyle(fontSize: 13, color: kWhiteColor),
          ),
        ),
      ),
    );

    // Widget yes = FlatButton(
    //   padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
    //   child: Text("OK"),
    //   onPressed: () {
    //     Navigator.of(context, rootNavigator: true).pop('dialog');
    //   },
    // );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      title: Text("Inconvenience Notice"),
      content: Text(
          "Order from different store in single order is not allowed. Sorry for inconvenience"),
      actions: [clear, no],
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

  void deleteAllRestProductItem(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("vendor_id", '');
    DatabaseHelper db = DatabaseHelper.instance;
    db.deleteAll();
  }
//  void getCartCount() {
//    DatabaseHelper db = DatabaseHelper.instance;
//    db.queryRowCount().then((value) {
//      setState(() {
//        if (value != null && value > 0) {
//          cartCount = value;
//          isCartCount = true;
//        } else {
//          cartCount = 0;
//          isCartCount = false;
//        }
//      });
//    });
//
//    getCatC();
//  }
//
//  void getCatC() async {
//    DatabaseHelper db = DatabaseHelper.instance;
//    db.calculateTotal().then((value) {
//      var tagObjsJson = value as List;
//      setState(() {
//        if (value != null) {
//          totalAmount = tagObjsJson[0]['Total'];
//        } else {
//          totalAmount = 0.0;
//        }
//      });
//    });
//  }
}
