import 'dart:ui';
import 'package:smart_home/screens/light_detail_widget.dart';
import 'package:flutter/material.dart';
import 'device.dart';

class Light extends Device {
  late double brightness;
  late Color color;

  Light({
    required super.id,
    required super.name,
    required super.mqtt_username,
    required super.mqtt_ip,
    required super.mqtt_port,
  }) {
    mqttClient.subscribe("V3", (brightness) {
      this.brightness = double.parse(brightness);
    });
    mqttClient.subscribe("V11", (colorString) {
      String hexColor = colorString.replaceAll("#", "");
      if (hexColor.length == 6) {
        hexColor = "FF" + hexColor;
      }
      this.color = Color(int.parse("0x$hexColor"));
    });
    mqttClient.subscribe("V10", (state) {
      if (state == "S") {
        isOn = true;
      } else {
        isOn = false;
      }
    });
    isOn = true;
    color = Colors.blue;
    brightness = 1;
  }

  @override
  Widget getDetailsWidget() {
    return LightDetailsWidget(
      initialBrightness: brightness,
      initialColor: color,
      initialPowerState: isOn,
      onBrightnessChange: (newBrightness) {
        brightness = newBrightness;
        notifyListeners();
        mqttClient.publish("V3", newBrightness.toString());
      },
      onColorChange: (newColor) {
        color = newColor;
        notifyListeners();
        mqttClient.publish("V11", newColor.toString());
      },
      onPowerChange: (newPowerState) {
        isOn = newPowerState;
        notifyListeners();
        mqttClient.publish("V10", newPowerState ? "S" : "s");
      },
    );
  }

  @override
  Widget getSummaryWidget() {
    String getColorHex(Color color) {
      return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
    }

    Widget getIcon(double brightness, Color color) {
    double glowIntensity = brightness.clamp(0.0, 1.0) * 20;
    Color glowColor = Color.lerp(Colors.white, color, brightness)!.withOpacity(brightness.clamp(0.2, 1.0)); 
  return Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: glowColor,
          blurRadius: glowIntensity,
          spreadRadius: glowIntensity / 2,
        ),
      ],
    ),
    child: Icon(
      Icons.lightbulb,
      size: 50,
      color: glowColor,
    ),
  );
}


    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.black,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 14.0),
            isOn ? getIcon(brightness, color):getIcon(0, Colors.black),
            const SizedBox(height: 14.0),
            if (isOn) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    getColorHex(color),
                    style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 2.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.brightness_6, size: 24, color: Colors.white),
                  const SizedBox(width: 2),
                  const Text(
                    ':',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${(brightness * 100).toInt()}%',
                    style: const TextStyle(fontSize: 14, color: Colors.yellow, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ] else ...[
              Text(
                'The light is off',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
