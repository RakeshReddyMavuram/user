import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:user/Themes/colors.dart';
import 'package:user/Themes/constantfile.dart';
import 'package:user/baseurl/baseurl.dart';
import 'package:http/http.dart' as http;
import 'package:user/bean/bannerbean.dart';

class ImageSliderList extends StatefulWidget {
  final VoidCallback onVerificationDone;
  List<BannerDetails> listImage;
  ImageSliderList(this.listImage,this.onVerificationDone);
  @override
  _ImageSliderListState createState() => _ImageSliderListState();
}

class _ImageSliderListState extends State<ImageSliderList> {
  List<String> listImages = ['', '', '', '', ''];
  List<BannerDetails> listImage = [];

  bool isFetch = false;



  @override
  void initState() {
    // isFetch = true;
    // hitBannerUrl();
    listImage = widget.listImage;
    super.initState();
  }

  void hitBannerUrl() async {
    var url = resturant_banner;
    http.get(url).then((response){
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        print('Response Body: - ${response.body}');
        if (jsonData['status'] == "1") {
          var tagObjsJson = jsonDecode(response.body)['data'] as List;
          List<BannerDetails> tagObjs = tagObjsJson
              .map((tagJson) => BannerDetails.fromJson(tagJson))
              .toList();
          if(tagObjs!=null && tagObjs.length>0){
            setState(() {
              isFetch = false;
              listImage.clear();
              listImage = tagObjs;
            });
          }else{
            setState(() {
              isFetch = false;
            });
          }
        }else{
          setState(() {
            isFetch = false;
          });
        }
      }else{
        setState(() {
          isFetch = false;
        });
      }
    }).catchError((e){
      print(e);
      // setState(() {
      //   isFetch = false;
      // });
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Visibility(
      visible: (isFetch && listImage.length == 0)?false:true,
      child: Container(
        width: width,
        height: 160.0,
        child:
        Padding(
          padding: EdgeInsets.only(top: 10, bottom: 5),
          child:  (listImage!=null && listImage.length>0)?ListView.builder(
            itemCount: listImage.length,
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              // final item = listImage[index];
              return InkWell(
                onTap: () {},
                child: Container(
                  width: 170.0,
                  margin: (index != (listImage.length - 1))
                      ? EdgeInsets.only(left: fixPadding)
                      : EdgeInsets.only(left: fixPadding, right: fixPadding),
                  decoration: BoxDecoration(
                    // image: DecorationImage(
                    //   image: Image.network(imageBaseUrl+listImage[index].banner_image),
                    //   fit: BoxFit.cover,
                    // ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Image.network(imageBaseUrl+listImage[index].banner_image,fit: BoxFit.fill,),
                ),
              );
            },
          ):ListView.builder(
            itemCount: listImages.length,
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              // final item = listImages[index];
              return InkWell(
                onTap: () {},
                child: Container(
                  width: 170.0,
                  margin: (index != (listImages.length - 1))
                      ? EdgeInsets.only(left: fixPadding)
                      : EdgeInsets.only(left: fixPadding, right: fixPadding),
                  decoration: BoxDecoration(
                    // image: DecorationImage(
                    //   image: AssetImage(imageBaseUrl+item.banner_image),
                    //   fit: BoxFit.cover,
                    // ),
                    borderRadius: BorderRadius.circular(10.0),
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
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
