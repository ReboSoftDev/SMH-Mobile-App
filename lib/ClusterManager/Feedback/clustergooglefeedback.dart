import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';
import 'package:intl/intl.dart';
//import 'package:sample_2/CustomerFeedback/BillingFeedBack.dart';
//import 'package:sample_2/CustomerFeedback/FeedBackHome.dart';
//import 'package:sample_2/CustomerFeedback/TrialRoomFeedBack.dart';


import 'clusterBillingBarChart.dart';
//import 'feedbacksummary.dart';
import 'clusterBillingFeedBack.dart';
import 'clusterFeedBackHome.dart';
import 'clusterGoogleReviews.dart';
import 'clusterTrialRoomFeedBack.dart';

class clustergooglefeedback extends StatefulWidget {
  final String username;

  const clustergooglefeedback({Key? key, this. stId, required this.username, required this.newSelectedYear, required this.newSelectedMonth, required this.newStoreCode,}) : super(key: key);
  final String? stId;
  final int newSelectedYear;
  final int newSelectedMonth;
  final String newStoreCode;
  @override
  State<clustergooglefeedback> createState() => _HomePageState();
}
// DateTime currentDate = DateTime.now();
// String selectedMonth = DateFormat('MMMM').format(currentDate);
class _HomePageState extends State<clustergooglefeedback> {

  List<dynamic> data = [];
  List<String> storecodes = [];
  String? selectedStoreCode;
  List<String> storeNames = [];

  String selectedTypeOfFeedback = "GOOGLE";
  int selectedYear = DateTime.now().year;

  String? total_review_1;
  String? total_review_2;
  String? total_review_3;
  String? total_review_4;
  String? total_review_5;
  double percentage_review_1 = 0,percentage_1 =0;
  double percentage_review_2 = 0,percentage_2 =0;
  double percentage_review_3 = 0,percentage_3 =0;
  double percentage_review_4 = 0,percentage_4 =0;
  double percentage_review_5 = 0,percentage_5 =0;
  String? total_review_all;
  String? total_review_bad;
  String? total_review_good,TotalPercentage = '0';
  double Total = 0;
  int selectedMonth = DateTime.now().month;
  String? storecode;
  String? StoreCode;

  String get username => widget.username;

  @override
  void initState() {
    getWhichStore();

    fetchStores();

    super.initState();
    selectedYear = widget.newSelectedYear;
    selectedMonth = widget.newSelectedMonth;
    selectedStoreCode = widget.newStoreCode;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> fetchStores() async {
    print('USERNAME: ${widget.username}');
    HttpClient client = HttpClient();
    client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);
    final response = await ioClient.post(
      Uri.parse('https://smh-app.trent-tata.com/flask/get_cluster_store_codes'),
      body: json.encode({"user_id": widget.username}),
      headers: {"content-type": "application/json",},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<String> names = data.map((dynamic item) => item['code'].toString()).toList();
      names.sort();
      setState(() {
        storeNames = names; // Update the storeNames list with the fetched values
      });
    } else {
      throw Exception('Failed to load store names');
    }
    fetchGoogle();
  }

