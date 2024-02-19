//
// import 'package:flutter/material.dart';
// import 'package:sample/HomeMenu.dart';
// import 'package:sample/Menu/Login.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({Key? key}) : super(key: key);
//
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Add any initialization logic here
//     // Example: Loading data, initializing variables, etc.
//     navigateToNextScreen();
//   }
//
//   void navigateToNextScreen() async {
//     // Simulate a delay for the splash screen
//      await Future.delayed(const Duration(microseconds: 0));
//
//     final SharedPreferences preferences = await SharedPreferences.getInstance();
//     final bool isLoggedIn = preferences.getBool('isLoggedIn') ?? false;
//     final String? userId = preferences.getString('userId');
//
//     if (isLoggedIn && userId != null) {
//       // User is logged in, navigate to HomeMenu
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => HomeMenu(stid: userId),
//         ),
//       );
//     } else {
//       // User is not logged in, navigate to AuthPage
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => AuthPage(
//             onLoginSuccess: (isLoggedIn, userId) {
//               preferences.setBool('isLoggedIn', isLoggedIn);
//               preferences.setString('userId', userId);
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => HomeMenu(stid: userId),
//                 ),
//               );
//             },
//           ),
//         ),
//       );
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black, // Set the background color to black
//       body:
//       Center(
//           child: Image.asset('assets/ZudioLogo.png'),
//
//
//       ),
//     );
//   }
//
// }
