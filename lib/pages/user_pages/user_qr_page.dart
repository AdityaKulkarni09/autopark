import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class UserQrPage extends StatelessWidget {
  final String userId;
  final Color _customColor = Colors.purple.withOpacity(0.6);
  UserQrPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your QR Code'),backgroundColor: _customColor),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 5)
                  ),
                  child: QrImageView(
                    data: userId,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Scan this QR code at the checkpoint',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}