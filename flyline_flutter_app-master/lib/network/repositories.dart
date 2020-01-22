import 'package:motel/models/locations.dart';

import 'providers.dart';
import 'dart:async';

class FlyLineRepository {

  FlyLineProvider _flyLineProvider = FlyLineProvider();


  Future<String> login(email, password){
    return _flyLineProvider.login(email, password);
  }

  Future<List<LocationObject>> locationQuery(term){
    return _flyLineProvider.locationQuery(term);
  }

}