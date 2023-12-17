import 'package:flutter/material.dart';
import 'package:automated_parking/utils/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHomePage extends StatefulWidget {
  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final Color _customColor = Colors.purple.withOpacity(0.5);
  final _random = Random();
  TextEditingController _giftCardAmountController = TextEditingController();
  String? _giftCardCode;

  @override
  void dispose() {
    _giftCardAmountController.dispose();
    super.dispose();
  }

  Future<void> _generateGiftCard() async {
    final amount = _giftCardAmountController.text;
    if (amount.isNotEmpty) {
      // Generate a unique gift card code based on current time and a random number
      final DateTime now = DateTime.now();
      final Timestamp timestamp = Timestamp.fromDate(now);
      final randomCode = _random.nextInt(9999).toString().padLeft(4, '0');
      final giftCardCode = 'GC${timestamp.seconds}$randomCode';

      try {
        final FirebaseFirestore firestore = FirebaseFirestore.instance;

        // Check if the code already exists to ensure uniqueness
        final DocumentReference giftCardRef = firestore.collection('giftcards').doc(giftCardCode);
        final DocumentSnapshot existingGiftCard = await giftCardRef.get();

        if (!existingGiftCard.exists) {
          // Code does not exist, save it to Firestore with the gift card code as the document ID
          final Timestamp expirationTimestamp =
          Timestamp.fromDate(now.add(Duration(hours: 1))); // Set expiration time to 1 hour from now
          await giftCardRef.set({
            'amount': double.parse(amount),
            'expirationTimestamp': expirationTimestamp,
            'isRedeemed': false,
          });

          setState(() {
            _giftCardCode = giftCardCode;
          });

          // Clear the input field
          _giftCardAmountController.clear();
        } else {
          print('Gift card with code $giftCardCode already exists. Please generate a unique code.');
        }
      } catch (e) {
        print('Error generating and saving gift card: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _customColor,
        elevation: 2,
        title: Text(
          "AutoPark Admin",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamed(context, MyRoutes.startRoute);
            },
            icon: Icon(
              Icons.logout,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30),
            Container(
              height: 700,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: _customColor,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.qr_code,
                            size: 120,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, MyRoutes.adminChoicesRoute);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _customColor,
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Scan QR Code",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      Text(
                        "Generate Top-up Code",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _giftCardAmountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Enter Amount",
                          labelText: "Top-up Amount",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _generateGiftCard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _customColor,
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Generate",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      if (_giftCardCode != null)
                        Text(
                          "Gift Card Code: $_giftCardCode",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _customColor,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
