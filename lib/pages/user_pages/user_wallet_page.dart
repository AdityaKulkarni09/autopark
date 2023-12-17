import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserWalletPage extends StatefulWidget {
  double walletBalance;

  UserWalletPage({required this.walletBalance});

  @override
  _UserWalletPageState createState() => _UserWalletPageState();
}

class _UserWalletPageState extends State<UserWalletPage> {
  final _customColor = Colors.purple.withOpacity(0.5);
  final TextEditingController _giftCardCodeController = TextEditingController();
  bool _showGiftCardField = false;

  @override
  void dispose() {
    _giftCardCodeController.dispose();
    super.dispose();
  }

  Future<void> _addGiftCardToWallet() async {
    final _giftCardCode = _giftCardCodeController.text.trim();

    if (_giftCardCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gift card code is required."),
        ),
      );
      return;
    }

    try {
      final giftCardRef = FirebaseFirestore.instance.collection('giftcards').doc(_giftCardCode);

      final giftCardSnapshot = await giftCardRef.get();

      if (giftCardSnapshot.exists) {
        final giftCardData = giftCardSnapshot.data() as Map<String, dynamic>;

        final Timestamp expirationTimestamp = giftCardData['expirationTimestamp'];
        final bool isRedeemed = giftCardData['isRedeemed'] ?? false;

        if (expirationTimestamp.toDate().isAfter(DateTime.now()) && !isRedeemed) {
          final double giftCardAmount = giftCardData['amount'];

          final userId = FirebaseAuth.instance.currentUser!.uid;
          final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

          await FirebaseFirestore.instance.runTransaction((transaction) async {
            final userSnapshot = await transaction.get(userRef);

            if (userSnapshot.exists) {
              final double currentBalance = userSnapshot['walletBalance'];
              transaction.update(userRef, {'walletBalance': currentBalance + giftCardAmount});
              transaction.update(giftCardRef, {'isRedeemed': true});

              setState(() {
                widget.walletBalance = currentBalance + giftCardAmount;
                _showGiftCardField = false;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Gift card successfully redeemed!"),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("User not found."),
                ),
              );
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid or expired gift card."),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gift card not found in Firestore."),
          ),
        );
      }
    } catch (e) {
      print("Error adding gift card to wallet: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An error occurred. Please try again."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Wallet"),
        backgroundColor: _customColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Current Balance",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "\₹${widget.walletBalance.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Add Balance to your Account",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showGiftCardField = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _customColor,
                padding: EdgeInsets.symmetric(horizontal: 20),
              ),
              child: Text(
                "Add Funds",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            if (_showGiftCardField)
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: _customColor, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextFormField(
                      controller: _giftCardCodeController,
                      decoration: InputDecoration(
                        hintText: "Enter Gift Card Code",
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Gift Card Code is required";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _addGiftCardToWallet();
                    },
                    child: Text("Redeem"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _customColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20), // Adding space below the Redeem button
                ],
              ),
          ],
        ),
      ),
    );
  }
}
