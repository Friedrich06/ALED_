import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:my_led_controller/models/settings.dart';
import 'package:my_led_controller/models/alarm.dart';
import 'package:my_led_controller/models/light.dart';
import 'package:rxdart/rxdart.dart';

typedef void EventListener(dynamic data);

/// Diese Klasse ist Global.
/// Alle anderen Klassen können nur auf diese eine Instanz zugreifen.
class Server {
  static final Server _singleton = new Server._internal();

  final Logger _log = new Logger('Server');

  factory Server() {
    return _singleton;
  }

  /// Beim Erstellen der Server Klasse wird ein Client angelegt, der mit dem Server kommuniziert.
  /// Die Variable "isConnected" zeigt die aktive Verbindung zum Server an.
  Server._internal() {
    _client = Client();
    /// Startwert wird auf false gesetzt, erst bei erfolgreicher Verbindung wird true gesetzt.
    _isConnected.sink.add(
        false);

    reconnect();
    /// Funktion zum Laden der Url und des Ports. Wird zum versenden eines Pings an den Server benötigt. (getRGB status 200)
    _log.fine("internal");
  }

  Client _client;

  /// Indikator zum Überprüfen ob schon eine Verbindung besteht.
  // ignore: close_sinks
  final _isConnected = BehaviorSubject<bool>.seeded(
      false);


  /// Variable die als Stream benutzt werden kann.
  // ignore: close_sinks
  final _serverColor = BehaviorSubject<Color>.seeded(
      Colors.black);

  /// Variable die als Stream benutzt werden kann.
  // ignore: close_sinks
  final _serverAlarm = BehaviorSubject<Alarm>.seeded(
      Alarm.zero);


  /// Drei Variable die geteilt werden können und als Stream intern verwendet werden.
  Stream<bool> get isConnectedStream => _isConnected;

  Stream<Color> get serverColor => _serverColor;

  Stream<Alarm> get serverAlarm => _serverAlarm;

  String _url;
  String _port;

  String get _compUrl {
    String url;

    /// Hier wird geschaut ob bei die Url ein http/s davorsteht oder nicht.
    /// Falls kein http oder https davor gesetzt worden ist, wird eine http:// vor die URL gesetzt.
    if (_url.contains('http://') || _url.contains('https://'))
      url = _url;
    else
      url = 'http://' + _url;

    return '$url:$_port';
  }

  Future<Color> sendedColor;

  /// Die Funktion reconnect() ist dazu da, um zu schauen, ob ein reconnect sinnvoll ist oder nicht.
  /// Bei unveränderter URL und unveränderter PORT kein reconnect nötig.
  /// Es sollen nicht mehrere Verbindungen zwischen den Klassen hergestellt werden können.
  Future<void> reconnect() async {
    Settings newSettings = await Settings()
        .load();
    /// Serverlädt die Settings und legt die Settings in newSettings ab.
    var isConnected = _isConnected.stream.value;
    if (isConnected && (_url == newSettings.url && _port == newSettings.port)) {
      /// Überprüfung ob URL und PORT übereinstimmen.
      _log.fine("already connected and Settings not changed");
      return;

      /// Bei abweichender URL oder abweichendem PORT, wird die vorhandenen Settings überschrieben.
    } else if (isConnected &&
        !(_url == newSettings.url && _port == newSettings.port)) {
      // if is connected but url changed
      _log.fine("Establish new connection");
      _url = newSettings.url;
      _port = newSettings.port;

      /// Wenn keine Information über URL und PORT vorhanden sind, werden diese in einer neuen Settings gespeichert.
    } else if (!isConnected &&
        !(_url == newSettings.url && _port == newSettings.port)) {
      // if not connected but url changed
      _log.fine("save settings and connect");
      _url = newSettings.url;
      _port = newSettings.port;
    }

    /// Test der Verbindung.
    /// Resultat des Verbindungstest via Ping.
    final connected = await testConnection();
    _isConnected.sink.add(connected);
  }

