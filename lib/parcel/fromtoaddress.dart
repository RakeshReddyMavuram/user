import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:user/Maps/UI/location_page.dart';
import 'package:user/Themes/colors.dart';
import 'package:user/parcel/parcel_details.dart';
import 'package:user/parcel/receiveraddress.dart';
import 'package:user/parcel/pharmacybean/parceladdress.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user/baseurl/baseurl.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:toast/toast.dart';

class AddressFrom extends StatefulWidget{
  final dynamic vendor_name;
  final dynamic vendor_id;
  final dynamic distance;
  AddressFrom(this.vendor_name, this.vendor_id, this.distance);

  @override
  State<StatefulWidget> createState() {
    return AddressFromState();
  }

}

class AddressFromState extends State<AddressFrom>{
  TextEditingController houseno = TextEditingController();
  TextEditingController pincode = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController landmark = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController sendername = TextEditingController();
  TextEditingController sendercontact = TextEditingController();

  GoogleMapsPlaces _places =
  GoogleMapsPlaces(apiKey: 'AIzaSyAbBC06pbdunTQvW3QRBNZY4Qcw7Sy9-Oo');

  bool isFetchStore = false;

  double lat=0.0;
  double lng=0.0;

  String currentAddress = '';

  @override
  void initState() {
    // city.text = 'Sonipat';
    _getLocation();
    // hitCityService();
    super.initState();
  }

