import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  cursorColor: Colors.blueGrey[200],
  colorScheme: ColorScheme(
    primary: Colors.blueGrey,
    primaryVariant: Colors.blueGrey[200],
    onPrimary: Colors.black,
    secondary: Colors.grey,
    secondaryVariant: Colors.grey[200],
    onSecondary: Colors.black,
    surface: Colors.white,
    onSurface: Colors.black,
    background: Colors.white,
    onBackground: Colors.black,
    error: Colors.redAccent,
    onError: Colors.amberAccent,
    brightness: Brightness.light,
  ),
  highlightColor: Colors.blueGrey[200],
  visualDensity: VisualDensity.adaptivePlatformDensity,
  textSelectionColor: Colors.blueGrey[200],
  textSelectionHandleColor: Colors.blueGrey[400],
  primaryColor: Colors.blueGrey[100],
  primaryColorLight: Colors.white,
  primaryColorDark: Color(0xFF9ea7aa),
  appBarTheme: AppBarTheme(
    textTheme: TextTheme(
      bodyText1: TextStyle(
        color: Colors.black,
      ),
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
  fontFamily: 'Manrope',
);

// dark theme guidelines https://material.io/design/color/dark-theme.html
ThemeData darkTheme= ThemeData(
  brightness: Brightness.dark,
  toggleableActiveColor: Colors.blueGrey,
  cursorColor: Colors.blueGrey[200],
  colorScheme: ColorScheme(
    primary: Colors.blueGrey,
    primaryVariant: Colors.blueGrey[200],
    onPrimary: Colors.black,
    secondary: Colors.grey,
    secondaryVariant: Colors.grey[200],
    onSecondary: Colors.black,
    surface: Colors.grey.shade800,
    onSurface: Colors.white,
    background: Colors.white,
    onBackground: Colors.black,
    error: Colors.redAccent,
    onError: Colors.amberAccent,
    brightness: Brightness.dark,
  ),
  highlightColor: Colors.blueGrey[200],
  visualDensity: VisualDensity.adaptivePlatformDensity,
  textSelectionColor: Colors.blueGrey[200],
  textSelectionHandleColor: Colors.blueGrey[400],
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
  fontFamily: 'Manrope',
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
