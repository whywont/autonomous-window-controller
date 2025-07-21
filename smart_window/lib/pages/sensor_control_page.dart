import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';

class SensorControlPage extends StatefulWidget {
  @override
  _SensorControlPageState createState() => _SensorControlPageState();
}

class _SensorControlPageState extends State<SensorControlPage> {
  bool _lightActive = false;
  double _lightThr = 500;

  bool _tempActive = false;
  double _tempThr = 25;

  bool _humActive = false;
  double _humThr = 50;

  final _bt = BluetoothService();

  void _save() {
    String msg = 'Save:';
    if (_lightActive) msg += 'L:${_lightThr.toInt()};';
    if (_tempActive)  msg += 'T:${_tempThr.toStringAsFixed(1)};';
    if (_humActive)   msg += 'H:${_humThr.toInt()};';
    msg += '\n';
    _bt.send(msg); // Send in one shot
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings sent to Arduino')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _sensorCard(
          title: 'Light',
          unit: 'lux',
          active: _lightActive,
          threshold: _lightThr,
          min: 0,
          max: 1000,
          onToggle: (v) => setState(() => _lightActive = v),
          onChange: (v) => setState(() => _lightThr = v),
        ),
        _sensorCard(
          title: 'Temperature',
          unit: '°C',
          active: _tempActive,
          threshold: _tempThr,
          min: 0,
          max: 50,
          onToggle: (v) => setState(() => _tempActive = v),
          onChange: (v) => setState(() => _tempThr = v),
        ),
        _sensorCard(
          title: 'Humidity',
          unit: '%',
          active: _humActive,
          threshold: _humThr,
          min: 0,
          max: 100,
          onToggle: (v) => setState(() => _humActive = v),
          onChange: (v) => setState(() => _humThr = v),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Save settings'),
            onPressed: _save,
          ),
        ),
      ],
    );
  }

  Widget _sensorCard({
    required String title,
    required String unit,
    required bool active,
    required double threshold,
    required double min,
    required double max,
    required ValueChanged<bool> onToggle,
    required ValueChanged<double> onChange,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text('$title Sensor'),
              subtitle: Text('Threshold: ${threshold.toStringAsFixed(1)} $unit'),
              value: active,
              onChanged: onToggle,
            ),
            if (active) ...[
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 6),
                child: Text(
                  'If a sensor value exceeds its threshold the window closes; if it falls below, the window opens.',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ),
              Slider(
                value: threshold,
                min: min,
                max: max,
                divisions: max.toInt(),
                label: threshold.toStringAsFixed(1),
                onChanged: onChange,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
