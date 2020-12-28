import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OverallState extends ChangeNotifier{
  bool darkMode;
  String revisionStyle;
  int lowerLimit;
  int upperLimit;
  bool deckChange = false;

  bool monday;
  bool tuesday;
  bool wednesday;
  bool thursday;
  bool friday;
  bool saturday;
  bool sunday;

  int scheduledHour;
  int scheduledMin;

  void getValuesFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    darkMode = prefs.getBool('darkMode') ?? false;
    lowerLimit = prefs.getInt('lowerLimit') ?? 50;
    upperLimit = prefs.getInt('upperLimit') ?? 75;
    revisionStyle = prefs.getString('revisionStyle') ?? 'standard';
    monday = prefs.getBool('monday') ?? false;
    tuesday = prefs.getBool('tuesday') ?? false;
    wednesday = prefs.getBool('wednesday') ?? false;
    thursday = prefs.getBool('thursday') ?? false;
    friday = prefs.getBool('friday') ?? false;
    saturday = prefs.getBool('saturday') ?? false;
    sunday = prefs.getBool('sunday') ?? false;

    scheduledHour = prefs.getInt('scheduledHour') ?? 0;
    scheduledMin = prefs.getInt('scheduledMin') ?? 0;
  }

  void setOptions() async{
    final prefs = await SharedPreferences.getInstance();

    prefs.setBool('darkMode', darkMode);
    prefs.setInt('lowerLimit', lowerLimit);
    prefs.setInt('upperLimit', upperLimit);
    prefs.setString('revisionStyle', revisionStyle);
    prefs.setBool('monday', monday);
    prefs.setBool('tuesday', tuesday);
    prefs.setBool('wednesday', wednesday);
    prefs.setBool('thursday', thursday);
    prefs.setBool('friday', friday);
    prefs.setBool('saturday', saturday);
    prefs.setBool('sunday', sunday);
    prefs.setInt('scheduledHour', scheduledHour);
    prefs.setInt('scheduledMin', scheduledMin);

    notifyListeners();
  }

  void setRevision(String style){
    revisionStyle = style;
    notifyListeners();
  }

  void deckHasBeenChanged(bool insideStats){
    deckChange = !deckChange;
    if(!insideStats){
      notifyListeners();
    }
  }

  void changeBrightness(){
    darkMode = !darkMode;
    notifyListeners();
  }
}