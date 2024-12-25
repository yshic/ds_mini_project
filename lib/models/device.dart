import 'package:flutter/widgets.dart';
import 'package:smart_home/services/mqtt_client.dart';
abstract class Device extends ChangeNotifier {
  final String id;
  final String name;
  late bool isOn;
  final MqttClient mqttClient;

  Device({
    required this.id,
    required this.name,
    required String mqtt_username,
    required String mqtt_ip,
    required String mqtt_port,
  }) : mqttClient = MqttClient(username: mqtt_username, ip: mqtt_ip, port: mqtt_port) 
  {
    isOn = false;
  }

  Widget getDetailsWidget();
  Widget getSummaryWidget();
}
