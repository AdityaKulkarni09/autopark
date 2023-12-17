import 'package:flutter/material.dart';
import 'package:automated_parking/utils/routes.dart';

class CheckVehiclePage extends StatelessWidget {
  final Color _customColor = Colors.purple.withOpacity(0.6);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _customColor,
        elevation: 2,
        title: Text("AutoPark"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 250,
            width: 250,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 5)
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, MyRoutes.exitScannerRoute);
                  },
                  child: Container(
                    width: 150,
                    height: 40,
                    color: _customColor,
                    child: Center(
                      child: Text(
                        "2 Wheeler",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  "or",
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, MyRoutes.exitScanner1Route);
                  },
                  child: Container(
                    width: 150,
                    height: 40,
                    color: _customColor,
                    child: Center(
                      child: Text(
                        "4 Wheeler",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
