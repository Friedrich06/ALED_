import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import "package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart";
import 'package:logging/logging.dart';
import 'package:my_led_controller/class/server.dart';
import 'package:my_led_controller/models/light.dart';

class ColorPickerScreen extends StatefulWidget {
  final Logger _log = new Logger('ColorPickerScreen');

  @override
  _ColorPickerScreenState createState() => _ColorPickerScreenState();
}

class _ColorPickerScreenState extends State<ColorPickerScreen> {
  Server _server = Server();

  Light _pickedLight = Light(false, Colors.black);
  Light _lastSendedLight = Light(false, Colors.black);
  Timer _timer;

  List<String> listButtonName = [
    'Dim 1m',
    'Dim 5m',
    'Dim 15m',
  ];
  List<Function> listButtonFunction = [
    () async {},
    () async {},
    () async {},
  ];

  /// Synchronisation beim Ein/Ausschalten der Beleuchtung.
  _onLightStateChanged(bool isActiv) {
    setState(() {
      _pickedLight.isOn = isActiv;
      _server.setLichtisActive(isActiv);
    });
  }

  /// Synchronisation bei ausgewählter Farbe
  _onColorPicked(Color color) {
    setState(() {
      _pickedLight.color = color;
    });
    _startSync();
  }

  /// Begrenzung der zu sendenden Daten, auf maximal alle 250ms pro Datenpacket, durch das Anlegen eines periodischen Timers.
  _startSync() {
    if ((_timer == null || !_timer.isActive) && _pickedLight.isOn) {
      _timer = Timer.periodic(
          Duration(milliseconds: 250), (Timer timer) => _sendPickedLight());
    }
  }

  /// Beendet den Timer wenn keine neu zu sendenden Daten vorliegen, sonst übergibt die Daten weiter, an ServerHandler der dir Kommunikation mit der Server(Raspberry Pi) händelt.

  /// Die Function _sendPickedLight() wird automatisch vom Timer alle 250 ms ausgeführt, wenn der Timer angelegt ist.
  _sendPickedLight() {
    if (_pickedLight == _lastSendedLight) {
      _timer.cancel();
      widget._log.fine('timer canceled');
      return;
    }

    _lastSendedLight = Light.fromLight(_pickedLight);

    widget._log.fine('sendLight');
    _server.setLight(_lastSendedLight);
  }

  /// Initial Funktion
  /// Fragt am Anfang den aktuellen Farbwert vom LED-Stripe vom Server an.
  @override
  void initState() {
    super.initState();
    _server.getLight().then((light) {
      setState(() {
        _pickedLight = Light.fromLight(light);
        _lastSendedLight = Light.fromLight(light);
      });
    });
  }

  /// Gib den reservierten Speicher vom Timer wieder frei (Function wird kruz vor der aufhebung der Klasse aufgerufen und den reservierten Speicher wieder freizugeben)
  @override
  void dispose() {
    if (_timer != null) _timer.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(26.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'ON',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    Switch(
                      value: _pickedLight.isOn,
                      onChanged: _onLightStateChanged,
                      activeColor: _pickedLight.color,
                    ),
                  ],
                ),
                RGBPicker(
                  color: _pickedLight.color,
                  onChanged: _onColorPicked,
                ),
                WheelPicker(
                  color: HSVColor.fromColor(_pickedLight.color),
                  onChanged: (color) => _onColorPicked(color.toColor()),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,

            children: List.generate(listButtonName.length, (int index) {
              return FlatButton(
                child: Text(listButtonName[index]),
                color: Colors.red,
                onPressed: listButtonFunction[index],
              );
            }),
          ),
        ],
      ),
    );
  }
}
