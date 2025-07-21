import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';

class WindowControlPage extends StatefulWidget {
  const WindowControlPage({super.key});

  @override
  State<WindowControlPage> createState() => _WindowControlPageState();
}

class _WindowControlPageState extends State<WindowControlPage> {
  final _bt = BluetoothService();

  bool _autoMode = false;
  bool _isWindowOpen = false;
  bool _isMoving = false;

  double _currentTemp = 25.5;
  double _currentLight = 550;
  double _currentHum = 60;

  void _setMode(bool auto) {
    if (_isMoving) return;
    setState(() => _autoMode = auto);
    _bt.send(auto ? 'a' : 'm');
  }

  Future<void> _moveWindow(bool open) async {
    if (_isMoving || _isWindowOpen == open) return;

    setState(() => _isMoving = true);
    _bt.send(open ? 'o' : 'c');

    await Future.delayed(const Duration(seconds: 10));

    if (!mounted) return;
    setState(() {
      _isMoving = false;
      _isWindowOpen = open;
    });
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: _modeToggle()),
            const SizedBox(height: 32),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _autoMode ? _autoBody() : _manualBody(),
              ),
            ),
          ],
        ),
      );

  Widget _modeToggle() => ToggleButtons(
        borderRadius: BorderRadius.circular(12),
        constraints: const BoxConstraints(minHeight: 48, minWidth: 140),
        selectedColor: Colors.white,
        fillColor: Theme.of(context).primaryColor,
        isSelected: [!_autoMode, _autoMode],
        onPressed: _isMoving ? null : (idx) => _setMode(idx == 1),
        children: const [
          Text('Manual'),
          Text('Automatic'),
        ],
      );

  Widget _manualBody() => Center(
        key: const ValueKey('manual'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Image.asset(
                      _isWindowOpen ? 'assets/window_open.png' : 'assets/window_closed.png',
                      key: ValueKey(_isWindowOpen),
                      height: 180,
                    ),
                  ),
                  if (_isMoving)
                    Container(
                      height: 180,
                      width: 180,
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ToggleButtons(
              borderRadius: BorderRadius.circular(12),
              constraints: const BoxConstraints(minHeight: 48, minWidth: 120),
              selectedColor: Colors.white,
              fillColor: Theme.of(context).primaryColor,
              isSelected: [_isWindowOpen, !_isWindowOpen],
              onPressed: _isMoving ? null : (idx) => _moveWindow(idx == 0),
              children: const [
                Text('Open'),
                Text('Close'),
              ],
            ),
          ],
        ),
      );

  Widget _autoBody() => SingleChildScrollView(
        key: const ValueKey('auto'),
        child: Column(
          children: [
            _title('Current Sensor Values'),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _sensorTile(Icons.thermostat, '${_currentTemp.toStringAsFixed(1)} °C'),
                    _sensorTile(Icons.wb_sunny, '${_currentLight.toInt()} lux'),
                    _sensorTile(Icons.water_drop, '${_currentHum.toInt()} %'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Thresholds and behaviour can be configured in the “Sensors” tab.\n'
                'If a sensor value exceeds its threshold the window closes;\n'
                'if it falls below, the window opens.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );

  Widget _sensorTile(IconData icon, String value) => Column(
        children: [
          Icon(icon, size: 36),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      );

  Widget _title(String text) => Text(
        text,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      );
}
