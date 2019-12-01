import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userid;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get userId {
    return _userid;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyAjPP3QDDMsH9Q9GUMSrzu5wdrWftsmDI8';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userid = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      _autoLogout();
      notifyListeners(); 
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userid,
        'expiryDate': _expiryDate.toIso8601String(),
      });
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> logIn(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    
    if(!prefs.containsKey('userData')){
      return false;
    }
    
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
    
    if(expiryDate.isBefore(DateTime.now())){
      return false;
    }

    _token = extractedUserData['token'];
    _expiryDate = expiryDate;
    _userid = extractedUserData['userId'];
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logOut() async {
    _userid = null;
    _token = null;
    _expiryDate = null;
    if(_authTimer != null){
      _authTimer.cancel();
      _authTimer = null;
    }
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('userData'); //this clears the data with the provided key and keeps others
    prefs.clear(); // this clears every data saved with different keys
    notifyListeners();
  }

  void _autoLogout() {
    if(_authTimer != null){
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logOut);
  }
}
