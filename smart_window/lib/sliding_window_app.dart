import 'package:flutter/material.dart';
import 'pages/window_control_page.dart';
import 'pages/sensor_control_page.dart';

class SlidingWindowApp extends StatefulWidget {
  @override
  _SlidingWindowAppState createState() => _SlidingWindowAppState();
}

class _SlidingWindowAppState extends State<SlidingWindowApp> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    WindowControlPage(),
    SensorControlPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Window',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Smart Window'),
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Control',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Sensors',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
