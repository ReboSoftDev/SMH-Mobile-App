import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';
import 'cityBillingFeedBack.dart';
import 'citySentimentdetail.dart';
import 'citygooglefeedback.dart';


class CityTrialRoomFeedback extends StatefulWidget {
  final String username;

  const CityTrialRoomFeedback({Key? key,  this.stId, required this.username, required this.newSelectedYear, required this.newSelectedMonth, required this.newStoreCode,}) : super(key: key);
  final String? stId;
  final int newSelectedYear;
  final int newSelectedMonth;
  final String newStoreCode;
  @override
  _CityTrialRoomFeedbackState createState() => _CityTrialRoomFeedbackState();
}

class _CityTrialRoomFeedbackState extends State<CityTrialRoomFeedback> {
  List<dynamic> data = [];
  List<dynamic> lmdata = [];
  List<dynamic> lydata = [];
  List<dynamic> stores = [];
  List<String> storecodes = [];
  String? selectedStoreCode;
  List<String> storeNames = [];
  String selectedTypeOfFeedback = "TRIAL ROOM";
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;


  int good_average = 0;
  int good_billing_time_count = 0;
  int good_staff_behaviour_count = 0;
  int good_total_count = 0;
  int good_waiting_time_count = 0;
  int low_average = 0;
  int low_billing_time_count = 0;
  int low_staff_behaviour_count = 0;
  int low_total_count = 0;
  int low_waiting_time_count = 0;
  int medium_average = 0;
  int medium_billing_time_count = 0;
  int medium_staff_behaviour_count = 0;
  int medium_total_count = 0;
  int medium_waiting_time_count = 0;
  int good_cleanliness_count = 0;
  int medium_cleanliness_count = 0;
  int low_cleanliness_count  = 0;

  int lm_good_average = 0;
  int lm_good_billing_time_count = 0;
  int lm_good_staff_behaviour_count = 0;
  int lm_good_total_count = 0;
  int lm_good_waiting_time_count = 0;
  int lm_low_average = 0;
  int lm_low_billing_time_count = 0;
  int lm_low_staff_behaviour_count = 0;
  int lm_low_total_count = 0;
  int lm_low_waiting_time_count = 0;
  int lm_medium_average = 0;
  int lm_medium_billing_time_count = 0;
  int lm_medium_staff_behaviour_count = 0;
  int lm_medium_total_count = 0;
  int lm_medium_waiting_time_count = 0;
  int lm_good_cleanliness_count = 0;
  int lm_medium_cleanliness_count = 0;
  int lm_low_cleanliness_count = 0;
  int score_waiting_time = 0;
  int score_cleanliness = 0;
  int score_staff_behaviour = 0;
  String? storecode;
  String? StoreCode;

  String get username => widget.username;


  Future<void> fetchStores() async {
    print('USERNAME: ${widget.username}');
    HttpClient client = HttpClient();
    client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);
    final response = await ioClient.post(
      Uri.parse('https://smh-app.trent-tata.com/flask/get_city_store_codes'),
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
    fetchData();
  }


