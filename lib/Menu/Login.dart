
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sample/homeclass.dart';
import 'dart:convert';
import '../AppColors.dart';
import '../CityManager/HomeMenuCityManager.dart';
import '../ClusterManager/HomeMenuClusterManager.dart';
import '../HomeMenu.dart';
import '../SeniorManager/HomeMenuBusinessHead.dart';
import 'package:shared_preferences/shared_preferences.dart';



class AuthPage extends StatefulWidget {
  const AuthPage({Key? key,}) : super(key: key);

  @override
  _AuthPageState createState() => _AuthPageState();
}


class _AuthPageState extends State<AuthPage> {


  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  final myController_Username = TextEditingController();
  final myController_Password = TextEditingController();
  String isenable = '1';
  String St_Man = 'Store Manager';
  String Ct_Man = 'City Manager';
  String Cl_Man = 'Cluster Manager';
  String Sr_Man = 'Senior Manager';
  String? Storeid;
  String? last_name;
  int? storeId;
  String? first_name;


  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: Center(
      child: SingleChildScrollView(
        reverse: true,
        padding: EdgeInsets.all(32),
        child: Column(
          children: <Widget>[
            buildLogo(),
            const SizedBox(height: 32),
            buildUsernameField(),
            const SizedBox(height: 16),
            buildPasswordField(),
            const SizedBox(height: 32),
            buildLoginButton(),
          ],
        ),
      ),
    ),
  );

  Widget buildLogo() {
   return  Column(
     mainAxisAlignment: MainAxisAlignment.start,
     children: [

        Container(
          alignment: Alignment.topCenter,
         height: 280,
          child: Image.asset("assets/images/auth.png"),

        ),
       ],

    );
  }

  Widget buildUsernameField() {
    return Column(
      children: [
        Container(
          // margin: const EdgeInsets.only(top: 0,left: 0,right: 0,bottom: 20),
          child: TextFormField(
            autocorrect: true,
            textCapitalization: TextCapitalization.words,
            enableSuggestions: false,
            validator: (value) {},
            cursorColor: Colors.black,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(

              prefixIcon: const Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Icon(Icons.person, color: Colors.black,),
              ),
              hintStyle: TextStyle(color: Colors.black),
              filled: true,
              fillColor: Colors.white38,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 1, color: Colors.black),
                borderRadius: BorderRadius.circular(12),
              ),

              labelText: 'Username',
              isDense: true,

              labelStyle: const TextStyle(
                color: Colors.black,
              ),

            ),
            onSaved: (username) {},
            controller: myController_Username,


          ),
        )
      ],
    );
  }


  bool _isVisible = false;

  void updateStatus() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  Widget buildPasswordField() => TextFormField(

    validator: (value) {},
      cursorColor: Colors.black,
      style: const TextStyle(color: Colors.black),

    decoration: InputDecoration(
      prefixIcon: const Padding(
        padding: EdgeInsets.all(defaultPadding),
        child: Icon(Icons.lock,color: Colors.black,),
      ),
      hintStyle: TextStyle(color: Colors.black),
      filled: true,
      fillColor: Colors.white38,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(width: 1,color: Colors.black),
        borderRadius: BorderRadius.circular(12),
      ),
      suffixIcon: IconButton(
        onPressed: () => updateStatus(),
        icon:
        Icon(_isVisible ? Icons.visibility : Icons.visibility_off),
        color: Colors.black,
      ),

      labelText: 'Password' ,
      isDense: true,

      labelStyle: const TextStyle(
        color: Colors.black,
      ),
    ),
      obscureText: _isVisible ? false : true,
      onSaved: (password) {
      },
      controller: myController_Password
  );



  Widget buildLoginButton() {
    return Column(
      children: [
             DecoratedBox(

                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [
                            Colors.black,
                            Colors.black,

                            //add more colors
                          ]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.57), //shadow for button
                            blurRadius: 5) //blur radius of shadow
                      ]
                  ),
                  child:ElevatedButton(

                      style: ElevatedButton.styleFrom(
                        primary: Colors.transparent,
                        onSurface: Colors.transparent,
                        shadowColor: Colors.transparent,
                        minimumSize: Size(400, 0),
                        //make color or elevated button transparent
                      ),
                      onPressed: (){
                        fetchResults(myController_Username,myController_Password);

                      },
                      child: const Padding(
                        padding:EdgeInsets.only(
                          top: 18,
                          bottom: 18,
                        ),
                        child:Text("LOGIN",style: TextStyle(fontSize: 15),),
                      )
                  )
              ),


        // ),
      ],
  );

  }
    Future<void> fetchResults(myControllerUsername, myControllerPassword) async {

      try {
        // Your network code here

        HttpClient client = HttpClient(context: await globalContext);
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => false;
        IOClient ioClient = IOClient(client);
        final response = await ioClient.post(
            Uri.parse(
                "https://smh-app.trent-tata.com/flask/get_login_role_latest"),
            body: json.encode({
              "userid": myControllerUsername.text,
              "password": myControllerPassword.text
            }),
            headers: {
              "content-type": "application/json",
            });

        if (response.statusCode != 200) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("INCORRECT USERNAME OR PASSWORD!..."),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ));
        }

        var resultsJson = json.decode(response.body);
        if (resultsJson is List && resultsJson.isEmpty) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("INCORRECT USERNAME OR PASSWORD!..."),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ));
        }
        if (resultsJson[0]['id'] == null) {
          setState(() {
            storeId == 0;
            first_name = '';
            last_name = '';
          });
        }
        else {
          setState(() {
            storeId = resultsJson[0]['id'];
            last_name = resultsJson[0]['last_name'];
            first_name = resultsJson[0]['first_name'];
          });
        }

        String role = resultsJson[0]['role'];
        if (role == St_Man) {
          final String userId = storeId.toString();
          const bool success = true;
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('store', userId);
          await prefs.setBool('Logged', success);
          // ignore: use_build_context_synchronously
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return homeClass(stid: storeId.toString());
              },
            ),
          );
        }
        else if (role == Ct_Man) {
          final usernameValue = myControllerUsername.text;
          final String lname = last_name.toString();
          final String fname = first_name.toString();
          const bool success = true;
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('first_name', fname);
          await prefs.setString('last_name', lname);
          await prefs.setString('usernameValue', usernameValue);
          await prefs.setBool('LoggedCity', success);
          // ignore: use_build_context_synchronously
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return HomeMenuCityManager(
                  fname: first_name.toString(),
                  lname: last_name.toString(),
                  username: usernameValue,

                );
              },
            ),
          );
        }
        else if (role == Cl_Man) {
          final usernameValue = myControllerUsername.text;
          final String lname = last_name.toString();
          final String fname = first_name.toString();
          const bool success = true;
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('first_name', fname);
          await prefs.setString('last_name', lname);
          await prefs.setString('usernameValue', usernameValue);
          await prefs.setBool('LoggedCluster', success);
          // ignore: use_build_context_synchronously
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return HomeMenuClusterManager(
                  fname: first_name.toString(),
                  lname: last_name.toString(),
                  username: usernameValue,
                );
              },
            ),
          );
        }
        else if (role.toString() == Sr_Man) {
          final usernameValue = myControllerUsername.text;
          final String lname = last_name.toString();
          final String fname = first_name.toString();
          const bool success = true;
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('first_name', fname);
          await prefs.setString('last_name', lname);
          await prefs.setString('usernameValue', usernameValue);
          await prefs.setBool('LoggedSenior', success);
          // ignore: use_build_context_synchronously
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return HomeMenuBusinessHead(
                  fname: first_name.toString(),
                  lname: last_name.toString(),
                  username: usernameValue,
                );
              },
            ),
          );
        }
      }catch (e) {
        print('Error: $e');
      }
  }

  Future<SecurityContext> get globalContext async {
    final sslCert1 = await
    rootBundle.load('assets/starttrent.pem');
    SecurityContext sc = SecurityContext(withTrustedRoots: false);
    sc.setTrustedCertificatesBytes(sslCert1.buffer.asInt8List());
    return sc;
  }


}





