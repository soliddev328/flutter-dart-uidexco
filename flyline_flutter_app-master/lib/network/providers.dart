
import 'dart:convert';
import 'dart:async';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:motel/models/locations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlyLineProvider {

  final baseUrl = "https://staging.joinflyline.com";
  
  Future <String> getAuthToken() async {
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token') ?? "";

    if(token.isNotEmpty) return token;
    else{
        var email = prefs.getString('email') ?? "";
        var password = prefs.getString('password') ?? "";

        if (email.isNotEmpty && password.isNotEmpty){

          return await login(email, password);

        }else return "logout";
    }
    
  }

  Future<String> login(email, password) async {
    var url = "$baseUrl/api/auth/login/";
    var result = "";

    Response response;
    Dio dio =  Dio();
    
    String credentials = email+":"+password;
    String encoded = base64Encode(utf8.encode(credentials));  
    var auth = "Basic $encoded";
    
    dio.options.headers["Authorization"] = auth;
    
    try {
      response = await dio.post(
        url,
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
      prefs.setString('token', response.data["token"]);

      prefs.setString('user_email', email);
      prefs.setString('user_password', password);

    } else {
      result = "";
    }
    return result;
  }
  
  Future<List<LocationObject>> locationQuery(term) async {
    
   var token = getAuthToken();

    Response response;
    Dio dio =  Dio();
    dio.options.headers["Authorization"] = "Token $token";

    List<LocationObject> locations = List<LocationObject>();

    try {
        response = await dio.get("$baseUrl/api/locations/query/?term=$term");
      } catch (e) {
        log(e.toString());
      }
    
    if(response.statusCode == 200) {
      
      for (dynamic i in response.data["locations"]) {
        locations.add(LocationObject.fromJson(i));
        }
    }
    return locations;
  }


}
