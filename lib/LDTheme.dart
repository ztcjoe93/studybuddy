import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  primaryColor: Colors.blueGrey[100],
  primaryColorLight: Colors.white,
  primaryColorDark: Color(0xFF9ea7aa),
  appBarTheme: AppBarTheme(
    textTheme: TextTheme(
      headline4: TextStyle(
        color: Colors.black,
      ),
      headline6: TextStyle(
        color: Colors.black,
        fontSize: 20,
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
  ),
  buttonColor: Colors.blueGrey[100],
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.blueGrey[100],
    selectedItemColor: Colors.black.withOpacity(0.8),
    unselectedItemColor: Colors.black.withOpacity(0.4),
  ),
  accentColor: Color(0xFF9ea7aa),
  fontFamily: 'Roboto',
);

// dark theme guidelines https://material.io/design/color/dark-theme.html
ThemeData darkTheme= ThemeData(
  brightness: Brightness.dark,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  primaryColor: Colors.white.withOpacity(0.16),
  backgroundColor: Color(0xFF121212),
  accentColor: Colors.white.withOpacity(0.16),
  appBarTheme: AppBarTheme(
    brightness: Brightness.dark,
    textTheme: TextTheme(
      headline6: TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
    ),
  ),
  fontFamily: 'Roboto',
  buttonColor: Colors.blueGrey,
  buttonBarTheme: ButtonBarThemeData(
    buttonTextTheme: ButtonTextTheme.normal,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white.withOpacity(0.16),
    selectedItemColor: Colors.white.withOpacity(0.7),
    unselectedItemColor: Colors.white.withOpacity(0.25),
  ),
);

SliderThemeData greatSlider = SliderThemeData(
  activeTrackColor: Colors.lightGreen,
  inactiveTrackColor: Colors.lightGreen[300],
  thumbColor: Colors.lightGreen,
  overlayColor: Colors.lightGreen[200].withOpacity(0.2),
);

SliderThemeData goodSlider = SliderThemeData(
  activeTrackColor: Colors.amber,
  inactiveTrackColor: Colors.amber[300],
  thumbColor: Colors.amber,
  overlayColor: Colors.amber[200].withOpacity(0.2),
);

SliderThemeData poorSlider = SliderThemeData(
  activeTrackColor: Colors.red,
  inactiveTrackColor: Colors.red[300],
  thumbColor: Colors.red,
  overlayColor: Colors.red[200].withOpacity(0.2),
);
