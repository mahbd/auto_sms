import 'package:flutter/material.dart';

class UserListProvider extends ChangeNotifier {
  ThemeData _themeData;
  UserListProvider(this._themeData);

  get getMessages => _themeData;
  void setTheme(ThemeData theme) {
    _themeData = theme;
    notifyListeners();
  }
}
