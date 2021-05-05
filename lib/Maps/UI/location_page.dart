import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:user/Components/bottom_bar.dart';
import 'package:user/Components/custom_appbar.dart';
import 'package:user/Themes/colors.dart';
import 'package:user/bean/latlng.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

// TextEditingController _addressController = TextEditingController();

class LocationPage extends StatelessWidget {
  final dynamic lat;
  final dynamic lng;

  LocationPage(this.lat, this.lng);

  @override
  Widget build(BuildContext context) {
    return SetLocation(lat, lng);
  }
}

class SetLocation extends StatefulWidget {
  final dynamic lat;
  final dynamic lng;

  SetLocation(this.lat, this.lng);

  @override
  SetLocationState createState() => SetLocationState(lat, lng);
}

GoogleMapsPlaces _places =
    GoogleMapsPlaces(apiKey: 'AIzaSyAbBC06pbdunTQvW3QRBNZY4Qcw7Sy9-Oo');

class SetLocationState extends State<SetLocation> {
  final apiKey = 'AIzaSyAbBC06pbdunTQvW3QRBNZY4Qcw7Sy9-Oo';
  dynamic lat;
  dynamic lng;
  CameraPosition kGooglePlex;

  SetLocationState(this.lat, this.lng) {
    kGooglePlex = CameraPosition(
      target: LatLng(lat, lng),
      zoom: 12.151926,
    );
  }

  bool isCard = false;
  Completer<GoogleMapController> _controller = Completer();

  var isVisible = false;

  var currentAddress = '';

