import 'dart:developer';
import 'dart:ui';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:motel/appTheme.dart';
import 'package:motel/models/hotelListData.dart';
import 'package:motel/models/locations.dart';
import 'package:motel/modules/hotelBooking/calendarPopupView.dart';
import 'package:motel/modules/hotelBooking/roomPopupView.dart';
import 'package:motel/modules/hotelDetailes/roomBookingScreen.dart';
import 'package:motel/modules/hotelDetailes/searchScreen.dart';
import 'package:motel/modules/myTrips/upcomingListView.dart';
import 'package:motel/network/blocs.dart';
import 'package:simple_autocomplete_formfield/simple_autocomplete_formfield.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'filtersScreen.dart';
// coded by Victor
import 'dart:io';
import 'dart:convert';

class HotelHomeScreen extends StatefulWidget {
  @override
  _HotelHomeScreenState createState() => _HotelHomeScreenState();
}

class _HotelHomeScreenState extends State<HotelHomeScreen> with TickerProviderStateMixin {
  AnimationController animationController;
  AnimationController _animationController;
  var hotelList = HotelListData.hotelList;
  ScrollController scrollController = new ScrollController();
  int room = 1;
  int ad = 2;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(Duration(days: 5));
  bool isMap = false;


  List<LocationObject> departureLocations = List<LocationObject>();
  LocationObject selectedDeparture;
  List<LocationObject> arrivalLocations = List<LocationObject>();
  LocationObject selectedArrival;

  final searchBarHieght = 158.0;
  final filterBarHieght = 52.0;



  @override
  void initState() {



    animationController = AnimationController(duration: Duration(milliseconds: 1000), vsync: this);
    _animationController = AnimationController(duration: Duration(milliseconds: 0), vsync: this);
    scrollController.addListener(() {
      if (context != null) {
        if (scrollController.offset <= 0) {
          _animationController.animateTo(0.0);
        } else if (scrollController.offset > 0.0 && scrollController.offset < searchBarHieght) {
          // we need around searchBarHieght scrolling values in 0.0 to 1.0
          _animationController.animateTo((scrollController.offset / searchBarHieght));
        } else {
          _animationController.animateTo(1.0);
        }
      }
    });
    super.initState();
  }

