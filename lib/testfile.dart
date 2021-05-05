/*
Visibility(
visible: ((onParcelCompleted != null &&
onParcelCompleted.length > 0) ||
(onRestCompleted != null &&
onRestCompleted.length > 0) ||
(onCompleted != null &&
onCompleted.length > 0) ||
(onPharmaCompleted != null &&
onPharmaCompleted.length > 0))
? true
: false,
child: Column(
children: [
Container(
width: MediaQuery.of(context).size.width,
color: kCardBackgroundColor,
padding: EdgeInsets.only(
left: 15.0, bottom: 10.0, top: 10),
child: Text(
'Completed Orders',
style: TextStyle(
color: kMainTextColor, fontSize: 15.0),
),
),
ListView.builder(
shrinkWrap: true,
primary: false,
itemBuilder: (context, t) {
return GestureDetector(
onTap: () {
if (onCompleted[t].order_status ==
'Cancelled') {
} else {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => OrderMapPage(
pageTitle:
'${onGoingOrders[t].vendor_name}',
ongoingOrders: onGoingOrders[t],
currency: currency,
),
),
).then((value) {
getAllThreeData();
});
}
},
behavior: HitTestBehavior.opaque,
child: Container(
child: Column(
children: [
Row(
children: <Widget>[
Padding(
padding: const EdgeInsets.only(
left: 16.3),
child: Image.asset(
'images/maincategory/vegetables_fruitsact.png',
height: 42.3,
width: 33.7,
),
),
Expanded(
child: ListTile(
title: Text(
'Order Id - #${onCompleted[t].cart_id}',
style:
orderMapAppBarTextStyle
    .copyWith(
letterSpacing:
0.07),
),
subtitle: Text(
(onCompleted[t].delivery_date !=
null &&
onCompleted[t]
    .time_slot !=
null)
? '${onCompleted[t].delivery_date} | ${onCompleted[t].time_slot}'
    : '',
// '${onCompleted[t]
//     .delivery_date} | ${onCompleted[t]
//     .time_slot}',
style: Theme.of(context)
    .textTheme
    .headline6
    .copyWith(
fontSize: 11.7,
letterSpacing: 0.06,
color: Color(
0xffc1c1c1)),
),
trailing: Column(
mainAxisAlignment:
MainAxisAlignment
    .center,
children: <Widget>[
Text(
'${onCompleted[t].order_status}',
style: orderMapAppBarTextStyle
    .copyWith(
color:
kMainColor),
),
SizedBox(height: 7.0),
Text(
'${onCompleted[t].data.length} items | $currency ${onCompleted[t].price}',
style: Theme.of(context)
    .textTheme
    .headline6
    .copyWith(
fontSize: 11.7,
letterSpacing:
0.06,
color: Color(
0xffc1c1c1)),
)
],
),
),
)
],
),
Divider(
color: kCardBackgroundColor,
thickness: 1.0,
),
Row(
children: <Widget>[
Padding(
padding: EdgeInsets.only(
left: 36.0,
bottom: 6.0,
top: 12.0,
right: 12.0),
child: ImageIcon(
AssetImage(
'images/custom/ic_pickup_pointact.png'),
size: 13.3,
color: kMainColor,
),
),
//                              Text(
//                                'Grocery\t',
//                                style: orderMapAppBarTextStyle.copyWith(
//                                    fontSize: 10.0, letterSpacing: 0.05),
//                              ),
Text(
'${onCompleted[t].vendor_name}',
style: Theme.of(context)
    .textTheme
    .caption
    .copyWith(
fontSize: 10.0,
letterSpacing: 0.05),
),
],
),
Row(
children: <Widget>[
Padding(
padding: EdgeInsets.only(
left: 36.0,
bottom: 12.0,
top: 12.0,
right: 12.0),
child: ImageIcon(
AssetImage(
'images/custom/ic_droppointact.png'),
size: 13.3,
color: kMainColor,
),
),
//                              Text(
//                                'Home\t',
//                                style: orderMapAppBarTextStyle.copyWith(
//                                    fontSize: 10.0, letterSpacing: 0.05),
//                              ),
Expanded(
child: Text(
'${onCompleted[t].address}',
style: Theme.of(context)
    .textTheme
    .caption
    .copyWith(
fontSize: 10.0,
letterSpacing: 0.05),
),
),
],
),
(onCompleted.length - 1 == t)
? Divider(
color: kCardBackgroundColor,
thickness: 0.0,
)
    : Divider(
color: kCardBackgroundColor,
thickness: 13.3,
),
],
),
),
);
},
// separatorBuilder: (context, t2) {
//   return t2 == (onCompleted.length - 1) ? Container(
//     height: 20,
//   ) : Container(
//     height: 10,
//   );
// },
itemCount: onCompleted.length),
Visibility(
visible: (onRestCompleted != null &&
onRestCompleted.length > 0)
? true
: false,
child: ListView.builder(
shrinkWrap: true,
primary: false,
itemBuilder: (context, t) {
return GestureDetector(
onTap: () {
if (onRestCompleted[t].order_status ==
'Cancelled') {
} else {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) =>
OrderMapRestPage(
pageTitle:
'${onRestCompleted[t].vendor_name}',
ongoingOrders:
onRestCompleted[t],
currency: currency,
),
),
).then((value) {
getAllThreeData();
});
}
},
behavior: HitTestBehavior.opaque,
child: Container(
child: Column(
children: [
Row(
children: <Widget>[
Padding(
padding:
const EdgeInsets.only(
left: 16.3),
child: Image.asset(
'images/maincategory/vegetables_fruitsact.png',
height: 42.3,
width: 33.7,
),
),
Expanded(
child: ListTile(
title: Text(
'Order Id - #${onRestCompleted[t].cart_id}',
style:
orderMapAppBarTextStyle
    .copyWith(
letterSpacing:
0.07),
),
subtitle: Text(
// '${onCancelOrders[t]
//     .delivery_date} | ${onCancelOrders[t]
//     .time_slot}',
(onRestCompleted[t]
    .delivery_date !=
null &&
onRestCompleted[
t]
    .time_slot !=
null)
? '${onRestCompleted[t].delivery_date} | ${onRestCompleted[t].time_slot}'
    : '',
style: Theme.of(context)
    .textTheme
    .headline6
    .copyWith(
fontSize: 11.7,
letterSpacing:
0.06,
color: Color(
0xffc1c1c1)),
),
trailing: Column(
mainAxisAlignment:
MainAxisAlignment
    .center,
children: <Widget>[
Text(
'${onRestCompleted[t].order_status}',
style: orderMapAppBarTextStyle
    .copyWith(
color:
kMainColor),
),
SizedBox(height: 7.0),
Text(
'${onRestCompleted[t].data.length} items | $currency ${onRestCompleted[t].price}',
style: Theme.of(
context)
    .textTheme
    .headline6
    .copyWith(
fontSize:
11.7,
letterSpacing:
0.06,
color: Color(
0xffc1c1c1)),
)
],
),
),
)
],
),
Divider(
color: kCardBackgroundColor,
thickness: 1.0,
),
Row(
children: <Widget>[
Padding(
padding: EdgeInsets.only(
left: 36.0,
bottom: 6.0,
top: 12.0,
right: 12.0),
child: ImageIcon(
AssetImage(
'images/custom/ic_pickup_pointact.png'),
size: 13.3,
color: kMainColor,
),
),
//                              Text(
//                                'Grocery\t',
//                                style: orderMapAppBarTextStyle.copyWith(
//                                    fontSize: 10.0, letterSpacing: 0.05),
//                              ),
Text(
'${onRestCompleted[t].vendor_name}',
style: Theme.of(context)
    .textTheme
    .caption
    .copyWith(
fontSize: 10.0,
letterSpacing:
0.05),
),
],
),
Row(
children: <Widget>[
Padding(
padding: EdgeInsets.only(
left: 36.0,
bottom: 12.0,
top: 12.0,
right: 12.0),
child: ImageIcon(
AssetImage(
'images/custom/ic_droppointact.png'),
size: 13.3,
color: kMainColor,
),
),
//                              Text(
//                                'Home\t',
//                                style: orderMapAppBarTextStyle.copyWith(
//                                    fontSize: 10.0, letterSpacing: 0.05),
//                              ),
Expanded(
child: Text(
'${onRestCompleted[t].address}',
style: Theme.of(context)
    .textTheme
    .caption
    .copyWith(
fontSize: 10.0,
letterSpacing:
0.05),
),
),
],
),
(onRestCompleted.length - 1 == t)
? Divider(
color:
kCardBackgroundColor,
thickness: 0.0,
)
    : Divider(
color:
kCardBackgroundColor,
thickness: 13.3,
),
],
),
),
);
},
// separatorBuilder: (context, t2) {
//   return t2 == (onCancelOrders.length) ? Container(
//     height: 20,
//     color: kWhiteColor,
//   ) : Container(
//     height: 10,
//     color: kWhiteColor,
//   );
// },
itemCount: onRestCompleted.length)),
Visibility(
visible: (onPharmaCompleted != null &&
onPharmaCompleted.length > 0)
? true
: false,
child: ListView.builder(
shrinkWrap: true,
primary: false,
itemBuilder: (context, t) {
return GestureDetector(
onTap: () {
if (onPharmaCompleted[t]
    .order_status ==
'Cancelled') {
} else {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) =>
OrderMapPharmaPage(
pageTitle:
'${onPharmaCompleted[t].vendor_name}',
ongoingOrders:
onPharmaCompleted[t],
currency: currency,
),
),
).then((value) {
getAllThreeData();
});
}
},
behavior: HitTestBehavior.opaque,
child: Container(
child: Column(
children: [
Row(
children: <Widget>[
Padding(
padding:
const EdgeInsets.only(
left: 16.3),
child: Image.asset(
'images/maincategory/vegetables_fruitsact.png',
height: 42.3,
width: 33.7,
),
),
Expanded(
child: ListTile(
title: Text(
'Order Id - #${onPharmaCompleted[t].cart_id}',
style:
orderMapAppBarTextStyle
    .copyWith(
letterSpacing:
0.07),
),
subtitle: Text(
// '${onCancelOrders[t]
//     .delivery_date} | ${onCancelOrders[t]
//     .time_slot}',
(onPharmaCompleted[t]
    .delivery_date !=
null &&
onPharmaCompleted[
t]
    .time_slot !=
null)
? '${onPharmaCompleted[t].delivery_date} | ${onPharmaCompleted[t].time_slot}'
    : '',
style: Theme.of(context)
    .textTheme
    .headline6
    .copyWith(
fontSize: 11.7,
letterSpacing:
0.06,
color: Color(
0xffc1c1c1)),
),
trailing: Column(
mainAxisAlignment:
MainAxisAlignment
    .center,
children: <Widget>[
Text(
'${onPharmaCompleted[t].order_status}',
style: orderMapAppBarTextStyle
    .copyWith(
color:
kMainColor),
),
SizedBox(height: 7.0),
Text(
'${onPharmaCompleted[t].data.length} items | $currency ${onPharmaCompleted[t].price}',
style: Theme.of(
context)
    .textTheme
    .headline6
    .copyWith(
fontSize:
11.7,
letterSpacing:
0.06,
color: Color(
0xffc1c1c1)),
)
],
),
),
)
],
),
Divider(
color: kCardBackgroundColor,
thickness: 1.0,
),
Row(
children: <Widget>[
Padding(
padding: EdgeInsets.only(
left: 36.0,
bottom: 6.0,
top: 12.0,
right: 12.0),
child: ImageIcon(
AssetImage(
'images/custom/ic_pickup_pointact.png'),
size: 13.3,
color: kMainColor,
),
),
//                              Text(
//                                'Grocery\t',
//                                style: orderMapAppBarTextStyle.copyWith(
//                                    fontSize: 10.0, letterSpacing: 0.05),
//                              ),
Text(
'${onPharmaCompleted[t].vendor_name}',
style: Theme.of(context)
    .textTheme
    .caption
    .copyWith(
fontSize: 10.0,
letterSpacing:
0.05),
),
],
),
Row(
children: <Widget>[
Padding(
padding: EdgeInsets.only(
left: 36.0,
bottom: 12.0,
top: 12.0,
right: 12.0),
child: ImageIcon(
AssetImage(
'images/custom/ic_droppointact.png'),
size: 13.3,
color: kMainColor,
),
),
//                              Text(
//                                'Home\t',
//                                style: orderMapAppBarTextStyle.copyWith(
//                                    fontSize: 10.0, letterSpacing: 0.05),
//                              ),
Expanded(
child: Text(
'${onPharmaCompleted[t].address}',
style: Theme.of(context)
    .textTheme
    .caption
    .copyWith(
fontSize: 10.0,
letterSpacing:
0.05),
),
),
],
),
(onPharmaCompleted.length - 1 ==
t)
? Divider(
color:
kCardBackgroundColor,
thickness: 0.0,
)
    : Divider(
color:
kCardBackgroundColor,
thickness: 13.3,
),
],
),
),
);
},
// separatorBuilder: (context, t2) {
//   return t2 == (onCancelOrders.length) ? Container(
//     height: 20,
//     color: kWhiteColor,
//   ) : Container(
//     height: 10,
//     color: kWhiteColor,
//   );
// },
itemCount: onPharmaCompleted.length)),
Visibility(
visible: (onParcelCompleted != null &&
onParcelCompleted.length > 0)
? true
: false,
child: Column(
children: [
Divider(
color: kCardBackgroundColor,
thickness: 13.3,
),
ListView.builder(
shrinkWrap: true,
primary: false,
itemBuilder: (context, t) {
return GestureDetector(
onTap: () {
if (onParcelCompleted[t]
    .order_status ==
'Cancelled') {
} else {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) =>
OrderMapParcelPage(
pageTitle:
'${onParcelCompleted[t].vendor_name}',
ongoingOrders:
onParcelCompleted[t],
currency: currency,
),
),
).then((value) {
getAllThreeData();
});
}
},
behavior: HitTestBehavior.opaque,
child: Container(
child: Column(
children: [
Row(
children: <Widget>[
Padding(
padding:
const EdgeInsets.only(
left: 16.3),
child: Image.asset(
'images/maincategory/vegetables_fruitsact.png',
height: 42.3,
width: 33.7,
),
),
Expanded(
child: ListTile(
title: Text(
'Order Id - #${onParcelCompleted[t].cart_id}',
style: orderMapAppBarTextStyle
    .copyWith(
letterSpacing:
0.07),
),
subtitle: Text(
// '${onCancelOrders[t]
//     .delivery_date} | ${onCancelOrders[t]
//     .time_slot}',
(onParcelCompleted[t]
    .pickup_date !=
null &&
onParcelCompleted[
t]
    .pickup_time !=
null)
? '${onParcelCompleted[t].pickup_date} | ${onParcelCompleted[t].pickup_time}'
    : '',
style: Theme.of(
context)
    .textTheme
    .headline6
    .copyWith(
fontSize:
11.7,
letterSpacing:
0.06,
color: Color(
0xffc1c1c1)),
),
trailing: Column(
mainAxisAlignment:
MainAxisAlignment
    .center,
children: <Widget>[
Text(
'${onParcelCompleted[t].order_status}',
style: orderMapAppBarTextStyle
    .copyWith(
color:
kMainColor),
),
SizedBox(
height: 7.0),
Text(
'1 items | ${currency} ${(onParcelCompleted[t].distance != null && double.parse('${onParcelCompleted[t].distance}') > 1) ? double.parse('${onParcelCompleted[t].charges}') * double.parse('${onParcelCompleted[t].distance}') : double.parse('${onParcelCompleted[t].charges}')}\n\n',
style: Theme.of(
context)
    .textTheme
    .headline6
    .copyWith(
fontSize:
11.7,
letterSpacing:
0.06,
color: Color(
0xffc1c1c1)),
)
],
),
),
)
],
),
Divider(
color: kCardBackgroundColor,
thickness: 1.0,
),
Row(
children: <Widget>[
Padding(
padding: EdgeInsets.only(
left: 36.0,
bottom: 6.0,
top: 12.0,
right: 12.0),
child: ImageIcon(
AssetImage(
'images/custom/ic_pickup_pointact.png'),
size: 13.3,
color: kMainColor,
),
),
//                              Text(
//                                'Grocery\t',
//                                style: orderMapAppBarTextStyle.copyWith(
//                                    fontSize: 10.0, letterSpacing: 0.05),
//                              ),
Text(
'${onParcelCompleted[t].vendor_name}',
style: Theme.of(context)
    .textTheme
    .caption
    .copyWith(
fontSize: 10.0,
letterSpacing:
0.05),
),
],
),
Row(
children: <Widget>[
Padding(
padding: EdgeInsets.only(
left: 36.0,
bottom: 12.0,
top: 12.0,
right: 12.0),
child: ImageIcon(
AssetImage(
'images/custom/ic_droppointact.png'),
size: 13.3,
color: kMainColor,
),
),
//                              Text(
//                                'Home\t',
//                                style: orderMapAppBarTextStyle.copyWith(
//                                    fontSize: 10.0, letterSpacing: 0.05),
//                              ),
Expanded(
child: Text(
'${onParcelCompleted[t].vendor_loc}',
style: Theme.of(context)
    .textTheme
    .caption
    .copyWith(
fontSize: 10.0,
letterSpacing:
0.05),
),
),
],
),
(onParcelCompleted.length - 1 ==
t)
? Divider(
color:
kCardBackgroundColor,
thickness: 0.0,
)
    : Divider(
color:
kCardBackgroundColor,
thickness: 13.3,
),
],
),
),
);
},
// separatorBuilder: (context, t2) {
//   return t2 == (onCancelOrders.length) ? Container(
//     height: 20,
//     color: kWhiteColor,
//   ) : Container(
//     height: 10,
//     color: kWhiteColor,
//   );
// },
itemCount: onParcelCompleted.length),
],
),
),
],
)),
Visibility(
visible: ((onParcelCancelOrders != null &&
onParcelCancelOrders.length > 0) ||
(onRestCancelOrders != null &&
onRestCancelOrders.length > 0) ||
(onCancelOrders != null &&
onCancelOrders.length > 0) ||
(onPharmaCancelOrders != null &&
onPharmaCancelOrders.length > 0))
? true
: false,
child: Column(
children: [
Container(
width: MediaQuery.of(context).size.width,
color: kCardBackgroundColor,
padding: EdgeInsets.only(
left: 15.0, bottom: 10.0, top: 10),
child: Text(
'Cancel Orders',
style: TextStyle(
color: kMainTextColor, fontSize: 15.0),
),
),
ListView.builder(
shrinkWrap: true,
primary: false,
itemBuilder: (context, t) {
return GestureDetector(
onTap: () {
if (onCancelOrders[t].order_status ==
'Cancelled') {
} else {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => OrderMapPage(
pageTitle:
'${onCancelOrders[t].vendor_name}',
ongoingOrders: onCancelOrders[t],
currency: currency,
),
),
).then((value) {
getAllThreeData();
});
}
},
behavior: HitTestBehavior.opaque,
child: Container(
child: Column(
children: [
Row(
children: <Widget>[
Padding(
padding: const EdgeInsets.only(
left: 16.3),
child: Image.asset(
'images/maincategory/vegetables_fruitsact.png',
height: 42.3,
width: 33.7,
),
),
Expanded(
child: ListTile(
title: Text(
'Order Id - #${onCancelOrders[t].cart_id}',
style:
orderMapAppBarTextStyle
    .copyWith(
letterSpacing:
0.07),
),
subtitle: Text(
// '${onCancelOrders[t]
//     .delivery_date} | ${onCancelOrders[t]
//     .time_slot}',
(onCancelOrders[t]
    .delivery_date !=
null &&
onCancelOrders[t]
    .time_slot !=
null)
? '${onCancelOrders[t].delivery_date} | ${onCancelOrders[t].time_slot}'
    : '',
style: Theme.of(context)
    .textTheme
    .headline6
    .copyWith(
fontSize: 11.7,
letterSpacing: 0.06,
color: Color(
0xffc1c1c1)),
),
trailing: Column(
mainAxisAlignment:
MainAxisAlignment
    .center,
children: <Widget>[
Text(
'${onCancelOrders[t].order_status}',
style: orderMapAppBarTextStyle
    .copyWith(
color:
kMainColor),
),
SizedBox(height: 7.0),
Text(
'${onCancelOrders[t].data.length} items | $currency ${onCancelOrders[t].price}',
style: Theme.of(context)
    .textTheme
    .headline6
    .copyWith(
fontSize: 11.7,
letterSpacing:
0.06,
color: Color(
0xffc1c1c1)),
)
],
),
),
)
],
),
Divider(
color: kCardBackgroundColor,
thickness: 1.0,
),
Row(
children: <Widget>[
Padding(
padding: EdgeInsets.only(
left: 36.0,
bottom: 6.0,
top: 12.0,
right: 12.0),
child: ImageIcon(
AssetImage(
'images/custom/ic_pickup_pointact.png'),
size: 13.3,
color: kMainColor,
),
),
//                              Text(
//                                'Grocery\t',
//                                style: orderMapAppBarTextStyle.copyWith(
//                                    fontSize: 10.0, letterSpacing: 0.05),
//                              ),
Text(
'${onCancelOrders[t].vendor_name}',
style: Theme.of(context)
    .textTheme
    .caption
    .copyWith(
fontSize: 10.0,
letterSpacing: 0.05),
),
],
),
Row(
children: <Widget>[
Padding(
padding: EdgeInsets.only(
left: 36.0,
bottom: 12.0,
top: 12.0,
right: 12.0),
child: ImageIcon(
AssetImage(
'images/custom/ic_droppointact.png'),
size: 13.3,
color: kMainColor,
),
),
//                              Text(
//                                'Home\t',
//                                style: orderMapAppBarTextStyle.copyWith(
//                                    fontSize: 10.0, letterSpacing: 0.05),
//                              ),
Expanded(
child: Text(
'${onCancelOrders[t].address}',
style: Theme.of(context)
    .textTheme
    .caption
    .copyWith(
fontSize: 10.0,
letterSpacing: 0.05),
),
),
],
),
(onCancelOrders.length - 1 == t)
? Divider(
color: kCardBackgroundColor,
thickness: 0.0,
)
    : Divider(
color: kCardBackgroundColor,
thickness: 13.3,
),
],
),
),
);
},
// separatorBuilder: (context, t2) {
//   return t2 == (onCancelOrders.length) ? Container(
//     height: 20,
//     color: kWhiteColor,
//   ) : Container(
//     height: 10,
//     color: kWhiteColor,
//   );
// },
itemCount: onCancelOrders.length),
Visibility(
visible: (onRestCancelOrders != null &&
onRestCancelOrders.length > 0)
? true
: false,
child: ListView.builder(
shrinkWrap: true,
primary: false,
itemBuilder: (context, t) {
return GestureDetector(
onTap: () {
if (onRestCancelOrders[t]
    .order_status ==
'Cancelled') {
} else {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) =>
OrderMapRestPage(
pageTitle:
'${onRestCancelOrders[t].vendor_name}',
ongoingOrders:
onRestCancelOrders[t],
currency: currency,
),
),
).then((value) {
getAllThreeData();
});
}
},
behavior: HitTestBehavior.opaque,
child: Container(
child: Column(
children: [
Row(
children: <Widget>[
Padding(
padding:
const EdgeInsets.only(
left: 16.3),
child: Image.asset(
'images/maincategory/vegetables_fruitsact.png',
height: 42.3,
width: 33.7,
),
),
Expanded(
child: ListTile(
title: Text(
'Order Id - #${onRestCancelOrders[t].cart_id}',
style:
orderMapAppBarTextStyle
    .copyWith(
letterSpacing:
0.07),
),
subtitle: Text(
// '${onCancelOrders[t]
//     .delivery_date} | ${onCancelOrders[t]
//     .time_slot}',
(onRestCancelOrders[t]
    .delivery_date !=
null &&
onRestCancelOrders[
t]
    .time_slot !=
null)
? '${onRestCancelOrders[t].delivery_date} | ${onRestCancelOrders[t].time_slot}'
    : '',
style: Theme.of(context)
    .textTheme
    .headline6
    .copyWith(
fontSize: 11.7,
letterSpacing:
0.06,
color: Color(
0xffc1c1c1)),
),
trailing: Column(
mainAxisAlignment:
MainAxisAlignment
    .center,
children: <Widget>[
Text(
'${onRestCancelOrders[t].order_status}',
style: orderMapAppBarTextStyle
    .copyWith(
color:
kMainColor),
),
SizedBox(height: 7.0),
Text(
'${onRestCancelOrders[t].data.length} items | $currency ${onRestCancelOrders[t].price}',
style: Theme.of(
context)
    .textTheme
    .headline6
    .copyWith(
fontSize:
11.7,
letterSpacing:
0.06,
color: Color(
0xffc1c1c1)),
)
],
),
),
)
],
),
Divider(
color: kCardBackgroundColor,
thickness: 1.0,
),
Row(
children: <Widget>[
Padding(
padding: EdgeInsets.only(
left: 36.0,
bottom: 6.0,
top: 12.0,
right: 12.0),
child: ImageIcon(
AssetImage(
'images/custom/ic_pickup_pointact.png'),
size: 13.3,
color: kMainColor,
),
),
//                              Text(
//                                'Grocery\t',
//                                style: orderMapAppBarTextStyle.copyWith(
//                                    fontSize: 10.0, letterSpacing: 0.05),
//                              ),
Text(
'${onRestCancelOrders[t].vendor_name}',
style: Theme.of(context)
    .textTheme
    .caption
    .copyWith(
fontSize: 10.0,
letterSpacing:
0.05),
),
],
),
Row(
children: <Widget>[
Padding(
padding: EdgeInsets.only(
left: 36.0,
bottom: 12.0,
top: 12.0,
right: 12.0),
child: ImageIcon(
AssetImage(
'images/custom/ic_droppointact.png'),
size: 13.3,
color: kMainColor,
),
),
//                              Text(
//                                'Home\t',
//                                style: orderMapAppBarTextStyle.copyWith(
//                                    fontSize: 10.0, letterSpacing: 0.05),
//                              ),
Expanded(
child: Text(
'${onRestCancelOrders[t].address}',
style: Theme.of(context)
    .textTheme
    .caption
    .copyWith(
fontSize: 10.0,
letterSpacing:
0.05),
),
),
],
),
(onRestCancelOrders.length - 1 ==
t)
? Divider(
color:
kCardBackgroundColor,
thickness: 0.0,
)
    : Divider(
color:
kCardBackgroundColor,
thickness: 13.3,
),
],
),
),
);
},
// separatorBuilder: (context, t2) {
//   return t2 == (onCancelOrders.length) ? Container(
//     height: 20,
//     color: kWhiteColor,
//   ) : Container(
//     height: 10,
//     color: kWhiteColor,
//   );
// },
itemCount: onRestCancelOrders.length)),
Visibility(
visible: (onPharmaCancelOrders != null &&
onPharmaCancelOrders.length > 0)
? true
: false,
child: ListView.builder(
shrinkWrap: true,
primary: false,
itemBuilder: (context, t) {
return GestureDetector(
onTap: () {
if (onPharmaCancelOrders[t]
    .order_status ==
'Cancelled') {
} else {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) =>
OrderMapPharmaPage(
pageTitle:
'${onPharmaCancelOrders[t].vendor_name}',
ongoingOrders:
onPharmaCancelOrders[t],
currency: currency,
),
),
).then((value) {
getAllThreeData();
});
}
},
behavior: HitTestBehavior.opaque,
child: Container(
child: Column(
children: [
Row(
children: <Widget>[
Padding(
padding:
const EdgeInsets.only(
left: 16.3),
child: Image.asset(
'images/maincategory/vegetables_fruitsact.png',
height: 42.3,
width: 33.7,
),
),
Expanded(
child: ListTile(
title: Text(
'Order Id - #${onPharmaCancelOrders[t].cart_id}',
style:
orderMapAppBarTextStyle
    .copyWith(
letterSpacing:
0.07),
),
subtitle: Text(
// '${onCancelOrders[t]
//     .delivery_date} | ${onCancelOrders[t]
//     .time_slot}',
(onPharmaCancelOrders[t]
    .delivery_date !=
null &&
onPharmaCancelOrders[
t]
    .time_slot !=
null)
? '${onPharmaCancelOrders[t].delivery_date} | ${onPharmaCancelOrders[t].time_slot}'
    : '',
style: Theme.of(context)
    .textTheme
    .headline6
    .copyWith(
fontSize: 11.7,
letterSpacing:
0.06,
color: Color(
0xffc1c1c1)),
),
trailing: Column(
mainAxisAlignment:
MainAxisAlignment
    .center,
children: <Widget>[
Text(
'${onPharmaCancelOrders[t].order_status}',
style: orderMapAppBarTextStyle
    .copyWith(
color:
kMainColor),
),
SizedBox(height: 7.0),
Text(
'${onPharmaCancelOrders[t].data.length} items | $currency ${onPharmaCancelOrders[t].price}',
style: Theme.of(
context)
    .textTheme
    .headline6
    .copyWith(
fontSize:
11.7,
letterSpacing:
0.06,
color: Color(
0xffc1c1c1)),
)
],
),
),
)
],
),
Divider(
color: kCardBackgroundColor,
thickness: 1.0,
),
Row(
children: <Widget>[
Padding(
padding: EdgeInsets.only(
left: 36.0,
bottom: 6.0,
top: 12.0,
right: 12.0),
child: ImageIcon(
AssetImage(
'images/custom/ic_pickup_pointact.png'),
size: 13.3,
color: kMainColor,
),
),
//                              Text(
//                                'Grocery\t',
//                                style: orderMapAppBarTextStyle.copyWith(
//                                    fontSize: 10.0, letterSpacing: 0.05),
//                              ),
Text(
'${onPharmaCancelOrders[t].vendor_name}',
style: Theme.of(context)
    .textTheme
    .caption
    .copyWith(
fontSize: 10.0,
letterSpacing:
0.05),
),
],
),
Row(
children: <Widget>[
Padding(
padding: EdgeInsets.only(
left: 36.0,
bottom: 12.0,
top: 12.0,
right: 12.0),
child: ImageIcon(
AssetImage(
'images/custom/ic_droppointact.png'),
size: 13.3,
color: kMainColor,
),
),
//                              Text(
//                                'Home\t',
//                                style: orderMapAppBarTextStyle.copyWith(
//                                    fontSize: 10.0, letterSpacing: 0.05),
//                              ),
Expanded(
child: Text(
'${onPharmaCancelOrders[t].address}',
style: Theme.of(context)
    .textTheme
    .caption
    .copyWith(
fontSize: 10.0,
letterSpacing:
0.05),
),
),
],
),
(onPharmaCancelOrders.length -
1 ==
t)
? Divider(
color:
kCardBackgroundColor,
thickness: 0.0,
)
    : Divider(
color:
kCardBackgroundColor,
thickness: 13.3,
),
],
),
),
);
},
// separatorBuilder: (context, t2) {
//   return t2 == (onCancelOrders.length) ? Container(
//     height: 20,
//     color: kWhiteColor,
//   ) : Container(
//     height: 10,
//     color: kWhiteColor,
//   );
// },
itemCount: onPharmaCancelOrders.length)),
Visibility(
visible: (onParcelCancelOrders != null &&
onParcelCancelOrders.length > 0)
? true
: false,
child: Column(
children: [
Divider(
color: kCardBackgroundColor,
thickness: 13.3,
),
ListView.builder(
shrinkWrap: true,
primary: false,
itemBuilder: (context, t) {
return GestureDetector(
onTap: () {
if (onParcelCancelOrders[t]
    .order_status ==
'Cancelled') {
} else {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) =>
OrderMapParcelPage(
pageTitle:
'${onParcelCancelOrders[t].vendor_name}',
ongoingOrders:
onParcelCancelOrders[t],
currency: currency,
),
),
).then((value) {
getAllThreeData();
});
}
},
behavior: HitTestBehavior.opaque,
child: Container(
child: Column(
children: [
Row(
children: <Widget>[
Padding(
padding:
const EdgeInsets.only(
left: 16.3),
child: Image.asset(
'images/maincategory/vegetables_fruitsact.png',
height: 42.3,
width: 33.7,
),
),
Expanded(
child: ListTile(
title: Text(
'Order Id - #${onParcelCancelOrders[t].cart_id}',
style: orderMapAppBarTextStyle
    .copyWith(
letterSpacing:
0.07),
),
subtitle: Text(
// '${onCancelOrders[t]
//     .delivery_date} | ${onCancelOrders[t]
//     .time_slot}',
(onParcelCancelOrders[
t]
    .pickup_date !=
null &&
onParcelCancelOrders[
t]
    .pickup_time !=
null)
? '${onParcelCancelOrders[t].pickup_date} | ${onParcelCancelOrders[t].pickup_time}'
    : '',
style: Theme.of(
context)
    .textTheme
    .headline6
    .copyWith(
fontSize:
11.7,
letterSpacing:
0.06,
color: Color(
0xffc1c1c1)),
),
trailing: Column(
mainAxisAlignment:
MainAxisAlignment
    .center,
children: <Widget>[
Text(
'${onParcelCancelOrders[t].order_status}',
style: orderMapAppBarTextStyle
    .copyWith(
color:
kMainColor),
),
SizedBox(
height: 7.0),
Text(
'1 items | ${currency} ${(double.parse('${onParcelCancelOrders[t].distance}') != null && double.parse('${onParcelCancelOrders[t].distance}') > 1) ? double.parse('${onParcelCancelOrders[t].charges}') * double.parse('${onParcelCancelOrders[t].distance}') : double.parse('${onParcelCancelOrders[t].charges}')}\n\n',
style: Theme.of(
context)
    .textTheme
    .headline6
    .copyWith(
fontSize:
11.7,
letterSpacing:
0.06,
color: Color(
0xffc1c1c1)),
)
],
),
),
)
],
),
Divider(
color: kCardBackgroundColor,
thickness: 1.0,
),
Row(
children: <Widget>[
Padding(
padding: EdgeInsets.only(
left: 36.0,
bottom: 6.0,
top: 12.0,
right: 12.0),
child: ImageIcon(
AssetImage(
'images/custom/ic_pickup_pointact.png'),
size: 13.3,
color: kMainColor,
),
),
//                              Text(
//                                'Grocery\t',
//                                style: orderMapAppBarTextStyle.copyWith(
//                                    fontSize: 10.0, letterSpacing: 0.05),
//                              ),
Text(
'${onParcelCancelOrders[t].vendor_name}',
style: Theme.of(context)
    .textTheme
    .caption
    .copyWith(
fontSize: 10.0,
letterSpacing:
0.05),
),
],
),
Row(
children: <Widget>[
Padding(
padding: EdgeInsets.only(
left: 36.0,
bottom: 12.0,
top: 12.0,
right: 12.0),
child: ImageIcon(
AssetImage(
'images/custom/ic_droppointact.png'),
size: 13.3,
color: kMainColor,
),
),
//                              Text(
//                                'Home\t',
//                                style: orderMapAppBarTextStyle.copyWith(
//                                    fontSize: 10.0, letterSpacing: 0.05),
//                              ),
Expanded(
child: Text(
'${onParcelCancelOrders[t].vendor_loc}',
style: Theme.of(context)
    .textTheme
    .caption
    .copyWith(
fontSize: 10.0,
letterSpacing:
0.05),
),
),
],
),
(onParcelCancelOrders.length -
1 ==
t)
? Divider(
color:
kCardBackgroundColor,
thickness: 0.0,
)
    : Divider(
color:
kCardBackgroundColor,
thickness: 13.3,
),
],
),
),
);
},
// separatorBuilder: (context, t2) {
//   return t2 == (onCancelOrders.length) ? Container(
//     height: 20,
//     color: kWhiteColor,
//   ) : Container(
//     height: 10,
//     color: kWhiteColor,
//   );
// },
itemCount: onParcelCancelOrders.length),
],
),
),
],
)),*/
