import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'pages/window_control_page.dart';
import 'pages/sensor_control_page.dart';
import 'services/bluetooth_service.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await FlutterBluetoothSerial.instance.requestEnable();
  }

  runApp(SmartWindowApp());
}

class SmartWindowApp extends StatefulWidget {
  @override
  _SmartWindowAppState createState() => _SmartWindowAppState();
}

class _SmartWindowAppState extends State<SmartWindowApp> {
  int _selectedIndex = 0;
  bool _isConnecting = true;

  final List<Widget> _pages = [
    WindowControlPage(),
    SensorControlPage(),
  ];

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  Future<void> _initBluetooth() async {
    // Give Android’s Bluetooth stack a moment to settle
    await Future.delayed(const Duration(seconds: 2));
    await BluetoothService().connectToHC05();
    setState(() => _isConnecting = false);
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Window',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(title: const Text('Smart Window')),
        body: _isConnecting
            ? const Center(child: CircularProgressIndicator())
            : _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.window), label: 'Control'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Sensors'),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