  Future<void> fetchData() async {
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    Uri url = Uri.parse('https://smh-app.trent-tata.com/flask/getTrialRoomSentimentCounts/$selectedStoreCode/$selectedYear/$selectedMonth');
    print('https://smh-app.trent-tata.com/flask/getTrialRoomSentimentCounts/$selectedStoreCode/$selectedYear/$selectedMonth');
    var response = await ioClient.get(url);
    var resultJson = json.decode(response.body);
    print("$resultJson.........fetchdata");
    if (response.statusCode == 200) {
      setState(() {
        data = jsonDecode(response.body);
        print("$data.........fetchdata");
        good_waiting_time_count = int.parse(data.first['good_waiting_time_count'].toString());
        good_cleanliness_count = int.parse(data.first['good_cleanliness_count'].toString());
        good_staff_behaviour_count = int.parse(data.first['good_staff_behaviour_count'].toString());
        good_total_count = int.parse(data.first['good_total_count'].toString());
        good_average = int.parse(data.first['good_average'].toString());

        medium_waiting_time_count = int.parse(data.first['medium_waiting_time_count'].toString());
        medium_cleanliness_count = int.parse(data.first['medium_cleanliness_count'].toString());
        medium_staff_behaviour_count = int.parse(data.first['medium_staff_behaviour_count'].toString());
        medium_total_count = int.parse(data.first['medium_total_count'].toString());
        medium_average = int.parse(data.first['medium_average'].toString());

        low_waiting_time_count = int.parse(data.first['low_waiting_time_count'].toString());
        low_cleanliness_count = int.parse(data.first['low_cleanliness_count'].toString());
        low_staff_behaviour_count = int.parse(data.first['low_staff_behaviour_count'].toString());
        low_total_count = int.parse(data.first['low_total_count'].toString());
        low_average = int.parse(data.first['low_average'].toString());

        score_waiting_time = int.parse(data.first['score_waiting_time'].toString());
        score_cleanliness = int.parse(data.first['score_cleanliness'].toString());
        score_staff_behaviour = int.parse(data.first['score_staff_behaviour'].toString());
        // good_waiting_time_count = resultJson[0]['good_waiting_time_count'];
        // good_cleanliness_count = resultJson[0]['good_cleanliness_count'];
        // good_staff_behaviour_count = resultJson[0]['good_staff_behaviour_count'];
        // good_total_count = resultJson[0]['good_total_count'];
        // good_average = resultJson[0]['good_average'];
        //
        // medium_waiting_time_count = resultJson[0]['medium_waiting_time_count'];
        // medium_cleanliness_count = resultJson[0]['medium_cleanliness_count'];
        // medium_staff_behaviour_count = resultJson[0]['medium_staff_behaviour_count'];
        // medium_total_count = resultJson[0]['medium_total_count'];
        // medium_average = resultJson[0]['medium_average'];
        //
        // low_waiting_time_count = resultJson[0]['low_waiting_time_count'];
        // low_cleanliness_count = resultJson[0]['low_cleanliness_count'];
        // low_staff_behaviour_count = resultJson[0]['low_staff_behaviour_count'];
        // low_total_count = resultJson[0]['low_total_count'];
        // low_average = resultJson[0]['low_average'];

      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<SecurityContext> get globalContext async {
    final sslCert1 = await
    rootBundle.load('assets/starttrent.pem');
    SecurityContext sc = SecurityContext(withTrustedRoots: false);
    sc.setTrustedCertificatesBytes(sslCert1.buffer.asInt8List());
    return sc;
  }

  Future<void> fetchLMData(selectedMonth) async {
    int? lastMonth;
    if(selectedMonth == 1)
    {
      lastMonth = 12;
    }
    else{
      lastMonth = selectedMonth - 1 % 12;
    }

    print(selectedMonth);
    print(lastMonth);
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    Uri url = Uri.parse('https://smh-app.trent-tata.com/flask/getLMTrialRoomSentimentCounts/$selectedStoreCode/$selectedYear/$lastMonth');
    var response = await ioClient.get(url);
    var resultJson = json.decode(response.body);
    print("$resultJson.........fetchdata");
    if (response.statusCode == 200) {
      setState(() {
        lmdata = jsonDecode(response.body);
        lm_good_waiting_time_count = resultJson[0]['lm_good_waiting_time_count'];
        lm_good_cleanliness_count = resultJson[0]['lm_good_cleanliness_count'];
        lm_good_staff_behaviour_count = resultJson[0]['lm_good_staff_behaviour_count'];
        lm_good_total_count = resultJson[0]['lm_good_total_count'];
        lm_good_average = resultJson[0]['lm_good_average'];

        lm_medium_waiting_time_count = resultJson[0]['lm_medium_waiting_time_count'];
        lm_medium_cleanliness_count = resultJson[0]['lm_medium_cleanliness_count'];
        lm_medium_staff_behaviour_count = resultJson[0]['lm_medium_staff_behaviour_count'];
        lm_medium_total_count = resultJson[0]['lm_medium_total_count'];
        lm_medium_average = resultJson[0]['lm_medium_average'];

        lm_low_waiting_time_count = resultJson[0]['lm_low_waiting_time_count'];
        lm_low_cleanliness_count = resultJson[0]['lm_low_cleanliness_count'];
        lm_low_staff_behaviour_count = resultJson[0]['lm_low_staff_behaviour_count'];
        lm_low_total_count = resultJson[0]['lm_low_total_count'];
        lm_low_average = resultJson[0]['lm_low_average'];
      });
    } else {
      throw Exception('Failed to load data');
    }
  }
  // void handleShowDetail(String sentimentname,String sentimenttype, bool isLM){
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (BuildContext context) {
  //         return  SentimentDetail(
  //             feedbacktype: selectedTypeOfFeedback,
  //             storeid : selectedStoreCode!,
  //             year : selectedYear.toString(),
  //             month : (isLM)?(selectedMonth - 1).toString():selectedMonth.toString(),
  //             sentimentname : sentimentname,
  //             sentimenttype : sentimenttype
  //         );
  //       },
  //     ),
  //   );
  // }
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
  void initState() {
    getWhichStore();
    super.initState();
    selectedYear = widget.newSelectedYear;
    selectedMonth = widget.newSelectedMonth;
    selectedStoreCode = widget.newStoreCode;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    fetchStores();
    fetchLMData(selectedMonth);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Voice of Customer TrialRoom Table',style: TextStyle(fontSize: 16,color: Colors.white)),
          automaticallyImplyLeading: false,
          leading: IconButton(
              onPressed:(){
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
        body: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(left:30, bottom: 0, right: 30, top:0),

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
                          fetchData();
                          fetchLMData(selectedMonth);
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
                          fetchData();
                          fetchLMData(selectedMonth);
                          fetchStores();
                        });
                      },
                    ),
                    DropdownButton<int>(
                      value: selectedMonth,
                      items: <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].map((int month) {
                        List<String> monthNames = ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
                        return DropdownMenuItem<int>(
                          value: month,
                          child: Text(monthNames[month]),
                        );
                      }).toList(),
                      onChanged: (int? value) {
                        setState(() {
                          selectedMonth = value!;
                          // lastMonth = (selectedMonth - 1) % 12;
                          print("selectedMonth $selectedMonth");
                          fetchData();
                          fetchLMData(selectedMonth);
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
                          fetchData();
                          fetchLMData(selectedMonth);
                          fetchStores();
                          if (selectedTypeOfFeedback == "GOOGLE"){
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (
                                  context) =>  citygooglefeedback(
                                stId:widget.stId,
                                username: username,
                                newSelectedYear: selectedYear, // Use selectedYear
                                newSelectedMonth: selectedMonth,
                                newStoreCode: selectedStoreCode.toString(),),
                              ),
                            );
                          }
                          if (selectedTypeOfFeedback == "BILLING"){
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (
                                  context) =>  CityBillingFeedback(
                                stId:widget.stId,
                                username: username,
                                newSelectedYear: selectedYear, // Use selectedYear
                                newSelectedMonth: selectedMonth,
                                newStoreCode: selectedStoreCode.toString(),),
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
                    //           MaterialPageRoute(builder: (context) =>  CityBillingBar(stid:widget.stId, username: username,)),
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
                child: DataTable(
                  headingRowHeight: 50,
                  dataRowHeight: 60,
                  headingRowColor:
                  MaterialStateColor.resolveWith((states) =>Colors.black45),
                  columns: const [
                    DataColumn(label: Center(child: Text('SENTIMENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)))),
                    DataColumn(label: Center(child: Text('WAITING TIME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)))),
                    DataColumn(label: Center(child: Text('CLEANLINESS',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white))), ),
                    DataColumn(label: Center(child: Text('STAFF BEHAVIOUR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)))),
                    DataColumn(label: Center(child: Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)))),
                    // DataColumn(label: Center(child: Text('AVERAGE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)))),
                    // DataColumn(label: Center(child: Text('PERCENTAGE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)))),
                  ],
                  rows: [],
                ),
              ),
              (data.isEmpty && lmdata.isEmpty && lydata.isEmpty)
                  ? const Center(
                // child: CircularProgressIndicator(),
                child: Text('Data is empty'),
              )
                  : FittedBox(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                        headingRowHeight: 0,

                        dataRowHeight: 30,
                        headingRowColor: MaterialStateColor.resolveWith((states) =>
                        Colors.black45),
                        columns: const [
                          DataColumn(label: Center(child: Text('\t\t\t\t\t\t\t\t\t', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)))),
                          DataColumn(label: Center(child: Text('\t\t\t\t\t\t\t\t\t', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)))),
                          DataColumn(label: Center(child: Text('\t\t\t\t\t\t\t\t\t',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white))), ),
                          DataColumn(label: Center(child: Text('\t\t\t\t\t\t\t\t\t', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)))),
                          DataColumn(label: Center(child: Text('\t\t\t\t\t\t\t\t\t', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)))),
                        //   DataColumn(label: Center(child: Text('\t\t\t\t\t\t\t\t\t', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)))),
                        //   DataColumn(label: Center(child: Text('\t\t\t\t\t\t\t\t\t', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)))),
                         ],
                        rows: [
                          DataRow(cells: [
                            DataCell(Container(
                                padding: EdgeInsets.only(left: 50),
                                width: 100,
                                child: Text('😀'))),
                            DataCell(
                              Container(
                                // color: Colors.yellow,
                                width: 100,
                                padding: EdgeInsets.only(left: 50),
                                child: Row(
                                  children: [
                                    // Space between the arrow icon and the text

                                    Text(good_waiting_time_count.toString(), textAlign: TextAlign.left),
                                    // const SizedBox(width: 10),
                                    // if(good_waiting_time_count > lm_good_waiting_time_count )
                                    //   const Icon(Icons.arrow_upward, weight:50.5,size: 20,color: Colors.green),
                                    // if(good_waiting_time_count == lm_good_waiting_time_count )
                                    //   const Icon(Icons.circle, weight:50.5,size: 15,color: Colors.orange),
                                    // if(good_waiting_time_count < lm_good_waiting_time_count )
                                    //   const Icon(Icons.arrow_downward, size: 20,color: Colors.red,),

                                  ],
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CitySentimentDetail(
                                          feedbacktype: selectedTypeOfFeedback,
                                          storeid : selectedStoreCode!,
                                          year : selectedYear.toString(),
                                          month : selectedMonth.toString(),
                                          sentimentname : 'good',
                                          sentimenttype : 'waiting_time',
                                        ),
                                  ),
                                );
                              },
                            ),
                            DataCell(
                              Container(
                                // color: Colors.yellow,
                                width: 100,
                                padding: EdgeInsets.only(left: 50),
                                child: Row(
                                  children: [
                                    // Space between the arrow icon and the text

                                    Text(good_cleanliness_count.toString(), textAlign: TextAlign.left),
                                    // const SizedBox(width: 10),
                                    // if(good_cleanliness_count > lm_good_cleanliness_count )
                                    //   const Icon(Icons.arrow_upward, weight:50.5,size: 20,color: Colors.green),
                                    // if(good_cleanliness_count == lm_good_cleanliness_count )
                                    //   const Icon(Icons.circle, weight:50.5,size: 15,color: Colors.orange),
                                    // if(good_cleanliness_count < lm_good_cleanliness_count )
                                    //   const Icon(Icons.arrow_downward, size: 20,color: Colors.red,),

                                  ],
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CitySentimentDetail(
                                          feedbacktype: selectedTypeOfFeedback,
                                          storeid : selectedStoreCode!,
                                          year : selectedYear.toString(),
                                          month : selectedMonth.toString(),
                                          sentimentname : 'good',
                                          sentimenttype : 'cleanliness',
                                        ),
                                  ),
                                );
                              },
                            ),

                            DataCell(
                              Container(
                                // color: Colors.yellow,
                                width: 100,
                                padding: EdgeInsets.only(left: 60),
                                child: Row(
                                  children: [
                                    // Space between the arrow icon and the text

                                    Text(good_staff_behaviour_count.toString(), textAlign: TextAlign.left),
                                    // const SizedBox(width: 10),
                                    // if(good_staff_behaviour_count > lm_good_staff_behaviour_count )
                                    //   const Icon(Icons.arrow_upward, weight:50.5,size: 20,color: Colors.green),
                                    // if(good_staff_behaviour_count == lm_good_staff_behaviour_count )
                                    //   const Icon(Icons.circle, weight:50.5,size: 15,color: Colors.orange),
                                    // if(good_staff_behaviour_count < lm_good_staff_behaviour_count )
                                    //   const Icon(Icons.arrow_downward, size: 20,color: Colors.red,),

                                  ],
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CitySentimentDetail(
                                          feedbacktype: selectedTypeOfFeedback,
                                          storeid : selectedStoreCode!,
                                          year : selectedYear.toString(),
                                          month : selectedMonth.toString(),
                                          sentimentname : 'good',
                                          sentimenttype : 'staff_behaviour',
                                        ),
                                  ),
                                );
                              },
                            ),
                            DataCell(
                              Container(
                                // color: Colors.yellow,
                                width: 100,
                                padding: EdgeInsets.only(left: 50),
                                child: Row(
                                  children: [
                                    // Space between the arrow icon and the text

                                    Text(good_total_count.toString(), textAlign: TextAlign.left),
                                    // const SizedBox(width: 10),
                                    // if(good_total_count > lm_good_total_count )
                                    //   const Icon(Icons.arrow_upward, weight:50.5,size: 20,color: Colors.green),
                                    // if(good_total_count == lm_good_total_count )
                                    //   const Icon(Icons.circle, weight:50.5,size: 15,color: Colors.orange),
                                    // if(good_total_count < lm_good_total_count )
                                    //   const Icon(Icons.arrow_downward, size: 20,color: Colors.red,),

                                  ],
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CitySentimentDetail(
                                          feedbacktype: selectedTypeOfFeedback,
                                          storeid : selectedStoreCode!,
                                          year : selectedYear.toString(),
                                          month : selectedMonth.toString(),
                                          sentimentname : 'good',
                                          sentimenttype : 'total',
                                        ),
                                  ),
                                );
                              },
                            ),

                            // DataCell(
                            //   Container(
                            //     // color: Colors.yellow,
                            //     width: 60,
                            //     child: Row(
                            //       children: [
                            //         // Space between the arrow icon and the text
                            //
                            //         Text(good_average.toString(), textAlign: TextAlign.left),
                            //         const SizedBox(width: 10),
                            //         if(good_average > lm_good_average )
                            //           const Icon(Icons.arrow_upward, weight:50.5,size: 20,color: Colors.green),
                            //         if(good_average == lm_good_average )
                            //           const Icon(Icons.circle, weight:50.5,size: 15,color: Colors.orange),
                            //         if(good_average < lm_good_average )
                            //           const Icon(Icons.arrow_downward, size: 20,color: Colors.red,),
                            //
                            //       ],
                            //     ),
                            //   ),
                            //   onTap: () {
                            //     // handleShowDetail('good', 'waiting_time', false);
                            //   },
                            // ),
                            // DataCell(
                            //     Container(
                            //         width:30,child:Text((good_total_count + medium_total_count + low_total_count) > 0 ?
                            //     ((good_total_count) * 100 / (good_total_count + medium_total_count + low_total_count)).round().toString()
                            //         : 0.toString(),textAlign: TextAlign.right,
                            //     ))
                            //
                            // ),

                          ]
                          ),



                          // DataRow(cells: [
                          //   const DataCell(Text('Last Month')),
                          //   DataCell(
                          //     Container(
                          //       // color: Colors.yellow,
                          //       width: 60,
                          //       child: Row(
                          //         children: [
                          //           // Space between the arrow icon and the text
                          //
                          //           Text(lm_good_waiting_time_count.toString(), textAlign: TextAlign.left),
                          //           const SizedBox(width: 10),
                          //           // if(lm_good_billing_time_count > lm_good_billing_time_count )
                          //           //   const Icon(Icons.arrow_upward, weight:50.5,size: 20,color: Colors.green),
                          //           // if(good_billing_time_count == lm_good_billing_time_count )
                          //           //   const Icon(Icons.circle, weight:50.5,size: 15,color: Colors.orange),
                          //           // if(good_billing_time_count < lm_good_billing_time_count )
                          //           //   const Icon(Icons.arrow_downward, size: 20,color: Colors.red,),
                          //
                          //         ],
                          //       ),
                          //     ),
                          //     onTap: () {
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //           builder: (context) =>
                          //               CitySentimentDetail(
                          //                 feedbacktype: selectedTypeOfFeedback,
                          //                 storeid : selectedStoreCode!,
                          //                 year : selectedYear.toString(),
                          //                 month : selectedMonth.toString(),
                          //                 sentimentname : 'good',
                          //                 sentimenttype : 'waiting_time',
                          //               ),
                          //         ),
                          //       );
                          //     },
                          //   ),
                          //   DataCell(Text(lm_good_cleanliness_count.toString()),
                          //       onTap: () {
                          //         Navigator.push(
                          //           context,
                          //           MaterialPageRoute(
                          //             builder: (context) =>
                          //                 CitySentimentDetail(
                          //                   feedbacktype: selectedTypeOfFeedback,
                          //                   storeid : selectedStoreCode!,
                          //                   year : selectedYear.toString(),
                          //                   month : selectedMonth.toString(),
                          //                   sentimentname : 'good',
                          //                   sentimenttype : 'cleanliness',
                          //                 ),
                          //           ),
                          //         );
                          //       }
                          //
                          //   ),
                          //   DataCell(
                          //     Container(
                          //         width:30,
                          //         child: Text(lm_good_staff_behaviour_count.toString(),textAlign: TextAlign.left,)),
                          //     onTap: (){
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //           builder: (context) =>
                          //               CitySentimentDetail(
                          //                 feedbacktype: selectedTypeOfFeedback,
                          //                 storeid : selectedStoreCode!,
                          //                 year : selectedYear.toString(),
                          //                 month : selectedMonth.toString(),
                          //                 sentimentname : 'good',
                          //                 sentimenttype : 'staff_behaviour',
                          //               ),
                          //         ),
                          //       );
                          //     },
                          //   ),
                          //   DataCell(
                          //     Container(
                          //         width:40,
                          //         child:Text(lm_good_total_count.toString(),textAlign: TextAlign.left,)),
                          //     onTap: (){
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //           builder: (context) =>
                          //               CitySentimentDetail(
                          //                 feedbacktype: selectedTypeOfFeedback,
                          //                 storeid : selectedStoreCode!,
                          //                 year : selectedYear.toString(),
                          //                 month : selectedMonth.toString(),
                          //                 sentimentname : 'good',
                          //                 sentimenttype : 'total',
                          //               ),
                          //         ),
                          //       );
                          //     },),
                          //   DataCell(
                          //       Container(
                          //           width:20,child:Text(lm_good_average.toString(),textAlign: TextAlign.left,))),
                          //   DataCell(
                          //       Container(
                          //           width:30,child:Text((lm_good_total_count + lm_medium_total_count + lm_low_total_count) > 0 ?
                          //       ((lm_good_total_count) * 100 /
                          //           (lm_good_total_count + lm_medium_total_count + lm_low_total_count)).round().toString()
                          //           : 0.toString(),textAlign: TextAlign.right,
                          //       ))
                          //
                          //   ),
                          // ]
                          // ),



                          DataRow(cells: [
                            DataCell(Container(
                                padding: EdgeInsets.only(left: 50),
                                child: Text('😐'))),
                            DataCell(
                              Container(
                                // color: Colors.yellow,
                                width: 100,
                                padding: EdgeInsets.only(left: 50),
                                child: Row(
                                  children: [
                                    // Space between the arrow icon and the text

                                    Text(medium_waiting_time_count.toString(), textAlign: TextAlign.left),
                                    // const SizedBox(width: 10),
                                    // if(medium_waiting_time_count > lm_medium_waiting_time_count )
                                    //   const Icon(Icons.arrow_upward, weight:50.5,size: 20,color: Colors.green),
                                    // if(medium_waiting_time_count == lm_good_waiting_time_count )
                                    //   const Icon(Icons.circle, weight:50.5,size: 15,color: Colors.orange),
                                    // if(medium_waiting_time_count < lm_medium_waiting_time_count )
                                    //   const Icon(Icons.arrow_downward, size: 20,color: Colors.red,),

                                  ],
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CitySentimentDetail(
                                          feedbacktype: selectedTypeOfFeedback,
                                          storeid : selectedStoreCode!,
                                          year : selectedYear.toString(),
                                          month : selectedMonth.toString(),
                                          sentimentname : 'medium',
                                          sentimenttype : 'waiting_time',
                                        ),
                                  ),
                                );
                              },
                            ),

                            DataCell(
                              Container(
                                // color: Colors.yellow,
                                width: 100,
                                padding: EdgeInsets.only(left: 50),
                                child: Row(
                                  children: [
                                    // Space between the arrow icon and the text

                                    Text(medium_cleanliness_count.toString(), textAlign: TextAlign.left),
                                    // const SizedBox(width: 10),
                                    // if(medium_cleanliness_count > lm_medium_cleanliness_count )
                                    //   const Icon(Icons.arrow_upward, weight:50.5,size: 20,color: Colors.green),
                                    // if(medium_cleanliness_count == lm_medium_cleanliness_count )
                                    //   const Icon(Icons.circle, weight:50.5,size: 15,color: Colors.orange),
                                    // if(medium_cleanliness_count < lm_medium_cleanliness_count )
                                    //   const Icon(Icons.arrow_downward, size: 20,color: Colors.red,),

                                  ],
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CitySentimentDetail(
                                          feedbacktype: selectedTypeOfFeedback,
                                          storeid : selectedStoreCode!,
                                          year : selectedYear.toString(),
                                          month : selectedMonth.toString(),
                                          sentimentname : 'medium',
                                          sentimenttype : 'cleanliness',
                                        ),
                                  ),
                                );
                              },
                            ),


                            DataCell(
                              Container(
                                // color: Colors.yellow,
                                width: 100,
                                padding: EdgeInsets.only(left: 60),
                                child: Row(
                                  children: [
                                    // Space between the arrow icon and the text

                                    Text(medium_staff_behaviour_count.toString(), textAlign: TextAlign.left),
                                    // const SizedBox(width: 10),
                                    // if(medium_staff_behaviour_count > lm_medium_staff_behaviour_count )
                                    //   const Icon(Icons.arrow_upward, weight:50.5,size: 20,color: Colors.green),
                                    // if(medium_staff_behaviour_count == lm_medium_staff_behaviour_count )
                                    //   const Icon(Icons.circle, weight:50.5,size: 15,color: Colors.orange),
                                    // if(medium_staff_behaviour_count < lm_medium_staff_behaviour_count )
                                    //   const Icon(Icons.arrow_downward, size: 20,color: Colors.red,),

                                  ],
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CitySentimentDetail(
                                          feedbacktype: selectedTypeOfFeedback,
                                          storeid : selectedStoreCode!,
                                          year : selectedYear.toString(),
                                          month : selectedMonth.toString(),
                                          sentimentname : 'medium',
                                          sentimenttype : 'staff_behaviour',
                                        ),
                                  ),
                                );
                              },
                            ),


                            DataCell(
                              Container(
                                // color: Colors.yellow,
                                width: 100,
                                padding: EdgeInsets.only(left: 50),
                                child: Row(
                                  children: [
                                    // Space between the arrow icon and the text

                                    Text(medium_total_count.toString(), textAlign: TextAlign.left),
                                    // const SizedBox(width: 10),
                                    // if(medium_total_count > lm_medium_total_count )
                                    //   const Icon(Icons.arrow_upward, weight:50.5,size: 20,color: Colors.green),
                                    // if(medium_total_count == lm_medium_total_count )
                                    //   const Icon(Icons.circle, weight:50.5,size: 15,color: Colors.orange),
                                    // if(medium_total_count < lm_medium_total_count )
                                    //   const Icon(Icons.arrow_downward, size: 20,color: Colors.red,),

                                  ],
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CitySentimentDetail(
                                          feedbacktype: selectedTypeOfFeedback,
                                          storeid : selectedStoreCode!,
                                          year : selectedYear.toString(),
                                          month : selectedMonth.toString(),
                                          sentimentname : 'medium',
                                          sentimenttype : 'total',
                                        ),
                                  ),
                                );
                              },
                            ),

                            // DataCell(
                            //   Container(
                            //     // color: Colors.yellow,
                            //     width: 60,
                            //     child: Row(
                            //       children: [
                            //         // Space between the arrow icon and the text
                            //
                            //         Text(medium_average.toString(), textAlign: TextAlign.left),
                            //         const SizedBox(width: 10),
                            //         if(medium_average > lm_medium_average )
                            //           const Icon(Icons.arrow_upward, weight:50.5,size: 20,color: Colors.green),
                            //         if(medium_average == lm_medium_average )
                            //           const Icon(Icons.circle, weight:50.5,size: 15,color: Colors.orange),
                            //         if(medium_average < lm_medium_average )
                            //           const Icon(Icons.arrow_downward, size: 20,color: Colors.red,),
                            //
                            //       ],
                            //     ),
                            //   ),
                            //   onTap: () {
                            //     // handleShowDetail('good', 'waiting_time', false);
                            //   },
                            // ),
                            // DataCell(
                            //     Container(
                            //         width:30,child:Text((good_total_count + medium_total_count + low_total_count) > 0 ?
                            //     ((medium_total_count) * 100 /
                            //         (good_total_count + medium_total_count + low_total_count)).round().toString()
                            //         : 0.toString(),textAlign: TextAlign.right,
                            //     ))
                            //
                            // ),
                          ]
                          ),






