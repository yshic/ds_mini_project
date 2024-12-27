import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home/models/device.dart';
import 'package:smart_home/models/fan.dart';
import 'package:smart_home/models/light.dart';
import 'package:smart_home/models/door.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final String mqtt_ip = "localhost";
  final String mqtt_port = "1883";
  final String username = "admin";
  late List<Device> devices;

  @override
  void initState() {
    super.initState();
    devices = [
      Fan(id: '1', name: 'Living Room Fan', mqtt_username: username, mqtt_ip: mqtt_ip, mqtt_port: mqtt_port),
      Light(id: '2', name: 'Bedroom LED', mqtt_username: username, mqtt_ip: mqtt_ip, mqtt_port: mqtt_port),
      Door(id: '3', name: 'Front Door', mqtt_username: username, mqtt_ip: mqtt_ip, mqtt_port: mqtt_port),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Smart Home')),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 1.0,
        ),
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          return ChangeNotifierProvider<Device>.value(
            value: device,
            child: Consumer<Device>(
              builder: (context, device, child) {
                return device.isInitialized() ? GestureDetector(
                  onTap: device is Door ? device.toggleDoor : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeviceScreen(device: device),
                      ),
                    );
                  },
                  child: Card(
                    child: Center(
                      child: device.getSummaryWidget(),
                    ),
                  ),
                ) 
                : LoadingScreen();
              },
            ),
          );
        },
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.grey[300]),
            ),
          ),
    );
  }
}

class DeviceScreen extends StatelessWidget {
  final Device device;
  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(device.name)),
      body: Center(
        child: device.getDetailsWidget(),
      ),
    );
  }
}