  Future<void> _goToTheLake(lat, lng) async {
    final CameraPosition _kLake = CameraPosition(
        bearing: 192.8334901395799,
        target: LatLng(lat, lng),
        tilt: 59.440717697143555,
        zoom: 18);
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  void dispose() {
    super.dispose();
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
        Timer(Duration(seconds: 5), () async {
          double lat = position.latitude;
          double lng = position.longitude;
          prefs.setString("lat", lat.toStringAsFixed(8));
          prefs.setString("lng", lng.toStringAsFixed(8));
          // prefs.setString("lat", "29.006057");
          // prefs.setString("lat", lat.toStringAsFixed(8));
          // prefs.setString("lng", "77.027535");
          // prefs.setString("lng", lng.toStringAsFixed(8));
          // lat = 29.006057;
          // lng = 77.027535;
          final coordinates = new Coordinates(lat, lng);
          await Geocoder.local
              .findAddressesFromCoordinates(coordinates)
              .then((value) {
//          print("${value[0].featureName} : ${value[0].countryName} : ${value[0].locality} : ${value[0].subAdminArea} : ${value[0].adminArea} : ${value[0].subLocality} : ${value[0].addressLine}");
            setState(() {
              currentAddress = value[0].addressLine;
              _goToTheLake(lat, lng);
            });
          });
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

  void _getCameraMoveLocation(LatLng data) async {
    Timer(Duration(seconds: 1), () async {
      lat = data.latitude;
      lng = data.longitude;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("lat", data.latitude.toStringAsFixed(8));
      prefs.setString("lng", data.longitude.toStringAsFixed(8));
      // prefs.setString("lat", "29.006057");
      // prefs.setString("lat", lat.toStringAsFixed(8));
      // prefs.setString("lng", "77.027535");
      // prefs.setString("lng", lng.toStringAsFixed(8));
      final coordinates = new Coordinates(data.latitude, data.longitude);
      await Geocoder.local
          .findAddressesFromCoordinates(coordinates)
          .then((value) {
        setState(() {
          currentAddress = value[0].addressLine;
        });
      });
    });
  }

  void getPlaces(context) async {
    PlacesAutocomplete.show(
            context: context,
            apiKey: apiKey,
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
      // get detail (lat/lng)
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);
      final lat = detail.result.geometry.location.lat;
      final lng = detail.result.geometry.location.lng;
      print('damd ${lat} - ${lng}');
      _getCameraMoveLocation(LatLng(lat, lng));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//          extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(110.0),
        child: CustomAppBar(
          titleWidget: Text(
            'Set delivery location',
            style: TextStyle(fontSize: 16.7, color: black_color),
          ),
          onTap: () {
            // Toast.show("This feature is disable in demo application", context,duration: Toast.LENGTH_SHORT);
            getPlaces(context);
//            setState(() {
//              isVisible = true;
//            });
//             Navigator.of(context).push(MaterialPageRoute(builder: (context){
//               return CustomSearchScaffold();
//             })).then((value){
//               BackLatLng latLng = value;
//               _getCameraMoveLocation(LatLng(latLng.lat, latLng.lng));
//             });
          },
          hint: 'Enter location',
          actions: [
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: IconButton(
                  icon: Icon(
                    Icons.my_location,
                    color: kMainColor,
                  ),
                  iconSize: 30,
                  onPressed: () {
                    _getLocation();
                  },
                ))
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(
            height: 8.0,
          ),
          Expanded(
            child: Stack(
              children: <Widget>[
//                Image.asset(
//                  'images/map.png',
//                  width: MediaQuery.of(context).size.width,
//                  fit: BoxFit.fitWidth,
//                ),
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: kGooglePlex,
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  compassEnabled: false,
                  mapToolbarEnabled: false,
                  buildingsEnabled: false,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  onCameraIdle: () {
                    getMapLoc();
                  },
                  onCameraMove: (post) {
                    lat = post.target.latitude;
                    lng = post.target.longitude;
                  },
                ),
//                Visibility(
//                  visible: isVisible,
//                ),
                Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 36.0),
                      child: Image.asset(
                        'images/map_pin.png',
                        height: 36,
                      ),
                    ))
              ],
            ),
          ),
          Container(
            color: kCardBackgroundColor,
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              children: <Widget>[
                Image.asset(
                  'images/map_pin.png',
                  scale: 3,
                ),
                SizedBox(
                  width: 16.0,
                ),
                Expanded(
                  child: Text(
                    '${currentAddress}',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.caption,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
//          isCard ? SaveAddressCard() : Container(),
          BottomBar(
              text: "Continue",
              onTap: () {
//                Navigator.popAndPushNamed(context, PageRoutes.homeOrderAccountPage);
                Navigator.pop(context, BackLatLng(lat, lng));
              }),
        ],
      ),
    );
  }

  void getMapLoc() async {
    _getCameraMoveLocation(LatLng(lat, lng));
  }
}

//var apiKey = 'AIzaSyAbBC06pbdunTQvW3QRBNZY4Qcw7Sy9-Oo';
class CustomSearchScaffold extends PlacesAutocompleteWidget {
//  var apiKey = '';
  CustomSearchScaffold()
      : super(
          apiKey: 'AIzaSyAbBC06pbdunTQvW3QRBNZY4Qcw7Sy9-Oo',
          sessionToken: Uuid().generateV4(),
          language: "en",
        );

  @override
  _CustomSearchScaffoldState createState() => _CustomSearchScaffoldState();
}

class _CustomSearchScaffoldState extends PlacesAutocompleteState {
  void getPlaces(context) async {
    PlacesAutocomplete.show(
            context: context,
            apiKey: "AIzaSyAbBC06pbdunTQvW3QRBNZY4Qcw7Sy9-Oo",
            mode: Mode.fullscreen, // Mode.fullscreen
            language: "en")
        .then((value) {
      displayPrediction(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(title: AppBarPlacesAutoCompleteTextField());
    final body = PlacesAutocompleteResult(
      onTap: (p) {
        displayPrediction(p);
      },
    );
    return Scaffold(appBar: appBar, body: body);
  }

  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      // get detail (lat/lng)
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId);
      final lat = detail.result.geometry.location.lat;
      final lng = detail.result.geometry.location.lng;
      print('${lat} - ${lng}');
      Navigator.pop(context, BackLatLng(lat, lng));
    }
  }

  @override
  void onResponseError(PlacesAutocompleteResponse response) {
    super.onResponseError(response);
    print('${response.status}');
  }

  @override
  void onResponse(PlacesAutocompleteResponse response) {
    super.onResponse(response);

    if (response != null && response.predictions.isNotEmpty) {
      print('${response.predictions}');
    }
  }
}

class Uuid {
  final Random _random = Random();

  String generateV4() {
    final int special = 8 + _random.nextInt(4);
    return '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}-'
        '${_bitsDigits(16, 4)}-'
        '4${_bitsDigits(12, 3)}-'
        '${_printDigits(special, 1)}${_bitsDigits(12, 3)}-'
        '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}';
  }

  String _bitsDigits(int bitCount, int digitCount) =>
      _printDigits(_generateBits(bitCount), digitCount);

  int _generateBits(int bitCount) => _random.nextInt(1 << bitCount);

  String _printDigits(int value, int count) =>
      value.toRadixString(16).padLeft(count, '0');
}

//enum AddressType {
//  Home,
//  Office,
//  Other,
//}
//
//AddressType selectedAddress = AddressType.Other;
//
//class SaveAddressCard extends StatefulWidget {
//  @override
//  _SaveAddressCardState createState() => _SaveAddressCardState();
//}
//
//class _SaveAddressCardState extends State<SaveAddressCard> {
//  @override
//  Widget build(BuildContext context) {
//    return Column(
//      crossAxisAlignment: CrossAxisAlignment.start,
//      children: <Widget>[
//        Padding(
//          padding: EdgeInsets.symmetric(horizontal: 8.0),
//          child: EntryField(
//            controller: _addressController,
//            label: 'FLAT NUM, LANDMARK, APARTMENT, ETC.',
//          ),
//        ),
//        Padding(
//          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//          child: Text(
//            'SAVE ADDRESS AS',
//            style: Theme.of(context).textTheme.subtitle2,
//          ),
//        ),
//        Padding(
//          padding: EdgeInsets.only(bottom: 16.0),
//          child: Row(
//            mainAxisAlignment: MainAxisAlignment.spaceAround,
//            children: <Widget>[
//              AddressTypeButton(
//                label: 'Home',
//                image: 'images/address/ic_homeblk.png',
//                onPressed: () {
//                  setState(() {
//                    selectedAddress = AddressType.Home;
//                  });
//                },
//                isSelected: selectedAddress == AddressType.Home,
//              ),
//              AddressTypeButton(
//                label: 'Office',
//                image: 'images/address/ic_officeblk.png',
//                onPressed: () {
//                  setState(() {
//                    selectedAddress = AddressType.Office;
//                  });
//                },
//                isSelected: selectedAddress == AddressType.Office,
//              ),
//              AddressTypeButton(
//                label: 'Other',
//                image: 'images/address/ic_otherblk.png',
//                onPressed: () {
//                  setState(() {
//                    selectedAddress = AddressType.Other;
//                  });
//                },
//                isSelected: selectedAddress == AddressType.Other,
//              ),
//            ],
//          ),
//        )
//      ],
//    );
//  }
//}