                          // DataRow(cells: [
                          //   const DataCell(Text('Last Month')),
                          //   DataCell(
                          //     Container(
                          //       // color: Colors.yellow,
                          //       width: 60,
                          //       child: Row(
                          //         children: [
                          //           // Space between the arrow icon and the text
                          //
                          //           Text(lm_medium_waiting_time_count.toString(), textAlign: TextAlign.left),
                          //           const SizedBox(width: 10),
                          //
                          //         ],
                          //       ),
                          //     ),
                          //     onTap: () {
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //           builder: (context) =>
                          //               CitySentimentDetail(
                          //                 feedbacktype: selectedTypeOfFeedback,
                          //                 storeid : selectedStoreCode!,
                          //                 year : selectedYear.toString(),
                          //                 month : selectedMonth.toString(),
                          //                 sentimentname : 'medium',
                          //                 sentimenttype : 'waiting_time',
                          //               ),
                          //         ),
                          //       );
                          //     },
                          //   ),
                          //   DataCell(Text(lm_medium_cleanliness_count.toString()),
                          //       onTap: () {
                          //         Navigator.push(
                          //           context,
                          //           MaterialPageRoute(
                          //             builder: (context) =>
                          //                 CitySentimentDetail(
                          //                   feedbacktype: selectedTypeOfFeedback,
                          //                   storeid : selectedStoreCode!,
                          //                   year : selectedYear.toString(),
                          //                   month : selectedMonth.toString(),
                          //                   sentimentname : 'medium',
                          //                   sentimenttype : 'cleanliness',
                          //                 ),
                          //           ),
                          //         );
                          //       }
                          //
                          //   ),
                          //   DataCell(
                          //     Container(
                          //         width:30,
                          //         child: Text(lm_medium_staff_behaviour_count.toString(),textAlign: TextAlign.left,)),
                          //     onTap: (){
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //           builder: (context) =>
                          //               CitySentimentDetail(
                          //                 feedbacktype: selectedTypeOfFeedback,
                          //                 storeid : selectedStoreCode!,
                          //                 year : selectedYear.toString(),
                          //                 month : selectedMonth.toString(),
                          //                 sentimentname : 'medium',
                          //                 sentimenttype : 'staff_behaviour',
                          //               ),
                          //         ),
                          //       );
                          //     },
                          //   ),
                          //   DataCell(
                          //     Container(
                          //         width:40,
                          //         child:Text(lm_medium_total_count.toString(),textAlign: TextAlign.left,)),
                          //     onTap: (){
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //           builder: (context) =>
                          //               CitySentimentDetail(
                          //                 feedbacktype: selectedTypeOfFeedback,
                          //                 storeid : selectedStoreCode!,
                          //                 year : selectedYear.toString(),
                          //                 month : selectedMonth.toString(),
                          //                 sentimentname : 'medium',
                          //                 sentimenttype : 'total',
                          //               ),
                          //         ),
                          //       );
                          //     },),
                          //   DataCell(
                          //       Container(
                          //           width:30,child:Text(lm_medium_average.toString(),textAlign: TextAlign.left,))),
                          //   DataCell(
                          //       Container(
                          //           width:30,child:Text((lm_good_total_count + lm_medium_total_count + lm_low_total_count) > 0 ?
                          //       ((lm_medium_total_count) * 100 /
                          //           (lm_good_total_count + lm_medium_total_count + lm_low_total_count)).round().toString()
                          //           : 0.toString(),textAlign: TextAlign.right,
                          //       ))
                          //
                          //   ),
                          // ]
                          // ),




