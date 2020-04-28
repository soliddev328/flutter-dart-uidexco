import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:motel/appTheme.dart';
import 'package:motel/helper/helper.dart';
import 'package:motel/models/book_request.dart' as BookRequest;
import 'package:motel/modules/bookingflow/booking_complete.dart';
import 'package:motel/modules/bookingflow/confirm_booking.dart' as confirm_booking;
import 'package:motel/models/check_flight_response.dart';
import 'package:motel/models/traveler_information.dart';
import 'package:motel/network/blocs.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HotelHomeScreen extends StatefulWidget {
  final int numberOfPassengers;
  final CheckFlightResponse flightResponse;
  final List<TravelerInformation> travelerInformations;
  final Map<String, dynamic> retailInfo;
  final String bookingToken;
  final double totalPrice;

  HotelHomeScreen(
      {Key key,
      this.numberOfPassengers,
      this.travelerInformations,
      this.flightResponse,
      this.retailInfo,
      this.bookingToken,
      this.totalPrice})
      : super(key: key);

  @override
  _HotelHomeScreenState createState() => _HotelHomeScreenState();
}

class _HotelHomeScreenState extends State<HotelHomeScreen>
    with TickerProviderStateMixin {
  double priceOnPassenger = 0;
  double priceOnBaggage = 0;
  double tripTotal = 0;
  bool _clickedBookFlight = false;

  TextEditingController promoCodeController;
  TextEditingController nameOnCardController;
  TextEditingController creditController;
  TextEditingController expDateController;
  TextEditingController ccvController;
  TextEditingController emailAddressController;
  TextEditingController phoneNumberController;

  @override
  void initState() {
    priceOnPassenger = Helper.getCostNumber(widget.flightResponse.total,
        widget.flightResponse.conversion.amount, widget.flightResponse.total);

    widget.travelerInformations.forEach((t) {
      priceOnBaggage += Helper.costNumber(
              widget.flightResponse.total,
              widget.flightResponse.conversion.amount,
              t.carryOnSelected.price.amount) +
          Helper.costNumber(
              widget.flightResponse.total,
              widget.flightResponse.conversion.amount,
              t.checkedBagageSelected.price.amount);
    });
    tripTotal = priceOnPassenger + priceOnBaggage;

    this.getAccountInfo();
    super.initState();

    flyLinebloc.bookFlight.stream.listen((Map onData) {
      if (onData != null) {
        if (_clickedBookFlight && onData['status'] != 200) {
          Alert(
            context: context,
            title:
                "There seemed to be an error when booking your flight, try again or contact FlyLine support, support@joinflyline.com",
            buttons: [
              DialogButton(
                child: Text(
                  "Close",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                width: 120,
              ),
            ],
          ).show();
        } else {
          Alert(
            context: context,
            title: "Book flight successfully",
            buttons: [
              DialogButton(
                child: Text(
                  "Close",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                width: 120,
              ),
            ],
          ).show();
        }
        setState(() {
          _clickedBookFlight = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _clickedBookFlight = false;
    super.dispose();
  }

  void getAccountInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      promoCodeController = TextEditingController();
      nameOnCardController = TextEditingController();
      creditController = TextEditingController();
      expDateController = TextEditingController();
      ccvController = TextEditingController();
      emailAddressController = TextEditingController();
      phoneNumberController = TextEditingController();

      emailAddressController.text = prefs.getString('email');
      phoneNumberController.text = prefs.getString('phone_number');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F9FC),
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
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  getAppBarUI(),
                  Container(
                    child: Column(
                      children: <Widget>[
                        pageIndicator(),
                        // getTripDetails(),
                        //getCheckoutUI(),
                        getBookButton()
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget pageIndicator(){
    return new Container(
       // width: 375,
        height: 4,
        decoration:  BoxDecoration(
          color: Color(0xff0e3178)
        )
      );
  }

  Widget getCheckoutUI() {
    return Column(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          // margin: const EdgeInsets.only(top: 8, bottom: 8),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(
            left: 16.0,
          ),
          child: new Text(
            "Payment Info",
            style: TextStyle(
              fontFamily: 'AvenirNext',
              color: Color(0xff3a3f5c),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.normal,
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
          decoration: new BoxDecoration(
              color: Color(0xffffffff),
              borderRadius: BorderRadius.circular(15)),
          child: Container(
            width: MediaQuery.of(context).size.width / 4,
            padding: EdgeInsets.only(left: 10),
            child: TextField(
              controller: promoCodeController,
              textAlign: TextAlign.start,
              onChanged: (String txt) {},
              onTap: () {},
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              cursorColor: AppTheme.getTheme().primaryColor,
              decoration: new InputDecoration(
                border: InputBorder.none,
                hintText: "Promo Code",
              ),
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(
            left: 16,
            right: 16,
          ),
          decoration: new BoxDecoration(
              color: Color(0xffffffff),
              borderRadius: BorderRadius.circular(15)),
          child: Container(
            padding: EdgeInsets.only(left: 10),
            child: TextField(
              controller: nameOnCardController,
              textAlign: TextAlign.start,
              onChanged: (String txt) {},
              onTap: () {},
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              cursorColor: AppTheme.getTheme().primaryColor,
              decoration: new InputDecoration(
                border: InputBorder.none,
                hintText: "Name on Card",
              ),
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
          decoration: new BoxDecoration(
              color: Color(0xffffffff),
              borderRadius: BorderRadius.circular(15)),
          child: Container(
            padding: EdgeInsets.only(left: 10),
            child: TextField(
              controller: creditController,
              textAlign: TextAlign.start,
              onChanged: (String txt) {},
              onTap: () {},
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              cursorColor: AppTheme.getTheme().primaryColor,
              decoration: new InputDecoration(
                border: InputBorder.none,
                hintText: "Credit Card Number",
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(
                  left: 16,
                  right: 8,
                ),
                decoration: new BoxDecoration(
                    color: Color(0xffffffff),
                    borderRadius: BorderRadius.circular(15)),
                child: Container(
                  padding: EdgeInsets.only(left: 10),
                  child: TextField(
                    controller: expDateController,
                    textAlign: TextAlign.start,
                    onChanged: (String txt) {},
                    onTap: () {},
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    cursorColor: AppTheme.getTheme().primaryColor,
                    decoration: new InputDecoration(
                      border: InputBorder.none,
                      hintText: "Exp Date",
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(
                  left: 8,
                  right: 16,
                ),
                decoration: new BoxDecoration(
                    color: Color(0xffffffff),
                    borderRadius: BorderRadius.circular(15)),
                child: Container(
                  padding: EdgeInsets.only(left: 10),
                  child: TextField(
                    controller: ccvController,
                    textAlign: TextAlign.start,
                    onChanged: (String txt) {},
                    onTap: () {},
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    cursorColor: AppTheme.getTheme().primaryColor,
                    decoration: new InputDecoration(
                      border: InputBorder.none,
                      hintText: "CCV",
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
          decoration: new BoxDecoration(
              color: Color(0xffffffff),
              borderRadius: BorderRadius.circular(15)),
          child: Container(
            padding: EdgeInsets.only(left: 10),
            child: TextField(
              controller: emailAddressController,
              textAlign: TextAlign.start,
              onChanged: (String txt) {},
              onTap: () {},
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              cursorColor: AppTheme.getTheme().primaryColor,
              decoration: new InputDecoration(
                border: InputBorder.none,
                hintText: "Email Address",
              ),
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(
            left: 16,
            right: 16,
          ),
          decoration: new BoxDecoration(
              color: Color(0xffffffff),
              borderRadius: BorderRadius.circular(15)),
          child: Container(
            padding: EdgeInsets.only(left: 10),
            child: TextField(
              controller: phoneNumberController,
              textAlign: TextAlign.start,
              onChanged: (String txt) {},
              onTap: () {},
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              cursorColor: AppTheme.getTheme().primaryColor,
              decoration: new InputDecoration(
                border: InputBorder.none,
                hintText: "Phone Number",
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget getTripDetails() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: const Color(0xF6F6F6),
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
                          padding: EdgeInsets.only(left: 16.0, top: 20),
                          width: MediaQuery.of(context).size.width / 2,
                          child: new Text(
                            "Trip Summary",
                            style: TextStyle(
                              fontFamily: 'AvenirNext',
                              color: Color(0xff3a3f5c),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width - 32,
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(top: 10, left: 16, right: 16),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.getTheme().backgroundColor,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Expanded(
                                    child: new Text(
                                      "Passengers:  ",
                                      style: TextStyle(
                                        fontFamily: 'AvenirNext',
                                        color: Color(0xff8e969f),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        fontStyle: FontStyle.normal,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        child: Text(
                                          widget.numberOfPassengers.toString() +
                                              ' Adult',
                                          style: TextStyle(
                                            fontFamily: 'AvenirNext',
                                            color: Color(0xff3a3f5c),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FontStyle.normal,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                          child: Container(
                                            child: Text(
                                              "  + Add More",
                                              style: TextStyle(
                                                fontFamily: 'AvenirNext',
                                                color: Color(0xff00aeef),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                fontStyle: FontStyle.normal,
                                              ),
                                            ),
                                          ),
                                          onTap: () => {}
                                          //getAddAnotherPassenger(),
                                          ),
                                    ],
                                  ),
                                  // Container(
                                  //   alignment: Alignment.centerLeft,
                                  //   padding: EdgeInsets.only(left: 10, top: 6),
                                  //   margin: EdgeInsets.only(bottom: 6),
                                  //   child: Text(
                                  //     Helper.cost(
                                  //         widget.flightResponse.total,
                                  //         widget
                                  //             .flightResponse.conversion.amount,
                                  //         widget.flightResponse.total),
                                  //     textAlign: TextAlign.start,
                                  //     style: TextStyle(
                                  //         fontSize: 12,
                                  //         fontWeight: FontWeight.w600),
                                  //   ),
                                  // ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 10.0, bottom: 10.0),
                                child: Container(
                                    child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        "Trip Price:",
                                        style: TextStyle(
                                          fontFamily: 'AvenirNext',
                                          color: Color(0xff8e969f),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          fontStyle: FontStyle.normal,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: <Widget>[
                                        // Container(),
                                        Container(
                                          height: 30,
                                          width: 80,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: Color(0xffE5F7FE),
                                          ),
                                          child: Center(
                                            child: Text(
                                              Helper.cost(
                                                  widget.flightResponse.total,
                                                  widget.flightResponse
                                                      .conversion.amount,
                                                  widget.flightResponse.total),
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily: 'AvenirNext',
                                                color: Color(0xff00aeef),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                fontStyle: FontStyle.normal,
                                              ),
                                            ),
                                          ),
                                          //child: Text("\$ " + widget.flight.price.toString()),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                              ),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      child: new Text(
                                        "Bagage:",
                                        style: TextStyle(
                                          fontFamily: 'AvenirNext',
                                          color: Color(0xff8e969f),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          fontStyle: FontStyle.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 30,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Color(0xffE5F7FE),
                                    ),
                                    child: Center(
                                      child: Text(
                                        Helper.formatNumber(priceOnBaggage),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontFamily: 'AvenirNext',
                                          color: Color(0xff00aeef),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          fontStyle: FontStyle.normal,
                                        ),
                                      ),
                                    ),
                                    //child: Text("\$ " + widget.flight.price.toString()),
                                  ),
                                  // Container(
                                  //   alignment: Alignment.centerLeft,
                                  //   padding: EdgeInsets.only(left: 10, top: 5),
                                  //   margin: EdgeInsets.only(bottom: 3),
                                  //   child: Text(
                                  //     Helper.formatNumber(priceOnBaggage),
                                  //     textAlign: TextAlign.start,
                                  //     style: TextStyle(
                                  //         fontSize: 12,
                                  //         fontWeight: FontWeight.w600),
                                  //   ),
                                  // ),
                                ],
                              ),
                              // Row(
                              //   mainAxisAlignment:
                              //       MainAxisAlignment.spaceAround,
                              //   children: <Widget>[
                              //     Expanded(
                              //       child: Container(
                              //         padding:
                              //             EdgeInsets.only(left: 10, top: 5),
                              //         margin: EdgeInsets.only(bottom: 3),
                              //         alignment: Alignment.centerLeft,
                              //         child: Text(
                              //           "Automatic Check-in",
                              //           textAlign: TextAlign.start,
                              //           style: TextStyle(
                              //               fontSize: 12,
                              //               fontWeight: FontWeight.w600),
                              //         ),
                              //       ),
                              //     ),
                              //     Container(
                              //       alignment: Alignment.centerLeft,
                              //       padding: EdgeInsets.only(left: 10, top: 5),
                              //       margin: EdgeInsets.only(bottom: 3),
                              //       child: Text(
                              //         "Free ",
                              //         textAlign: TextAlign.start,
                              //         style: TextStyle(
                              //             fontSize: 12,
                              //             fontWeight: FontWeight.w600),
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              // Padding(
                              //   padding: EdgeInsets.only(top: 10, bottom: 10),
                              //   child: Container(
                              //     height: 1,
                              //     color: Colors.grey.withOpacity(0.4),
                              //   ),
                              // ),
                              // Row(
                              //   mainAxisAlignment:
                              //       MainAxisAlignment.spaceAround,
                              //   children: <Widget>[
                              //     Expanded(
                              //       child: Container(
                              //         padding:
                              //             EdgeInsets.only(left: 10, top: 5),
                              //         margin: EdgeInsets.only(bottom: 3),
                              //         alignment: Alignment.centerLeft,
                              //         child: Text(
                              //           "Trip Total",
                              //           textAlign: TextAlign.start,
                              //           style: TextStyle(
                              //               fontSize: 13,
                              //               fontWeight: FontWeight.w800),
                              //         ),
                              //       ),
                              //     ),
                              //     Container(
                              //       alignment: Alignment.centerLeft,
                              //       padding: EdgeInsets.only(left: 10, top: 5),
                              //       margin: EdgeInsets.only(bottom: 3),
                              //       child: Text(
                              //         Helper.formatNumber(tripTotal),
                              //         textAlign: TextAlign.start,
                              //         style: TextStyle(
                              //             fontSize: 13,
                              //             fontWeight: FontWeight.w800),
                              //       ),
                              //     ),
                              //   ],
                              // ),
                            ],
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
    );
  }

  Widget getAppBarUI() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getTheme().backgroundColor,
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: AppTheme.getTheme().dividerColor,
              offset: Offset(0, 2),
              blurRadius: 8.0),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top, left: 8, right: 8),
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
                    child: Icon(Icons.arrow_back_ios),
                  ),
                ),
              ),
            ),
            Container(
              margin:
                  EdgeInsets.only(top: MediaQuery.of(context).padding.top / 2),
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: <Widget>[
                    new Text(
                      "Review and Book",
                      style: TextStyle(
                        fontFamily: 'Gilroy',
                        color: Color(0xff0e3178),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    RichText(
                      text: new TextSpan(children: [
                        new TextSpan(
                            text: "3 of 3 ",
                            style: TextStyle(
                              fontFamily: 'Gilroy',
                              color: Color(0xff0e3178),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.normal,
                            )),
                        new TextSpan(
                            text: "Steps",
                            style: TextStyle(
                              fontFamily: 'Gilroy',
                              color: Color(0xff8e969f),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                            )),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getBookButton() {
    return Container(
      //height: 50,
      margin: EdgeInsets.only(left: 16.0, right: 16, top: 170),
      // decoration: BoxDecoration(
      //     color: const Color(0xFF00AFF5),
      //     border: Border.all(color: const Color(0xFF00AFF5), width: 0.5)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RichText(
                  text: new TextSpan(children: [
                    new TextSpan(
                      text: "Total",
                      style: TextStyle(
                        fontFamily: 'Gilroy',
                        color: Color(0xff0e3178),
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                    new TextSpan(
                      //text: Helper.formatNumber(tripTotal),
                      text:Helper.formatNumber(widget.totalPrice),
                      style: TextStyle(
                        fontFamily: 'Gilroy',
                        color: Color(0xff0e3178),
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
          Text(
            "Will be charged to your card,",
            style: TextStyle(
              fontFamily: 'Gilroy',
              color: Color(0xff8e969f),
              fontSize: 18,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.normal,
            ),
          ),
           Padding(
             padding: const EdgeInsets.only(top:6.0,bottom: 30.0),
             child: Text(
              "You will recieve a confirmation email soon.",
              style: TextStyle(
                fontFamily: 'Gilroy',
                color: Color(0xff8e969f),
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.normal,
              ),
          ),
           ),
          InkWell(
            child: Container(
              //width: 199,
              height: 50,
              decoration: new BoxDecoration(
                color: Color(0xff00aeef),
                borderRadius: BorderRadius.circular(27),
                boxShadow: [
                  BoxShadow(
                      color: Color(0x3300a3da),
                      offset: Offset(0, 5),
                      blurRadius: 20,
                      spreadRadius: 0),
                ],
              ),
              child: Center(
                child: new Text(
                  "Confirm Booking",
                  style: TextStyle(
                    fontFamily: 'Gilroy',
                    color: Color(0xffffffff),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BookingCompletePage(
                        // numberOfPassengers: numberOfPassengers,
                        // travelerInformations: lists,
                        // flightResponse: _checkFlightResponse,
                        // retailInfo: widget.retailInfo,
                        // bookingToken: widget.bookingToken,
                        )),
              );
              // setState(() {
              //   _clickedBookFlight = true;
              // });
              // flyLinebloc.book(this.createBookRequest());
            },
          ),
          // FlatButton(
          //   child: Text("Book Flight For" + Helper.formatNumber(tripTotal),
          //       style: TextStyle(
          //           color: Colors.white,
          //           fontSize: 19.0,
          //           fontWeight: FontWeight.bold)),
          //   onPressed: () {
          //     setState(() {
          //       _clickedBookFlight = true;
          //     });
          //     flyLinebloc.book(this.createBookRequest());
          //   },
          // ),
        ],
      ),
    );
  }

  BookRequest.BookRequest createBookRequest() {
    BookRequest.Baggage baggage =
        BookRequest.Baggage(List<BookRequest.BaggageItem>());

    List<BookRequest.Passenger> passengers = List();

    Map<String, List<int>> carryOnPassengers = Map();
    List<BagItem> carryOns = List();

    Map<String, List<int>> checkedBagagePassengers = Map();
    List<BagItem> checkedBagages = List();

    widget.travelerInformations.forEach((p) {
      BookRequest.Passenger passenger = BookRequest.Passenger(
          DateTime.parse(p.dob),
          p.passportId,
          p.ageCategory,
          p.passportExpiration,
          p.firstName,
          "US",
          p.lastName,
          "mr");

      passengers.add(passenger);

      if (p.carryOnSelected != null &&
          p.carryOnSelected.conditions.passengerGroups.indexOf(p.ageCategory) !=
              -1) {
        if (carryOnPassengers.containsKey(p.carryOnSelected.uuid)) {
          carryOnPassengers.update(p.carryOnSelected.uuid, (List<int> val) {
            val.add(passengers.length - 1);
            return val;
          });
        } else {
          carryOns.add(p.carryOnSelected);
          carryOnPassengers.addAll({
            p.carryOnSelected.uuid: [passengers.length - 1]
          });
        }
      }

      if (p.checkedBagageSelected != null &&
          p.checkedBagageSelected.conditions.passengerGroups
                  .indexOf(p.ageCategory) !=
              -1) {
        if (checkedBagagePassengers.containsKey(p.checkedBagageSelected.uuid)) {
          checkedBagagePassengers.update(p.checkedBagageSelected.uuid,
              (List<int> val) {
            val.add(passengers.length - 1);
            return val;
          });
        } else {
          checkedBagages.add(p.checkedBagageSelected);
          checkedBagagePassengers.addAll({
            p.checkedBagageSelected.uuid: [passengers.length - 1]
          });
        }
      }
    });

    carryOns.forEach((item) {
      BookRequest.Combination combination = BookRequest.Combination(item);

      baggage.add(new BookRequest.BaggageItem(
          combination, carryOnPassengers[item.uuid]));
    });

    checkedBagages.forEach((item) {
      BookRequest.Combination combination = BookRequest.Combination(item);

      baggage.add(new BookRequest.BaggageItem(
          combination, checkedBagagePassengers[item.uuid]));
    });

    BookRequest.BookRequest bookRequest = BookRequest.BookRequest(
        baggage,
        BookRequest.BookRequest.DEFAULT_CURRENCY,
        BookRequest.BookRequest.DEFAULT_LANG,
        BookRequest.BookRequest.DEFAULT_LOCALE,
        BookRequest.BookRequest.DEFAULT_PAYMENT_GATEWAY,
        this.getPayment(),
        passengers,
        widget.retailInfo,
        widget.bookingToken);

    return bookRequest;
  }

  BookRequest.Payment getPayment() => BookRequest.Payment(
      creditController.text,
      ccvController.text,
      emailAddressController.text,
      expDateController.text,
      nameOnCardController.text,
      phoneNumberController.text,
      promoCodeController.text);
}
