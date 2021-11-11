import 'package:flutter/cupertino.dart';

final NavigationService navService = NavigationService();

class NavigationService<T, U> {
  static GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();

  // Add new named route
  Future<T?> pushNamed(String routeName, {Object? args}) async {
    return await navigationKey.currentState!.pushNamed<T>(
      routeName,
      arguments: args,
    );
  }

  // Add new route
  Future<T?> push(Route<T> route) async {
    return await navigationKey.currentState!.push<T>(route);
  }

  // Replace current route with new named one
  Future<T?> pushReplacementNamed(String routeName, {Object? args}) async {
    return await navigationKey.currentState!.pushReplacementNamed<T, U>(
      routeName,
      arguments: args,
    );
  }

  // Remove all routes and open new named one
  Future<T?> pushNamedAndRemoveUntil(String routeName, {Object? args}) async {
    return await navigationKey.currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
          (Route<dynamic> route) => false,
      arguments: args,
    );
  }

  Future<bool> maybePop([bool? args]) async {
    return await navigationKey.currentState!.maybePop<bool?>(args);
  }

  bool canPop() => navigationKey.currentState!.canPop();

  void goBack({T? result}) => navigationKey.currentState!.pop<T>(result);
}
