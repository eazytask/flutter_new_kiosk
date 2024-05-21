import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectedProjectProvider extends ChangeNotifier {
  String projectId = "";
  String projectName = "";

  String idKey = "projectId";
  String nameKey = "projectName";

  Future<Type> loadValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    projectId = prefs.getString(idKey)!;
    projectName = prefs.getString(nameKey)!;
    notifyListeners();
    return SharedPreferences;
  }

  Future<Type> saveToPrefs(String projectId, String projectName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(idKey, projectId);
    prefs.setString(nameKey, projectName);
    return SharedPreferences;
  }
}