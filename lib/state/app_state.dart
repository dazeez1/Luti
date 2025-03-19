import 'package:flutter/material.dart';

class AppState with ChangeNotifier {
  String _data = 'Initial Data';

  String get data => _data;

  void updateData(String newData) {
    _data = newData;
    notifyListeners();
  }
}
