import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class HardwareControlPage extends StatefulWidget {
  const HardwareControlPage({Key? key}) : super(key: key);

  @override
  _HardwareControlPageState createState() => _HardwareControlPageState();
}

class _HardwareControlPageState extends State<HardwareControlPage> {
  late BluetoothConnection connection;
  String adr = "00:22:12:02:47:D1"; // my Bluetooth device MAC Address

  Future<void> sendData(String data) async {
    data = data.trim();
    try {
      List<int> list = data.codeUnits;
      Uint8List bytes = Uint8List.fromList(list);
      connection.output.add(bytes);
      await connection.output.allSent;
      if (kDebugMode) {
        print('Data sent successfully');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // Request Bluetooth permissions
  Future<void> requestBluetoothPermission() async {
    final statusScan = await Permission.bluetoothScan.request();
    final statusConnect = await Permission.bluetoothConnect.request();
    if (statusScan.isGranted && statusConnect.isGranted) {
      // Both Bluetooth permissions granted
      print("Bluetooth permissions granted");
    } else {
      // Either Bluetooth permission is denied
      print("Bluetooth permissions denied");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hardware Control"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("MAC Address: $adr"),
            ElevatedButton(
              child: Text("Connect"),
              onPressed: () {
                requestBluetoothPermission(); // Request the Bluetooth permission.
                connect(adr); // Connect to the Bluetooth device.
              },
            ),
            SizedBox(height: 30.0,),
            ElevatedButton(
              child: Text("OPEN"),
              onPressed: () {
                sendData("1");
              },
            ),
            SizedBox(height: 10.0,),
            ElevatedButton(
              child: Text("CLOSE"),
              onPressed: () {
                sendData("0");
              },
            ),
          ],
        ),
      ),
    );
  }

  Future connect(String address) async {
    try {
      connection = await BluetoothConnection.toAddress(address);
      sendData('111');
      connection.input!.listen((Uint8List data) {
        // Data received from the connected device
        // Handle the received data here
      });
    } catch (exception) {
      print("Cannot connect, exception occurred: $exception");
    }
  }
}
