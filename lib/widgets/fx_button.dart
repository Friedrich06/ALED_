import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class FXButton extends StatefulWidget {
  FXButton({
    @required this.onPressed,
    @required this.name,
  });

  final Logger log = new Logger('FXButton');

  final VoidCallback onPressed;
  final String name;
  var _fxbs;


  set select(bool selected) {
    _fxbs.selected = selected;
  }

  @override
  _FXButtonState createState() {
    _fxbs = _FXButtonState(onPressed: onPressed, name: name);
    return _fxbs;
  }
}

class _FXButtonState extends State<FXButton>
    with SingleTickerProviderStateMixin {
  _FXButtonState({@required this.onPressed, @required this.name});

  AnimationController _animationController;
  Animation _colorTween;

  final VoidCallback onPressed;
  final String name;

  bool _isSelected = false;

  set selected(bool selected) {
    widget.log.fine("select: $selected, isSelected: $_isSelected");
    if (_isSelected == selected) return;
    _isSelected = selected;

    if (_isSelected) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _colorTween = ColorTween(begin: Colors.blue, end: Colors.green)
        .animate(_animationController);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorTween,
      builder: (context, child) => RaisedButton(
        child: Text(name),
        color: _colorTween.value,
        onPressed: onPressed,
      ),
    );
  }
}
