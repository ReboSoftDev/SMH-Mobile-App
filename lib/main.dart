// import 'package:alice/alice.dart';
import 'package:flutter/material.dart';
import 'package:sample/CityManager/HomeMenuCityManager.dart';
import 'package:sample/ClusterManager/HomeMenuClusterManager.dart';
import 'package:sample/HomeMenu.dart';
import 'package:sample/Menu/Login.dart';
import 'package:sample/SeniorManager/HomeMenuBusinessHead.dart';
import 'package:sample/constant.dart';
import 'package:sample/homeclass.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Alice alice = Alice();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool loggedIn = prefs.getBool('Logged') ?? false;
  final bool loggedCluster = prefs.getBool('LoggedCluster') ?? false;
  final bool loggedCity = prefs.getBool('LoggedCity') ?? false;
  final bool loggedSenior = prefs.getBool('LoggedSenior') ?? false;
  final String? storedUserId = prefs.getString('store');
  final String? usernameValue = prefs.getString('usernameValue');
  final String? fname = prefs.getString('first_name');
  final String? lname = prefs.getString('last_name');


   runApp(MyApp(loggedIn: loggedIn,stid: storedUserId.toString(), loggedCluster: loggedCluster, fname: fname.toString(),
   lname:lname.toString(), usernameValue: usernameValue.toString(),
   loggedCity:loggedCity,loggedSenior:loggedSenior));
}

class MyApp extends StatefulWidget {
  final bool loggedIn,loggedCluster,loggedCity,loggedSenior;
  final String stid,fname,lname, usernameValue;

  const MyApp({Key? key, required this.loggedIn, required this.stid, required this.loggedCluster, required this.fname,  required this.lname,required this.usernameValue,
    required this. loggedCity, required this. loggedSenior}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // navigatorKey: alice.getNavigatorKey(),
      title: 'VMMOBAPP',
      theme: ThemeData(
          primaryColor: kPrimaryColor,
          scaffoldBackgroundColor: Colors.white,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              primary: kPrimaryColor,
              shape: const StadiumBorder(),
              maximumSize: const Size(double.infinity, 56),
              minimumSize: const Size(double.infinity, 56),
            ),
          ),
            inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: kPrimaryLightColor,
            iconColor: kPrimaryColor,
            prefixIconColor: kPrimaryColor,
            contentPadding: EdgeInsets.symmetric(horizontal: defaultPadding, vertical: defaultPadding),
              border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              borderSide: BorderSide.none,
            ),
          )),
        home: (){
        if (widget.loggedIn) {
          return homeClass(stid: widget.stid);
           // HomeMenu(stid: widget.stid);
        }
          if (widget.loggedCity) {
            return HomeMenuCityManager(
              username: widget.usernameValue,
              fname: widget.fname,
              lname: widget.lname,
            );
          } else if (widget.loggedCluster) {
            return HomeMenuClusterManager(
              username: widget.usernameValue,
              fname: widget.fname,
              lname: widget.lname,
            );
          } else if (widget.loggedSenior) {
            return  HomeMenuBusinessHead(
              lname: widget.lname,
              fname: widget.fname,
              username: widget.usernameValue,
            );
          }
          else {
          return const AuthPage();
        }
      }(),
    );
  }
}