  void _getLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      bool isLocationServiceEnableds = await Geolocator.isLocationServiceEnabled();
      if (isLocationServiceEnableds) {
        Position position =
        await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        double lat = position.latitude;
        // double lat = 28.570810039366947;
        double lng = position.longitude;
        // double lng = 77.32593789642168;
        final coordinates = new Coordinates(lat, lng);
        await Geocoder.local
            .findAddressesFromCoordinates(coordinates)
            .then((value) {
          for(int i=0;i<value.length;i++){
            print('${value[i].locality}');
            if(value[i].locality!=null && value[i].locality.length>1){
              setState(() {
                city.text = value[i].locality;
                pincode.text = value[i].postalCode;
                state.text = value[i].adminArea;
              });
              break;
            }
          }

        });
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

  void hitCityService() async{
    setState(() {
      isFetchStore = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(
        '${prefs.getString('lat')} - ${prefs.getString('lng')} - ${widget.vendor_id}');
    var url = parcel_charges;
    http.post(url, body: {
      'lat': '${prefs.getString('lat')}',
      'lng': '${prefs.getString('lng')}',
      'vendor_id': '${widget.vendor_id}',
    }).then((value) {
      print('${value.statusCode} ${value.body}');
      if (value.statusCode == 200) {
        print('Response Body: - ${value.body}');
        var jsonData = jsonDecode(value.body);
        if (jsonData['status'] == "1") {
          // var tagObjsJson = jsonDecode(value.body)['data'] as List;
          // List<NearStores> tagObjs = tagObjsJson
          //     .map((tagJson) => NearStores.fromJson(tagJson))
          //     .toList();
          // setState(() {
          //   nearStores.clear();
          //   nearStoresSearch.clear();
          //   nearStores = tagObjs;
          //   nearStoresSearch = List.from(nearStores);
          // });
        }
      }
      setState(() {
        isFetchStore = false;
      });
    }).catchError((e) {
      setState(() {
        isFetchStore = false;
      });
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCardBackgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(52.0),
        child: AppBar(
          backgroundColor: kWhiteColor,
          titleSpacing: 0.0,
          title: Text(
            'Address detail\'s',
            style: TextStyle(
                fontSize: 18, color: black_color, fontWeight: FontWeight.w400),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(left: 10.0,top: 10, bottom: 10.0),
              child: Text(
                'Sender Address',
                style: TextStyle(
                    fontSize: 18,
                    color: black_color,
                    fontWeight: FontWeight.w400),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Sender Name',
                      style: TextStyle(
                          fontSize: 18,
                          color: black_color,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    elevation: 2,
                    color: kWhiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Container(
                      height: 52,
                      alignment: Alignment.centerLeft,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(left: 10.0),
                      child: TextFormField(
                        maxLines: 1,
                        controller: sendername,
                        decoration: InputDecoration(
                          hintText: 'Sender Name',
                          hintStyle: TextStyle(fontSize: 15),
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Sender Contact No.',
                      style: TextStyle(
                          fontSize: 18,
                          color: black_color,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    elevation: 2,
                    color: kWhiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Container(
                      height: 52,
                      alignment: Alignment.centerLeft,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(left: 10.0),
                      child: TextFormField(
                        maxLines: 1,
                        controller: sendercontact,
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        decoration: InputDecoration(
                          hintText: 'Sender Contact No.',
                          hintStyle: TextStyle(fontSize: 15),
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Address',
                      style: TextStyle(
                          fontSize: 18,
                          color: black_color,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: (){
                      getPlaces(context);
                      // _getCameraMoveLocation(LatLng(lat, lng),'');
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Card(
                      elevation: 2,
                      color: kWhiteColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.only(left: 10.0),
                        child: TextFormField(
                          maxLines: 5,
                          controller: address,
                          enabled: (address.text.length==0)?false:true,
                          decoration: InputDecoration(
                            hintText: 'Enter your address',
                            hintStyle: TextStyle(fontSize: 15),
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          onChanged: (value){
                            if(value.length==1){
                              getPlaces(context);
                            }
                          },
                          onTap: (){

                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      'House No/Flat No',
                      style: TextStyle(
                          fontSize: 18,
                          color: black_color,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    elevation: 2,
                    color: kWhiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Container(
                      height: 52,
                      alignment: Alignment.centerLeft,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(left: 10.0),
                      child: TextFormField(
                        maxLines: 1,
                        controller: houseno,
                        decoration: InputDecoration(
                          hintText: 'House No/Flat No',
                          hintStyle: TextStyle(fontSize: 15),
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child: Text(
                                'Pin Code',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: black_color,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Card(
                              elevation: 2,
                              color: kWhiteColor,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Container(
                                height: 52,
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width,
                                child: TextFormField(
                                  maxLines: 1,
                                  controller: pincode,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'Pin Code',
                                    hintStyle: TextStyle(fontSize: 15),
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child: Text(
                                'City',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: black_color,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Card(
                              elevation: 2,
                              color: kWhiteColor,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Container(
                                height: 52,
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width,
                                child: TextFormField(
                                  maxLines: 1,
                                  controller: city,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    hintText: 'City',
                                    enabled: false,
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(fontSize: 15),
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Landmark',
                      style: TextStyle(
                          fontSize: 18,
                          color: black_color,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    elevation: 2,
                    color: kWhiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Container(
                      height: 52,
                      alignment: Alignment.centerLeft,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(left: 10.0),
                      child: TextFormField(
                        maxLines: 1,
                        controller: landmark,
                        decoration: InputDecoration(
                          hintText: 'Landmark',
                          hintStyle: TextStyle(fontSize: 15),
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      'State',
                      style: TextStyle(
                          fontSize: 18,
                          color: black_color,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    elevation: 2,
                    color: kWhiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Container(
                      height: 52,
                      alignment: Alignment.centerLeft,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(left: 10.0),
                      child: TextFormField(
                        maxLines: 1,
                        controller: state,
                        decoration: InputDecoration(
                          hintText: 'State',
                          hintStyle: TextStyle(fontSize: 15),
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: GestureDetector(
                onTap: () {
                  if(houseno.text!=null && pincode.text!=null && city.text!=null && landmark.text!=null && address.text!=null && state.text!=null && lat!=null && lng!=null && sendername.text!=null && sendercontact.text!=null){
                    ParcelAddress parcelAddress = ParcelAddress(houseno.text,pincode.text,city.text,landmark.text,address.text,state.text,lat,lng,sendername.text,sendercontact.text);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AddressTo(widget.vendor_name,widget.vendor_id,widget.distance,parcelAddress)));
                  }else{
                    Toast.show('please enter all details to continue!', context,
                        duration: Toast.LENGTH_SHORT,gravity: Toast.CENTER);
                  }
                },
                child: Card(
                  elevation: 2,
                  color: kMainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Container(
                    height: 52,
                    padding: EdgeInsets.all(10.0),
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    child: Text('Submit',style: TextStyle(fontSize: 18,color: kWhiteColor),),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  void getPlaces(context) async {
    PlacesAutocomplete.show(
      context: context,
      apiKey: 'AIzaSyAbBC06pbdunTQvW3QRBNZY4Qcw7Sy9-Oo',
      mode: Mode.fullscreen,
      sessionToken: Uuid().generateV4(),
      onError: (response) {
        print('${response.errorMessage}');
      },
      language: "en",
    ).then((value) {
      displayPrediction(value);
    }).catchError((e) {
      print(e);
    });
  }

  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      PlacesDetailsResponse detail =
      await _places.getDetailsByPlaceId(p.placeId);
      final lat = detail.result.geometry.location.lat;
      final lng = detail.result.geometry.location.lng;
      print('damd ${lat} - ${lng} \n ${detail.result.formattedAddress}');
      _getCameraMoveLocation(LatLng(lat, lng),'${detail.result.formattedAddress}');
    }
  }

  void _getCameraMoveLocation(LatLng data, addressd) async {
    setState(() {
      lat = data.latitude;
      // lat = 28.570810039366947;
      lng = data.longitude;
      // lng = 77.32593789642168;
      currentAddress = '${addressd}';
    });
    final coordinates = new Coordinates(lat, lng);
    await Geocoder.local.findAddressesFromCoordinates(coordinates).then((value){
      for(int i=0;i<value.length;i++){
        print('${value[i].locality}');
        if(value[i].locality!=null && value[i].locality.length>1){
         setState(() {
           // currentAddress = value[i].addressLine;
           city.text = value[i].locality;
           pincode.text = value[i].postalCode;
           state.text = value[i].adminArea;
           currentAddress = currentAddress.replaceAll('${value[i].locality},', '');
           currentAddress = currentAddress.replaceAll('${pincode.text},', '');
           currentAddress = currentAddress.replaceAll('${state.text},', '');
           currentAddress = currentAddress.replaceAll('${value[i].locality}', '');
           currentAddress = currentAddress.replaceAll('${pincode.text}', '');
           currentAddress = currentAddress.replaceAll('${state.text}', '');
           currentAddress = currentAddress.replaceAll('${value[i].countryName}', '');
           address.text = currentAddress;
         });
          break;
        }
      }
    });
  }

}