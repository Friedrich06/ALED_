import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:my_led_controller/class/server.dart';
import 'package:my_led_controller/models/settings.dart';
import 'package:my_led_controller/widgets/fx_button.dart';

class OverviewScreen extends StatefulWidget {
  final Logger _log = new Logger('OverviewScreen');

  @override
  _OverviewScreenState createState() => _OverviewScreenState(_log);
}

class _OverviewScreenState extends State<OverviewScreen> {
  _OverviewScreenState(this._log);

  final Logger _log;

  Server _server = Server();

  String _url;
  String _port;

  final myController = TextEditingController();

  int duration = 1;
  int fxSelection;
  final fxButtonNameList = <String>["Solid","Blink","Breathe","Wipe","Wipe Random","Random Colors","Sweep","Dynamic","Colorloop","Rainbow","Scan","Dual Scan","Fade","Theater","Theater Rainbow","Running","Saw","Twinkle","Dissolve","Dissolve Rnd","Sparkle","Dark Sparkle","Sparkle+","Strobe","Strobe Rainbow","Mega Strobe","Blink Rainbow","Android","Chase","Chase Random","Chase Rainbow","Chase Flash","Chase Flash Rnd","Rainbow Runner","Colorful","Traffic Light","Sweep Random","Running 2","Red & Blue","Stream","Scanner","Lighthouse","Fireworks","Rain","Merry Christmas","Fire Flicker","Gradient","Loading","Police","Police All","Two Dots","Two Areas","Circus","Halloween","Tri Chase","Tri Wipe","Tri Fade","Lightning","ICU","Multi Comet","Dual Scanner","Stream 2","Oscillate","Pride 2015","Juggle","Palette","Fire 2012","Colorwaves","BPM","Fill Noise","Noise 1","Noise 2","Noise 3","Noise 4","Colortwinkle","Lake","Meteor","Smooth Meteor","Railway","Ripple","Twinklefox","Twinklecat","Halloween Eyes","Solid Pattern","Solid Pattern Tri","Spots","Spots Fade","Glitter","Candle","Fireworks Starburst","Fireworks 1D","Bouncing Balls","Sinelon","Sinelon Dual","Sinelon Rainbow","Popcorn","Drip","Plasma","Percent","Ripple Rainbow","Heartbeat","Pacifica"];
  final fxButtonList = <FXButton>[];

  Color get cardColor => Colors.blueGrey;

  Color get shadowColor => Colors.white;

  @override
  void initState() {
    super.initState();

    loadData();
    loadFxButtons();
  }

  /// Es werden die aktuellen Settingsdateien geladen. Aus diesen Informationen bedient sich die Funktion setState().
  /// Die Funktion setState verwendet die Variablen url und port aus den Settingsdateien.
  Future<void> loadData() async {
    Settings settings = await Settings().load();

    setState(() {
      _url = settings.url;
      _port = settings.port;
    });
  }

  /// Die Funktion loadFxButtons() generiert die FXButton Widgets und speichert sie als Liste ab.
  loadFxButtons() {
    for (var i = 0; i < fxButtonNameList.length; i++) {
      fxButtonList.add(
        FXButton(
          onPressed: () => setFX(i),
          name: fxButtonNameList[i],
        ),
      );
    }
  }

  /// Title Widget Template.
  Widget titleWidget(String text) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Die Funktion setFX() startet die Animation der ausgewählten und abgewählten Buttons.
  void setFX(int index) {
    _log.fine("setFX: $index, currFX: $fxSelection");
    setState(() {
      if (fxSelection != null) {
        fxButtonList[fxSelection].select = false;
      }
      fxButtonList[index].select = true;
      _server.setFX(index);
      fxSelection = index;
    });
  }

  /// Designed Card Widget Template
  Widget cardWidget({Widget child}) {
    return Container(
      child: Material(
        color: cardColor,
        elevation: 14.0,
        borderRadius: BorderRadius.circular(24.0),
        shadowColor: shadowColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }

  /// Auslagerung der SettingCard um in der Hauptbuild-Funktion die Übersichtlichkeit nicht zu verlieren.
  Widget settingCard() {
    return cardWidget(
      child: Column(
        children: <Widget>[
          titleWidget("Settings"),
          TextField(
            decoration: InputDecoration(
                hintText: _url != null ?? _url.isEmpty ? "address" : _url),
            onChanged: (String url) => _url = url,
          ),
          Row(
            children: <Widget>[
              Flexible(
                child: TextField(
                  decoration: InputDecoration(
                      hintText:
                          _port != null ?? _port.isEmpty ? "port" : _port),
                  onChanged: (String port) => _port = port,
                ),
              ),
              FlatButton(
                child: Text('connect'),
                onPressed: reloadData,
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Die Funktion reloadDate() speichert die eingegebenen URL und Port Informationen in der Settingsdatei.
  /// Das speichern wird durch das Betätigen des Connectbuttons initialisiert.
  void reloadData() {
    print('$_url');
    /// Erstelle Settings Klasse mit den neuen Werten.
    Settings settings = Settings(url: _url, port: _port);
    /// Speichere die Daten in den Androidspeicher.
    settings.safe();

    String jsonString = json.encode(settings.toJson());
    print(jsonString);
    Server().reconnect();
  }

  /// Auslagerung der DimCard um in der Hauptbuild-Funktion die Übersichtlichkeit nicht zu verlieren.
  Widget dimCard() {
    return cardWidget(
      child: Column(
        children: <Widget>[
          titleWidget("Dim duration"),
          Slider(
            activeColor: Colors.black87,
            inactiveColor: Colors.black38,
            value: duration.toDouble(),
            min: 1.0,
            max: 255.0,
            onChanged: (value) {
              setState(() {
                duration = value.toInt();
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FlatButton(
                child: Text('wakeup'),
                color: Colors.green,
                onPressed: () => _server.wakeup(true, duration.toInt()),
              ),
              Text("${duration.toInt()} min"),
              FlatButton(
                child: Text('sleep'),
                color: Colors.grey,
                onPressed: () => _server.wakeup(false, duration.toInt()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Haupt-Widget-Build Funktion dieser Klasse.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          settingCard(),
          SizedBox(height: 25),
          dimCard(),
          SizedBox(height: 25),
          Flexible(
            child: cardWidget(
              child: Column(
                children: <Widget>[
                  titleWidget("Choose effect"),
                  Flexible(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: fxButtonList.length,
                      itemBuilder: (context, index) {
                        return fxButtonList[index];
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8)
        ],
      ),
    );
  }
}
