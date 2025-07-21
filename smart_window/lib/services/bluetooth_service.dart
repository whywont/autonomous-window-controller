import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

/// Singleton service that holds the HC‑05 connection.
class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  BluetoothConnection? _connection;

  /// Call once at start‑up.
  Future<void> connectToHC05() async {
    final devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    final hc05 = devices.firstWhere(
      (d) => d.name == 'HC-05' || d.name == 'DSD TECH HC-05',
      orElse: () => throw ('HC‑05 not paired on this phone'),
    );

    _connection = await BluetoothConnection.toAddress(hc05.address);
    print('Connected to HC‑05 (${hc05.address})');
  }

  /// Send a plain‑text command (use '\n' at the end if your Arduino expects it).
  void send(String cmd) {
    if (_connection?.isConnected ?? false) {
      _connection!.output.add(Uint8List.fromList(cmd.codeUnits));
    } else {
      print('Not connected — cannot send “$cmd”');
    }
  }

  void dispose() => _connection?.dispose();
}
