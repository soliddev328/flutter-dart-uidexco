import 'package:motel/models/locations.dart';

import 'repositories.dart';
import 'package:rxdart/rxdart.dart';

class FlyLineBloc {
  final FlyLineRepository _repository = FlyLineRepository();

  final BehaviorSubject<String> _token =
  BehaviorSubject<String>();

  final BehaviorSubject<List<LocationObject>> _subjectlocationItems =
  BehaviorSubject<List<LocationObject>>();




  tryLogin(String email, String password) async {
    String response = await _repository.login(email, password);
    _token.sink.add(response);
  }

  Future<List<LocationObject>> locationQuery(String term) async {
    List<LocationObject> response = await _repository.locationQuery(term);
    _subjectlocationItems.sink.add(response);
    return response;
  }


  dispose() {
    _token.close();
    _subjectlocationItems.close();
  }

  

  BehaviorSubject<String> get loginResponse => _token;

  BehaviorSubject<List<LocationObject>> get locationItems => _subjectlocationItems;

  

}

final flyLinebloc = FlyLineBloc();