import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:motel/main.dart';
import 'package:motel/models/settingListData.dart';
import 'package:motel/modules/profile/myWebView.dart';

import '../../appTheme.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<SettingsListData> settingsList = SettingsListData.settingsList;
  var country = 'Australia';
  var currency = '\$ AUD';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getTheme().backgroundColor,
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
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top, bottom: 24),
              child: appBar(),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(0.0),
                itemCount: settingsList.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      if (index == 2) {
                        MyApp.restartApp(context);
                      } else if (index == 0) {
                        // Terms of Service
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyWebView(
                              title: "Terms of Service",
                              selectedUrl:
                                  "https://joinflyline.com/terms-of-services",
                            ),
                            fullscreenDialog: true,
                          ),
                        );
                      } else if (index == 1) {
                        // Privacy Policy
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyWebView(
                              title: "Privacy Policy",
                              selectedUrl:
                                  "https://joinflyline.com/privacy-policy",
                            ),
                            fullscreenDialog: true,
                          ),
                        );
                      }
                    },
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 8, right: 16),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    settingsList[index].titleTxt,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Container(
                                  child: Icon(settingsList[index].iconData,
                                      color: AppTheme.getTheme()
                                          .disabledColor
                                          .withOpacity(0.3)),
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
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
    );
  }

  Widget appBar() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
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
                        child: Icon(Icons.arrow_back),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: AppBar().preferredSize.height,
              child: Padding(
                padding: EdgeInsets.only(top: 8, right: 8),
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
                        MyApp.setCustomeTheme(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(AppTheme.isLightTheme
                            ? FontAwesomeIcons.cloudSun
                            : FontAwesomeIcons.cloudMoon),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, left: 24),
          child: Text(
            "Settings",
            style: new TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
