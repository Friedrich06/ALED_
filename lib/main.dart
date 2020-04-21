import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:my_led_controller/home_page.dart';


/// Wird beim Start der App ausgeführt.
void main() {
  initLogging();
  runApp(MyApp());
}

/// MaterialApp Klasse die, die Grundstruktur der App beinhaltet(AppBar, Themen, etc.)
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALED',
      theme: ThemeData(
        brightness: Brightness.dark
      ),
      home:  MyHomePage(title:  'ALED'),
    );
  }
}

/// Initialisiert den globalen Logger.
initLogging() {
  // Print output to console.
  Logger.root.onRecord.listen((LogRecord r) {
    print('${r.time}\t${r.loggerName}\t[${r.level.name}]:\t${r.message}');
  });

  // Root logger level.
  Logger.root.level = Level.FINEST;
}
