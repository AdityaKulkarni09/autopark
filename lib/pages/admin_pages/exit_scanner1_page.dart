import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:automated_parking/pages/admin_pages/hardware_control_page.dart';

class ExitScanner1Page extends StatefulWidget {
  @override
  _ExitScanner1PageState createState() => _ExitScanner1PageState();
}

class _ExitScanner1PageState extends State<ExitScanner1Page> {
  String _scanStatus = 'Scan a QR code';
  double deductionAmount = 0.0;
  final Color _customColor = Colors.purple.withOpacity(0.6);

  Future<void> _scanQRCode() async {
    String _scanResult = await FlutterBarcodeScanner.scanBarcode(
      "#ff6666",
      "Cancel",
      false,
      ScanMode.QR,
    );
    if (!mounted) return;
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.uid == '2NoE8GbnSsMcNx3RlhavhUTOoPm1') {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(_scanResult)
          .get();

      if (userSnapshot.exists) {
        DocumentReference userRecordRef = FirebaseFirestore.instance
            .collection("user_records")
            .doc(_scanResult);

        QuerySnapshot entryExitSnapshot = await userRecordRef
            .collection("entry_exit")
            .orderBy("entry_time", descending: true)
            .limit(1)
            .get();

        if (entryExitSnapshot.docs.isNotEmpty) {
          DocumentSnapshot latestEntryExitDoc = entryExitSnapshot.docs.first;
          if (latestEntryExitDoc.data() != null &&
              (latestEntryExitDoc.data() as Map<String, dynamic>).containsKey("exit_time")) {
            try {
              deductionAmount = calculateDeduction(
                latestEntryExitDoc["entry_time"].toDate(),
                DateTime.now(),
              );

              double currentWalletBalance = userSnapshot["walletBalance"];
              double newWalletBalance = currentWalletBalance - deductionAmount;

              await latestEntryExitDoc.reference.update({
                "exit_time": FieldValue.serverTimestamp(),
              });

              DocumentReference userDocRef = FirebaseFirestore.instance
                  .collection("users")
                  .doc(_scanResult);
              await userDocRef.update({
                "walletBalance": newWalletBalance,
              });
            } catch (e) {
              print("Error updating wallet balance: $e");
              setState(() {
                _scanStatus = "Error updating wallet balance";
              });
            }
            setState(() {
              _scanStatus = "Valid QR Scanned. Deducted $deductionAmount";
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
        } else {
          setState(() {
            _scanStatus = "No Entry Found";
          });
        }
      } else {
        setState(() {
          _scanStatus = "Invalid QR Scanned";
        });
      }
    } else {
      setState(() {
        _scanStatus = "Admin privileges required";
      });
    }
  }

  double calculateDeduction(DateTime entryTime, DateTime exitTime) {
    int timeDifferenceInMinutes = exitTime.difference(entryTime).inMinutes;
    if (timeDifferenceInMinutes <= 60) {
      return 40.0;
    } else if (timeDifferenceInMinutes <= 120) {
      return 80.0;
    } else if (timeDifferenceInMinutes <= 180) {
      return 120.0;
    } else if (timeDifferenceInMinutes <= 240) {
      return 160.0;
    } else if (timeDifferenceInMinutes <= 300) {
      return 200.0;
    } else if (timeDifferenceInMinutes <= 360) {
      return 240.0;
    } else if (timeDifferenceInMinutes <= 420) {
      return 280.0;
    } else if (timeDifferenceInMinutes <= 480) {
      return 320.0;
    } else if (timeDifferenceInMinutes <= 540) {
      return 360.0;
    } else if (timeDifferenceInMinutes <= 600) {
      return 400.0;
    } else {
      return 0.0;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Exit Scanner for 4 Wheeler"),
        backgroundColor: _customColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _scanStatus,
              style: TextStyle(
                fontSize: 20,
                color: _scanStatus == "Valid QR Scanned. Deducted $deductionAmount"
                    ? Colors.green
                    : Colors.red,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _scanQRCode,
              child: Text('Scan QR Code'),
            ),
          ],
        ),
      ),
    );
  }
}