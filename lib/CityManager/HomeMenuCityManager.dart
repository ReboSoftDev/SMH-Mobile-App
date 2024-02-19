import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Camera/CameraEquipmentDropdown.dart';
import '../CustomerFeedback/billingBarChart.dart';
import '../Menu/Login.dart';
import '../Menu/QRCodeGenerator.dart';
import '../Menu/StockQuery.dart';
import '../Menu/VMGuidline.dart';
import '../StoreManager/ComplianceReportHomemenu.dart';
import 'CityManagerCompliance/VMComplianceCityManager.dart';
import 'Feedback/cityBillingBarChart.dart';
import 'StockQuery.dart';



class HomeMenuCityManager extends StatefulWidget {
  const  HomeMenuCityManager ({Key? key,required this.username,  required this. fname,required this. lname }) : super(key: key);

  final String username;
  final String lname;
  final String fname;


  @override
  State<HomeMenuCityManager> createState() => _HomeMenuCityManagerState();
}
class _HomeMenuCityManagerState extends State<HomeMenuCityManager> {


  int currentPage = 0;
  String address = '';
  String city = '';
  String storeCode = '';

  @override
  void initState()  {
    super.initState();

  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop:() async{
        final value = await  showDialog<bool>(context: context, builder: (context){
          return AlertDialog(
            title: const Text("Exit"),
            content: const Text("Do you want to exit"),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  onPrimary: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  minimumSize: const Size(70, 35), //////// HERE
                ),
                child:const Text('No'),/// HERE
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  onPrimary: Colors.white,

                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                  minimumSize: const Size(70, 35), //////// HERE
                ),
                //return false when click on "NO"

                child:const Text('Yes'),/// HERE
              ),
            ],
          );
        });
        if(value!=null){
          return Future.value(value);
        }
        else{
          return Future.value(false);
        }
      },
      child:Scaffold(
        body: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * .45,
              decoration:  BoxDecoration(
                  color: Colors.grey.shade300
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(top: 20),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: PopupMenuButton<String>(
                          onSelected: (value) async {

                            if (value == 'option2') {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              await prefs.clear();
                              signOut();

                            }
                            else{
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => buildExitDialog(context),
                              );
                            }

                          },
                          itemBuilder: (BuildContext context) {
                            return <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'option1',
                                child: Row(
                                  children: [
                                    Icon(Icons.exit_to_app,color: Colors.black,),
                                    SizedBox(width: 8), // Add some space between icon and text
                                    Text('Exit',style: TextStyle(fontWeight: FontWeight.bold),),
                                  ],
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'option2',
                                child: Row(
                                  children: [
                                    Icon(Icons.logout,color: Colors.black,),
                                    SizedBox(width: 8), // Add some space between icon and text
                                    Text('Logout',style:TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),

                            ];
                          },
                          child: Container(
                            padding: const EdgeInsets.all(13),
                            height: 52,
                            width: 52,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: SvgPicture.asset("assets/menu.svg", color: Colors.black),
                          ),
                        ),
                      ),
                    ),


                    const Text("City Manager",
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),),
                    const SizedBox(height: 5,),
                    Text("${widget.fname}${widget.lname},",
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),),

                    const SizedBox(height: 35,),


                    Expanded(
                      child: GridView.count(
                        padding: const EdgeInsets.all(5),
                        crossAxisCount: 1,
                        childAspectRatio: 5,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 10,
                        children: <Widget>[
                          GestureDetector(
                            onTap:(){
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return const VMGuideline(stid: '',);
                                  },
                                ),
                              );

                            },
                            child:Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(13),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3), // changes the position of the shadow
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 30,),
                                  Container(
                                    width: 40,  // Adjust the width as needed
                                    height: 40,  // Adjust the height as needed
                                    decoration: BoxDecoration(
                                      color: Colors.black,  // Set the color of the left box
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: SvgPicture.asset("assets/images/vm_guidline.svg",color: Colors.white,)
                                    ),
                                  ),
                                  const SizedBox(width: 20,),
                                  const Text("VM GUIDELINE",style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),)
                                ],
                              ),
                            ),
                          ),





                          GestureDetector(

                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return VMComplianceCitymanager(username: widget.username);
                                  },
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(13),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3), // changes the position of the shadow
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 30,),
                                  Container(
                                    width: 40,  // Adjust the width as needed
                                    height: 40,  // Adjust the height as needed
                                    decoration: BoxDecoration(
                                      color: Colors.black,   // Set the color of the left box
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: SvgPicture.asset("assets/images/compliance.svg",color: Colors.white,)
                                    ),
                                  ),
                                  const SizedBox(width: 20,),
                                  const Text("VM COMPLIANCE",style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),)
                                ],
                              ),
                            ),
                          ),


                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return StockQueryCity(username:widget.username,);
                                  },
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(13),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3), // changes the position of the shadow
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 30,),
                                  Container(
                                    width: 40,  // Adjust the width as needed
                                    height: 40,  // Adjust the height as needed
                                    decoration: BoxDecoration(
                                      color: Colors.black,   // Set the color of the left box
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: SvgPicture.asset("assets/images/stockcheck.svg",color: Colors.white,)
                                    ),
                                  ),
                                  const SizedBox(width: 20,),
                                  const Text("STOCK CHECK",style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),)
                                ],
                              ),
                            ),
                          ),




                          GestureDetector(
                            onTap: (){
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return CityBillingBar(stid: '',username: widget.username);
                                  },
                                ),
                              );
                            },
                            child:Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(13),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3), // changes the position of the shadow
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 30,),
                                  Container(
                                    width: 40,  // Adjust the width as needed
                                    height: 40,  // Adjust the height as needed
                                    decoration: BoxDecoration(
                                      color: Colors.black,  // Set the color of the left box
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: SvgPicture.asset("assets/images/customer_feedback.svg",color: Colors.white,)
                                    ),
                                  ),
                                  const SizedBox(width: 20,),
                                  const Text("VOICE OF CUSTOMER",style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),)
                                ],
                              ),
                            ),
                          ),
                        ],
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

  // Function to handle sign-out
  void signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove('first_name');
    await prefs.remove('last_name');
    await prefs.remove('usernameValue');
    await prefs.remove('LoggedCity');

    // ignore: use_build_context_synchronously
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return const AuthPage(); // Replace SignInScreen with your actual sign-in screen
        },
      ),
    );
  }
}





Widget buildExitDialog(context) {
  return  AlertDialog(
      title: const Text("Exit App", style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
      content: const Text('Do you want to exit an App?'),
      actions:[
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: ElevatedButton.styleFrom(
            primary: Colors.black,
            onPrimary: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            minimumSize: const Size(70, 35), //////// HERE
          ),
          //return false when click on "NO"
          child:const Text('No'),/// HERE
        ),

        ElevatedButton(
          onPressed: () {
            SystemNavigator.pop();
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.black,
            onPrimary: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
            minimumSize: const Size(70, 35), //////// HERE
          ),
          child:const Text('Yes'),/// HERE
        )
      ]
  );
}










