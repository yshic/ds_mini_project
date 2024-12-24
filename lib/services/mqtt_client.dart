import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttClient {
  final MqttServerClient client;
  final String username;

  MqttClient({required  this.username, required String ip, required String port})
  :client = MqttServerClient(ip, username) {
    client.logging(on: false);
    client.onConnected = () {
      print('Connected');
    };
    client.onDisconnected = () {
      print('Disconnected');
    };
  }

  void connect() {
    client.connect();
  }

  void disconnect() {
    client.disconnect();
  }

  void publish(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage("$username/feeds/$topic", MqttQos.atLeastOnce, builder.payload!);
  }

  void subscribe(String topic, void Function(String) callback) {
    client.subscribe("$username/feeds/$topic", MqttQos.atLeastOnce);
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> event) {
      final MqttPublishMessage message = event[0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);
      callback(payload);
    });
  }

  void unsubscribe(String topic) {
    client.unsubscribe("$username/feeds/$topic");
  }
}