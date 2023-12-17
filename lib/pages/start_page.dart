import 'package:flutter/material.dart';
import 'package:automated_parking/utils/routes.dart';

class StartPage extends StatefulWidget {
  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final Color customColor = Colors.purple.withOpacity(0.6);
  @override
  Widget build(BuildContext context) {
    return Material(
        child: Container(
          decoration: BoxDecoration(
            color: customColor,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    width: 280,
                    height: 45,
                    child: Center(
                      child: Text(
                        "AutoPark",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                        ),
                      ),
                    ),
                  ),
                ),
                Text("Making your daily life easier!"),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.asset(
                    'assets/images/carwhite.png',
                    width: 180,
                    height: 180,
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(
                  height: 400,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, MyRoutes.userLoginRoute);
                  },
                  child: Text(
                    "Let's Go",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all<double?>(5.0),
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  ),
                ),
                SizedBox(height: 5),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, MyRoutes.adminLoginRoute);
                  },
                  child: Text(
                    "Admin Login",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all<double?>(5.0),
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}
