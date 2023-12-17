import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final Color _customColor = Colors.purple.withOpacity(0.6);
  bool _isEditingProfilePicture = false;
  String? _profilePictureURL;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchProfilePictureURL();
  }

  Future<void> _fetchProfilePictureURL() async {
    final userId = _auth.currentUser?.uid;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>;
      setState(() {
        _profilePictureURL = data['profilePictureURL'] as String?;
      });
    }
  }

  Future<void> _updateProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final file = File(pickedFile.path);

    final userId = _auth.currentUser?.uid;
    final Reference storageReference = FirebaseStorage.instance.ref().child('profile_pictures').child('$userId.jpg');

    final UploadTask uploadTask = storageReference.putFile(file);

    await uploadTask.whenComplete(() async {
      final String downloadURL = await storageReference.getDownloadURL();
      print("Download URL: $downloadURL");

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'profilePictureURL': downloadURL,
      });

      setState(() {
        _profilePictureURL = downloadURL;
        _isEditingProfilePicture = false; // Reset the edit mode after updating the picture
      });
    });
  }

  void _showResetPasswordDialog() {
    String? email = _auth.currentUser?.email;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Forgot Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("Email: $email"),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await _auth.sendPasswordResetEmail(email: email!);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Password reset email sent to $email"),
                      ),
                    );
                  } catch (e) {
                    print("Password reset failed: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Password reset failed. Please try again."),
                      ),
                    );
                  }
                },
                child: Text("Send Password Reset Email"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: _customColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _isEditingProfilePicture = true;
                });
              },
              child: Stack(
                alignment: AlignmentDirectional.bottomEnd,
                children: [
                  CircleAvatar(
                    radius: 100,
                    backgroundColor: _customColor,
                    child: CircleAvatar(
                      radius: 96,
                      backgroundColor: Colors.white,
                      child: _profilePictureURL != null
                          ? ClipOval(
                        child: Image.network(
                          _profilePictureURL!,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      )
                          : Icon(
                        Icons.person,
                        size: 120,
                        color: _customColor,
                      ),
                    ),
                  ),
                  if (_isEditingProfilePicture) // Display the edit icon when editing is enabled
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: _updateProfilePicture,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Icon(
                            Icons.edit,
                            color: _customColor,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 20),
            buildItem(Icons.account_circle_rounded, 'Edit Profile Picture', _updateProfilePicture),
            buildItem(Icons.lock, 'Change Password', _showResetPasswordDialog),
          ],
        ),
      ),
    );
  }

  Widget buildItem(IconData icon, String title, Function()? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _customColor,
            ),
            child: Icon(
              icon,
              size: 30,
              color: Colors.white,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 24,
            color: _customColor,
          ),
        ),
      ),
    );
  }
}
