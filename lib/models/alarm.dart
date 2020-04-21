import 'package:flutter/material.dart';

/// Diese Model-Klasse ist zum definiren der Alarm-Eigenschaften.
class Alarm {
  Key key;
  String name;
  TimeOfDay time;
  Color color;
  bool isActiv = true;

  Alarm(this.key, this.name, this.time, this.color, this.isActiv);

  Alarm.fromJson(Map<String, dynamic> json) {
    key = Key(json['key']);
    name = json['name'];
    var dataOfTime = json['time'];
    time = TimeOfDay(hour: dataOfTime['hour'], minute: dataOfTime['minute']);
    color = Color(json['colorValue']);
    isActiv = json['isActiv'];
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key.toString(),
      'name': name,
      'time': {'hour': time.hour, 'minute': time.minute},
      'colorValue': color.value,
      'isActiv': isActiv
    };
  }

  static Alarm zero =
      Alarm(Key('0'), 'zeroAlarm', TimeOfDay.now(), Colors.white, false);


}
