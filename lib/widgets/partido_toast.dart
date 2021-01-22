import 'package:fluttertoast/fluttertoast.dart';

class PartidoToast {

  static Future<bool?> showToast({
    required String msg,
  }) async {
    return Fluttertoast.showToast(
        msg: msg,
        timeInSecForIosWeb: 3,
        webBgColor: "#4CAF50",
        webPosition: "left"
    );
  }
}
