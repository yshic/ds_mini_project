import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class FanDetailsWidget extends StatefulWidget {
  final int speed;
  final double temperature;
  final double humidity;
  final Function(int) onSpeedChange;

  const FanDetailsWidget({
    Key? key,
    required this.speed,
    required this.temperature,
    required this.humidity,
    required this.onSpeedChange,
  }) : super(key: key);

  @override
  _FanDetailsWidgetState createState() => _FanDetailsWidgetState();
}

class _FanDetailsWidgetState extends State<FanDetailsWidget> {
  late int _currentSpeed;

  @override
  void initState() {
    super.initState();
    _currentSpeed = widget.speed.clamp(0, 5);
  }

  @override
  Widget build(BuildContext context) {
    Color getTemperatureColor(double temperature) {
      if (temperature < 30) {
        return Colors.blue;
      } else {
        return const Color.fromARGB(255, 255, 77, 0);
      }
    }

    Color getHumidityColor(double humidity) {
      if (humidity < 30) {
        return const Color.fromARGB(255, 152, 86, 0);
      } else {
        return const Color.fromARGB(255, 0, 205, 212);
      }
    }

    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                gradient: LinearGradient(
                  colors: [getTemperatureColor(widget.temperature), getHumidityColor(widget.humidity)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: Row(
                      children: [
                        Icon(Icons.thermostat, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Temperature: ${widget.temperature}°C',
                          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: Row(
                      children: [
                        Icon(Icons.water_drop, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Humidity: ${widget.humidity}%',
                          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: Center(
                child: SleekCircularSlider(
                  initialValue: _currentSpeed.toDouble(),
                  min: 0.0,
                  max: 5.0,
                  appearance: CircularSliderAppearance(
                    size: MediaQuery.of(context).size.width * 0.8,
                    customWidths: CustomSliderWidths(progressBarWidth: 8, trackWidth: 8, handlerSize: 15),
                    customColors: CustomSliderColors(
                      progressBarColors: [Colors.blue, Colors.red],
                      trackColor: Colors.grey,
                      dotColor: Colors.black,
                    ),
                    infoProperties: InfoProperties(
                      mainLabelStyle: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.09),
                      bottomLabelText: 'Speed',
                      bottomLabelStyle: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.09),
                      modifier: (double value) {
                        return '${value.ceil().toInt()}';
                      },
                    ),
                    animationEnabled: false,
                  ),
                  onChangeEnd: (double value) {
                    setState(() {
                      _currentSpeed = value.ceil().toInt();
                    });
                    widget.onSpeedChange(_currentSpeed);
                  },
                ),
              ),
            ),
          ],
        ),
    );
  }
}