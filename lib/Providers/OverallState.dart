import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OverallState extends ChangeNotifier{
  bool _darkMode;
  String revision;
  int _lowerLimit;
  int _upperLimit;
  bool deckChange = false;

  bool get brightness => _darkMode;
  int get lowerLimit => _lowerLimit;
  int get upperLimit => _upperLimit;

  void setOptions(bool darkMode, int lowerValue, int higherValue, String revisionStyle) async{
    revision = revisionStyle;
    _darkMode = darkMode;
    _lowerLimit = lowerValue;
    _upperLimit = higherValue;

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', _darkMode);
    prefs.setInt('lowerLimit', _lowerLimit);
    prefs.setInt('upperLimit', _upperLimit);
    prefs.setString('revisionStyle', revisionStyle);

    notifyListeners();
  }

  void setRevision(String style){
    revision = style;
    notifyListeners();
  }

  void deckHasBeenChanged(bool insideStats){
    deckChange = !deckChange;
    if(!insideStats){
      notifyListeners();
    }
  }

  void changeBrightness(){
    _darkMode = !_darkMode;
    notifyListeners();
  }
}