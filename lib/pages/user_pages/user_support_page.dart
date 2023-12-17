import 'package:flutter/material.dart';

class UserSupportPage extends StatelessWidget {
  final Color _customColor = Colors.purple.withOpacity(0.6);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Support'),
        backgroundColor: _customColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: _customColor, // Change color
              ),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 5, // Add elevation for a card effect
              child: ListTile(
                leading: Icon(
                  Icons.email,
                  color: _customColor, // Change icon color
                ),
                title: Text(
                  'Email: support@example.com',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            Card(
              elevation: 5,
              child: ListTile(
                leading: Icon(
                  Icons.phone,
                  color: _customColor,
                ),
                title: Text(
                  'Phone: +123-456-7890',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            Divider(thickness: 2),
            Text(
              'Frequently Asked Questions (FAQs)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: _customColor,
              ),
            ),
            SizedBox(height: 10),
            ExpansionTile(
              title: Text(
                'Parking Charges?',
                style: TextStyle(fontSize: 18),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '20 Rs per Hour and it will eventually with time like for first hour its 20, for first two hour its 40 and so on.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: Text(
                'How do I reset my password?',
                style: TextStyle(fontSize: 18),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'To reset your password, go to the login page and click on the "Forgot Password" link. Follow the instructions sent to your registered email.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: Text(
                'What should I do if I encounter an issue?',
                style: TextStyle(fontSize: 18),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'If you encounter any issues while using our app, please contact our support team at support@example.com or call us at +123-456-7890 for immediate assistance.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
