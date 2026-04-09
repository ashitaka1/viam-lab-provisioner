import 'package:flutter/cupertino.dart';

CupertinoThemeData cupertinoTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  return CupertinoThemeData(
    brightness: brightness,
    primaryColor: CupertinoColors.activeBlue,
    scaffoldBackgroundColor:
        isDark ? const Color(0xFF1E1E1E) : CupertinoColors.systemBackground,
    barBackgroundColor: isDark
        ? const Color(0xFF2D2D2D)
        : CupertinoColors.systemBackground.withOpacity(0.9),
    textTheme: CupertinoTextThemeData(
      textStyle: TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 14,
        color: isDark ? CupertinoColors.white : CupertinoColors.black,
      ),
    ),
  );
}
