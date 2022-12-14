import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String? _userId;
  DateTime? _expiryDate;
  String? _token;
  Timer? _authTimer;

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId ?? "";
  }

  Future<void> authenticate(
      String email, String password, String urlSegment) async {
    final url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyBWl8CF9vcV8WQRoCzx1lzt6EIxTZWx-54");
    try {
      final response = await http.post(url,
          body: json.encode({
            "email": email,
            "password": password,
            "returnSecureToken": true,
          }));
      print("RESULT--->${json.decode(response.body)}");
      final responseData = json.decode(response.body);
      if (responseData["error"] != null) {
        throw HttpException(responseData["error"]["message"]);
      }
      _token = responseData["idToken"];
      _userId = responseData["localId"];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData["expiresIn"])));
      autoLogout();
      notifyListeners();

      // save user data in shared preferences to let him login automatically if already logged in before
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({      // convert from map to string
        "token" : _token,
        "userId" : _userId,
        "expiryDate" : _expiryDate?.toIso8601String(),
      });
      prefs.setString("userData", userData);

    } catch (error) {
      throw error;
    }
  }

  Future<bool> tryAutoLogin() async{
    final prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey("userData")){
      return false;
    }
    final extractedData = json.decode(prefs.getString("userData")!) as Map<String, dynamic>;   // data stored is string so we want to convert it to map to extract each data separately so we used json.decode
    final expiryDate = DateTime.parse(extractedData["expiryDate"]);
    if(expiryDate.isBefore(DateTime.now())){
      return false;
    }
    _token = extractedData["token"];
    _userId = extractedData["userId"];
    _expiryDate = expiryDate;
     notifyListeners();
     autoLogout();
     return true;
  }

  Future<void> signup(String email, String password) async {
    return authenticate(
        email, password, "signUp"); // return here to see the spinner
  }

  Future<void> login(String email, String password) async {
    return authenticate(email, password,
        "signInWithPassword"); // return here to see the spinner
  }

  void logout() async{
    _userId = null;
    _token = null;
    _expiryDate = null;
    if(_authTimer != null){
      _authTimer!.cancel();
      _authTimer = null;
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();

    notifyListeners();
  }

  void autoLogout(){
    if(_authTimer != null){
      _authTimer!.cancel();
    }
    final timeToExpire = _expiryDate?.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpire!), logout);

  }
}
