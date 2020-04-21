import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_led_controller/class/server.dart';
import 'package:my_led_controller/pages/about_page.dart';
import 'package:my_led_controller/pages/alarm_screen.dart';
import 'package:my_led_controller/pages/color_picker_screen.dart';
import 'package:my_led_controller/pages/overview_screen.dart';


/// Die Klasse MyHomePage regelt die Seitennavigation.
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  // ignore: close_sinks
  static final _appBarStreamController = StreamController<List<Widget>>();

  static get appBarStreamController => _appBarStreamController;

  @override
  _MyHomePageState createState() => _MyHomePageState(_appBarStreamController);
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState(this._appBarStreamController);

  String _currentBodyTitle = 'Home';
  Widget _body;

  StreamController<List<Widget>> _appBarStreamController;

  @override
  void initState() {
    super.initState();

    _body = OverviewScreen();
  }

  /// Darstellung der Seitennavigation.
  List<Widget> _buildDrawerList(BuildContext context) {
    List<Widget> children = [];
    children
      ..add(_buildUserAccount(context))
      ..addAll(_buildDrawerLable(context, 'Home', icon: Icon(Icons.home)))
      ..addAll(
          _buildDrawerLable(context, 'Color', icon: Icon(Icons.color_lens)))
      ..addAll(_buildDrawerLable(context, 'Alarm', icon: Icon(Icons.alarm)))
      ..addAll(_buildDrawerLable(context, 'About', icon: Icon(Icons.info)));
    return children;
  }

/// Darstellung des Userbereichs
  Widget _buildUserAccount(BuildContext context) {
    NetworkImage avImage, bgImage;

    try {
      avImage = NetworkImage(
      'https://cdn.pixabay.com/photo/2016/06/15/17/01/pear-1459383_960_720.png',
        //Freie kommerzielle Nutzung, vereinfachte Pixabay Lizenz, letzter Abruf 19.04. 17:00 Quelle:https://pixabay.com/de/illustrations/birne-icon-leuchten-scheinen-1459383/
      );
      bgImage = NetworkImage(
      "https://cdn.pixabay.com/photo/2015/12/14/09/17/bridge-1092256_960_720.jpg",
        //Freie kommerzielle Nutzung, vereinfachte Pixabay Lizenz, letzter Abruf 19.04. 17:00 Quelle: https://pixabay.com/de/photos/br%C3%BCcke-beleuchtet-bunt-nacht-1092256/
      );
    } catch (e) {}

    return UserAccountsDrawerHeader(
      accountName: Text('Andrej Görzen u. Friedrich Schiemann'),
      accountEmail: Text('aled@fschiemann.de'),
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: bgImage,
        ),
      ),
      currentAccountPicture: CircleAvatar(
        backgroundImage: avImage,
      ),
    );
  }

/// Darstellung eines Page-Segments, in der Seitennavigation.
  List<Widget> _buildDrawerLable(BuildContext context, String title,
      {Icon icon}) {
    return [
      ListTile(
        title: Text(title),
        onTap: () => _onListTileTap(context, title),
        leading: icon,
      ),
      Divider()
    ];
  }

/// Wechselt die Pages aus der Seitennavigationsleiste.
  _onListTileTap(BuildContext context, String title) {
    if (title == 'Home') {
      if (title != _currentBodyTitle) {
        setState(() {
          _body = OverviewScreen();
          _currentBodyTitle = title;
        });
      }
      Navigator.of(context).pop();
    } else if (title == 'Color') {
      if (title != _currentBodyTitle) {
        setState(() {
          _body = ColorPickerScreen();
          _currentBodyTitle = title;
        });
      }
      Navigator.of(context).pop();
    } else if (title == 'Alarm') {
      if (title != _currentBodyTitle) {
        setState(() {
          _body = AlarmScreen();
          _currentBodyTitle = title;
        });
      }
      Navigator.of(context).pop();
    } else if (title == 'About') {
      Navigator.of(context).pop();
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) => AboutPage()));
    } else {
      Navigator.of(context).pop();
    }
  }

/// Darstellung der Kommunikationsiconindikator.
  Widget _buildConnectionIndicator() {
    return StreamBuilder(
      stream: Server().isConnectedStream,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        final bool connection = snapshot.data;
        if (connection == null || !connection)
          return Icon(
            Icons.signal_wifi_off,
            color: Colors.red,
          );
        return Icon(
          Icons.signal_wifi_4_bar,
          color: Colors.blue,
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, kToolbarHeight),
        child: AppBar(title: Text(widget.title), actions: [
          Padding(
            padding: EdgeInsets.all(16),
            child: StreamBuilder/*<Object>*/(
                stream: _appBarStreamController.stream,
                builder: (context, snapshot) {
                  List<Widget> iconWidgets = snapshot.data;
                  final int length =
                      iconWidgets != null ? iconWidgets.length : 1;
                  return Row(
                      children: List.generate(length, (index) {
                    if (index == length - 1) return _buildConnectionIndicator();
                    return iconWidgets[index];
                  }));
                }),
          )
        ]),
      ),
      drawer: Drawer(
        child: ListView(children: _buildDrawerList(context)),
      ),
      body: _body,
    );
  }

  @override
  void dispose() {
    this._appBarStreamController.close();
    super.dispose();
  }
}
