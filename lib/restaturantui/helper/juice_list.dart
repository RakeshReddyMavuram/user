import 'package:flutter/material.dart';
import 'package:user/Routes/routes.dart';
import 'package:user/Themes/colors.dart';
import 'package:user/Themes/constantfile.dart';
import 'package:user/Themes/style.dart';
import 'package:user/baseurl/baseurl.dart';
import 'package:user/bean/resturantbean/addonidlist.dart';
import 'package:user/bean/resturantbean/categoryresturantlist.dart';
import 'package:user/databasehelper/dbhelper.dart';
import 'package:user/restaturantui/widigit/column_builder.dart';
import 'package:toast/toast.dart';

class JuiceList extends StatefulWidget {
  final CategoryResturant item;
final dynamic currencySymbol;
  final VoidCallback onVerificationDone;
  List<CategoryResturant>  categoryListNew;
  JuiceList(this.item, this.categoryListNew, this.currencySymbol,this.onVerificationDone,);

  @override
  _JuiceListState createState() => _JuiceListState();
}

class _JuiceListState extends State<JuiceList> {
  int currentIndex = -1;

  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(right: fixPadding, left: fixPadding),
          child: Text(
            '${widget.categoryListNew.length} items',
            style: listItemSubTitleStyle,
          ),
        ),
        ListView.builder(
          itemCount: widget.categoryListNew.length,
          primary: false,
          shrinkWrap: true,
          itemBuilder: (context, indexs) {
            final items = widget.categoryListNew[indexs];
            return Container(
              width: width,
              margin: EdgeInsets.all(fixPadding),
              decoration: BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Stack(
                children: <Widget>[
                  // Positioned(
                  //   right: fixPadding,
                  //   child: InkWell(
                  //     onTap: () {
                  //       setFaviouriteResturant(
                  //           item, context, index, widget.item.product_id);
                  //     },
                  //     child: Icon(
                  //       (widget.item.variant[index].isFaviourite == 0)
                  //           ? Icons.bookmark_border
                  //           : Icons.bookmark,
                  //       // Icons.bookmark,
                  //       size: 22.0,
                  //       color: kHintColor,
                  //     ),
                  //   ),
                  // ),
                  ListView.separated(
                      itemBuilder: (context,index){
                        final item = items.variant[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: 100.0,
                          width: 90.0,
                          alignment: Alignment.topRight,
                          padding: EdgeInsets.all(fixPadding),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            // image: DecorationImage(
                            //   image: AssetImage(item['image']),
                            //   fit: BoxFit.cover,
                            // ),
                          ),
                          child: Image.network(
                            '${imageBaseUrl}${items.product_image}',
                            fit: BoxFit.fill,
                          ),
                        ),
                        Container(
                          width: width - ((fixPadding * 2) + 100.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(
                                    right: fixPadding * 2,
                                    left: fixPadding,
                                    bottom: fixPadding / 2),
                                child: Text(
                                  '${items.product_name}',
                                  style: listItemTitleStyle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: fixPadding, right: fixPadding),
                                child: Text(
                                  '${items.description}',
                                  style: listItemSubTitleStyle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: fixPadding,
                                    right: fixPadding,
                                    top: fixPadding),
                                child: Text(
                                  '(${item.quantity} ${item.unit})',
                                  style: listItemSubTitleStyle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: fixPadding, left: fixPadding),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      '${widget.currencySymbol} ${item.strick_price}',
                                      // '',
                                      style: priceStylesrick,
                                    ),
                                    Text(
                                      '${widget.currencySymbol} ${item.price}',
                                      // '',
                                      style: priceStyle,
                                    ),
                                    InkWell(
                                      onTap: () async{
                                        currentIndex = index;
                                        DatabaseHelper db =
                                            DatabaseHelper.instance;
                                        db.getRestProdQty('${item.variant_id}')
                                            .then((value) {
                                          print('dddd - ${value}');
                                          if (value != null) {
                                            setState(() {
                                              item.addOnQty = value;
                                            });
                                          }else{
                                            if(item.addOnQty>0){
                                              setState(() {
                                                item.addOnQty = 0;
                                              });
                                            }
                                          }
                                          db.getAddOnList('${item.variant_id}')
                                              .then((valued) {
                                            List<AddonList> addOnlist = [];
                                            if (valued != null &&
                                                valued.length > 0) {
                                              addOnlist = valued
                                                  .map((e) =>
                                                  AddonList.fromJson(e))
                                                  .toList();
                                              for (int i = 0;
                                              i < items.addons.length;
                                              i++) {
                                                int ind = addOnlist.indexOf(AddonList(
                                                    '${items.addons[i].addon_id}'));
                                                if (ind != null && ind >= 0) {
                                                  setState(() {
                                                    items.addons[i].isAdd =
                                                    true;
                                                  });
                                                }
                                              }
                                            }

                                            db.calculateTotalRestAdonA('${item.variant_id}').then((value1){
                                              double priced = 0.0;
                                              print('${value1}');
                                              if(value!=null){
                                                var tagObjsJson = value1 as List;
                                                dynamic totalAmount_1 = tagObjsJson[0]['Total'];
                                                print('${totalAmount_1}');
                                                if(totalAmount_1!=null){
                                                  setState((){
                                                    priced = double.parse('${totalAmount_1}');
                                                  });
                                                }
                                              }
                                              productDescriptionModalBottomSheets(
                                                  context,
                                                  height,
                                                  items,
                                                  index,
                                                  addOnlist,
                                                  widget.currencySymbol,priced,widget.onVerificationDone()).then((value) {
                                                // print('${value}');
                                                widget.onVerificationDone();
                                              });
                                            });
                                            print('list aaa - ${addOnlist.toString()}');
                                            print('list - ${valued}');
                                          });
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(3.0),
                                          color: kMainColor,
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.only(left:8,right:8 ,top:3,bottom: 3),
                                          child: Text('ADD',
                                            style: Theme.of(context)
                                            .textTheme
                                            .caption
                                            .copyWith(
                                            color: kWhiteColor,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.67),
                                         /* Icons.add,
                                          color: kWhiteColor,
                                          size: 15.0,*/
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },itemCount: items.variant.length,
                    separatorBuilder: (context,indi){
                        return Divider(
                          color: Colors.transparent,
                          thickness: 3,
                        );
                    },
                  shrinkWrap: true,
                  primary: false,)

                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // void setFaviouriteResturant(
  //     ResturantVarient item, BuildContext context, index, product_id) async {
  //   DatabaseHelper db = DatabaseHelper.instance;
  //   var vae = {
  //     DatabaseHelper.productId: product_id,
  //     DatabaseHelper.varientId: item.variant_id
  //   };
  //   db.insertFaviProduct(vae).then((value) {
  //     print('$value');
  //     setState(() {
  //       widget.item.variant[index].isFaviourite = 1;
  //     });
  //     Scaffold.of(context).showSnackBar(SnackBar(
  //       content: Text('Added to Favourite'),
  //     ));
  //   });
  // }
}

Future productDescriptionModalBottomSheets(context, height,
    CategoryResturant item, getIn, List<AddonList> addOnlist, currencySymbol, double priced, void onVerificationDone) async {
  int initialItemCount = 0;
  double itemPrice = 0.0;
  double price = 0.0;
  // item.variant[getIn].variant_id


  if (item.variant[getIn].addOnQty > 0) {
    price = (double.parse('${item.variant[getIn].addOnQty}') * double.parse('${item.variant[getIn].price}'))+priced;
  }
  double width = MediaQuery.of(context).size.width;

  DatabaseHelper db = DatabaseHelper.instance;
  db.getAddOnList('${item.variant[getIn].variant_id}')
      .then((valued) {
    List<AddonList> addOnlist = [];
    if (valued != null &&
        valued.length > 0) {
      addOnlist = valued
          .map((e) =>
          AddonList.fromJson(e))
          .toList();
      for (int i = 0; i < item.addons.length; i++) {
        int ind = addOnlist.indexOf(AddonList(
            '${item.addons[i].addon_id}'));
        if (ind != null && ind >= 0) {
          // setState(() {
          //
          // });
          item.addons[i].isAdd = true;
        }
      }
    }
    print(
        'list aaa - ${addOnlist.toString()}');
    // productDescriptionModalBottomSheet(context, MediaQuery.of(context).size.height,item,widget.currencySymbol);
  });




  return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder: (context, setState) {
            // incrementItem() {
            //   setState(() {
            //     initialItemCount = initialItemCount + 1;
            //     price = itemPrice * initialItemCount;
            //   });
            // }
            //
            // decrementItem() {
            //   if (initialItemCount > 1) {
            //     setState(() {
            //       initialItemCount = initialItemCount - 1;
            //       price = itemPrice * initialItemCount;
            //     });
            //   }
            // }


            setAddOrMinusProdcutQty(ResturantVarient items, BuildContext context, index, produtId, productName, qty) async {
              print('tb - ${qty}');
              DatabaseHelper db = DatabaseHelper.instance;
              db.getRestProductcount('${items.variant_id}').then((value) {
                print('value d - $value');
                var vae = {
                  DatabaseHelper.productId: produtId,
                  DatabaseHelper.varientId: '${items.variant_id}',
                  DatabaseHelper.productName: productName,
                  DatabaseHelper.price: ((double.parse('${items.price}')* qty)),
                  DatabaseHelper.addQnty: qty,
                  DatabaseHelper.unit: items.unit,
                  DatabaseHelper.quantitiy: items.quantity
                };
                if (value == 0) {
                  db.insertRaturantOrder(vae).then((valueaa) {
                    // setState(() {
                    //
                    // });

                    db.calculateTotalRestAdonA('${items.variant_id}').then((value1){
                      double pricedd = 0.0;
                      print('${value1}');
                      if(value!=null){
                        var tagObjsJson = value1 as List;
                        dynamic totalAmount_1 = tagObjsJson[0]['Total'];
                        print('${totalAmount_1}');
                        if(totalAmount_1!=null){
                          setState((){
                            pricedd = double.parse('${totalAmount_1}');
                            // item.varients[getIn].addOnQty = qty;
                            item.variant[getIn].addOnQty = qty;
                            price = (double.parse('${item.variant[getIn].price}') * qty)+pricedd;
                            // price = (double.parse('${item.variant[getIn].price}') * item.variant[getIn].addOnQty)+pricedd;
                          });
                        }else{
                          setState((){
                            item.variant[getIn].addOnQty = qty;
                            price = (double.parse('${item.variant[getIn].price}') * qty)+pricedd;
                          });
                        }

                      }
                      else{
                        setState((){
                          item.variant[getIn].addOnQty = qty;
                          price = (double.parse('${item.variant[getIn].price}') * qty)+pricedd;
                        });
                      }
                    });

                  });
                } else {
                  if (qty == 0) {
                    db.deleteResProduct('${items.variant_id}').then((value2) {
                      // setState(() {
                      //   item.variant[getIn].addOnQty = qty;
                      //   price = double.parse('${item.variant[getIn].price}') * qty;
                      // });
                      db.deleteAddOn(int.parse('${items.variant_id}')).then((value){
                        db.calculateTotalRestAdonA('${items.variant_id}').then((value1){
                          double pricedd = 0.0;
                          print('${value1}');
                          if(value!=null){
                            var tagObjsJson = value1 as List;
                            dynamic totalAmount_1 = tagObjsJson[0]['Total'];
                            print('${totalAmount_1}');
                            if(totalAmount_1!=null){
                              setState((){
                                pricedd = double.parse('${totalAmount_1}');
                                // item.varients[getIn].addOnQty = qty;
                                item.variant[getIn].addOnQty = qty;
                                price = (double.parse('${item.variant[getIn].price}') * qty)+pricedd;
                                // price = (double.parse('${item.variant[getIn].price}') * item.variant[getIn].addOnQty)+pricedd;
                              });
                            }else{
                              setState((){
                                item.variant[getIn].addOnQty = qty;
                                price = (double.parse('${item.variant[getIn].price}') * qty)+pricedd;
                              });
                            }

                          }
                          else{
                            setState((){
                              item.variant[getIn].addOnQty = qty;
                              price = (double.parse('${item.variant[getIn].price}') * qty)+pricedd;
                            });
                          }
                        });
                      });
                    });
                  } else {
                    db.updateRestProductData(vae, '${items.variant_id}')
                        .then((vay) {
                      print('vay - $vay');
                      // setState(() {
                      //
                      // });
                      db.calculateTotalRestAdonA('${items.variant_id}').then((value1){
                        double pricedd = 0.0;
                        print('${value1}');
                        if(value!=null){
                          var tagObjsJson = value1 as List;
                          dynamic totalAmount_1 = tagObjsJson[0]['Total'];
                          print('${totalAmount_1}');
                          if(totalAmount_1!=null){
                            setState((){
                              pricedd = double.parse('${totalAmount_1}');
                              item.variant[getIn].addOnQty = qty;
                              price = (double.parse('${item.variant[getIn].price}') * qty)+pricedd;
                              // price = (double.parse('${item.variant[getIn].price}') * item.variant[getIn].addOnQty)+pricedd;
                            });
                          }else{
                            setState((){
                              item.variant[getIn].addOnQty = qty;
                              price = (double.parse('${item.variant[getIn].price}') * qty)+pricedd;
                            });
                          }

                        }
                        else{
                          setState((){
                            item.variant[getIn].addOnQty = qty;
                            price = (double.parse('${item.variant[getIn].price}') * qty)+pricedd;
                          });
                        }
                      });
                    });
                  }
                }
              }).catchError((e) {
                print(e);
              });
            }

            Future<dynamic> setAddOnToDatabase(isSelected, DatabaseHelper db, AddOns addon, variant_id, int indexaa) async {
              var vae = {
                DatabaseHelper.varientId: '${variant_id}',
                DatabaseHelper.addonid: '${addon.addon_id}',
                DatabaseHelper.price: addon.addon_price,
                DatabaseHelper.addonName: addon.addon_name
              };
              await db.insertAddOn(vae).then((value) {
                print('addon add $value');
                if (value != null && value == 1) {
                  db.calculateTotalRestAdonA('${variant_id}').then((value1){
                    double pricedd = 0.0;
                    print('${value1}');
                    if(value!=null){
                      var tagObjsJson = value1 as List;
                      dynamic totalAmount_1 = tagObjsJson[0]['Total'];
                      print('${totalAmount_1}');
                      if(totalAmount_1!=null){
                        setState((){
                          item.addons[indexaa].isAdd = true;
                          // addon.isAdd = true;
                          isSelected = true;
                          pricedd = double.parse('${totalAmount_1}');
                          // item.varients[getIn].addOnQty = qty;
                          price = (double.parse('${item.variant[getIn].price}') * item.variant[getIn].addOnQty)+pricedd;
                        });
                      }else{
                        setState((){
                          item.addons[indexaa].isAdd = true;
                          // addon.isAdd = true;
                          isSelected = true;
                          // item.varients[getIn].addOnQty = qty;
                          price = (double.parse('${item.variant[getIn].price}') * item.variant[getIn].addOnQty)+pricedd;
                        });
                      }

                    }
                    else{
                      setState((){
                        item.addons[indexaa].isAdd = true;
                        // addon.isAdd = true;
                        isSelected = true;
                        price = (double.parse('${item.variant[getIn].price}') * item.variant[getIn].addOnQty)+pricedd;
                      });
                    }
                  });
                }
                else {
                  db.calculateTotalRestAdonA('${variant_id}').then((value1){
                    double pricedd = 0.0;
                    print('${value1}');
                    if(value!=null){
                      var tagObjsJson = value1 as List;
                      dynamic totalAmount_1 = tagObjsJson[0]['Total'];
                      print('${totalAmount_1}');
                      if(totalAmount_1!=null){
                        setState((){
                          item.addons[indexaa].isAdd = false;
                          // addon.isAdd = false;
                          isSelected = false;
                          pricedd = double.parse('${totalAmount_1}');
                          // item.varients[getIn].addOnQty = qty;
                          price = (double.parse('${item.variant[getIn].price}') * item.variant[getIn].addOnQty)+pricedd;
                        });
                      }else{
                        setState((){
                          item.addons[indexaa].isAdd = false;
                          // addon.isAdd = false;
                          isSelected = false;
                          // item.varients[getIn].addOnQty = qty;
                          price = (double.parse('${item.variant[getIn].price}') * item.variant[getIn].addOnQty)+pricedd;
                        });
                      }

                    }
                    else{
                      setState((){
                        item.addons[indexaa].isAdd = false;
                        // addon.isAdd = false;
                        isSelected = false;
                        price = (double.parse('${item.variant[getIn].price}') * item.variant[getIn].addOnQty)+pricedd;
                      });
                    }
                  });

                }
                return value;
              }).catchError((e) {
                return null;
              });
            }

            Future<dynamic> deleteAddOn(isSelected, DatabaseHelper db, AddOns addon, variant_id, int indexaa) async {
              await db.deleteAddOnId('${addon.addon_id}').then((value) {
                print('addon delete $value');
                if (value != null && value>0) {
                  db.calculateTotalRestAdonA('${variant_id}').then((value1){
                    double pricedd = 0.0;
                    print('${value1}');
                    if(value!=null){
                      var tagObjsJson = value1 as List;
                      dynamic totalAmount_1 = tagObjsJson[0]['Total'];
                      print('${totalAmount_1}');
                      if(totalAmount_1!=null){
                        setState((){
                          item.addons[indexaa].isAdd = false;
                          isSelected = false;
                          pricedd = double.parse('${totalAmount_1}');
                          // item.varients[getIn].addOnQty = qty;
                          price = (double.parse('${item.variant[getIn].price}') * item.variant[getIn].addOnQty)+pricedd;
                        });
                      }else{
                        setState((){
                          item.addons[indexaa].isAdd = false;
                          isSelected = false;
                          // item.varients[getIn].addOnQty = qty;
                          price = (double.parse('${item.variant[getIn].price}') * item.variant[getIn].addOnQty)+pricedd;
                        });
                      }

                    }
                    else{
                      setState((){
                        item.addons[indexaa].isAdd = false;
                        isSelected = false;
                        price = (double.parse('${item.variant[getIn].price}') * item.variant[getIn].addOnQty)+pricedd;
                      });
                    }
                  });

                }
                else {
                  db.calculateTotalRestAdonA('${variant_id}').then((value1){
                    double pricedd = 0.0;
                    print('${value1}');
                    if(value!=null){
                      var tagObjsJson = value1 as List;
                      dynamic totalAmount_1 = tagObjsJson[0]['Total'];
                      print('${totalAmount_1}');
                      if(totalAmount_1!=null){
                        setState((){
                          item.addons[indexaa].isAdd = true;
                          isSelected = true;
                          pricedd = double.parse('${totalAmount_1}');
                          // item.varients[getIn].addOnQty = qty;
                          price = (double.parse('${item.variant[getIn].price}') * item.variant[getIn].addOnQty)+pricedd;
                        });
                      }else{
                        setState((){
                          item.addons[indexaa].isAdd = true;
                          isSelected = true;
                          // item.varients[getIn].addOnQty = qty;
                          price = (double.parse('${item.variant[getIn].price}') * item.variant[getIn].addOnQty)+pricedd;
                        });
                      }

                    }
                    else{
                      setState((){
                        item.addons[indexaa].isAdd = true;
                        isSelected = true;
                        price = (double.parse('${item.variant[getIn].price}') * item.variant[getIn].addOnQty)+pricedd;
                      });
                    }
                  });
                }
                return value;
              }).catchError((e) {
                return null;
              });
            }

            // getAddOnItem(bool isSelected, String qty, String price, int indexaa,
            //     AddOns addon, variant_id) {
            //   var aqty = '';
            //   return Padding(
            //     padding: EdgeInsets.only(right: fixPadding, left: fixPadding),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       crossAxisAlignment: CrossAxisAlignment.center,
            //       children: <Widget>[
            //         Row(
            //           mainAxisAlignment: MainAxisAlignment.start,
            //           crossAxisAlignment: CrossAxisAlignment.center,
            //           children: <Widget>[
            //             InkWell(
            //               onTap: () async {
            //                 if (item.variant[getIn].addOnQty > 0) {
            //                   DatabaseHelper db = DatabaseHelper.instance;
            //                   db.getCountAddon('${addon.addon_id}').then((value) {
            //                     print('addon count $value');
            //                     if (value != null && value > 0) {
            //                       deleteAddOn(isSelected, db, addon, variant_id,indexaa)
            //                           .then((value) {
            //                         print('addon deleted $value');
            //                       }).catchError((e) {
            //                         print(e);
            //                       });
            //                     } else {
            //                       setAddOnToDatabase(
            //                               isSelected, db, addon, variant_id,indexaa)
            //                           .then((value) {
            //                         print('addon addd $value');
            //                       }).catchError((e) {
            //                         print(e);
            //                       });
            //                     }
            //                   }).catchError((e) {
            //                     print(e);
            //                   });
            //                 } else {
            //                   Toast.show(
            //                       'Add first product to add addon!', context,
            //                       duration: Toast.LENGTH_SHORT);
            //                 }
            //               },
            //               child: Container(
            //                 width: 26.0,
            //                 height: 26.0,
            //                 decoration: BoxDecoration(
            //                     color: (addon.isAdd) ? kMainColor : kWhiteColor,
            //                     borderRadius: BorderRadius.circular(13.0),
            //                     border: Border.all(
            //                         width: 1.0,
            //                         color: kHintColor.withOpacity(0.7))),
            //                 child: Icon(Icons.check,
            //                     color: kWhiteColor, size: 15.0),
            //               ),
            //             ),
            //             // widthSpace,
            //             // Text(
            //             //   'Size $size',
            //             //   style: listItemTitleStyle,
            //             // ),
            //             widthSpace,
            //             Text(
            //               '$qty',
            //               style: listItemTitleStyle,
            //             ),
            //           ],
            //         ),
            //         Text(
            //           '${currencySymbol} $price',
            //           style: listItemTitleStyle,
            //         ),
            //       ],
            //     ),
            //   );
            // }

            return Wrap(
              children: <Widget>[
                Container(
                  // height: height - 100.0,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                    color: kWhiteColor,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(fixPadding),
                        alignment: Alignment.center,
                        child: Container(
                          width: 35.0,
                          height: 3.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.0),
                            color: kHintColor,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(fixPadding),
                        child: Text(
                          'Add New Item',
                          style: headingStyle,
                        ),
                      ),
                      Container(
                        width: width,
                        margin: EdgeInsets.all(fixPadding),
                        decoration: BoxDecoration(
                          color: kWhiteColor,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: 70.0,
                              width: 70.0,
                              alignment: Alignment.topRight,
                              padding: EdgeInsets.all(fixPadding),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Image.network(
                                imageBaseUrl + item.product_image,
                                fit: BoxFit.fill,
                              ),
                            ),
                            Container(
                              width: width - ((fixPadding * 2) + 70.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(
                                        right: fixPadding * 2,
                                        left: fixPadding,
                                        bottom: fixPadding),
                                    child: Text(
                                      '${item.product_name}',
                                      style: listItemTitleStyle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        right: fixPadding * 2,
                                        left: fixPadding,
                                        bottom: fixPadding),
                                    child: Text(
                                      '${item.description}',
                                      style: listItemTitleStyle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        right: fixPadding * 2,
                                        left: fixPadding,
                                        bottom: fixPadding),
                                    child: Text(
                                      '(${item.variant[getIn].quantity} ${item.variant[getIn].unit})',
                                      style: listItemTitleStyle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: fixPadding,
                                        right: fixPadding,
                                        left: fixPadding),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          '${currencySymbol} ${item.variant[getIn].price}',
                                          style: priceStyle,
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            InkWell(
                                              // onTap: decrementItem,
                                              onTap: () {
                                                if (item.variant[getIn]
                                                        .addOnQty <=
                                                    0) {
                                                  print('in less then zero');
                                                } else {
                                                  setAddOrMinusProdcutQty(
                                                      item.variant[getIn],
                                                      context,
                                                      getIn,
                                                      item.product_id,
                                                      item.product_name,
                                                      (item.variant[getIn]
                                                              .addOnQty -
                                                          1));
                                                }
                                              },
                                              child: Container(
                                                height: 26.0,
                                                width: 26.0,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          13.0),
                                                  color: (item.variant[getIn]
                                                              .addOnQty ==
                                                          0)
                                                      ? Colors.grey[300]
                                                      : kMainColor,
                                                ),
                                                child: Icon(
                                                  Icons.remove,
                                                  color: (item.variant[getIn]
                                                              .addOnQty ==
                                                          0)
                                                      ? kMainTextColor
                                                      : kWhiteColor,
                                                  size: 15.0,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  right: 8.0, left: 8.0),
                                              child: Text(
                                                  '${item.variant[getIn].addOnQty}'),
                                            ),
                                            InkWell(
                                              // onTap: incrementItem(),
                                              onTap: () {
                                                setAddOrMinusProdcutQty(
                                                    item.variant[getIn],
                                                    context,
                                                    getIn,
                                                    item.product_id,
                                                    item.product_name,
                                                    (item.variant[getIn]
                                                            .addOnQty +
                                                        1));
                                              },
                                              child: Container(
                                                height: 26.0,
                                                width: 26.0,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          13.0),
                                                  color: kMainColor,
                                                ),
                                                child: Icon(
                                                  Icons.add,
                                                  color: kWhiteColor,
                                                  size: 15.0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      heightSpace,
                      // Size Start
                      // Container(
                      //   color: kCardBackgroundColor,
                      //   padding: EdgeInsets.all(fixPadding),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     crossAxisAlignment: CrossAxisAlignment.center,
                      //     children: <Widget>[
                      //       Text(
                      //         'Varient',
                      //         style: listItemSubTitleStyle,
                      //       ),
                      //       Text(
                      //         'Price',
                      //         style: listItemSubTitleStyle,
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // Container(
                      //     color: kWhiteColor,
                      //     child:
                      //         (item.variant != null && item.variant.length > 0)
                      //             ? ListView.separated(
                      //                 shrinkWrap: true,
                      //                 itemCount: item.variant.length,
                      //                 itemBuilder: (context, index) {
                      //                   return getSizeListItem(
                      //                       (item.variant[index].isSelected!=null && item.variant[index].isSelected)?true:false,
                      //                       '${item.variant[index].quantity} ${item.variant[index].unit}',
                      //                       '${item.variant[index].price}',index,item.variant[index]);
                      //                 },
                      //                 separatorBuilder: (context, ind) {
                      //                   return heightSpace;
                      //                 },
                      //               )
                      //             : Container()),
                      // Size End
                      // Options Start
                      Container(
                        width: width,
                        color: kCardBackgroundColor,
                        padding: EdgeInsets.all(fixPadding),
                        child: Text(
                          'Options',
                          style: listItemSubTitleStyle,
                        ),
                      ),
                      Container(
                        color: kWhiteColor,
                        child: (item.addons != null && item.addons.length > 0)
                            ? ListView.separated(
                                shrinkWrap: true,
                                itemCount: item.addons.length,
                                itemBuilder: (context, indexw) {
                                  // item.addons[index].isAdd = addOnlist.contains(AddonList(item.addons[index].addon_id))?true:false;
                                  return
                                    Padding(
                                      padding: EdgeInsets.only(right: fixPadding, left: fixPadding),
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
                                                  if (item.variant[getIn].addOnQty > 0) {
                                                    DatabaseHelper db = DatabaseHelper.instance;
                                                    db.getCountAddon('${item.addons[indexw].addon_id}').then((value) {
                                                      print('addon count $value');
                                                      if (value != null && value > 0) {
                                                        deleteAddOn((item.addons[indexw].isAdd != null && item.addons[indexw].isAdd) ? true : false, db, item.addons[indexw], item.variant[getIn].variant_id,indexw)
                                                            .then((value) {
                                                          print('addon deleted $value');
                                                        }).catchError((e) {
                                                          print(e);
                                                        });
                                                      } else {
                                                        // setAddOnToDatabase(
                                                        //     (item.addons[indexw].isAdd != null && item.addons[indexw].isAdd) ? true : false, db, item.addons[indexw], item.variant[getIn].variant_id,indexw)
                                                        //     .then((value) {
                                                        //   print('addon addd $value');
                                                        // }).catchError((e) {
                                                        //   print(e);
                                                        // });
                                                        var vae = {
                                                          DatabaseHelper.varientId: '${item.variant[getIn].variant_id}',
                                                          DatabaseHelper.addonid: '${item.addons[indexw].addon_id}',
                                                          DatabaseHelper.price: item.addons[indexw].addon_price,
                                                          DatabaseHelper.addonName: item.addons[indexw].addon_name
                                                        };
                                                        db.insertAddOn(vae).then((value) {
                                                          print('addon add $value');
                                                          if (value != null && value>0) {
                                                            // setState(() {
                                                            //
                                                            //   // addon.isAdd = true;
                                                            //   // isSelected = true;
                                                            // });
                                                            db.calculateTotalRestAdonA('${item.variant[getIn].variant_id}').then((value1){
                                                              double pricedd = 0.0;
                                                              print('${value1}');
                                                              if(value!=null){
                                                                var tagObjsJson = value1 as List;
                                                                dynamic totalAmount_1 = tagObjsJson[0]['Total'];
                                                                print('${totalAmount_1}');
                                                                if(totalAmount_1!=null){
                                                                  setState((){
                                                                    item.addons[indexw].isAdd = true;
                                                                    pricedd = double.parse('${totalAmount_1}');
                                                                    // item.varients[getIn].addOnQty = qty;
                                                                    price = (double.parse('${item.variant[getIn].price}') * item.variant[getIn].addOnQty)+pricedd;
                                                                  });
                                                                }else{
                                                                  setState((){
                                                                    item.addons[indexw].isAdd = true;
                                                                    // item.varients[getIn].addOnQty = qty;
                                                                    price = (double.parse('${item.variant[getIn].price}') * item.variant[getIn].addOnQty)+pricedd;
                                                                  });
                                                                }

                                                              }
                                                              else{
                                                                setState((){
                                                                  item.addons[indexw].isAdd = true;
                                                                  price = (double.parse('${item.variant[getIn].price}') * item.variant[getIn].addOnQty)+pricedd;
                                                                });
                                                              }
                                                            });
                                                          }
                                                          else {
                                                            // setState(() {
                                                            //
                                                            //   // addon.isAdd = false;
                                                            //   // isSelected = false;
                                                            // });
                                                            db.calculateTotalRestAdonA('${item.variant[getIn].variant_id}').then((value1){
                                                              double pricedd = 0.0;
                                                              print('${value1}');
                                                              if(value!=null){
                                                                var tagObjsJson = value1 as List;
                                                                dynamic totalAmount_1 = tagObjsJson[0]['Total'];
                                                                print('${totalAmount_1}');
                                                                if(totalAmount_1!=null){
                                                                  setState((){
                                                                    item.addons[indexw].isAdd = false;
                                                                    pricedd = double.parse('${totalAmount_1}');
                                                                    // item.varients[getIn].addOnQty = qty;
                                                                    price = (double.parse('${item.variant[getIn].price}') * item.variant[getIn].addOnQty)+pricedd;
                                                                  });
                                                                }else{
                                                                  setState((){
                                                                    item.addons[indexw].isAdd = false;
                                                                    // item.varients[getIn].addOnQty = qty;
                                                                    price = (double.parse('${item.variant[getIn].price}') * item.variant[getIn].addOnQty)+pricedd;
                                                                  });
                                                                }

                                                              }
                                                              else{
                                                                setState((){
                                                                  item.addons[indexw].isAdd = false;
                                                                  price = (double.parse('${item.variant[getIn].price}') * item.variant[getIn].addOnQty)+pricedd;
                                                                });
                                                              }
                                                            });
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
                                                      color: (item.addons[indexw].isAdd) ? kMainColor : kWhiteColor,
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
                                              widthSpace,
                                              Text(
                                                '${item.addons[indexw].addon_name}',
                                                style: listItemTitleStyle,
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '${currencySymbol} ${item.addons[indexw].addon_price}',
                                            style: listItemTitleStyle,
                                          ),
                                        ],
                                      ),
                                    );
                                    // getAddOnItem(
                                    //   (item.addons[indexw].isAdd != null && item.addons[indexw].isAdd) ? true : false,
                                    //   // addOnlist.contains(AddonList(item.addons[index].addon_id))?true:false,
                                    //   '${item.addons[indexw].addon_name}',
                                    //   '${item.addons[indexw].addon_price}',
                                    //   indexw,
                                    //   item.addons[indexw],
                                    //   item.variant[getIn].variant_id);
                                },
                                separatorBuilder: (context, ind) {
                                  return heightSpace;
                                },
                              )
                            : Container(),
                      ),
                      // Options End
                      // Add to Cart button row start here
                      Padding(
                        padding: EdgeInsets.all(fixPadding),
                        child: InkWell(
                          onTap: () async {
                            DatabaseHelper db = DatabaseHelper.instance;
                            db.queryResturantProdCount().then((value) {
                              if (value != null && value > 0) {
                              } else {
                                Toast.show(
                                    'Add some product into cart to continue!',
                                    context,
                                    duration: Toast.LENGTH_SHORT);
                              }
                            });
                            // Navigator.of(context).pushNamed()
                          },
                          child: Container(
                            width: width - (fixPadding * 2),
                            padding: EdgeInsets.all(fixPadding),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: kMainColor,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      '${item.variant[getIn].addOnQty} ITEM',
                                      style: TextStyle(
                                        color: kWhiteColor,
                                        fontFamily: 'OpenSans',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15.0,
                                      ),
                                    ),
                                    SizedBox(height: 3.0),
                                    Text(
                                      '${currencySymbol} $price',
                                      style: whiteSubHeadingStyle,
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: (){
                                    if (item.variant[getIn].addOnQty>0) {
                                      Navigator.of(context).pop();
                                      Navigator.pushNamed(context, PageRoutes.restviewCart).then((value){
                                        onVerificationDone;
                                      });
                                    } else {
                                      Toast.show('No Value in the cart!', context,
                                          duration: Toast.LENGTH_SHORT);
                                    }
                                  },
                                  child: Text(
                                    'Go to Cart',
                                    style: wbuttonWhiteTextStyle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Add to Cart button row end here
                    ],
                  ),
                ),
              ],
            );
          },
        );
      });
}
