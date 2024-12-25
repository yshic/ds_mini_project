import 'package:flutter/material.dart';
import 'package:smart_home/screens/fan_detail_widget.dart';

import 'device.dart';
class Fan extends Device {
  late int speed;
  late double temperature;
  late double humidity;

  Fan({
    required super.id,
    required super.name, 
    required super.mqtt_username, 
    required super.mqtt_ip,
    required super.mqtt_port,
  }) {
    mqttClient.subscribe("V1", (temperature) {
      this.temperature = double.parse(temperature);
      notifyListeners();
    });
    mqttClient.subscribe("V2", (humidity) {
      this.humidity = double.parse(humidity);
      notifyListeners();
    });
    mqttClient.subscribe("V12", (speed) {
      this.speed = int.parse(speed);
      if (this.speed > 0) {
        isOn = true;
      } else {
        isOn = false;
      }
      notifyListeners();
    });
    this.speed = 0;
    this.temperature = 30.0;
    this.humidity = 80.0;
  }

  @override
  Widget getDetailsWidget() {
    return FanDetailsWidget(
      speed: speed,
      temperature: temperature,
      humidity: humidity,
      onSpeedChange: (newSpeed) {
        speed = newSpeed;
        notifyListeners();
        mqttClient.publish("V12", newSpeed.toString());
      },
    );
  }

  @override
  Widget getSummaryWidget() {
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
      } else{
        return const Color.fromARGB(255, 0, 205, 212);
      } 
    }

    Widget getIconByTemp(double temperature) {
      double iconSize = 50.0;
      if (temperature < 30) {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: [Colors.white, Colors.blue],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ).createShader(bounds);
          },
          child: Icon(Icons.ac_unit, size: iconSize, color: Colors.white),
        );
      } else {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: [const Color.fromARGB(255, 255, 153, 0), Colors.red],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ).createShader(bounds);
          },
          child: Icon(Icons.sunny, size: iconSize, color: Colors.white),
        );
      }
    }

    LinearGradient getGradient(double temperature, double humidity) {
      Color tempColor = getTemperatureColor(temperature);
      Color humidityColor = getHumidityColor(humidity);
      return LinearGradient(
        colors: [tempColor, humidityColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        gradient: getGradient(temperature, humidity),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 2.0),
            getIconByTemp(temperature),
            SizedBox(height: 1.0),
            Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.speed, size: 24, color: Colors.white),
                    Text(': ', style: TextStyle(fontSize: 14, color: Colors.white)),
                    SizedBox(width: 3),
                    Text('$speed', style: TextStyle(fontSize: 14, color: Colors.white)),
                  ],
                ),
                SizedBox(height: 1.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.thermostat, size: 24, color: Colors.white),
                    Text(': ', style: TextStyle(fontSize: 14, color: Colors.white)),
                    SizedBox(width: 2),
                    Text('$temperature°C', style: TextStyle(fontSize: 14, color: Colors.white)),
                  ],
                ),
                SizedBox(height: 1.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.water_drop, size: 24, color: Colors.white),
                    Text(': ', style: TextStyle(fontSize: 14, color: Colors.white)),
                    SizedBox(width: 2),
                    Text('$humidity%', style: TextStyle(fontSize: 14, color: Colors.white)),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}