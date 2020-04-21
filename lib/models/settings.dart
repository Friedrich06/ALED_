import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';

  /// Klasse zum speichern und laden der Settings.
  /// Sie wird im Serverwidget erzeugt werden bzw. die Daten können eingetragen werden.
class Settings {
  String _url;
  String _port;

  String get url => _url;       /// Vergleich der public und privat Variablen.

  String get port => _port;     /// Vergleich der public und privat Variablen.

  final _log = new Logger('Server');
  static final FlutterSecureStorage _storage = FlutterSecureStorage();
  static final String _storageKey = 'settings';

  /// Dekodierung vom JSON format in ein Dart Objekt.
  Settings.fromJson(Map<String, dynamic> json) {
    _url = json['url'];
    _port = json['port'];
  }

  Map<String, dynamic> toJson() {
    return {
      'url': _url,
      'port': _port,
    };
  }

  Settings({String url, String port}) {
    _url = url ?? "";
    _port = port ?? "";
  }

  /// Laden der Settings und Dekodiren der Daten in JSON format.
  Future<Settings> load() async {
    _log.fine('loading Settings');
    String data = await _storage.read(key: _storageKey);
    if (data == null)
      return Settings();
    return Settings.fromJson(json.decode(data));
  }

  /// Speichern der URL und PORT Information in einen JSON format String.
  Future<void> safe() async {
    String jsonString = json.encode(this.toJson());
    return _storage.write(key: _storageKey, value: jsonString);
  }
}