  /// Funktion für das Testen der Verbindung mit dem Server.
  Future<bool> testConnection() async {
    _log.fine('testConnection');

    /// Aktuelle URL und subURL wird angehangen.
    /// Die SubURL ist relevant zur Überprüfung der Server Kommunikation.
    if (_url.isEmpty || _port.isEmpty) return false;
    String compUrl =
        '$_compUrl/getRGB';

    _log.fine('url: $compUrl');

    /// Fehler abfangen wenn der Server kein response zurückschickt.
    var response = await _client.head(compUrl).catchError((err) {
      return true;
    });
    _log.fine('testConnection: ${response.statusCode.toString()}');

    /// Überprüfung der Verbindung.
    /// Ein Übertragnes 200 signalisiert den erfolgreiche Verbindungsaufbau. Bei Abweichung ist der Verbindungsaufbau fehlgeschlagen.
    if (response.statusCode != 200) {
      _log.fine('test failed');
      return false;
    } else {
      _log.fine('test done');
      return true;
    }
  }

  /// Funktion die für das Übermitteln der Daten zum Server zuständig ist.
  /// Die Daten werden als String übermittelt.
  /// Dabei wird die URL und das subURL versendet.
  Future<String> _getPostData(String subUrl,
      {String data, String header="application/json", bool post = false}) async {

    /// Abfrage ob eine Verbindung besteht.
    if (!(_isConnected.stream.value)) return null;

    /// Hier wird der Datentyp definiert, welcher gesendet wird.
    /// Nur für den POST wichtig.
    final Map<String, String> lHeaders = {"content-type": header};
    Response res;

    /// Überprüfung ob es ein Post ist und ob Daten vorhanden sind, die versendet werden sollen.
    if (post && data != null) {
      _log.fine('post => adress: $_compUrl$subUrl data: $data');
      res = await _client.post('$_compUrl$subUrl',
          headers: lHeaders, body: data);
      /// Beispiel: piServer:1880/setRGB
    }
    /// Sollte kein Post gesendet worden sein, dann nur die URL und den Header versenden.
    else if (!post)
      res = await _client.get('$_compUrl$subUrl',
          headers: lHeaders); /// Beispiel: piServer:1880/getRGB
    else
      return null;

    /// Es wird geschaut ob der StatusCode zwischen 200 und 400 liegt und ob es in JSON Format ist.
    final int statusCode = res.statusCode;

    if (statusCode < 200 || statusCode > 400 || json == null) {
      final connected = await testConnection();
      _isConnected.sink.add(connected);
      return null;
    }

    return res.body;
  }

  /// Public Funktion, bei der die Daten in JSON Format decodiert werden.
  /// Funktion gibt eine Light Klasse zurück..
  Future<Light> getLight() async {

    _log.fine('getColor');

    final body = await _getPostData('/getRGB');
    final jData = json.decode(body);
    return Light.fromJson(jData);
  }

  /// Public Funktion die Farbwerte setzt, sobald im Hauptmenü eine Farbe angeklickt bzw. gewählt wird.
  void setLight(Light light) {

    _log.fine('setColor');

    String sData = json.encode(light.toJson());
    _getPostData('/setRGB', data: sData, post: true);
  }

  void setLichtisActive(bool isActive){
    int state = 0;
    if(isActive) state = 1;
     _getPostData('/setCmd', header: "text/plain", data: "T=${state}", post: true);
  }

  void setBrightness(int b){
    _getPostData('/setCmd', data: "A=${b}", post: true);
  }

  void wakeup(bool wakeup, int duration) {
    _log.fine('wakeup: $wakeup');
    /// Abfangen falscher Eingaben.
    if (duration < 0 )
      duration = 0;
    else if (duration > 255)
      duration = 255;
    else if (duration.isNaN)
      duration = 1;


    String sData = '{"wakeup":${wakeup? 1:0},"duration":$duration}';
    _getPostData('/wakeup', data: sData, post: true);
  }

  void setFX(int fx) {
    _log.fine('setFx: ${fx}');

    String sData = '{"fx" : ${fx.toString()}}';
    _getPostData("/setFX", data: sData, post: true);
  }



  void setAlarm(Alarm alarm){

    String alarmString = alarm.toJson().toString();

    if (!this._isConnected.value){
      _log.fine('Can\'t uplaod Alarm. No Connection');
      return;
    }

    _log.fine('sending ');
  }

  /// Freigabe des Arbeitsspeichers.
  void dispose() {
    this._isConnected.close();
    this._serverColor.close();
    this._serverAlarm.close();
  }
}
