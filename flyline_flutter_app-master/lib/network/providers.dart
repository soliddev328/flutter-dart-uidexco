
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlyLineProvider {
  
  Future<String> login(email, password) async {
    var url = "https://staging.joinflyline.com/api/auth/login/";
    var result = "";

    Response response;
    Dio dio =  Dio();
    
    String credentials = email+":"+password;
    String encoded = base64Encode(utf8.encode(credentials));  
    
    try {
      response = await dio.post(
        url,

        options: Options(
        headers: {
          Headers.wwwAuthenticateHeader:"Token " + encoded,
        },
      ),
        data: json.encode({})
      );
    } on DioError catch (e) {
      result = e.toString();
      print(result);
    }on Error catch (e) {
      print(e);
    }

    if (response != null && response.statusCode == 200) {
      result = response.toString();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      //prefs.setString('user_id', response.data["id"]);

    } else {
      print("noothing");
      print (response);
      result = "";
    }
    return result;
  }

}
