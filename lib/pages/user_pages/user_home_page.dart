import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:automated_parking/utils/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class UserHomePage extends StatefulWidget {
  final Map<String, dynamic> arguments;
  UserHomePage({required this.arguments});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  String? _profilePictureURL;

  @override
  void initState() {
    super.initState();
    _fetchProfilePictureURL();
  }

  Future<void> _fetchProfilePictureURL() async {
    final userId = widget.arguments['userId'] as String? ?? '';
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>;
      setState(() {
        _profilePictureURL = data['profilePictureURL'] as String?;
      });
    }
  }

  ThemeData get themeData => ThemeData(
    primaryColor: Colors.purple.withOpacity(0.5),
  );

  Widget _buildFeatureCard(BuildContext context, String title, IconData icon, String route, {dynamic arguments}) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route, arguments: arguments);
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [themeData.primaryColor, themeData.primaryColor.withOpacity(0.7)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 60,
                color: Colors.white,
              ),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final file = File(pickedFile.path);

    final String userId = widget.arguments['userId'] as String? ?? '';
    final Reference storageReference =
    FirebaseStorage.instance.ref().child('profile_pictures').child('$userId.jpg');

    final String profilePictureURL = widget.arguments['profilePictureURL'] as String? ?? '';

    if (profilePictureURL.isNotEmpty) {
      setState(() {
        _profilePictureURL = profilePictureURL;
      });
      return;
    }

    final UploadTask uploadTask = storageReference.putFile(file);

    await uploadTask.whenComplete(() async {
      final String downloadURL = await storageReference.getDownloadURL();
      print("Download URL: $downloadURL");

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'profilePictureURL': downloadURL,
      });

      setState(() {
        _profilePictureURL = downloadURL;
        widget.arguments['profilePictureURL'] = downloadURL;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final _customColor = themeData.primaryColor;
    final _email = widget.arguments['email'] as String? ?? 'Unknown Email';
    final _fullName = widget.arguments['fullName'] as String? ?? 'Unknown Full Name';
    final _userId = widget.arguments['userId'] as String? ?? 'Unknown User ID';
    final _walletBalance = widget.arguments['walletBalance'] as double? ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: Text("AutoPark"),
        backgroundColor: _customColor,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 2,
                  margin: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: ListTile(
                    title: Text(
                      "Current Balance",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "₹$_walletBalance",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: _customColor,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFeatureCard(
                        context,
                        'Profile',
                        Icons.manage_accounts,
                        MyRoutes.userProfileRoute,
                      ),
                      _buildFeatureCard(
                        context,
                        'Wallet',
                        Icons.wallet,
                        MyRoutes.userWalletRoute,
                        arguments: {'walletBalance': _walletBalance},
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFeatureCard(
                        context,
                        'History',
                        Icons.history,
                        MyRoutes.userHistoryRoute,
                        arguments: {'userId': _userId},
                      ),
                      _buildFeatureCard(
                        context,
                        'Find Us',
                        Icons.near_me,
                        MyRoutes.userNearbyParkingRoute,
                        arguments: {'userId': _userId},
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                _fullName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              accountEmail: Text(
                _email,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: _customColor,
                child: GestureDetector(
                  onTap: _updateProfilePicture,
                  child: _profilePictureURL != null
                      ? ClipOval(
                    child: Image.network(
                      _profilePictureURL!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Icon(
                    Icons.person,
                    size: 70,
                    color: Colors.white,
                  ),
                ),
              ),
              decoration: BoxDecoration(
                color: _customColor.withOpacity(0.2),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.qr_code,
                color: _customColor,
              ),
              title: Text(
                'My QR Code',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, MyRoutes.userQrRoute, arguments: {'userId': _userId});
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(
                Icons.support_agent,
                color: _customColor,
              ),
              title: Text(
                'Support',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushNamed(context, MyRoutes.userSupportRoute);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: _customColor,
              ),
              title: Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushNamed(context, MyRoutes.startRoute);
              },
            ),
          ],
        ),
      ),
    );
  }
}
