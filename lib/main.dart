

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whether_app/screen/splash_screen.dart';


import 'controller/api.dart';
import 'controller/theme.dart';


void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => APICallProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => ModelTheme(),
      )
    ],
    child: Consumer<ModelTheme>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          home: SplashScreen(),
          theme: themeNotifier.isDark
              ? ThemeData(useMaterial3: true, brightness: Brightness.dark)
              : ThemeData(useMaterial3: true, brightness: Brightness.light),
          debugShowCheckedModeBanner: false,
        );
      },
    ),
  ));
}