import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:automated_parking/utils/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:automated_parking/utils/clippers.dart';

class UserSignupPage extends StatefulWidget {
  @override
  State<UserSignupPage> createState() => _UserSignupPageState();
}

class _UserSignupPageState extends State<UserSignupPage> {
  Color customColor = Colors.purple.withOpacity(0.6);
  final _formKey = GlobalKey<FormState>();
  String? _fullName;
  String? _emailId;
  String? _password;
  double _walletBalance = 200.0;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signup(String? email, String? password) async {
    try {
      if (email != null && password != null) {
        final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final String uid = userCredential.user!.uid;
        print("$uid");
        await _saveDataToDb(uid, _fullName, email, _walletBalance);
        final Map<String, dynamic> userArgs = {
          'fullName': _fullName,
          'email': _emailId,
          'userId': uid,
          'walletBalance': _walletBalance,
        };
        print("$uid");
        Navigator.pushNamed(context, MyRoutes.userHomeRoute, arguments: userArgs);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "weak-password") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("The password provided is too weak."),
          ),
        );
      } else if (e.code == "email-already-in-use") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("The account already exists for that email."),
          ),
        );
      }
    } catch (e) {
      print("signup failed $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An error occurred. Please try again."),
        ),
      );
    }
  }

  Future<void> _saveDataToDb(String uid, String? _fullName, String email, double walletBalance) async {
    try {
      final CollectionReference userCollection = FirebaseFirestore.instance.collection("users");
      print("$uid");
      await userCollection.doc(uid).set({
        'fullName': _fullName ?? '',
        'email': email,
        'walletBalance': walletBalance,
        'profilePictureURl': '',
      });
      print("User data saved to Firestore");
    } catch (e) {
      print("Failed to save user data to Firestore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            ClipPath(
              clipper: Clip1Clipper(),
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.5),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Create account to continue!",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: "enter full name",
                        labelText: "Full Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                        prefixIcon: Icon(Icons.person),
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(26),
                          borderSide: BorderSide(color: Colors.purple),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(26),
                          borderSide: BorderSide(color: Colors.purple), // Change the enabled border color
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Full Name is required";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _fullName = value;
                      },
                    ),
                    SizedBox(height:10),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: "enter email id",
                        labelText: "Email Id",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                        prefixIcon: Icon(Icons.email_rounded),
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(26),
                          borderSide: BorderSide(color: Colors.purple),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(26),
                          borderSide: BorderSide(color: Colors.purple), // Change the enabled border color
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email Id is required";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _emailId = value;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "enter new password",
                        labelText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                        prefixIcon: Icon(Icons.lock),
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(26),
                          borderSide: BorderSide(color: Colors.purple),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(26),
                          borderSide: BorderSide(color: Colors.purple), // Change the enabled border color
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password is required";
                        }
                        else if (value.length <= 6) {
                          return "Password must be more than 6 characters";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _password = value;
                      },
                    ),
                    SizedBox(height: 230),
                    Material(
                      elevation: 2,
                      borderRadius: BorderRadius.circular(8),
                      child: GestureDetector(
                        onTap: () {
                          if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            _signup(_emailId, _password);
                          }
                        },
                        child: Container(
                          width: 150,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue, Colors.purple],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, MyRoutes.userLoginRoute);
                      },
                      child: Text("Already have an account? Sign in",
                        style: TextStyle(
                          color: customColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
