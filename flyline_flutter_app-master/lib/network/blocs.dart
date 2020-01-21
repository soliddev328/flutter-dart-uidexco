import 'repositories.dart';
import 'package:rxdart/rxdart.dart';

class FlyLineBloc {
  final FlyLineRepository _repository = FlyLineRepository();

  final BehaviorSubject<String> _token =
  BehaviorSubject<String>();



  tryLogin(String email, String password) async {
    String response = await _repository.login(email, password);
    _token.sink.add(response);
  }


  dispose() {
    _token.close();
  }

  

  BehaviorSubject<String> get loginResponse => _token;

  

}

final flyLinebloc = FlyLineBloc();