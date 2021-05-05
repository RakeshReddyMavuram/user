import 'dart:async';

import 'package:flutter/material.dart';
import 'package:user/Components/custom_appbar.dart';
import 'package:user/Pages/view_cart.dart';
import 'package:user/Themes/colors.dart';
import 'package:user/databasehelper/dbhelper.dart';
import 'package:user/restaturantui/resturant_cart.dart';

class CombineCart extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CombineCartState();
  }
}

class CombineCartState extends State<CombineCart> with SingleTickerProviderStateMixin{
  List<Tab> tabs = <Tab>[];
  TabController tabController;
  StreamController<String> streamController = StreamController.broadcast();
  int currentIndex = 0;

  @override
  void initState() {
    tabs.add(Tab(
      text: 'Grocery',
    ));
    tabs.add(Tab(
      text: 'Restaurant',
    ));
    super.initState();
    tabController = TabController(length: tabs.length, vsync: this);
    tabController.addListener(() {
      if(!tabController.indexIsChanging){

      }
    });
  }

  @override
  void dispose() {
    streamController.close();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(106.0),
          child: CustomAppBar(
            titleWidget: Text('Confirm Order',
                style: Theme.of(context).textTheme.bodyText1),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 10, top: 10, bottom: 10),
                child: RaisedButton(
                  onPressed: () {
                    clearCart(tabController.index);
                  },
                  child: Text(
                    'Clear Cart',
                    style: TextStyle(
                        color: kWhiteColor, fontWeight: FontWeight.w400),
                  ),
                  color: kMainColor,
                  highlightColor: kMainColor,
                  focusColor: kMainColor,
                  splashColor: kMainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(0.0),
              child:
              TabBar(
                tabs: tabs,
                isScrollable: false,
                labelColor: kMainColor,
                unselectedLabelColor: kLightTextColor,
                controller: tabController,
                indicatorPadding: EdgeInsets.symmetric(horizontal: 24.0),
              ),
              // Row(
              //   children: <Widget>[
              //     GestureDetector(
              //       onTap: () {
              //         setState(() {
              //           currentIndex = 0;
              //         });
              //       },
              //       child: Container(
              //         width: MediaQuery.of(context).size.width / 2,
              //         color: (currentIndex == 0) ? kMainColor : kWhiteColor,
              //         height: 52,
              //         alignment: Alignment.center,
              //         child: Text('Grocery',
              //             style: Theme.of(context).textTheme.bodyText1.copyWith(color: (currentIndex == 0) ? kWhiteColor : kMainTextColor,fontWeight: FontWeight.w300)),
              //       ),
              //     ),
              //     GestureDetector(
              //       onTap: () {
              //         setState(() {
              //           currentIndex = 1;
              //         });
              //       },
              //       child: Container(
              //         width: MediaQuery.of(context).size.width / 2,
              //         color: (currentIndex == 1) ? kMainColor : kWhiteColor,
              //         height: 52,
              //         alignment: Alignment.center,
              //         child: Text('Restaurant',
              //             style: Theme.of(context).textTheme.bodyText1.copyWith(color: (currentIndex == 1) ? kWhiteColor : kMainTextColor,fontWeight: FontWeight.w300)),
              //       ),
              //     )
              //   ],
              // ),
            ),
          ),
        ),
        body:
        DefaultTabController(
          length: tabs.length,
          child: TabBarView(
            controller: tabController,
            children: tabs.map((Tab tab) {
              if(tab.text=='Grocery'){
                return ViewCart();
              }else if(tab.text=='Restaurant'){
                return RestuarantViewCart();
              }else{
                return Container();
              }
            }).toList(),
          ),
        )
        // IndexedStack(
        //   index: currentIndex,
        //   children: [ViewCart(),RestuarantViewCart()],
        // )
    );
  }

  void clearCart(int index) async {
    if(index==1){
      setState(() {
        tabs[1] = Tab(
          text: '',
        );
      });
    }else if(index==0){
      setState(() {
        tabs[0] = Tab(
          text: '',
        );
      });
    }
    DatabaseHelper db = DatabaseHelper.instance;
    if(index == 0){
      db.deleteAll().then((value) {
        setState(() {
          tabs[0] = Tab(
            text: 'Grocery',
          );
        });
      });
    }else if(index == 1){
      db.deleteAllRestProdcut().then((value) {
        setState(() {
          tabs[1] = Tab(
            text: 'Restaurant',
          );
        });
      });
    }
  }
}
