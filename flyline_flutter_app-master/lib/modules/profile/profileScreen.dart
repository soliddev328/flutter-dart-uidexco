import 'package:flutter/material.dart';
import 'package:motel/appTheme.dart';
import 'package:motel/models/settingListData.dart';
import 'package:motel/modules/profile/editProfile.dart';
import 'package:motel/modules/profile/myWebView.dart';
import 'package:motel/modules/profile/settingsScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final AnimationController animationController;

  const ProfileScreen({Key key, this.animationController}) : super(key: key);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<SettingsListData> userSettingsList = SettingsListData.userSettingsList;
  List<SettingsListData> userInfoList = SettingsListData.userInfoList;
  String travelerName = '<<FirstName>>';

  @override
  void initState() {
    widget.animationController.forward();
    this.getAccountInfo();
    super.initState();
  }

  void getAccountInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.travelerName = prefs.getString("first_name");
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (BuildContext context, Widget child) {
        return FadeTransition(
          opacity: widget.animationController,
          child: new Transform(
            transform: new Matrix4.translationValues(
                0.0, 40 * (1.0 - widget.animationController.value), 0.0),
            child: Scaffold(
              backgroundColor: AppTheme.getTheme().backgroundColor,
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top),
                    child: Container(child: appBar()),
                  ),
                  Expanded(
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.all(0.0),
                      itemCount: userSettingsList.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {

                            if (index == 0) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyWebView(
                                    title: "Frequently Asked Questions",
                                    selectedUrl:
                                    "https://joinflyline.com/faq",
                                  ),
                                  fullscreenDialog: true,
                                ),
                              );
                            }
                            if (index == 1) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SettingsScreen(),
                                    fullscreenDialog: true,
                                  ));
                            }

                            // if (index == 0) {
                            //   Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (context) => ChangepasswordScreen(),
                            //       fullscreenDialog: true,
                            //     ),
                            //   );
                            // }
                          },
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 8, right: 16),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          userSettingsList[index].titleTxt,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Container(
                                        child: Icon(
                                            userSettingsList[index].iconData,
                                            color: AppTheme.getTheme()
                                                .disabledColor
                                                .withOpacity(0.3)),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 16, right: 16),
                                child: Divider(
                                  height: 1,
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget appBar() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditProfile(),
            fullscreenDialog: true,
          ),
        ).whenComplete(() {
          this.getAccountInfo();
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    travelerName,
                    style: new TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    "View and edit traveler info",
                    style: new TextStyle(
                      fontSize: 16,
                      color: AppTheme.getTheme().disabledColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 24, top: 16, bottom: 16),
            child: Container(
              width: 70,
              height: 70,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(40.0)),
                child: Image.asset("assets/images/user_img.png"),
              ),
            ),
          )
        ],
      ),
    );
  }
}