                          DataRow(cells: [
                            DataCell(Container(
                                padding: EdgeInsets.only(left: 50),
                                child: Text('😞'))),
                            DataCell(
                              Container(
                                // color: Colors.yellow,
                                width: 100,
                                padding: EdgeInsets.only(left: 50),
                                child: Row(
                                  children: [
                                    // Space between the arrow icon and the text

                                    Text(low_waiting_time_count.toString(), textAlign: TextAlign.left),
                                    // const SizedBox(width: 10),
                                    // if(low_waiting_time_count < lm_low_waiting_time_count )
                                    //   const Icon(Icons.arrow_upward, weight:50.5,size: 20,color: Colors.green),
                                    // if(low_waiting_time_count == lm_low_waiting_time_count )
                                    //   const Icon(Icons.circle, weight:50.5,size: 15,color: Colors.orange),
                                    // if(low_waiting_time_count > lm_low_waiting_time_count )
                                    //   const Icon(Icons.arrow_downward, size: 20,color: Colors.red,),

                                  ],
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CitySentimentDetail(
                                          feedbacktype: selectedTypeOfFeedback,
                                          storeid : selectedStoreCode!,
                                          year : selectedYear.toString(),
                                          month : selectedMonth.toString(),
                                          sentimentname : 'low',
                                          sentimenttype : 'waiting_time',
                                        ),
                                  ),
                                );
                              },
                            ),

                            DataCell(
                              Container(
                                // color: Colors.yellow,
                                width: 100,
                                padding: EdgeInsets.only(left: 50),
                                child: Row(
                                  children: [
                                    // Space between the arrow icon and the text

                                    Text(low_cleanliness_count.toString(), textAlign: TextAlign.left),
                                    // const SizedBox(width: 10),
                                    // if(low_cleanliness_count < lm_low_cleanliness_count )
                                    //   const Icon(Icons.arrow_upward, weight:50.5,size: 20,color: Colors.green),
                                    // if(low_cleanliness_count == lm_low_cleanliness_count )
                                    //   const Icon(Icons.circle, weight:50.5,size: 15,color: Colors.orange),
                                    // if(low_cleanliness_count > lm_low_cleanliness_count )
                                    //   const Icon(Icons.arrow_downward, size: 20,color: Colors.red,),

                                  ],
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CitySentimentDetail(
                                          feedbacktype: selectedTypeOfFeedback,
                                          storeid : selectedStoreCode!,
                                          year : selectedYear.toString(),
                                          month : selectedMonth.toString(),
                                          sentimentname : 'low',
                                          sentimenttype : 'cleanliness',
                                        ),
                                  ),
                                );
                              },
                            ),




