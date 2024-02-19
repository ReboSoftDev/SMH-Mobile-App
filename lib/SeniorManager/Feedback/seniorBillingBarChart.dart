import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'seniorFeedBackHome.dart';

class SeniorBillingBar extends StatefulWidget {
  final String username;
  const SeniorBillingBar({Key? key, this. stid, required this.username}) : super(key: key);
  final String? stid;


  @override
  _SeniorBillingBarState createState() => _SeniorBillingBarState();
}

class _SeniorBillingBarState extends State<SeniorBillingBar> {
  String? selectedStoreCode;
  List<int> billingScorePercent = [];
  List<int> trialroomScorePercent = [];
  List<int> googleScorePercent = [];
  List<int> totalScores = [];
  List<String> storeNames = [];
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  String monthSelected = DateFormat('MMMM').format(DateTime.now()).toUpperCase();
  String? selectedFeedbackType;
  String? storecode;
  String? StoreCode;

  String get username => widget.username;

  @override
  void initState() {

    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    getWhichStore();
    fetchStores();
    fetchData();
    fetchDataTrial();
    fetchDataGoogle();// Call the fetchStores() function to populate storeNames
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Future <void> getWhichStore()async {
    HttpClient client = HttpClient();
    client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);
    final storeResponse = await ioClient.post(
      Uri.parse("https://smh-app.trent-tata.com/flask/get_which_store"),
      body: json.encode({"storeId": widget.stid.toString()}),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Of Customer Summary Graph', style: TextStyle(fontSize: 16,color: Colors.white)),
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Container(
                  //    // padding: const EdgeInsets.only(left:30, bottom: 0, right: 30, top:0),
                  //
                  //     child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: [
                  //           Container(
                  //             padding: const EdgeInsets.all(10.0),
                  //             alignment: Alignment.center,
                  //             child: StoreCode == null
                  //                 ? const Text('', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),)
                  //                 : Text(StoreCode!, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  //             ),
                  //           ),
                  //         ]
                  //     )
                  // ),


                  DropdownButton<String>(
                    value: selectedStoreCode,
                    hint: const Text('Select a Store'),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedStoreCode = newValue;
                        fetchData();
                        fetchDataTrial();
                        fetchDataGoogle();
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
                        fetchDataTrial();
                        fetchDataGoogle();
                        fetchStores();
                      });
                    },
                  ),
                  Container(
                      width: 180,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>  SeniorSentimentHome(
                                stid:widget.stid.toString(),
                                username: username,
                                newSelectedYear: selectedYear,
                                newStoreCode: selectedStoreCode.toString(),)),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(10),  // Set the padding for the button
                          backgroundColor: Colors.black, // Set the background color for the button
                        ),
                        child: Text('Summary Details'),
                      )
                  )
                ],
              ),
              seniorBuildLineChart(),
            ],
          ),
        ),
      ),
    );
  }


  void calculateTotalScores() {
    totalScores.clear(); // Clear the existing totalScores list

    for (int i = 0; i < 12; i++) {
      double totalScore =
          (billingScorePercent[i] * 0.4) + (trialroomScorePercent[i] * 0.4) + (googleScorePercent[i] * 0.2);
      int roundedTotalScore = totalScore.round(); // Round the total score to the nearest integer
      totalScores.add(roundedTotalScore);
      print('totalScores======================================$totalScores');
    }
  }



  ///////////////////////////////////////////api for billing//////////////////////////////////

  Future<void> fetchData() async {
    print(StoreCode.toString());
    HttpClient client = HttpClient();
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    IOClient ioClient = IOClient(client);
    Uri url = Uri.parse(
        'https://smh-app.trent-tata.com/flask/getBillingSentiment/$selectedStoreCode/$selectedYear');
    print('https://smh-app.trent-tata.com/flask/getBillingSentiment/$selectedStoreCode/$selectedYear');
    final response = await ioClient.get(url);
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body) as List<dynamic>;
      // Clear the existing billingScorePercent list to avoid duplicates
      billingScorePercent.clear();
      // Extract the billingScorePercent for each month and store them in the list
      for (var monthData in jsonData) {
        int billingScorePercentForMonth = monthData['billingScorePercent'];
        billingScorePercent.add(billingScorePercentForMonth);
        print("billingScorePercent================================================$billingScorePercent");
      }
      setState(() {
        calculateTotalScores();
        // Update the UI after fetching and processing the data
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  //////////////////////////////////api for trial room////////////////////////////////////////////

  Future<void> fetchDataTrial() async {
    HttpClient client = HttpClient();
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    IOClient ioClient = IOClient(client);
    Uri url = Uri.parse(
        'https://smh-app.trent-tata.com/flask/getTrialRoomSentiment/$selectedStoreCode/$selectedYear');
    print('https://smh-app.trent-tata.com/flask/getTrialRoomSentiment/$selectedStoreCode/$selectedYear');
    final response = await ioClient.get(url);
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body) as List<dynamic>;
      // Clear the existing trialroomScorePercent list to avoid duplicates
      trialroomScorePercent.clear();
      // Extract the trialroomScorePercent for each month and store them in the list
      for (var monthData in jsonData) {
        int trialroomScorePercentForMonth = monthData['trialroomScorePercent'];
        trialroomScorePercent.add(trialroomScorePercentForMonth);
        print("trialroomScorePercent================================================$trialroomScorePercent");
      }
      setState(() {
        calculateTotalScores();
        // Update the UI after fetching and processing the data
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  //////////////////////////////////api for google////////////////////////////////////////////

  Future<void> fetchDataGoogle() async {
    HttpClient client = HttpClient();
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    IOClient ioClient = IOClient(client);
    Uri url = Uri.parse(
        'https://smh-app.trent-tata.com/flask/getGoogleReview/$selectedStoreCode/$selectedYear');
    print('https://smh-app.trent-tata.com/flask/getGoogleReview/$selectedStoreCode/$selectedYear');
    var response = await ioClient.get(url);
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body) as List<dynamic>;
      // Clear the existing googleScorePercent list to avoid duplicates
      googleScorePercent.clear();
      // Extract the googleScorePercent for each month and store them in the list
      for (var monthData in jsonData) {
        int googleScorePercentForMonth = monthData['googleScorePercent'];
        googleScorePercent.add(googleScorePercentForMonth);
        print("googleScorePercent================================================$googleScorePercent");
      }
      setState(() {
        calculateTotalScores();
        // Update the UI after fetching and processing the data
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  ///////////////////////////////////api to get store code//////////////////////////////////

  Future<void> fetchStores() async {
    HttpClient client = HttpClient();
    client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);
    final response = await ioClient.get(Uri.parse('https://smh-app.trent-tata.com/flask/getallstores'));
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
  }


  Widget seniorBuildLineChart() {
    if (totalScores.isEmpty) {
      return SizedBox.shrink(); // If totalScores is empty, display an empty widget
    }

    return Container(
      width: 650,
      height: 200,
      padding: const EdgeInsets.all(16.0),
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: totalScores.asMap().entries.map((entry) {
                int monthIndex = entry.key;
                int totalScore = entry.value;
                return FlSpot(monthIndex.toDouble(), totalScore.toDouble());
              }).toList(),
              isCurved: true,
              colors: [Colors.blue],
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: SideTitles(showTitles: true, getTitles: (value) => '${value.toInt()}%',margin: 8,
              reservedSize: 30,),
            topTitles: SideTitles(showTitles: false),
            rightTitles: SideTitles(showTitles: false),
            bottomTitles: SideTitles(
              showTitles: true,
              getTitles: (value) {
                switch (value.toInt()) {
                  case 0:
                    return 'Jan';
                  case 1:
                    return 'Feb';
                  case 2:
                    return 'Mar';
                  case 3:
                    return 'Apr';
                  case 4:
                    return 'May';
                  case 5:
                    return 'Jun';
                  case 6:
                    return 'Jul';
                  case 7:
                    return 'Aug';
                  case 8:
                    return 'Sep';
                  case 9:
                    return 'Oct';
                  case 10:
                    return 'Nov';
                  case 11:
                    return 'Dec';
                  default:
                    return '';
                }
              },
            ),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey)),
        ),
      ),
    );
  }
}




