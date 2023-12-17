import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:automated_parking/pages/admin_pages/hardware_control_page.dart';

class EntryScannerPage extends StatefulWidget {
  @override
  _EntryScannerPageState createState() => _EntryScannerPageState();
}

class _EntryScannerPageState extends State<EntryScannerPage> {
  String _scanStatus = 'Scan a QR code';
  String? selectedVehicleType;

  Future<void> _scanQRCode() async {
    if (selectedVehicleType == null) {
      setState(() {
        _scanStatus = "Please select a vehicle type";
      });
      return;
    }

    String _scanResult = await FlutterBarcodeScanner.scanBarcode(
      "#ff6666",
      "Cancel",
      false,
      ScanMode.QR,
    );

    if (!mounted) return;

    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(_scanResult)
        .get();

    if (userSnapshot.exists) {
      DocumentReference userRecordRef = FirebaseFirestore.instance
          .collection("user_records")
          .doc(_scanResult);

      CollectionReference entryExitSubCollection = userRecordRef.collection("entry_exit");
      await entryExitSubCollection.add({
        "entry_time": FieldValue.serverTimestamp(),
        "exit_time": null,
        "vehicle_type": selectedVehicleType, // Store selectedVehicleType
      });

      setState(() {
        _scanStatus = "Valid QR Scanned";
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HardwareControlPage()),
      );
    } else {
      setState(() {
        _scanStatus = "Invalid QR Scanned";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Entry Scanner"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _scanStatus,
              style: TextStyle(
                fontSize: 20,
                color: _scanStatus == "Valid QR Scanned" ? Colors.green : Colors.red,
              ),
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              hint: Text("Select Vehicle Type"),
              value: selectedVehicleType,
              onChanged: (value) {
                setState(() {
                  selectedVehicleType = value;
                });
              },
              items: <String>['2 Wheeler', '4 Wheeler']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (selectedVehicleType == null) {
                  setState(() {
                    _scanStatus = "Please select a vehicle type";
                  });
                  return;
                }
                _scanQRCode();
              },
              child: Text('Scan QR Code'),
            ),
          ],
        ),
      ),
    );
  }
}
