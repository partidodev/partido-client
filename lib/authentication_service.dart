import 'dart:async';

import 'package:dio/dio.dart';
import 'package:partido_flutter/api_service.dart';

class AuthenticationService {

  // Try auto login with stored JSESSION-ID if remember-me cookie exists
  Future<bool> autoLogin() async {
    return await new Future<bool>.delayed(
        new Duration(seconds: 2), () => false
        );
  }

  // Login
  Future<bool> login() async {
    // Simulate a future for response after 2 second.
    return await new Future<bool>.delayed(
        new Duration(seconds: 2), () => true //new Random().nextBool()
        );
  }

  // Logout
  Future<void> logout() async {
    // Simulate a future for response after 1 second.
    return await new Future<void>.delayed(new Duration(seconds: 1));
  }
}
