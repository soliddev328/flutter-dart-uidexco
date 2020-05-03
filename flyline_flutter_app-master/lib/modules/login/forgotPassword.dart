import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../appTheme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController emailTextController = new TextEditingController();
  GlobalKey<FormState> formKey = new GlobalKey();
  var response;
  int statusCode;
  bool textTappted = false;

  Future<dynamic> forgotPasswordApiCall() async {
    String url =
        'https://joinflyline.com/api/password_reset/'; // here i am checking with my own api
    response = await http.post(url, body: {"email": emailTextController.text});
    statusCode = response.statusCode;

    //this is output i got

//         I/flutter (11222): response body is  Instance of 'Response'.body
// I/flutter (11222):
// I/flutter (11222): {"balance":null,"email":null,"response_desc":"User id found"}
    // return json_decode(response.body);

    print("response body is  " + '$response.body');
    print(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        // backgroundColor: AppTheme.getTheme().backgroundColor,
        body: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          focusColor: Colors.transparent,
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: appBar(),
              ),
              Expanded(
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 20, bottom: 20, left: 50, right: 50),
                          child: Row(
                            children: <Widget>[
                              Text(
                                "We will send a verification code to your \n registered email address.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: HexColor("#8E969F"),
                                  fontSize: 16,
                                  fontFamily: "Gilroy",
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 24, right: 24),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.getTheme().backgroundColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              // border: Border.all(
                              //   color: HexColor("#757575").withOpacity(0.6),
                              // ),
                              // boxShadow: <BoxShadow>[
                              //   BoxShadow(
                              //     color: AppTheme.getTheme().dividerColor,
                              //     blurRadius: 8,
                              //     offset: Offset(4, 4),
                              //   ),
                              // ],
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 20,),
                              child: Container(
                                height: 48,
                                child: Center(
                                  child: TextFormField(
                                    controller: emailTextController,
                                    maxLines: 1,
                                    onChanged: (String txt) {},
                                    onTap: () {
                                      setState(() {
                                        textTappted = true;
                                      });
                                    },
                                    style: TextStyle(
                                      fontFamily: 'Gilroy',
                                      color: Color(0xff3a3f5c),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    cursorColor:
                                        AppTheme.getTheme().primaryColor,
                                    decoration: new InputDecoration(
                                      fillColor: Colors.white,
                                      filled: true,
                                      errorText: null,
                                      border: InputBorder.none,
                                      hintText: "Enter your email",
                                      hintStyle: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontFamily: "Gilroy",
                                          color: Color(0xFFC7C9D1)),
                                    ),
                                    // ignore: missing_return
                                    validator: (value) {
                                      if (value.length == 0) {
                                        return "Email must not be null";
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 24, right: 24, bottom: 8, top: 16),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: textTappted
                                  ? Color.fromRGBO(0, 174, 239, 1)
                                  : Color.fromRGBO(199, 201, 209, 1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(27)),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(24.0)),
                                highlightColor: Colors.transparent,
                                // ignore: missing_return
                                onTap: () async {
                                  if (formKey.currentState.validate()) {
                                    await forgotPasswordApiCall();
                                    if (statusCode == 200) {
//                                      Navigator.pop(context);
                                      return Alert(
                                        context: context,
                                        title:
                                            "Please check your email, we have sent you instructions to reset your password",
                                        buttons: [
                                          DialogButton(
                                            child: Text(
                                              "OKAY",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            width: 120,
                                          ),
                                        ],
                                      ).show();
                                    } else if (response.statusCode == 500) {
                                      return Alert(
                                        context: context,
                                        title:
                                            "something went wrong, try again later",
                                        buttons: [
                                          DialogButton(
                                            child: Text(
                                              "OKAY",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20),
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
                                      return Alert(
                                        context: context,
                                        title: "Email doesn't exist ",
                                        buttons: [
                                          DialogButton(
                                            child: Text(
                                              "OKAY",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20),
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
                                  }
                                },

                                child: Center(
                                  child: Text(
                                    "Send Verification Code",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Gilroy Bold',
                                        fontSize: 16,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget appBar() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: AppBar().preferredSize.height,
          child: Padding(
            padding: EdgeInsets.only(top: 8, left: 8),
            child: Container(
              width: AppBar().preferredSize.height - 8,
              height: AppBar().preferredSize.height - 8,
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
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 146, left: 49.5, right: 49.5),
            child: Text(
              "Forgot Password",
              style: new TextStyle(
                  fontFamily: "Gilroy",
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color.fromRGBO(14, 49, 120, 1)),
            ),
          ),
        )
      ],
    );
  }
}
