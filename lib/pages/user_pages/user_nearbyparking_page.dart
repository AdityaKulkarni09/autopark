import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class UserNearbyParkingPage extends StatefulWidget {
  final String userId;
  UserNearbyParkingPage({required this.userId});

  @override
  _UserNearbyParkingPageState createState() => _UserNearbyParkingPageState();
}

class _UserNearbyParkingPageState extends State<UserNearbyParkingPage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? selectedCity;
  final _customColor = Colors.purple.withOpacity(0.5);
  Map<String, List<Map<String, dynamic>>> parkingData = {};

  Future<void> fetchParkingAreas(String cityName) async {
    try {
      final areaSnapshot = await firestore
          .collection('parking_areas')
          .doc(cityName)
          .collection('areas')
          .get();

      parkingData[cityName] = areaSnapshot.docs.map((areaDoc) {
        return areaDoc.data() as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      print('Error fetching parking areas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nearby Parking"),
        backgroundColor: _customColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('parking_areas').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<DropdownMenuItem<String>> cityDropdownItems = [];

          snapshot.data!.docs.forEach((parkingDoc) {
            String cityName = parkingDoc.id;
            cityDropdownItems.add(
              DropdownMenuItem<String>(
                value: cityName,
                child: Text(
                  cityName,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            );
          });

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                DropdownButton<String>(
                  hint: Text(
                    "Select a city",
                    style: TextStyle(fontSize: 18),
                  ),
                  value: selectedCity,
                  onChanged: (value) async {
                    setState(() {
                      selectedCity = value;
                    });
                    await fetchParkingAreas(selectedCity!);
                    setState(() {});
                  },
                  items: cityDropdownItems,
                ),
                SizedBox(height: 20),
                if (selectedCity != null)
                  Text(
                    "Parking Areas in $selectedCity:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                if (selectedCity != null)
                  Expanded(
                    child: ListView.builder(
                      itemCount: parkingData[selectedCity]?.length ?? 0,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> data = parkingData[selectedCity]![index];
                        String address = data['address'] ?? '';

                        // Function to open Google Maps for navigation
                        Future<void> openGoogleMaps() async {
                          String url = 'https://www.google.com/maps/search/?api=1&query=$address';
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            throw 'Could not launch Google Maps';
                          }
                        }

                        return GestureDetector(
                          onTap: openGoogleMaps, // Assign the openGoogleMaps function to the onTap property
                          child: Card(
                            elevation: 3,
                            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: ListTile(
                              title: Text(
                                data['name'] ?? '',
                                style: TextStyle(fontSize: 18),
                              ),
                              subtitle: Text(
                                address,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
