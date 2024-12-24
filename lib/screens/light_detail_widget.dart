import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class LightDetailsWidget extends StatefulWidget {
  final Color initialColor;
  final double initialBrightness;
  final Function(Color) onColorChange;
  final Function(double) onBrightnessChange;
  final Function(bool) onPowerChange;
  final bool initialPowerState;

  const LightDetailsWidget({
    Key? key,
    required this.initialColor,
    required this.initialBrightness,
    required this.onColorChange,
    required this.onBrightnessChange,
    required this.onPowerChange,
    required this.initialPowerState,
  }) : super(key: key);

  @override
  _LightDetailsWidgetState createState() => _LightDetailsWidgetState();
}

class _LightDetailsWidgetState extends State<LightDetailsWidget> {
  late Color _currentColor;
  late double _currentBrightness;
  late bool _isOn;
  final List<Color> _colorHistory = [];

  @override
  void initState() {
    super.initState();
    _currentColor = widget.initialColor;
    _currentBrightness = widget.initialBrightness;
    _isOn = widget.initialPowerState;
  }

  void _changeColor(Color color) {
    setState(() {
      _currentColor = color;
    });
    widget.onColorChange(color);
  }

  void _changeBrightness(double brightness) {
    setState(() {
      _currentBrightness = brightness;
    });
    widget.onBrightnessChange(brightness);
  }

  void _togglePower(bool value) {
    setState(() {
      _isOn = value;
    });
    widget.onPowerChange(value);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Turn ' + (_isOn ? 'Off' : 'On'),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: _isOn,
                  onChanged: _togglePower,
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Text(
              'Color',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            GestureDetector(
              onTap: _isOn
                  ? () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Select Color'),
                          content: SingleChildScrollView(
                            child: ColorPicker(
                              pickerColor: _currentColor,
                              onColorChanged: (color) {
                                _changeColor(color);
                                _colorHistory.add(color);
                              },
                              displayThumbColor: false,
                              pickerAreaHeightPercent: 0.8,
                              enableAlpha: false,
                              hexInputBar: true,
                            ),
                          ),
                          actions: [
                            TextButton(
                              child: Text('Done'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    }
                  : null,
              child: Container(
                width: double.infinity,
                height: 50,
                color: _isOn ? _currentColor : Colors.grey,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Brightness',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Slider(
              value: _currentBrightness,
              min: 0,
              max: 1,
              divisions: 100,
              label: (_currentBrightness * 100).toInt().toString(),
              onChanged: _isOn ? _changeBrightness : null,
            ),
          ],
        ),
    );
  }
}