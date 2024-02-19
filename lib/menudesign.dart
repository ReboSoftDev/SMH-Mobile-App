import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'Menu/VMGuidline.dart';

void main() {
  runApp(MyButtonApp());
}

class MyButtonApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Button Demo',
      home: ButtonDemo(),
    );
  }
}

class ButtonDemo extends StatefulWidget {
  @override
  _ButtonDemoState createState() => _ButtonDemoState();
}

class _ButtonDemoState extends State<ButtonDemo> {
  bool buttonClickedToday = false;
  DateTime? _today;
  bool isButtonEnabled = false;

  // @override
  // void initState() {
  //   super.initState();
  //   initializeDate();
  // }
  //
  // Future<void> initializeDate() async {
  //   print("hi.....1");
  //   HttpClient client = HttpClient(context: await globalContext);
  //   client.badCertificateCallback =
  //       (X509Certificate cert, String host, int port) => false;
  //   IOClient ioClient = IOClient(client);
  //   // make an HTTP GET request to fetch the DateTime value from the Flask API
  //   ioClient.get(Uri.parse('https://smh-app.trent-tata.com/flask/date')).then((response) {
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       print("hi.....2");
  //       print(data);
  //       _today = DateTime.parse(data['date']); // parse the DateTime value from the response
  //     } else {
  //       _today = DateTime.now();
  //       print("hi.....3");// fallback to DateTime.now() if the API call fails
  //     }
  //
  //     // check if button was clicked today
  //     getLastButtonClickedDateFromSharedPreferences().then((lastButtonClicked) {
  //       if (lastButtonClicked == null || !_isSameDay(_today!, lastButtonClicked)) {
  //         // button not clicked today, reset variable
  //         setState(() {
  //           buttonClickedToday = false;
  //           isButtonEnabled = _isButtonEnabled(); // enable/disable the button based on time
  //         });
  //       } else {
  //         // button clicked today, disable it
  //         setState(() {
  //           buttonClickedToday = true;
  //           isButtonEnabled = false; // disable the button
  //         });
  //       }
  //     });
  //   });
  // }

// rest of the code






  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    print(_today);

    // check if button was clicked today
    getLastButtonClickedDateFromSharedPreferences().then((lastButtonClicked) {
      if (lastButtonClicked == null || !_isSameDay(_today!, lastButtonClicked)) {
        // button not clicked today, reset variable
        setState(() {
          buttonClickedToday = false;
          isButtonEnabled = _isButtonEnabled(); // enable/disable the button based on time
        });
      } else {
        // button clicked today, disable it
        setState(() {
          buttonClickedToday = true;
          isButtonEnabled = false; // disable the button
        });
      }
    });
  }

  Future<DateTime?> getLastButtonClickedDateFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? lastButtonClickedTimestamp = prefs.getInt('lastButtonClickedTimestamp');
    if (lastButtonClickedTimestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(lastButtonClickedTimestamp);
    } else {
      return null;
    }
  }

  Future<void> setLastButtonClickedDateInSharedPreferences(DateTime date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('lastButtonClickedTimestamp', date.millisecondsSinceEpoch);
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  bool _isButtonEnabled() {
    final now = DateTime.now();
    final morningStart = DateTime(now.year, now.month, now.day, 10);
    final morningEnd = DateTime(now.year, now.month, now.day, 11);
    final eveningStart = DateTime(now.year, now.month, now.day, 22);
    final eveningEnd = DateTime(now.year, now.month, now.day,23);

    if ((now.isAfter(morningStart) && now.isBefore(morningEnd)) ||
        (now.isAfter(eveningStart) && now.isBefore(eveningEnd))) {
      return true;
    } else {
      return false;
    }
  }

  void _onButtonClicked() {
    // check if the button has already been clicked today
    if (buttonClickedToday) {
      return; // do nothing
    }

    // button clicked for the first time today
    setState(() {
      buttonClickedToday = true;
      isButtonEnabled = false; // disable the button
    });

    // store the current date as the last button clicked date
    setLastButtonClickedDateInSharedPreferences(_today!);

    // perform button action
    print("Button clicked!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Button Demo'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: isButtonEnabled ? _onButtonClicked : null,
          child: Text("Click me!"),
        ),


      ),
    );
  }
}




// class MyButtonApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Button Demo',
//       home: ButtonDemo(),
//     );
//   }
// }
//
// class ButtonDemo extends StatefulWidget {
//   @override
//   _ButtonDemoState createState() => _ButtonDemoState();
// }
//
// class _ButtonDemoState extends State<ButtonDemo> {
//   bool buttonClickedToday = false;
//   DateTime? _today;
//   bool isButtonEnabled = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _today = DateTime.now();
//
//     // check if button was clicked today
//     getLastButtonClickedDateFromSharedPreferences().then((lastButtonClicked) {
//       if (lastButtonClicked == null || !_isSameDay(_today!, lastButtonClicked)) {
//         // button not clicked today, reset variable
//         setState(() {
//           buttonClickedToday = false;
//           isButtonEnabled = true; // enable the button
//         });
//       } else {
//         // button clicked today, disable it
//         setState(() {
//           buttonClickedToday = true;
//           isButtonEnabled = false; // disable the button
//         });
//       }
//     });
//   }
//
//   Future<DateTime?> getLastButtonClickedDateFromSharedPreferences() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     int? lastButtonClickedTimestamp = prefs.getInt('lastButtonClickedTimestamp');
//     if (lastButtonClickedTimestamp != null) {
//       return DateTime.fromMillisecondsSinceEpoch(lastButtonClickedTimestamp);
//     } else {
//       return null;
//     }
//   }
//
//   Future<void> setLastButtonClickedDateInSharedPreferences(DateTime date) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setInt('lastButtonClickedTimestamp', date.millisecondsSinceEpoch);
//   }
//
//   bool _isSameDay(DateTime d1, DateTime d2) {
//     return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
//   }
//
//   void _onButtonClicked() {
//     // check if the button has already been clicked today
//     if (buttonClickedToday) {
//       return; // do nothing
//     }
//
//     // button clicked for the first time today
//     setState(() {
//       buttonClickedToday = true;
//       isButtonEnabled = false; // disable the button
//     });
//
//     // store the current date as the last button clicked date
//     setLastButtonClickedDateInSharedPreferences(_today!);
//
//     // perform button action
//     print("Button clicked!");
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Button Demo'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: isButtonEnabled ? _onButtonClicked : null,
//           child: Text("Click me!"),
//         ),
//       ),
//     );
//   }
// }
//









//