  Future<bool> getData() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }

  searchForLocation(query, isDeparture) async {
    flyLinebloc.locationItems.add(List<LocationObject>());
    flyLinebloc.locationQuery(query);
    //flyLinebloc.locationItems.stream.listen((data) => onUpdateResult(data, isDeparture));
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Column(
              children: <Widget>[
                getAppBarUI(),
                isMap
                    ? Expanded(
                        child: Column(
                          children: <Widget>[
                            getSearchBarUI(),
                            getTimeDateUI(),
                            getSearchButton(),
                            Expanded(
                              child: Stack(
                                children: <Widget>[
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width,
                                        child: Image.asset(
                                          "assets/images/mapImage.png",
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Container(
                                        height: 80,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppTheme.getTheme().scaffoldBackgroundColor.withOpacity(1.0),
                                              AppTheme.getTheme().scaffoldBackgroundColor.withOpacity(0.0),
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                        ),
                                      ),
                                    ] +
                                    [
                                      getFlightDetails()
                                        
                                      ,
                                    ],
                              ),
                            )
                          ],
                        ),
                      )
                    : Expanded(
                        child: SingleChildScrollView(
                                  child: Column(
                                      children: <Widget>[
                                        Container(
                                          color: AppTheme.getTheme().scaffoldBackgroundColor,
                                          child: Column(
                                            children: <Widget>[
                                              getSearchBarUI(),
                                              getTimeDateUI(),
                                              getSearchButton(),
                                            ],
                                          ),
                                        ),
                                        getFilterBarUI(),
                                        
                                        getFlightDetails(),
                                      ]
                                  ),
                        )
                      )
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> getMapPinUI() {
    List<Widget> list = List<Widget>();

    for (var i = 0; i < hotelList.length; i++) {
      double top;
      double left;
      double right;
      double bottom;
      if (i == 0) {
        top = 150;
        left = 50;
      } else if (i == 1) {
        top = 50;
        right = 50;
      } else if (i == 2) {
        top = 40;
        left = 10;
      } else if (i == 3) {
        bottom = 260;
        right = 140;
      } else if (i == 4) {
        bottom = 160;
        right = 20;
      }
      list.add(
        Positioned(
          top: top,
          left: left,
          right: right,
          bottom: bottom,
          child: Container(
            decoration: BoxDecoration(
              color: hotelList[i].isSelected ? AppTheme.getTheme().primaryColor : AppTheme.getTheme().backgroundColor,
              borderRadius: BorderRadius.all(Radius.circular(24.0)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppTheme.getTheme().dividerColor,
                  blurRadius: 16,
                  offset: Offset(4, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.all(Radius.circular(24.0)),
                onTap: () {
                  if (hotelList[i].isSelected == false) {
                    setState(() {
                      hotelList.forEach((f) {
                        f.isSelected = false;
                      });
                      hotelList[i].isSelected = true;
                    });
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                  child: Text(
                    "\$${hotelList[i].perNight}",
                    style: TextStyle(
                        color: hotelList[i].isSelected ? AppTheme.getTheme().backgroundColor : AppTheme.getTheme().primaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return list;
  }

  Widget getListUI() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getTheme().backgroundColor,
        boxShadow: <BoxShadow>[
          BoxShadow(color: AppTheme.getTheme().dividerColor, offset: Offset(0, -2), blurRadius: 8.0),
        ],
      ),
      child: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height - 156 - 50,
            child: FutureBuilder(
              future: getData(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox();
                } else { return getFlightDetails();
                  
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Widget getHotelViewList() {
    List<Widget> hotelListViews = List<Widget>();
    for (var i = 0; i < hotelList.length; i++) {
      var count = hotelList.length;
      var animation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Interval((1 / count) * i, 1.0, curve: Curves.fastOutSlowIn),
        ),
      );
      hotelListViews.add(
        HotelListView(
          callback: () {},
          hotelData: hotelList[i],
          animation: animation,
          animationController: animationController,
        ),
      );
    }
    animationController.forward();
    return Column(
      children: hotelListViews,
    );
  }

  Widget getFlightDetails(){
    return Container(
          margin: EdgeInsets.only(left: 16, right: 16, top : 10),
          decoration: BoxDecoration(
                  color: AppTheme.getTheme().backgroundColor,
                  boxShadow: <BoxShadow>[
                    BoxShadow(color: AppTheme.getTheme().dividerColor, offset: Offset(0, 2), blurRadius: 8.0),
                  ],
                ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(

                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[

                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(                   
                                          padding: EdgeInsets.only(left: 16.0 , top :14, bottom : 14),
                                          width: MediaQuery.of(context).size.width/2,
                                            child: Text("10 Feb | Departure",
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600
                                              ),
                                            ),
                                          ),

                                        
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.only(left:20, top:6),
                                              child: Container(
                                                width: 1,
                                                height: 120,
                                                color: Colors.grey.withOpacity(1),
                                              ),
                                            ),

                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Container(                   
                                                  padding: EdgeInsets.only(left:10, top:5, bottom: 10),
                                                  margin: EdgeInsets.only(bottom:8),
                                                  width: MediaQuery.of(context).size.width/2,
                                                    child: Text("6 : 15 AM Dallas (DAL)",
                                                      textAlign: TextAlign.start,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w800
                                                      ),
                                                    ),
                                                  ),

                                                Row (
                                                  children: <Widget>[
                                                    Container(     
                                                      margin: EdgeInsets.only(left: 10),
                                                      padding: EdgeInsets.only(top:3, bottom:3, left:5, right: 5),
                                                      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.6)),
                                                        child: Text("7h 15m",
                                                          textAlign: TextAlign.start,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.lightBlue,
                                                            fontWeight: FontWeight.w800
                                                          ),
                                                        ),
                                                      ),

                                                    Container(
                                                      margin: EdgeInsets.only(left : 10, right: 5),
                                                      child: Icon(Icons.favorite, color: Colors.red, size: 14,)),

                                                    Container(
                                                      margin: EdgeInsets.only(left : 5, right: 5),
                                                      child: Icon(Icons.favorite, color: Colors.red, size: 14,)),
                                                    
                                                    
                                                    Container(     
                                                      margin: EdgeInsets.only(left: 5),              
                                                      padding: EdgeInsets.only(top:3, bottom: 3, left:5, right: 5),
                                                      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.6)),
                                                        child: Text("1 Stopover",
                                                          textAlign: TextAlign.start,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.lightBlue,
                                                            fontWeight: FontWeight.w800
                                                          ),
                                                        ),
                                                      ),

                                                  ],
                                                ),

                                                Container(     
                                                      margin: EdgeInsets.only(left: 10, top : 10),              
                                                      padding: EdgeInsets.only(top:3, bottom: 3, left:5, right: 5),
                                                      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.6)),
                                                        child: Text("Economy",
                                                          textAlign: TextAlign.start,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.lightBlue,
                                                            fontWeight: FontWeight.w800
                                                          ),
                                                        ),
                                                      ),


                                              Container(                   
                                                  padding: EdgeInsets.only(left:10, top:20),
                                                  margin: EdgeInsets.only(bottom:3),
                                                  width: MediaQuery.of(context).size.width/2,
                                                    child: Text("3 : 30 PM ARUBA (AUA)",
                                                      textAlign: TextAlign.start,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w800
                                                      ),
                                                    ),
                                                  ),  
                                            ],)

                                            
                                          ],
                                          ),

                                        
                                        
                                      ],
                                    ),
                    
                                  ],
                                ),
                                ),
                
                Container(        
                  
                  padding: EdgeInsets.only(left:16, top : 20, bottom: 10),
                  
                  width: MediaQuery.of(context).size.width/2,
                    child: Text("10 nights in Aruba",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w600
                        ),
                    ),
                  ), 
                 Container(
                                
                    child: Row(
                      children: <Widget>[

                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(                   
                              padding: EdgeInsets.only(left: 16.0, top :14, bottom : 14),
                              width: MediaQuery.of(context).size.width/2,
                                child: Text("20 Feb | Return",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600
                                  ),
                                ),
                              ),

                            
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(left:20, top:6),
                                  child: Container(
                                    width: 1,
                                    height: 120,
                                    color: Colors.grey.withOpacity(0.8),
                                  ),
                                ),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(                   
                                      padding: EdgeInsets.only(left:10, top:5, bottom: 10),
                                      margin: EdgeInsets.only(bottom:8),
                                      width: MediaQuery.of(context).size.width/2,
                                        child: Text("6 : 15 AM Dallas (DAL)",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800
                                          ),
                                        ),
                                      ),

                                    Row (
                                      children: <Widget>[
                                        Container(     
                                          margin: EdgeInsets.only(left: 10),
                                          padding: EdgeInsets.only(top:3, bottom:3, left:5, right: 5),
                                          decoration: BoxDecoration(color: Colors.grey.withOpacity(0.6)),
                                            child: Text("7h 15m",
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.lightBlue,
                                                fontWeight: FontWeight.w800
                                              ),
                                            ),
                                          ),

                                        Container(
                                          margin: EdgeInsets.only(left : 10, right: 5),
                                          child: Icon(Icons.favorite, color: Colors.red, size: 14,)),

                                        Container(
                                          margin: EdgeInsets.only(left : 5, right: 5),
                                          child: Icon(Icons.favorite, color: Colors.red, size: 14,)),
                                        
                                        
                                        Container(     
                                          margin: EdgeInsets.only(left: 5),              
                                          padding: EdgeInsets.only(top:3, bottom: 3, left:5, right: 5),
                                          decoration: BoxDecoration(color: Colors.grey.withOpacity(0.6)),
                                            child: Text("1 Stopover",
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.lightBlue,
                                                fontWeight: FontWeight.w800
                                              ),
                                            ),
                                          ),

                                      ],
                                    ),

                                    Container(     
                                          margin: EdgeInsets.only(left: 10, top : 10),              
                                          padding: EdgeInsets.only(top:3, bottom: 3, left:5, right: 5),
                                          decoration: BoxDecoration(color: Colors.grey.withOpacity(0.6)),
                                            child: Text("Economy",
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.lightBlue,
                                                fontWeight: FontWeight.w800
                                              ),
                                            ),
                                          ),


                                      Container(                   
                                      padding: EdgeInsets.only(left:10, top:20),
                                      margin: EdgeInsets.only(bottom:3),
                                      width: MediaQuery.of(context).size.width/2,
                                        child: Text("3 : 30 PM ARUBA (AUA)",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800
                                          ),
                                        ),
                                      ),

                                    
                                ],)

                                
                              ],
                              ),

                            
                            
                          ],
                        ),




                        
                        
                      ],
                    ),
                    ),
              
              ],
            ),
          
    );
  }
  
  Widget getSearchButton(){
    return Container(
      margin: EdgeInsets.only(left:16.0, right:16, top : 10),
      color: Colors.lightBlue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FlatButton(
            child: Text("Search Flights",style: TextStyle(
                color: Colors.white,
                fontSize: 19.0 , fontWeight: FontWeight.bold)),
            onPressed: () {
              // $fly_from='city:DFW';
              // $fly_to='city:LAS';
              // $date_from='24%2F01%2F2020';
              // $date_to='24%2F01%2F2020';
              // $type='round';
              // $return_from='26%2F01%2F2020';
              // $return_to='26%2F01%2F2020';
              // $adults=1;
              // $infants=0;
              // $hildren=0;
              // $selected_cabins='M';
              // $curr='USD';
              // $url = 'http://staging.joinflyline.com/api/search/?' 
              //   + 'fly_from=' + $fly_from 
              //   + '&fly_to=' + $fly_to 
              //   + '&date_from=' + $date_from 
              //   + '&date_to=' +  $date_to 
              //   + '&type=' +   $type 
              //   + '&return_from=' +   $return_from 
              //   + '&return_to=' +  $return_to 
              //   + '&adults=' +  $adults 
              //   + '&infants=' +  $infants 
              //   + '&children=' +  $hildren 
              //   + '&selected_cabins=' +  $selected_cabins
              //   + '&curr=' +  $curr;
              // HttpClient()
              //   .getUrl(Uri.parse($url)) // produces a request object
              //   .then((request) => request.close()) // sends the request
              //   .then((response) =>
              //     response.transform(Utf8Decoder()).listen(print)); // transforms and prints the response
            },
          ),
        ],
      ),
    );
  }

  Widget getTimeDateUI() {
    return Padding(
      padding: const EdgeInsets.only(left: 18, bottom: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    focusColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    splashColor: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.all(
                      Radius.circular(4.0),
                    ),
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      // setState(() {
                      //   isDatePopupOpen = true;
                      // });
                      showDemoDialog(context: context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4, right: 4, top: 4, bottom: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Trip Dates",
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            "${DateFormat("dd, MMM").format(startDate)} - ${DateFormat("dd, MMM").format(endDate)}",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Container(
              width: 1,
              height: 42,
              color: Colors.grey.withOpacity(0.8),
            ),
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    focusColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    splashColor: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.all(
                      Radius.circular(4.0),
                    ),
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => RoomPopupView(
                          ad: 2,
                          room: 1,
                          ch: 0,
                          barrierDismissible: true,
                          onChnage: (ro, a, c) {
                            setState(() {
                              room = ro;
                              ad = a;
                            });
                          },
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4, right: 4, top: 4, bottom: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Passengers",
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            "$room Room - $ad Adults",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),


          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Container(
              width: 1,
              height: 42,
              color: Colors.grey.withOpacity(0.8),
            ),
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    focusColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    splashColor: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.all(
                      Radius.circular(4.0),
                    ),
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => RoomPopupView(
                          ad: 2,
                          room: 1,
                          ch: 0,
                          barrierDismissible: true,
                          onChnage: (ro, a, c) {
                            setState(() {
                              room = ro;
                              ad = a;
                            });
                          },
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4, right: 4, top: 4, bottom: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Class of Service",
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            "Basic Economy",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        

        ],
      ),
    );
  }

  Widget getSearchBarUI() {
    return Column(
      children: <Widget>[
        Container(
                  width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.getTheme().backgroundColor,
                      boxShadow: <BoxShadow>[
                        BoxShadow(color: AppTheme.getTheme().dividerColor, offset: Offset(0, 2), blurRadius: 8.0),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(                   
                          width: MediaQuery.of(context).size.width/4,
                            child: TextField(
                              textAlign: TextAlign.center,
                              onChanged: (String txt) {},
                              onTap: () {
                              },
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600
                              ),
                              cursorColor: AppTheme.getTheme().primaryColor,
                              decoration: new InputDecoration(
                                border: InputBorder.none,
                                hintText: "Round-Trip",
                              ),
                            ),
                          ),

                        Padding(
                            padding: EdgeInsets.all(8),
                            child: Container(
                              width: 1,
                              height: 45,
                              color: Colors.grey.withOpacity(0.8),
                            ),
                          ),
                            

                        Container(                    
                          width: MediaQuery.of(context).size.width/4,
                            child: TextField(
                                  textAlign: TextAlign.center,
                                  onChanged: (String txt) {},
                                  onTap: () {
                                    // FocusScope.of(context).requestFocus(FocusNode());
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(builder: (context) => SearchScreen(), fullscreenDialog: true),
                                    // );
                                  },
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                  cursorColor: AppTheme.getTheme().primaryColor,
                                  decoration: new InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "One way",
                                  ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Container(
                              width: 1,
                              height: 45,
                              color: Colors.grey.withOpacity(0.8),
                            ),
                          ),


                          Container(                 
                            width: MediaQuery.of(context).size.width/4,
                            child: Stack(
                              children: <Widget>[

                                Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(top : 0),
                                  child: Text(
                                    "Coming soon",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),


                                Container(
                                  
                                  padding: EdgeInsets.only(top:0),
                                  child: TextField(
                                    textAlign: TextAlign.center,
                                    onChanged: (String txt) {},
                                    onTap: () {
                                      // FocusScope.of(context).requestFocus(FocusNode());
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(builder: (context) => SearchScreen(), fullscreenDialog: true),
                                      // );
                                    },
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                    cursorColor: AppTheme.getTheme().primaryColor,
                                    decoration: new InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Nomad",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    ),

        Container(
          width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: AppTheme.getTheme().backgroundColor,
              boxShadow: <BoxShadow>[
                BoxShadow(color: AppTheme.getTheme().dividerColor, offset: Offset(0, 2), blurRadius: 8.0),
              ],
            ),
            child: Container(                   
                  width: MediaQuery.of(context).size.width/4,
                  padding: EdgeInsets.only(left: 10),
                    child: LocationSearchUI("Departure", true, notifyParent: refreshDepartureValue),
              ),
            ),

            Container(
          width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: AppTheme.getTheme().backgroundColor,
              boxShadow: <BoxShadow>[
                BoxShadow(color: AppTheme.getTheme().dividerColor, offset: Offset(0, 2), blurRadius: 8.0),
              ],
            ),
            child: Container(                   
                  width: MediaQuery.of(context).size.width/4,
                  padding: EdgeInsets.only(left: 10),
                    child: LocationSearchUI("Arrival", true, notifyParent: refreshDepartureValue),
                  ),
            ),
      
      ],
    );
        
  }

  Widget getFilterBarUI() {
    return Stack(
      children: <Widget>[
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.getTheme().backgroundColor,
              boxShadow: <BoxShadow>[
                BoxShadow(color: AppTheme.getTheme().dividerColor, offset: Offset(0, -2), blurRadius: 8.0),
              ],
            ),
          ),
        ),
        Container(
          color: AppTheme.getTheme().backgroundColor,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 4),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "530 flights found",
                      style: TextStyle(
                        fontWeight: FontWeight.w100,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    focusColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    splashColor: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.all(
                      Radius.circular(4.0),
                    ),
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FiltersScreen(), fullscreenDialog: true),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Row(
                        children: <Widget>[
                          Text(
                            "Filter",
                            style: TextStyle(
                              fontWeight: FontWeight.w100,
                              fontSize: 16,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.sort, color: AppTheme.getTheme().primaryColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Divider(
            height: 1,
          ),
        )
      ],
    );
  }

  void showDemoDialog({BuildContext context}) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CalendarPopupView(
        barrierDismissible: true,
        minimumDate: DateTime.now(),
        //  maximumDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 10),
        initialEndDate: endDate,
        initialStartDate: startDate,
        onApplyClick: (DateTime startData, DateTime endData) {
          setState(() {
            if (startData != null && endData != null) {
              startDate = startData;
              endDate = endData;
            }
          });
        },
        onCancelClick: () {},
      ),
    );
  }

  Widget getAppBarUI() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getTheme().backgroundColor,
        boxShadow: <BoxShadow>[
          BoxShadow(color: AppTheme.getTheme().dividerColor, offset: Offset(0, 2), blurRadius: 8.0),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 8, right: 8),
        child: Stack(
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              width: AppBar().preferredSize.height + 40,
              height: AppBar().preferredSize.height,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.all(
                    Radius.circular(32.0),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.arrow_back),
                  ),
                ),
              ),
            ),
            Container(
                margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top/2),
                alignment: Alignment.center,
                child: Text(
                  "Explore",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  refreshDepartureValue(value, isDeparture) {
    if(this.mounted) setState(() {
      if (isDeparture) selectedDeparture = value;
      else selectedArrival = value;
    });
    }
}


class LocationSearchUI extends StatefulWidget {

  final Function(LocationObject value, bool type) notifyParent;
  final title;
  final isDeparture;

  LocationSearchUI(this.title, this.isDeparture, {Key key, @required this.notifyParent}) : super(key: key);


  @override
  _LocationSearchUIState createState() => _LocationSearchUIState(title);
}

  
  class _LocationSearchUIState extends State<LocationSearchUI> with TickerProviderStateMixin {
    
    var title;
  
    _LocationSearchUIState(var item){
      this.title = title;
    }

    @override
    Widget build(BuildContext context) {
      return SimpleAutocompleteFormField<LocationObject>(
                        itemToString: (location) => location != null ? location.code: "",
                        textAlign: TextAlign.start,
                        itemBuilder: (context, location) => Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(location.name,
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(location.code)
                              ]),
                        ),
                    onSearch: (search) async {
                        if(search.length > 0){
                          var response = flyLinebloc.locationQuery(search);
                          return response;
                        }else return null;
                        
                      
                    },
                    onChanged: (value) =>  widget.notifyParent(value, widget.isDeparture),
                    onSaved: (value) => widget.notifyParent(value, widget.isDeparture),
                    validator: (location) => location.name == null ? 'Invalid location.' : null,

                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600
                    ),
                    decoration: new InputDecoration(
                      border: InputBorder.none,
                      hintText: widget.title+" City or Airport",
                    ),
                  );
    }
}