                            DataCell(
                              Container(
                                // color: Colors.yellow,
                                width: 100,
                                padding: EdgeInsets.only(left: 60),
                                child: Row(
                                  children: [
                                    // Space between the arrow icon and the text

                                    Text(low_staff_behaviour_count.toString(), textAlign: TextAlign.left),
                                    // const SizedBox(width: 10),
                                    // if(low_staff_behaviour_count < lm_low_staff_behaviour_count )
                                    //   const Icon(Icons.arrow_upward, weight:50.5,size: 20,color: Colors.green),
                                    // if(low_staff_behaviour_count == lm_low_staff_behaviour_count )
                                    //   const Icon(Icons.circle, weight:50.5,size: 15,color: Colors.orange),
                                    // if(low_staff_behaviour_count > lm_low_staff_behaviour_count )
                                    //   const Icon(Icons.arrow_downward, size: 20,color: Colors.red,),

                                  ],
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CitySentimentDetail(
                                          feedbacktype: selectedTypeOfFeedback,
                                          storeid : selectedStoreCode!,
                                          year : selectedYear.toString(),
                                          month : selectedMonth.toString(),
                                          sentimentname : 'low',
                                          sentimenttype : 'staff_behaviour',
                                        ),
                                  ),
                                );
                              },
                            ),



                            DataCell(
                              Container(
                                // color: Colors.yellow,
                                width: 100,
                                padding: EdgeInsets.only(left: 50),
                                child: Row(
                                  children: [
                                    // Space between the arrow icon and the text

                                    Text(low_total_count.toString(), textAlign: TextAlign.left),
                                    // const SizedBox(width: 10),
                                    // if(low_total_count < lm_low_total_count )
                                    //   const Icon(Icons.arrow_upward, weight:50.5,size: 20,color: Colors.green),
                                    // if(low_total_count == lm_low_total_count )
                                    //   const Icon(Icons.circle, weight:50.5,size: 15,color: Colors.orange),
                                    // if(low_total_count > lm_low_total_count )
                                    //   const Icon(Icons.arrow_downward, size: 20,color: Colors.red,),

                                  ],
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CitySentimentDetail(
                                          feedbacktype: selectedTypeOfFeedback,
                                          storeid : selectedStoreCode!,
                                          year : selectedYear.toString(),
                                          month : selectedMonth.toString(),
                                          sentimentname : 'low',
                                          sentimenttype : 'total',
                                        ),
                                  ),
                                );
                              },
                            ),

                            // DataCell(
                            //   Container(
                            //     // color: Colors.yellow,
                            //     width: 60,
                            //     child: Row(
                            //       children: [
                            //         // Space between the arrow icon and the text
                            //
                            //         Text(low_average.toString(), textAlign: TextAlign.left),
                            //         const SizedBox(width: 10),
                            //         if(low_average < lm_low_average )
                            //           const Icon(Icons.arrow_upward, weight:50.5,size: 20,color: Colors.green),
                            //         if(low_average == lm_low_average )
                            //           const Icon(Icons.circle, weight:50.5,size: 15,color: Colors.orange),
                            //         if(low_average > lm_low_average )
                            //           const Icon(Icons.arrow_downward, size: 20,color: Colors.red,),
                            //
                            //       ],
                            //     ),
                            //   ),
                            //   onTap: () {
                            //     // handleShowDetail('good', 'waiting_time', false);
                            //   },
                            // ),
                            // DataCell(
                            //     Container(
                            //         width:30,child:Text((good_total_count + medium_total_count + low_total_count) > 0 ?
                            //     ((low_total_count) * 100 /
                            //         (good_total_count + medium_total_count + low_total_count)).round().toString()
                            //         : 0.toString(),textAlign: TextAlign.right,
                            //     ))
                            //
                            // ),
                          ]
                          ),






                          DataRow(cells: [
                            DataCell(Container(
                                padding: EdgeInsets.only(left: 35),
                                child: Text('SCORE'))),
                            DataCell(
                              Container(
                                // color: Colors.yellow,
                                width: 100,
                                padding: EdgeInsets.only(left: 50),
                                child: Row(
                                  children: [
                                    // Space between the arrow icon and the text

                                    Text(score_waiting_time.toString(), textAlign: TextAlign.left),
                                    const SizedBox(width: 10),


                                  ],
                                ),
                              ),
                              // onTap: () {
                              //   Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) =>
                              //           SentimentDetail(
                              //             feedbacktype: selectedTypeOfFeedback,
                              //             storeid : StoreCode!,
                              //             year : selectedYear.toString(),
                              //             month : selectedMonth.toString(),
                              //             sentimentname : 'low',
                              //             sentimenttype : 'waiting_time',
                              //           ),
                              //     ),
                              //   );
                              // },
                            ),
                            DataCell(Container(
                                width: 100,
                                padding: EdgeInsets.only(left: 50),
                                child: Text(score_cleanliness.toString())),
                              // onTap: (){
                              //   Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) =>
                              //           SentimentDetail(
                              //             feedbacktype: selectedTypeOfFeedback,
                              //             storeid : StoreCode!,
                              //             year : selectedYear.toString(),
                              //             month : selectedMonth.toString(),
                              //             sentimentname : 'low',
                              //             sentimenttype : 'billing_time',
                              //           ),
                              //     ),
                              //   );
                              // }

                            ),
                            DataCell(
                              Container(
                                  width:100,
                                  padding: EdgeInsets.only(left: 60),
                                  child: Text(score_staff_behaviour.toString(),textAlign: TextAlign.left,)),

                              // onTap: (){
                              //   Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) =>
                              //           SentimentDetail(
                              //             feedbacktype: selectedTypeOfFeedback,
                              //             storeid : StoreCode!,
                              //             year : selectedYear.toString(),
                              //             month : selectedMonth.toString(),
                              //             sentimentname : 'low',
                              //             sentimenttype : 'staff_behaviour',
                              //           ),
                              //     ),
                              //   );
                              // },
                            ),
                            DataCell(
                              Container(
                                  width:100,
                                  padding: EdgeInsets.only(left: 50),
                                  child:Text(" ",textAlign: TextAlign.left,)),
                              onTap: (){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CitySentimentDetail(
                                          feedbacktype: selectedTypeOfFeedback,
                                          storeid : StoreCode!,
                                          year : selectedYear.toString(),
                                          month : selectedMonth.toString(),
                                          sentimentname : 'low',
                                          sentimenttype : 'total',
                                        ),
                                  ),
                                );
                              },),
                            // DataCell(
                            //     Container(
                            //         width:20,child:Text(lm_low_average.toString(),textAlign: TextAlign.left,))),
                            // DataCell(
                            //     Container(
                            //         width:30,child:Text((good_total_count + medium_total_count + low_total_count) > 0 ?
                            //     ((lm_low_total_count) * 100 /
                            //         (good_total_count + medium_total_count + low_total_count)).round().toString()
                            //         : 0.toString(),textAlign: TextAlign.right,
                            //     ))
                            //
                            // ),
                          ]
                          ),



                        ]
                    ),
                  )

              ),
            ]
        )
    );
  }

}
