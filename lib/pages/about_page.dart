import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  AboutPage({Key key}) : super(key: key);

  static const String routeName = "/AboutPage";

  final String title = 'About';

  @override
  _AboutPageState createState() => new _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text("Diese App ist im Rahmen einer Studienarbeit an der FH Bielefeld entstanden."
            "Die App ist die Clientkomponente, welche an einen NodeRED Server via HTTP REQUEST Anfragen versendet."
            "Der NodeRED Server sendet die Anfrage dann via MQTT an einen ESP8266 Microkontroller weiter. Auf diesem läuft das Framework WLED. Ein an den ESP8266 angeschlossener WS2812B RGB Strip kann die Eingaben dieser App dann darstellen.\n  \n"
            "Wir bedanken uns für die Unterstützung bei Herr Prof. Dr. rer. nat. Georgios Lajios.\n"),
          ),
        ),
      ),
    );
  }

  void _onFloatingActionButtonPressed() {}
}
