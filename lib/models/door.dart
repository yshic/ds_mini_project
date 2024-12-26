import 'package:flutter/material.dart';
import 'device.dart';

class Door extends Device {
  Door({
    required super.id,
    required super.name, 
    required super.mqtt_username, 
    required super.mqtt_ip,
    required super.mqtt_port,
  }) {
    mqttClient.connect();
    mqttClient.subscribe("V9", (message) {
      if (message == "T") {
        isOn = true;
      } else if (message == "t") {
        isOn = false;
      }
    });
  }

  void toggleDoor() {
    isOn = !isOn;
    mqttClient.publish("V9", "t");
    notifyListeners();
  }

  @override
  Widget getDetailsWidget() {
    return Text('Door Details');
  }
  
  @override
  Widget getSummaryWidget() {
    IconData getDoorIcon(bool isOn) {
      return isOn ? Icons.door_back_door : Icons.door_back_door;
    }

    Color getDoorColor(bool isOn) {
      return isOn ? Colors.green : const Color.fromARGB(255, 198, 54, 44);
    }

    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: getDoorColor(isOn),
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
              const SizedBox(height: 8.0),
              Icon(
                getDoorIcon(isOn),
                size: 50,
                color: Colors.white,
              ),
              const SizedBox(height: 8.0),
              Text(
                isOn ? 'Open' : 'Closed',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                "Tap to " + (isOn ? "close": "open"),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
