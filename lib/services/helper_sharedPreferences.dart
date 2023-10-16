
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static saveDocumentId(shopname) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('documentReferenceId', shopname);
  }

  static getDocumentId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String? stringValue = prefs.getString('documentReferenceId');
    return stringValue;
  }
}