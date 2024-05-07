import 'package:kiosk/src/core/data/datasources/local/storage.helper.dart';
import 'package:kiosk/src/core/provider/base.provider.dart';
import 'package:flutter/material.dart';


class ThemeProvider extends BaseProvider {

  ThemeProvider({required this.cacheManager}) {
    cachedTheme;
  }

  StorageHelper cacheManager;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  set themeMode(ThemeMode mode) {
    _themeMode = mode;
    cacheManager.set(StorageKeys.theme, mode.toString());
  }

  void changeThemeMode() {
    switch(_themeMode.toString()) {
      case "ThemeMode.dark":
        themeMode = ThemeMode.light;
        break;
      case "ThemeMode.light":
        themeMode = ThemeMode.dark;
        break;
      default:
        themeMode = ThemeMode.system;
        break;
    }
    notifyListeners();
  }

  Future<ThemeMode> get cachedTheme async {
    String? stored = await cacheManager.get(StorageKeys.theme);
    switch(stored) {
      case "ThemeMode.dark":
        themeMode = ThemeMode.dark;
        isDarkChecked = true;
        break;
      case "ThemeMode.light":
        themeMode = ThemeMode.light;
        break;
      default:
        themeMode = ThemeMode.system;
        break;
    }
    notifyListeners();
    return themeMode;
  }

  bool _isDarkChecked = false;
  bool get isDarkChecked => _isDarkChecked;
  set isDarkChecked(bool value) {
    _isDarkChecked = value;
    notifyListeners();
  }
}