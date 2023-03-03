import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const MaterialColor customPalette =
    MaterialColor(_mcgpalette0PrimaryValue, <int, Color>{
  50: Color(0xFFFEE4E2),
  100: Color(0xFFFEBCB7),
  200: Color(0xFFFD8F87),
  300: Color(0xFFFC6256),
  400: Color(0xFFFB4032),
  500: Color(_mcgpalette0PrimaryValue),
  600: Color(0xFFF91A0C),
  700: Color(0xFFF9160A),
  800: Color(0xFFF81208),
  900: Color(0xFFF60A04),
});
const int _mcgpalette0PrimaryValue = 0xFFFA1E0E;

const MaterialColor customPaletteAccent =
    MaterialColor(_mcgpalette0AccentValue, <int, Color>{
  100: Color(0xFFFFFFFF),
  200: Color(_mcgpalette0AccentValue),
  400: Color(0xFFFFB8B7),
  700: Color(0xFFFF9E9D),
});
const int _mcgpalette0AccentValue = 0xFFFFEAEA;

final ThemeData theme = ThemeData(
  useMaterial3: true,
  primarySwatch: customPalette,
  fontFamily: "Outfit",
  scaffoldBackgroundColor: Colors.white,
  backgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: customPalette.shade100,
    foregroundColor: Colors.black,
    elevation: 0,
    splashColor: customPalette.shade700.withOpacity(.4),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      elevation: MaterialStateProperty.all(0),
      padding: MaterialStateProperty.all(
        const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 20,
        ),
      ),
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey[300]!;
          }

          return customPalette;
        },
      ),
      foregroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey;
          }

          return Colors.white;
        },
      ),
      overlayColor: MaterialStateProperty.all(Colors.black.withOpacity(.4)),
      shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    ),
  ),
);