  Future <void> getWhichStore()async {
    HttpClient client = HttpClient();
    client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);
    final storeResponse = await ioClient.post(
      Uri.parse("https://smh-app.trent-tata.com/flask/get_which_store"),
      body: json.encode({"storeId": widget.stId.toString()}),
      headers: {"content-type": "application/json",},
    );
    var storeJson = json.decode(storeResponse.body);
    storecode = storeJson[0]['code'];
    if(storeJson[0]['code'] == null)
    {
      setState(() {
        StoreCode = '';
      });
    }
    else{
      setState(() {
        StoreCode = storecode!;
      });
    }
    print("storeCode.......$storecode");

  }


  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
          appBar: AppBar(title: const Text(
              'Voice of Customer Google Table', style: TextStyle(fontSize: 16,color: Colors.white)),
            automaticallyImplyLeading: false,
            leading: IconButton(
                onPressed: () {
                  // Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back_ios,color: Colors.white,)),

            titleSpacing: 00.0,
            centerTitle: true,
            toolbarHeight: 50.2,
            toolbarOpacity: 0.8,
            backgroundColor: Colors.black,
            elevation: 0.00,
          ),
          body:Column(
            children:  [
              Container(
                padding: const EdgeInsets.only(left:30, bottom: 0, right: 30, top:0),
                // padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      alignment: Alignment.center,
                      child: StoreCode == null
                          ? const Text('', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),)
                          : Text(StoreCode!, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                    DropdownButton<String>(
                      value: selectedStoreCode,
                      hint: const Text('Select a Store'),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedStoreCode = newValue;
                          fetchGoogle();
                          fetchStores();
                        });
                      },
                      items: storeNames.map((String storeName) {
                        return DropdownMenuItem<String>(
                          value: storeName,
                          child: Text(storeName),
                        );
                      }).toList(),
                    ),

                    DropdownButton<int>(
                      value: selectedYear,
                      items: <int>[selectedYear - 2, selectedYear - 1, selectedYear, selectedYear + 1, selectedYear + 2].map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                      onChanged: (int? value) {
                        setState(() {
                          selectedYear = value!;
                          print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>$selectedYear");
                          fetchGoogle();
                          fetchStores();
                        });
                      },
                    ),
                    DropdownButton<int>(
                      value: selectedMonth,
                      items: List.generate(12, (index) {
                        final monthName = DateFormat('MMMM').format(DateTime(DateTime.now().year, index + 1));
                        return DropdownMenuItem<int>(
                          value: index + 1,
                          child: Text(monthName.toUpperCase()), // Display month name in uppercase
                        );
                      }),
                      onChanged: (int? value) {
                        setState(() {
                          selectedMonth = value!;
                          fetchGoogle();
                          fetchStores();
                        });
                      },
                    ),



                    DropdownButton<String>(
                      value: selectedTypeOfFeedback,
                      items: ["BILLING","TRIAL ROOM","GOOGLE"].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          selectedTypeOfFeedback = value!;
                          fetchGoogle();
                          fetchStores();
                          if (selectedTypeOfFeedback == "BILLING" ){
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (
                                  context) =>  ClusterBillingFeedback(
                                stId: widget.stId,
                                username: username,
                                newSelectedYear: selectedYear,
                                newSelectedMonth: selectedMonth,
                                newStoreCode: selectedStoreCode.toString(),),
                              ),
                            );
                          }
                          else if (selectedTypeOfFeedback == "TRIAL ROOM")
                          {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (
                                  context) =>  ClusterTrialRoomFeedback(
                                stId: widget.stId,
                                username: username,
                                newSelectedYear: selectedYear,
                                newSelectedMonth: selectedMonth,
                                newStoreCode: selectedStoreCode.toString(),
                              ),
                              ),
                            );
                          }
                        });
                      },
                    ),
                    // Container(
                    //     width: 120,
                    //     height: 40,
                    //     child: ElevatedButton(
                    //       onPressed: () {
                    //         Navigator.push(
                    //           context,
                    //           MaterialPageRoute(builder: (context) =>  ClusterBillingBar(stid:widget.stId, username: username,)),
                    //         );
                    //       },
                    //       style: ElevatedButton.styleFrom(
                    //         padding: EdgeInsets.all(10),  // Set the padding for the button
                    //         backgroundColor: Colors.black, // Set the background color for the button
                    //       ),
                    //       child: Text('Graph'),
                    //     )
                    // ),
                  ],
                ),
              ),

              FittedBox(
                  fit: BoxFit.fill,
                  child: DataTable(
                    dataRowHeight: 50,
                    headingRowHeight: 50,
                    columnSpacing: 100,
                    headingRowColor:
                    MaterialStateColor.resolveWith((states) =>
                    Colors.black45),
                    columns: const [
                      DataColumn(label: Text('Ratings',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.white),)),
                      DataColumn(label: Text('Total Reviews',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.white),)),
                      DataColumn(label: Text('Total Good\nReviews',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.white),)),
                      DataColumn(label: Text('Total Bad\nReviews',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.white),)),
                      DataColumn(label: Text('Percentage',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.white,),)),

                    ], rows: const [],
                  )

              ),
              (data.isEmpty) ?
              const Center(
                  child: Text('Data is empty'))
                  : Expanded(child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  headingRowHeight: 0,
                  columnSpacing: 70,
                  columns: const [
                    DataColumn(label: Text('Ratings',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.white),)),
                    DataColumn(label: Text('Total Reviews',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.white),)),
                    DataColumn(label: Text('Total Good\nReviews',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.white),)),
                    DataColumn(label: Text('Total Bad\nReviews',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.white),)),
                    DataColumn(label: Text('Percentage',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.white,),)),

                  ],
                  rows: [
                    DataRow(cells: [
                      DataCell(
                          const Center(
                              child:Text("1", textAlign: TextAlign.center, style:  TextStyle(fontSize: 15),)
                          ),
                          onTap:(){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClusterGoogleReviews(storeCode:selectedStoreCode.toString(),year:selectedYear.toString(),month:selectedMonth.toString(),rating:'1',username: username),
                              ),
                            );
                          }
                      ),
                      DataCell(Center(
                          child:Text(total_review_1.toString(), textAlign: TextAlign.center, style:  const TextStyle(fontSize: 15),)),
                          onTap:(){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClusterGoogleReviews(storeCode:selectedStoreCode.toString(),year:selectedYear.toString(),month:selectedMonth.toString(),rating:'1',username: username),
                              ),
                            );
                          }
                      ),
                      DataCell(Center(child:Text("0", textAlign: TextAlign.center, style:  TextStyle(fontSize: 15),)),
                          onTap:(){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClusterGoogleReviews(storeCode:selectedStoreCode.toString(),year:selectedYear.toString(),month:selectedMonth.toString(),rating:'1',username: username),
                              ),
                            );
                          }),
                      DataCell(Center(child:Text(total_review_1.toString(), textAlign: TextAlign.center, style:  const TextStyle(fontSize: 15),)),
                          onTap:(){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClusterGoogleReviews(storeCode:selectedStoreCode.toString(),year:selectedYear.toString(),month:selectedMonth.toString(),rating:'1',username: username),
                              ),
                            );
                          }),
                      DataCell(Center(child:Text(percentage_1.toString(), textAlign: TextAlign.center, style:  const TextStyle(fontSize: 15),)),
                          onTap:(){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClusterGoogleReviews(storeCode:selectedStoreCode.toString(),year:selectedYear.toString(),month:selectedMonth.toString(),rating:'1',username: username),
                              ),
                            );
                          }),


                    ]),
                    DataRow(cells: [
                      DataCell(Center(child:Text("2", textAlign: TextAlign.center, style:  TextStyle(fontSize: 15),)),
                          onTap:(){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClusterGoogleReviews(storeCode:selectedStoreCode.toString(),year:selectedYear.toString(),month:selectedMonth.toString(),rating:'2',username: username),
                              ),
                            );
                          }
                      ),
                      DataCell(Center(child:Text(total_review_2.toString(), textAlign: TextAlign.center, style:  const TextStyle(fontSize: 15),)),
                          onTap:(){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClusterGoogleReviews(storeCode:selectedStoreCode.toString(),year:selectedYear.toString(),month:selectedMonth.toString(),rating:'2',username: username),
                              ),
                            );
                          }),
                      DataCell(Center(child:Text("0", textAlign: TextAlign.center, style:  TextStyle(fontSize: 15),)),
                          onTap:(){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClusterGoogleReviews(storeCode:selectedStoreCode.toString(),year:selectedYear.toString(),month:selectedMonth.toString(),rating:'2',username: username),
                              ),
                            );
                          }),
                      DataCell(Center(child:Text(total_review_2.toString(), textAlign: TextAlign.center, style:  const TextStyle(fontSize: 15),)),
                          onTap:(){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClusterGoogleReviews(storeCode:selectedStoreCode.toString(),year:selectedYear.toString(),month:selectedMonth.toString(),rating:'2',username: username),
                              ),
                            );
                          }),
                      DataCell(Center(child:Text(percentage_2.toString(), textAlign: TextAlign.center, style:  const TextStyle(fontSize: 15),)),
                          onTap:(){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClusterGoogleReviews(storeCode:selectedStoreCode.toString(),year:selectedYear.toString(),month:selectedMonth.toString(),rating:'2',username: username),
                              ),
                            );
                          }),

                    ]),
                    DataRow(cells: [
                      DataCell(Center(child:Text("3", textAlign: TextAlign.center, style:  TextStyle(fontSize: 15),)),
                          onTap:(){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClusterGoogleReviews(storeCode:selectedStoreCode.toString(),year:selectedYear.toString(),month:selectedMonth.toString(),rating:'3',username: username),
                              ),
                            );
                          }),
                      DataCell(Center(child:Text(total_review_3.toString(), textAlign: TextAlign.center, style:  const TextStyle(fontSize: 15),)),
                          onTap:(){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClusterGoogleReviews(storeCode:selectedStoreCode.toString(),year:selectedYear.toString(),month:selectedMonth.toString(),rating:'3',username: username),
                              ),
                            );
                          }),
                      DataCell(Center(child:Text("0", textAlign: TextAlign.center, style:  TextStyle(fontSize: 15),)),
                          onTap:(){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClusterGoogleReviews(storeCode:selectedStoreCode.toString(),year:selectedYear.toString(),month:selectedMonth.toString(),rating:'3',username: username),
                              ),
                            );
                          }),
                      DataCell(Center(child:Text(total_review_3.toString(), textAlign: TextAlign.center, style:  const TextStyle(fontSize: 15),)),
                          onTap:(){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClusterGoogleReviews(storeCode:selectedStoreCode.toString(),year:selectedYear.toString(),month:selectedMonth.toString(),rating:'3',username: username),
                              ),
                            );
                          }),
                      DataCell(Center(child:Text(percentage_3.toString(), textAlign: TextAlign.center, style:  const TextStyle(fontSize: 15),)),
                          onTap:(){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClusterGoogleReviews(storeCode:selectedStoreCode.toString(),year:selectedYear.toString(),month:selectedMonth.toString(),rating:'3',username: username),
                              ),
                            );
                          }),

                    ]),
                    DataRow(cells: [
                      DataCell(Center(child:Text("4", textAlign: TextAlign.center, style:  TextStyle(fontSize: 15),)),
                          onTap:(){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClusterGoogleReviews(storeCode:selectedStoreCode.toString(),year:selectedYear.toString(),month:selectedMonth.toString(),rating:'4',username: username),
                              ),
                            );
                          }),
                      DataCell(Center(child:Text(total_review_4.toString(), textAlign: TextAlign.center, style:  const TextStyle(fontSize: 15),)),
                          onTap:(){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClusterGoogleReviews(storeCode:selectedStoreCode.toString(),year:selectedYear.toString(),month:selectedMonth.toString(),rating:'4',username: username),
                              ),
                            );
                          }),
                      DataCell(Center(child:Text(total_review_4.toString(), textAlign: TextAlign.center, style:  const TextStyle(fontSize: 15),)),
                          onTap:(){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClusterGoogleReviews(storeCode:selectedStoreCode.toString(),year:selectedYear.toString(),month:selectedMonth.toString(),rating:'4',username: username),
                              ),
                            );
                          }),
                      DataCell(Center(child:Text("0", textAlign: TextAlign.center, style:  TextStyle(fontSize: 15),)),
                          onTap:(){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClusterGoogleReviews(storeCode:selectedStoreCode.toString(),year:selectedYear.toString(),month:selectedMonth.toString(),rating:'4',username: username),
                              ),
                            );
                          }),
                      DataCell(Center(child:Text(percentage_4.toString(), textAlign: TextAlign.center, style:  const TextStyle(fontSize: 15),)),
                          onTap:(){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClusterGoogleReviews(storeCode:selectedStoreCode.toString(),year:selectedYear.toString(),month:selectedMonth.toString(),rating:'4',username: username),
                              ),
                            );
                          }),

                    ]),

                    DataRow(cells: [
                      DataCell(Center(child:Text("5", textAlign: TextAlign.center, style:  TextStyle(fontSize: 15),)),
                          onTap:(){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClusterGoogleReviews(storeCode:selectedStoreCode.toString(),year:selectedYear.toString(),month:selectedMonth.toString(),rating:'5',username: username),
                              ),
                            );
                          }),
                      DataCell(Center(child:Text(total_review_5.toString(), textAlign: TextAlign.center, style:  const TextStyle(fontSize: 15),)),
                          onTap:(){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClusterGoogleReviews(storeCode:selectedStoreCode.toString(),year:selectedYear.toString(),month:selectedMonth.toString(),rating:'5',username: username),
                              ),
                            );
                          }),
                      DataCell(Center(child:Text(total_review_5.toString(), textAlign: TextAlign.center, style:  const TextStyle(fontSize: 15),)),
                          onTap:(){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClusterGoogleReviews(storeCode:selectedStoreCode.toString(),year:selectedYear.toString(),month:selectedMonth.toString(),rating:'5',username: username),
                              ),
                            );
                          }),
                      DataCell(Center(child:Text("0", textAlign: TextAlign.center, style:  TextStyle(fontSize: 15),)),
                          onTap:(){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClusterGoogleReviews(storeCode:selectedStoreCode.toString(),year:selectedYear.toString(),month:selectedMonth.toString(),rating:'5',username: username),
                              ),
                            );
                          }),
                      DataCell(Center(child:Text(percentage_5.toString(), textAlign: TextAlign.center, style:  const TextStyle(fontSize: 15),)),
                          onTap:(){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClusterGoogleReviews(storeCode:selectedStoreCode.toString(),year:selectedYear.toString(),month:selectedMonth.toString(),rating:'5',username: username),
                              ),
                            );
                          }),

                    ]),
                    DataRow(cells: [
                      const DataCell(Center(child:Text("Total", textAlign: TextAlign.center, style:  TextStyle(fontSize: 15,fontWeight: FontWeight.bold),))),
                      DataCell(Center(child: total_review_all.toString()=='null'?const Text('0', textAlign: TextAlign.center, style:  TextStyle(fontSize: 15,fontWeight: FontWeight.bold),):
                      Text(total_review_all.toString(), textAlign: TextAlign.center, style:  const TextStyle(fontSize: 15,fontWeight: FontWeight.bold),))),
                      DataCell(Center(child:total_review_good.toString()=='null'?const Text('0', textAlign: TextAlign.center, style:  TextStyle(fontSize: 15,fontWeight: FontWeight.bold),):
                      Text(total_review_good.toString(), textAlign: TextAlign.center, style:  const TextStyle(fontSize: 15,fontWeight: FontWeight.bold),))),
                      DataCell(Center(child: total_review_bad.toString()=='null'?const Text('0', textAlign: TextAlign.center, style:  TextStyle(fontSize: 15,fontWeight: FontWeight.bold),):
                      Text(total_review_bad.toString(), textAlign: TextAlign.center, style:  const TextStyle(fontSize: 15,fontWeight: FontWeight.bold),))),
                      DataCell(Center(child: TotalPercentage.toString()=='null'?const Text('0', textAlign: TextAlign.center, style:  TextStyle(fontSize: 15,fontWeight: FontWeight.bold),):
                      Text(TotalPercentage.toString(), textAlign: TextAlign.center, style:  const TextStyle(fontSize: 15,fontWeight: FontWeight.bold),))
                      ),

                    ]),
                  ],
                ),
              ),
              )
            ],
          )
    );

  }
  Future<void> fetchGoogle() async {
    print(selectedStoreCode);
    print(selectedYear);
    print(selectedMonth);
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    String selectedMonthName = monthNames[selectedMonth].toUpperCase();
    Uri url = Uri.parse("https://smh-app.trent-tata.com/flask/getGoogleReviewTableData/$selectedStoreCode/$selectedYear/$selectedMonthName");
    var response = await ioClient.get(url);
    print("successAPI");
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    print(".............fetching,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,$resultsJson");
    if (response.statusCode == 200) {
      setState(() {
        data = jsonDecode(response.body);
        total_review_1 = (data.first['total_review_1'].toString());
        total_review_2 = (data.first['total_review_2'].toString());
        total_review_3 = (data.first['total_review_3'].toString());
        total_review_4 = (data.first['total_review_4'].toString());
        total_review_5 = (data.first['total_review_5'].toString());
        percentage_review_1 = double.parse(data.first['percentage_review_1'].toString());
        percentage_review_2 = double.parse(data.first['percentage_review_2'].toString());
        percentage_review_3 = double.parse(data.first['percentage_review_3'].toString());
        percentage_review_4 = double.parse(data.first['percentage_review_4'].toString());
        percentage_review_5 = double.parse(data.first['percentage_review_5'].toString());
        percentage_1 = double.parse(percentage_review_1.toStringAsFixed(2));
        percentage_2 = double.parse(percentage_review_2.toStringAsFixed(2));
        percentage_3 = double.parse(percentage_review_3.toStringAsFixed(2));
        percentage_4 = double.parse(percentage_review_4.toStringAsFixed(2));
        percentage_5 = double.parse(percentage_review_5.toStringAsFixed(2));
        total_review_all = (data.first['total_review_all'].toString());
        total_review_bad = (data.first['total_review_bad'].toString());
        total_review_good=(data.first['total_review_good'].toString());
        Total  = percentage_1 + percentage_2 + percentage_3 + percentage_4 + percentage_5;
        double roundPercent = double.parse(Total.toStringAsFixed(1));
        TotalPercentage = roundPercent.toString();


      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  // Future<List<String>> fetchStores() async {
  //   HttpClient client = HttpClient();
  //   client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
  //   IOClient ioClient = IOClient(client);
  //   final response = await ioClient.get(Uri.parse('https://smh-app.trent-tata.com/flask/getallstores'));
  //   var resultJson = json.decode(response.body);
  //   print(resultJson);
  //   if (response.statusCode == 200) {
  //     final List<dynamic> data = json.decode(response.body);
  //     final List<String> storeNames = data.map((dynamic item) => item['code'].toString()).toList();
  //     storeNames.sort();
  //     return storeNames;
  //   } else {
  //     throw Exception('Failed to load equipment names');
  //   }
  // }
  Future<SecurityContext> get globalContext async {
    final sslCert1 = await
    rootBundle.load('assets/starttrent.pem');
    SecurityContext sc = SecurityContext(withTrustedRoots: false);
    sc.setTrustedCertificatesBytes(sslCert1.buffer.asInt8List());
    return sc;
  }
}

List<String> monthNames = [
  '',
  'JANUARY',
  'FEBRUARY',
  'MARCH',
  'APRIL',
  'MAY',
  'JUNE',
  'JULY',
  'AUGUST',
  'SEPTEMBER',
  'OCTOBER',
  'NOVEMBER',
  'DECEMBER'
];

