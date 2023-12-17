import 'package:automated_parking/pages/admin_pages/admin_home_page.dart';
import 'package:automated_parking/pages/admin_pages/check_vehicle_page.dart';
import 'package:automated_parking/pages/admin_pages/entry_scanner_page.dart';
import 'package:automated_parking/pages/admin_pages/exit_scanner1_page.dart';
import 'package:automated_parking/pages/admin_pages/exit_scanner_page.dart';
import 'package:automated_parking/pages/admin_pages/hardware_control_page.dart';
import 'package:automated_parking/pages/user_pages/user_history_page.dart';
import 'package:automated_parking/pages/user_pages/user_home_page.dart';
import 'package:automated_parking/pages/user_pages/user_login_page.dart';
import 'package:automated_parking/pages/user_pages/user_nearbyparking_page.dart';
import 'package:automated_parking/pages/user_pages/user_profile_page.dart';
import 'package:automated_parking/pages/user_pages/user_qr_page.dart';
import 'package:automated_parking/pages/user_pages/user_reservation_page.dart';
import 'package:automated_parking/pages/user_pages/user_signup_page.dart';
import 'package:automated_parking/pages/start_page.dart';
import 'package:automated_parking/pages/user_pages/user_support_page.dart';
import 'package:automated_parking/pages/user_pages/user_wallet_page.dart';
import 'package:automated_parking/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:automated_parking/pages/admin_pages/admin_login_page.dart';
import 'package:automated_parking/pages/admin_pages/admin_choices_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Color customColor = Colors.blue.withOpacity(0.6);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      theme: ThemeData(
        fontFamily: GoogleFonts.lato().fontFamily,
        primaryColor: customColor,
      ),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        if (settings.name == MyRoutes.userHomeRoute) {
          final Map<String, dynamic>? args =
              settings.arguments as Map<String, dynamic>? ?? {};
          final String userId = args?['userId'] as String? ?? '';
          final String fullName = args?['fullName'] as String? ?? '';
          final String email = args?['email'] as String? ?? '';
          final double walletBalance = args?['walletBalance'] as double? ?? 0.0;

          return MaterialPageRoute(
            builder: (context) => UserHomePage(
              arguments: {
                'userId': userId,
                'fullName': fullName,
                'email': email,
                'walletBalance': walletBalance,
              },
            ),
          );
        } else if (settings.name == MyRoutes.adminHomeRoute) {
          return MaterialPageRoute(builder: (context) => AdminHomePage());
        } else if (settings.name == MyRoutes.adminLoginRoute) {
          return MaterialPageRoute(builder: (context) => AdminLoginPage());
        } else if (settings.name == MyRoutes.userLoginRoute) {
          return MaterialPageRoute(builder: (context) => UserLoginPage());
        } else if (settings.name == MyRoutes.userSignupRoute) {
          return MaterialPageRoute(builder: (context) => UserSignupPage());
        } else if (settings.name == MyRoutes.adminChoicesRoute) {
          return MaterialPageRoute(builder: (context) => AdminChoicesPage());
        } else if (settings.name == MyRoutes.checkVehicleRoute) {
          return MaterialPageRoute(builder: (context) => CheckVehiclePage());
        }else if (settings.name == MyRoutes.hardwareControlRoute) {
          return MaterialPageRoute(builder: (context) => HardwareControlPage());
        } else if (settings.name == MyRoutes.userQrRoute) {
          final Map<String, dynamic>? args =
              settings.arguments as Map<String, dynamic>? ?? {};
          return MaterialPageRoute(
            builder: (context) => UserQrPage(userId: args?['userId'] as String ?? ''),
          );
        } else if (settings.name == MyRoutes.entryScannerRoute) {
          return MaterialPageRoute(builder: (context) => EntryScannerPage());
        } else if (settings.name == MyRoutes.exitScannerRoute) {
          return MaterialPageRoute(builder: (context) => ExitScannerPage());
        } else if (settings.name == MyRoutes.exitScanner1Route) {
          return MaterialPageRoute(builder: (context) => ExitScanner1Page());
        } else if (settings.name == MyRoutes.userProfileRoute) {
          return MaterialPageRoute(builder: (context) => UserProfilePage());
        } else if (settings.name == MyRoutes.userSupportRoute) {
          return MaterialPageRoute(builder: (context) => UserSupportPage());
        } else if (settings.name == MyRoutes.userWalletRoute) {
          final Map<String, double>? args = settings.arguments as Map<String, double>? ?? {};
          final double walletBalance = args?['walletBalance'] ?? 0.0;
          return MaterialPageRoute(
            builder: (context) => UserWalletPage(walletBalance: walletBalance),
          );
        } else if (settings.name == MyRoutes.userHistoryRoute) {
          final Map<String, dynamic>? args =
              settings.arguments as Map<String, dynamic>? ?? {};
          final String userId = args?['userId'] as String ?? '';
          return MaterialPageRoute(
            builder: (context) => UserHistoryPage(userId: userId),
          );
        } else if (settings.name == MyRoutes.userNearbyParkingRoute) {
          final Map<String, dynamic>? args =
              settings.arguments as Map<String, dynamic>? ?? {};
          final String userId = args?['userId'] as String ?? '';
          return MaterialPageRoute(
            builder: (context) => UserNearbyParkingPage(userId: userId),
          );
        } else if (settings.name == MyRoutes.userReservationRoute) {
          return MaterialPageRoute(builder: (context) => UserReservationPage());
        }
        return MaterialPageRoute(builder: (context) => StartPage());
      },
    );
  }
}
