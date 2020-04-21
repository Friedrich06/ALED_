import 'dart:ui';


/// Diese Model-Klasse ist zum definiren der Licht-Eigenschaften.
class Light {
  bool _isOn;
  Color _color;

  // ignore: unnecessary_getters_setters
  bool get isOn => _isOn;

  // ignore: unnecessary_getters_setters
  Color get color => _color;

  // ignore: unnecessary_getters_setters
  set isOn(bool value) => _isOn = value;

  // ignore: unnecessary_getters_setters
  set color(Color value) => _color = value;

  Light(this._isOn, this._color);

  Light.zero() {
    _isOn = false;
    _color = Color(0);
  }

  Light.fromJson(Map<String, dynamic> json) {
    _isOn = json['on'];
    final a = json['a'];
    final r = json['r'];
    final g = json['g'];
    final b = json['b'];
    _color = Color.fromARGB(a, r, g, b);
  }

  Light.fromLight(Light light) {
    _isOn = light.isOn;
    _color = Color(light.color.value);
  }

  Map<String, dynamic> toJson() {
    return {
      'on': _isOn,
      'a': _color.alpha,
      'r': _color.red,
      'g': _color.green,
      'b': _color.blue
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Light &&
          runtimeType == other.runtimeType &&
          _isOn == other.isOn &&
          _color.value == other.color.value;

  @override
  int get hashCode => isOn.hashCode ^ _color.hashCode;
}
