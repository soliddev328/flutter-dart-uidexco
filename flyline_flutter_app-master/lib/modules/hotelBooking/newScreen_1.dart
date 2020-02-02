import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:motel/appTheme.dart';
import 'package:motel/helper/helper.dart';
import 'package:motel/models/checkFlightResponse.dart';
import 'package:motel/models/flightInformation.dart';
import 'package:motel/models/travelerInformation.dart';
import 'package:motel/modules/hotelBooking/newScreen_2.dart' as newScreen2;
import 'package:motel/network/blocs.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:select_dialog/select_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class HotelHomeScreen extends StatefulWidget {
  List<FlightRouteObject> routes;
  final int ad;
  final int ch;
  final String bookingToken;
  final Map<String, dynamic> retailInfo;

  HotelHomeScreen(
      {Key key,
      this.routes,
      this.ad,
      this.ch,
      this.bookingToken,
      this.retailInfo})
      : super(key: key);

  @override
  _HotelHomeScreenState createState() => _HotelHomeScreenState();
}

class _HotelHomeScreenState extends State<HotelHomeScreen>
    with TickerProviderStateMixin {
  var personalItemBool = false;
  var noHandBagBool = true;
  var noCheckBagBool = true;
  var oneCheckBagBool = false;
  var twoCheckBagBool = false;

  int numberOfPassengers = 0;

  bool _checkFlight = false;
  bool _firstLoad = false;

  List<BagItem> carryOnSelectedList;
  List<Map<String, bool>> carryOnCheckBoxes;
  List<BagItem> checkedBagageSelectedList;

  List<TextEditingController> firstNameControllers;
  List<TextEditingController> lastNameControllers;
  List<TextEditingController> dobControllers;
  List<TextEditingController> genderControllers;
  List<TextEditingController> passportIdControllers;
  List<TextEditingController> passportExpirationControllers;

  List<Widget> travailInformationUIs;

  static var genders = [
    "Male",
    "Female",
  ];
  static var genderValues = ["0", "1"];

  var selectedGender = genders[0];
  var selectedGenderValue = genderValues[0];

  CheckFlightResponse _checkFlightResponse;
  List<BagItem> handBags;
  List<BagItem> holdBags;

  bool _displayPayment = false;

  void addPassenger() async {
    numberOfPassengers++;
    TextEditingController firstNameController = new TextEditingController();
    TextEditingController lastNameController = new TextEditingController();
    TextEditingController dobController = new TextEditingController();
    TextEditingController genderController = new TextEditingController();
    TextEditingController passportIdController = new TextEditingController();
    TextEditingController passportExpirationController =
        new TextEditingController();

    firstNameControllers.add(firstNameController);
    lastNameControllers.add(lastNameController);
    dobControllers.add(dobController);
    genderControllers.add(genderController);
    passportIdControllers.add(passportIdController);
    passportExpirationControllers.add(passportExpirationController);

    carryOnSelectedList.add(null);
    checkedBagageSelectedList.add(null);

    carryOnCheckBoxes.add(Map());

    if (numberOfPassengers == 1) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      firstNameController.text = prefs.getString('first_name');
      lastNameController.text = prefs.getString('last_name');
      dobController.text = prefs.getString('dob');
      genderController.text =
          int.parse(prefs.getString('gender')) == 0 ? 'Male' : 'Female';
    }
  }

  @override
  void initState() {
    travailInformationUIs = List();
    firstNameControllers = List();
    lastNameControllers = List();
    dobControllers = List();
    genderControllers = List();
    passportIdControllers = List();
    passportExpirationControllers = List();
    carryOnSelectedList = List();
    checkedBagageSelectedList = List();

    carryOnCheckBoxes = List();

    handBags = List();
    holdBags = List();

    addPassenger();
    flyLinebloc.checkFlights(widget.bookingToken, 0, widget.ch, widget.ad);
    _checkFlight = true;
    super.initState();

    flyLinebloc.checkFlightData.stream.listen((CheckFlightResponse response) {
      if (response != null && _checkFlight) {
        setState(() {
          if (!_firstLoad) {
            _checkFlightResponse = response;
            handBags.addAll(response.baggage.combinations.handBag);
            holdBags.addAll(response.baggage.combinations.holdBag);
            travailInformationUIs
                .add(this.getTravailInformationUI(numberOfPassengers));
            _firstLoad = true;
          }
        });

        if (!response.flightsChecked) {
          flyLinebloc.checkFlights(
              widget.bookingToken, 0, widget.ch, widget.ad);
        } else {
          setState(() {
            _displayPayment = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _checkFlight = false;
    _firstLoad = false;
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
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  getAppBarUI(),
                  Container(
                    child: Column(
                      children: <Widget>[
                        getFlightDetails(),
                        Column(
                          children: travailInformationUIs,
                        ),
                        getAddAnotherPassenger(),
                        getSearchButton()
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

  Widget getTravailInformationUI(int position) {
    List<Widget> listOfHandBag = List();
    for (var i = 0; i < handBags.length; i++) {
      var bag = handBags[i];
      var uuid = Uuid().v4();
      if (i == 0) {
        this.carryOnCheckBoxes[numberOfPassengers - 1] = Map();
        this.carryOnCheckBoxes[numberOfPassengers - 1].addAll({uuid: true});
      } else {
        this.carryOnCheckBoxes[numberOfPassengers - 1].addAll({uuid: false});
      }
      this.carryOnSelectedList[numberOfPassengers - 1] = bag;
      if (bag.indices.length == 0) {
        listOfHandBag.add(Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: AppTheme.getTheme().backgroundColor,
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey, offset: Offset(0, 2), blurRadius: 8.0),
            ],
          ),
          child: Container(
            padding: EdgeInsets.only(left: 10),
            width: MediaQuery.of(context).size.width,
            child: Row(
              //mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Checkbox(
                  value: carryOnCheckBoxes[numberOfPassengers - 1][uuid],
                  onChanged: (value) {
                    setState(() {
                      personalItemBool = value;
                      carryOnCheckBoxes[numberOfPassengers - 1][uuid] = value;
                      carryOnSelectedList[numberOfPassengers - 1] = bag;
                    });
                  },
                ),
                Text(
                  "Personal item",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  Helper.cost(_checkFlightResponse.total,
                      _checkFlightResponse.conversion.amount, bag.price.amount),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ));
      } else {
        listOfHandBag.add(Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: AppTheme.getTheme().backgroundColor,
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey, offset: Offset(0, 2), blurRadius: 8.0),
            ],
          ),
          child: Container(
            padding: EdgeInsets.only(left: 10),
            width: MediaQuery.of(context).size.width,
            child: Row(
              //mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Checkbox(
                  value: carryOnCheckBoxes[numberOfPassengers - 1][uuid],
                  onChanged: (value) {
                    carryOnCheckBoxes[numberOfPassengers - 1][uuid] = value;
                    setState(() {
                      carryOnSelectedList[numberOfPassengers - 1] = bag;
                    });
                  },
                ),
                Text(
                  "No Hand Baggage",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  Helper.cost(_checkFlightResponse.total,
                      _checkFlightResponse.conversion.amount, bag.price.amount),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ));
      }
    }

    List<Widget> listOfHoldBag = List();
    for (var i = 0; i < holdBags.length; i++) {
      var bag = holdBags[i];
      if (bag.indices.length == 0) {
        checkedBagageSelectedList[numberOfPassengers - 1] = bag;
        listOfHoldBag.add(Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: AppTheme.getTheme().backgroundColor,
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey, offset: Offset(0, 2), blurRadius: 8.0),
            ],
          ),
          child: Container(
            padding: EdgeInsets.only(left: 10),
            width: MediaQuery.of(context).size.width,
            child: Row(
              //mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Checkbox(
                  value: noCheckBagBool,
                  onChanged: (value) {
                    setState(() {
                      checkedBagageSelectedList[numberOfPassengers - 1] = bag;
                      noCheckBagBool = value;
                    });
                  },
                ),
                Text(
                  "No Checked bagage",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  Helper.cost(_checkFlightResponse.total,
                      _checkFlightResponse.conversion.amount, bag.price.amount),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ));
      } else {
        List<Widget> rows = List();
        for (var i = 0; i < bag.indices.length; i++) {
          rows.add(Text(
            "Checked Baggage",
            textAlign: TextAlign.start,
            style: TextStyle(
                fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600),
          ));
        }
        listOfHoldBag.add(Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: AppTheme.getTheme().backgroundColor,
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey, offset: Offset(0, 2), blurRadius: 8.0),
            ],
          ),
          child: Container(
            padding: EdgeInsets.only(left: 10),
            width: MediaQuery.of(context).size.width,
            child: Row(
              //mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Checkbox(
                  value: oneCheckBagBool,
                  onChanged: (value) {
                    setState(() {
                      checkedBagageSelectedList[numberOfPassengers - 1] = bag;
                      oneCheckBagBool = value;
                    });
                  },
                ),
                Column(
                  children: rows,
                ),
                Text(
                  Helper.cost(_checkFlightResponse.total,
                      _checkFlightResponse.conversion.amount, bag.price.amount),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ));
      }
    }
    return Column(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(top: 8, bottom: 8),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 16.0, top: 10),
          child: Text(
            "Traveler Information",
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: AppTheme.getTheme().backgroundColor,
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey, offset: Offset(0, 2), blurRadius: 8.0),
            ],
          ),
          child: Container(
            width: MediaQuery.of(context).size.width / 4,
            padding: EdgeInsets.only(left: 10),
            child: TextField(
              controller: firstNameControllers[numberOfPassengers - 1],
              textAlign: TextAlign.start,
              onChanged: (String txt) {},
              onTap: () {},
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              cursorColor: AppTheme.getTheme().primaryColor,
              decoration: new InputDecoration(
                border: InputBorder.none,
                hintText: "First Name",
              ),
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: AppTheme.getTheme().backgroundColor,
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey, offset: Offset(0, 2), blurRadius: 8.0),
            ],
          ),
          child: Container(
            padding: EdgeInsets.only(left: 10),
            child: TextField(
              controller: lastNameControllers[numberOfPassengers - 1],
              textAlign: TextAlign.start,
              onChanged: (String txt) {},
              onTap: () {},
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              cursorColor: AppTheme.getTheme().primaryColor,
              decoration: new InputDecoration(
                border: InputBorder.none,
                hintText: "Last Name",
              ),
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: AppTheme.getTheme().backgroundColor,
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey, offset: Offset(0, 2), blurRadius: 8.0),
            ],
          ),
          child: Container(
            padding: EdgeInsets.only(left: 10),
            child: TextField(
              controller: dobControllers[position - 1],
              textAlign: TextAlign.start,
              onChanged: (String txt) {},
              onTap: () {
                DatePicker.showDatePicker(context,
                    showTitleActions: true,
                    minTime: DateTime(1960, 1, 1),
                    maxTime: DateTime.now(), onChanged: (date) {
                  print('change $date');
                }, onConfirm: (date) {
                  dobControllers[position - 1].text =
                      Helper.getDateViaDate(date, 'yyyy-MM-dd');
                }, currentTime: DateTime.now(), locale: LocaleType.en);
              },
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              cursorColor: AppTheme.getTheme().primaryColor,
              decoration: new InputDecoration(
                border: InputBorder.none,
                hintText: "Birth Date",
              ),
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: AppTheme.getTheme().backgroundColor,
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey, offset: Offset(0, 2), blurRadius: 8.0),
            ],
          ),
          child: Container(
            padding: EdgeInsets.only(left: 10),
            child: TextField(
              controller: genderControllers[position - 1],
              textAlign: TextAlign.start,
              onChanged: (String txt) {},
              onTap: () async {
                List<Widget> items = List();
                items.add(Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        //                    <--- top side
                        color: AppTheme.getTheme().dividerColor,
                      ),
                    ),
                  ),
                  child: Container(),
                ));
                genders.forEach((item) {
                  items.add(Container(
                      margin: const EdgeInsets.only(
                          left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            //                    <--- top side
                            color: AppTheme.getTheme().dividerColor,
                          ),
                        ),
                      ),
                      child: SimpleDialogOption(
                        onPressed: () {
                          Navigator.pop(context, item);
                          setState(() {
                            selectedGender = item;
                            selectedGenderValue =
                                genderValues[genders.indexOf(item)];
                            genderControllers[position - 1].text = item;
                          });
                        },
                        child: Text(item),
                      )));
                });
                await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SimpleDialog(
                        title: const Text('Select Gender'),
                        children: items,
                      );
                    });
              },
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              cursorColor: AppTheme.getTheme().primaryColor,
              decoration: new InputDecoration(
                border: InputBorder.none,
                hintText: "Gender",
              ),
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(top: 8, bottom: 8),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 16.0, top: 16),
          child: Text(
            "Only required on International",
            textAlign: TextAlign.start,
            style: TextStyle(
                color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: AppTheme.getTheme().backgroundColor,
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey, offset: Offset(0, 2), blurRadius: 8.0),
            ],
          ),
          child: Container(
            padding: EdgeInsets.only(left: 10),
            child: TextField(
              controller: passportIdControllers[numberOfPassengers - 1],
              textAlign: TextAlign.start,
              onChanged: (String txt) {},
              onTap: () {},
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              cursorColor: AppTheme.getTheme().primaryColor,
              decoration: new InputDecoration(
                border: InputBorder.none,
                hintText: "Passport ID",
              ),
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: AppTheme.getTheme().backgroundColor,
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey, offset: Offset(0, 2), blurRadius: 8.0),
            ],
          ),
          child: Container(
            padding: EdgeInsets.only(left: 10),
            child: TextField(
              controller: passportExpirationControllers[numberOfPassengers - 1],
              textAlign: TextAlign.start,
              onChanged: (String txt) {},
              onTap: () {},
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              cursorColor: AppTheme.getTheme().primaryColor,
              decoration: new InputDecoration(
                border: InputBorder.none,
                hintText: "Passport Expiration",
              ),
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(top: 15, bottom: 10),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 16.0, top: 10),
          child: Text(
            "Carry On",
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        Column(
          children: <Widget>[] + listOfHandBag,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(top: 15, bottom: 10),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 16.0, top: 10),
          child: Text(
            "Checked Bagage",
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        Column(
          children: <Widget>[] + listOfHoldBag,
        ),
      ],
    );
  }

  Widget getFlightDetails() {
    List<Widget> lists = List();
    for (var i = 0; i < widget.routes.length; i++) {
      FlightRouteObject route = widget.routes[i];
      lists.add(Container(
        padding: EdgeInsets.only(bottom: 5),
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
                        padding: EdgeInsets.only(left: 16.0, top: 10),
                        width: MediaQuery.of(context).size.width / 2,
                        child: Text(
                          Helper.getDateViaDate(
                                  route.localDeparture, "dd MMM") +
                              " | " +
                              (route.returnFlight == 0
                                  ? "Departure"
                                  : "Return"),
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width - 32,
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(top: 10, left: 16, right: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.getTheme().backgroundColor,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: AppTheme.getTheme().dividerColor,
                              offset: Offset(4, 4),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(left: 10, top: 5),
                                    margin: EdgeInsets.only(bottom: 3),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      Helper.getDateViaDate(
                                              route.localDeparture, "hh:mm a") +
                                          " " +
                                          route.flyFrom +
                                          " (" +
                                          route.cityFrom +
                                          ")",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.only(left: 10, top: 5),
                                    margin: EdgeInsets.only(bottom: 3),
                                    child: Text(
                                      Helper.getDateViaDate(
                                              route.localArrival, "hh:mm a") +
                                          " " +
                                          route.flyTo +
                                          " (" +
                                          route.cityTo +
                                          ")",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                right: 10,
                              ),
                              color: Colors.blueAccent,
                              child: Image.network(
                                "https://storage.googleapis.com/joinflyline/images/airlines/${route.airline}.png",
                                height: 20,
                                width: 20,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width - 20,
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          Helper.duration(route.duration),
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ));
    }
    return Column(
      children: lists,
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
                    child: Icon(Icons.arrow_back),
                  ),
                ),
              ),
            ),
            Container(
              margin:
                  EdgeInsets.only(top: MediaQuery.of(context).padding.top / 2),
              alignment: Alignment.center,
              child: Text(
                "Confirm Booking",
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

  Widget getAddAnotherPassenger() {
    return Container(
        margin: EdgeInsets.only(right: 16, top: 16, left: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
                child: this.numberOfPassengers > 1
                    ? InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onTap: () {
                          if (this.numberOfPassengers > 1) {
                            print('remove passenger');
                            setState(() {
                              travailInformationUIs.removeLast();
                              this.numberOfPassengers--;
                            });
                          }
                        },
                        child: Text("Remove passenger",
                            softWrap: true,
                            style: TextStyle(color: Colors.red)))
                    : Container()),
            Expanded(
                child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onTap: () {
                      print("add another");
                      this.addPassenger();
                      setState(() {
                        travailInformationUIs.add(this
                            .getTravailInformationUI(this.numberOfPassengers));
                        print(travailInformationUIs.length);
                      });
                    },
                    child: Text("Add another passenger",
                        textAlign: TextAlign.right,
                        softWrap: true,
                        style: TextStyle(color: Colors.lightBlue)))),
          ],
        ));
  }

  Widget getSearchButton() {
    if (_displayPayment) {
      return Column(
        children: <Widget>[
          Container(
            height: 40,
            margin: EdgeInsets.only(left: 16.0, right: 16, top: 30),
            decoration: BoxDecoration(
                color: const Color(0xFF00AFF5),
                border: Border.all(color: const Color(0xFF00AFF5), width: 0.5)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  child: Text("Check Out",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 19.0,
                          fontWeight: FontWeight.bold)),
                  onPressed: () {
                    if (_checkFlightResponse.noAvailableForBooking) {
                      Alert(
                        context: context,
                        title:
                            "Sorry, seems like the flight does not exist. Please choose another one.",
                        buttons: [
                          DialogButton(
                            child: Text(
                              "OKAY",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            width: 120,
                          ),
                        ],
                      ).show();
                    } else {
                      List<TravelerInformation> lists = List();
                      int index = 0;

                      travailInformationUIs.forEach((f) {
                        var uuid = new Uuid();
                        carryOnSelectedList[index].uuid = uuid.v4();

                        var uuid2 = new Uuid();
                        checkedBagageSelectedList[index].uuid = uuid2.v4();
                        TravelerInformation travelerInformation =
                            TravelerInformation(
                                firstNameControllers[index].text,
                                lastNameControllers[index].text,
                                dobControllers[index].text,
                                genderControllers[index].text,
                                passportIdControllers[index].text,
                                passportExpirationControllers[index].text,
                                carryOnSelectedList[index],
                                checkedBagageSelectedList[index]);
                        lists.add(travelerInformation);
                        index++;
                      });

                      carryOnSelectedList.forEach((f) {
                        print(f.jsonSerialize);
                      });

                      checkedBagageSelectedList.forEach((f) {
                        print(f.jsonSerialize);
                      });

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => newScreen2.HotelHomeScreen(
                                  numberOfPassengers: numberOfPassengers,
                                  travelerInformations: lists,
                                  flightResponse: _checkFlightResponse,
                                  retailInfo: widget.retailInfo,
                                  bookingToken: widget.bookingToken,
                                )),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 38)
        ],
      );
    }
    return Container();
  }
}