class MapHotelListView extends StatelessWidget {
  final VoidCallback callback;
  final HotelListData hotelData;

  const MapHotelListView({Key key, this.hotelData, this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 24, right: 8, top: 8, bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.getTheme().backgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppTheme.getTheme().dividerColor,
              offset: Offset(4, 4),
              blurRadius: 16,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          child: AspectRatio(
            aspectRatio: 2.7,
            child: Stack(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    AspectRatio(
                      aspectRatio: 0.90,
                      child: Image.asset(
                        hotelData.imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              hotelData.titleTxt,
                              maxLines: 2,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              hotelData.subTxt,
                              style: TextStyle(fontSize: 14, color: Colors.grey.withOpacity(0.8)),
                            ),
                            Expanded(
                              child: SizedBox(),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(
                                            FontAwesomeIcons.mapMarkerAlt,
                                            size: 12,
                                            color: AppTheme.getTheme().primaryColor,
                                          ),
                                          Text(
                                            " ${hotelData.dist.toStringAsFixed(1)} km to city",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 14, color: Colors.grey.withOpacity(0.8)),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: SmoothStarRating(
                                          allowHalfRating: true,
                                          starCount: 5,
                                          rating: hotelData.rating,
                                          size: 20,
                                          color: AppTheme.getTheme().primaryColor,
                                          borderColor: AppTheme.getTheme().primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        "\$${hotelData.perNight}",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 22,
                                        ),
                                      ),
                                      Text(
                                        "/per night",
                                        style: TextStyle(fontSize: 14, color: Colors.grey.withOpacity(0.8)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: AppTheme.getTheme().primaryColor.withOpacity(0.1),
                    onTap: () {
                      callback();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
