import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:my_led_controller/home_page.dart';
import 'package:my_led_controller/models/alarm.dart';
import 'package:my_led_controller/models/settings.dart';
import 'package:random_color/random_color.dart';


class AlarmScreen extends StatefulWidget {
  final Logger _log = new Logger('AlarmScreen');

  @override
  _AlarmScreenState createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  final storage = FlutterSecureStorage();

  // ignore: close_sinks
  final StreamController<List<Widget>> _appBarStreamController =
      MyHomePage.appBarStreamController;


  /// Liste der angelegten Alarme.
  List<Alarm> _alarmList = [];

  @override
  initState() {
    super.initState();
    _loadAlarmList();
  }

  @override
  dispose() {
    super.dispose();
    _appBarStreamController.sink.add([]);
//    _appBarStreamController.close();
  }

  /// Darstellung eines Alarmitems.
  Widget _buildItem(Alarm alarm) {
    return Dismissible(
      key: Key(alarm.hashCode.toString()),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.0),
        child: Icon(Icons.edit),
        color: Colors.blue,
      ),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20.0),
        child: Icon(Icons.close),
        color: Colors.red,
      ),
      onDismissed: (direction) {
        print(direction);
        if (direction == DismissDirection.startToEnd) {
          int index = _alarmList.indexOf(alarm);
          _removeAlarm(index);
        } else {
          int index = _alarmList.indexOf(alarm);
          _removeAlarm(index);
        }
      },
      child: ListTile(
        onTap: () => _toggleAlarm(alarm),
        title: Text(
          alarm.name,
          style: TextStyle(
            fontSize: 20,
            color: alarm.isActiv
                ? Theme.of(context).textTheme.body1.color
                : Colors.grey,
          ),
        ),
        leading: Container(
          padding: EdgeInsets.all(2.0),
          child: CircleAvatar(
            backgroundColor: alarm.color,
          ),
          decoration: new BoxDecoration(
            color: const Color(0xFFFFFFFF), // border color
            shape: BoxShape.circle,
          ),
        ),
        trailing: Text(
          '${alarm.time.hour}:${alarm.time.minute}',
          style: TextStyle(fontSize: 40, fontFamily: 'Digital'),
        ),
      ),
    );
  }
/// Ablegen der Liste in den Androidspeicher.
  _saveAlarmList() async {
    var jsonString = json.encode(_alarmList);
    storage.write(key: '_alarmList', value: jsonString);
    print('saved: ${_alarmList.length} items');
  }

  /// Laden der Liste aus dem Androidspeicher.
  _loadAlarmList() {
    storage.read(key: '_alarmList').then((jsonString) {
      List jsonIter = json.decode(jsonString);
      setState(() {
        _alarmList = jsonIter.map((i) => Alarm.fromJson(i)).toList();
      });
    });
  }

  /// Hinzufügen eines neuen Alarms.
  _addAlarm({@required Alarm alarm, int index = 0, bool init = false}) {
    if (!init) {
      Settings settings = Settings();

      print(settings.url);
      print(settings.port);

      Map lMap = alarm.toJson();
      String lData = json.encode(lMap);

      setState(() {
        _alarmList.insert(index, alarm);
        _saveAlarmList();
      });
    }
  }

  /// Löschen eines vorhandenen Alarms.
  _removeAlarm(int index) {
    if (_alarmList.length <= 0) return;

    Alarm removedAlarm = _alarmList.elementAt(index);

    setState(() {
      _alarmList.removeAt(index);
    });
    _saveAlarmList();

  }

  /// Status des Alarmobjekt wird geändert.
  _toggleAlarm(Alarm alarm) {
    setState(() {
      alarm.isActiv = !(alarm.isActiv);
    });

    _saveAlarmList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ListView.builder(
          itemCount: _alarmList.length,
          itemBuilder: (context, index) => _buildItem(_alarmList[index]),
        ),
        Positioned(
          bottom: 15,
          right: 15,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
            ),
            child: IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _addAlarm(
                alarm: Alarm(
                  Key(_alarmList.length.toString()),
                  'Alarm ${_alarmList.length}',
                  TimeOfDay.now(),  /// Aktuelle Zeit wird erfasst und übergeben.
                  RandomColor().randomColor(), /// Zufalls Farbenwert wird generiert.
                  true,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
