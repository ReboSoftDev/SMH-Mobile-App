import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';
import 'package:intl/intl.dart';
import 'clusterBillingFeedBack.dart';


class ClusterSentimentHome extends StatefulWidget {
  const ClusterSentimentHome({Key? key,  this.stid, required this.username, required this.newSelectedYear, required this.newStoreCode,}) : super(key: key);
  final String? stid;
  final String username;
  final int newSelectedYear;
  final String newStoreCode;
  @override
  _ClusterSentimentHomeState createState() => _ClusterSentimentHomeState();
}

class _ClusterSentimentHomeState extends State<ClusterSentimentHome> {
  List<dynamic> data = [];
  List<dynamic> stores = [];
  List<String> storecodes = [];
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  String? selectedStoreCode;
  List<String> storeNames = [];
  int billing_goods_count = 0;
  int billing_mediums_count = 0;
  int billing_lows_count = 0;
  int trial_goods_count = 0;
  int trial_mediums_count = 0;
  int trial_lows_count = 0;
  int google_goods_count = 0;
  int google_mediums_count = 0;
  int google_lows_count = 0;
  String Month =  DateFormat('MMMM').format(DateTime.now()).toUpperCase();
  int billingtotal = 0;
  int trialtotal = 0;
  int googletotal = 0;

  int totalgoods = 0;
  int totalmediums = 0;
  int totallows = 0;
  int scoreBillings = 0;
  int billingScorePercent = 0;
  int trialScorePercent = 0;
  int googleScorePercent = 0;

  String? storecode;
  String? StoreCode;


  String get username => widget.username;


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
  }


  Future<SecurityContext> get globalContext async {
    final sslCert1 = await
    rootBundle.load('assets/starttrent.pem');
    SecurityContext sc = SecurityContext(withTrustedRoots: false);
    sc.setTrustedCertificatesBytes(sslCert1.buffer.asInt8List());
    return sc;
  }
  Future<void> fetchBillingData() async {
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    Uri url = Uri.parse('https://smh-app.trent-tata.com/flask/getBillingSentimentCounts/$selectedStoreCode/$selectedYear/$selectedMonth');
    final response = await ioClient.get(url);
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    print(resultsJson);
    if (response.statusCode == 200) {
      setState(() {
        data = jsonDecode(response.body);
        billing_goods_count = int.tryParse(data.first['good_total_count'].toString()) ?? 0;
        billing_mediums_count = int.tryParse(data.first['medium_total_count'].toString()) ?? 0;
        billing_lows_count = int.tryParse(data.first['low_total_count'].toString()) ?? 0;
        totalgoods += billing_goods_count;
        totalmediums += billing_mediums_count;
        totallows += billing_lows_count;

        billingtotal = billing_goods_count + billing_mediums_count + billing_lows_count;
        //scoreBillings = (billing_goods_count * 1 + billing_mediums_count * 0.75 + billing_lows_count * 0).toInt();
        if (billingtotal != 0) {
          billingScorePercent = (((billing_goods_count * 1 + billing_mediums_count * 0.75 + billing_lows_count * 0) / billingtotal) * 100).toInt();
        } else {
          // Set billingScorePercent to 0 if billingtotal is 0
          billingScorePercent = 0;
        }
        print("billingtotal>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>$billingtotal");
        print("scoreBillings>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>$scoreBillings");
        print("billingScorePercent>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>$billingScorePercent");
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchTrialRoomData() async {
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    Uri url = Uri.parse('https://smh-app.trent-tata.com/flask/getTrialRoomSentimentCounts/$selectedStoreCode/$selectedYear/$selectedMonth');
    final response = await ioClient.get(url);
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    print(resultsJson);
    if (response.statusCode == 200) {
      setState(() {
        data = jsonDecode(response.body);
        trial_goods_count = int.tryParse(data.first['good_total_count'].toString()) ?? 0;
        trial_mediums_count = int.tryParse(data.first['medium_total_count'].toString()) ?? 0;
        trial_lows_count = int.tryParse(data.first['low_total_count'].toString()) ?? 0;
        totalgoods += trial_goods_count;
        totalmediums += trial_mediums_count;
        totallows += trial_lows_count;
        trialtotal = trial_goods_count + trial_mediums_count + trial_lows_count;
        if (trialtotal != 0) {
          trialScorePercent = (((trial_goods_count * 1 + trial_mediums_count * 0.75 + trial_lows_count * 0)/trialtotal ) * 100).toInt();
        } else {
          // Set billingScorePercent to 0 if billingtotal is 0
          trialScorePercent = 0;
        }
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchGoogleData() async {
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    Uri url = Uri.parse("https://smh-app.trent-tata.com/flask/getGoogleReviewTableData/$selectedStoreCode/$selectedYear/$Month");
    var response = await ioClient.get(url);
    print("successAPI");
    print('https://smh-app.trent-tata.com/flask/getGoogleReviewTableData/$selectedStoreCode/$selectedYear/$Month');
    var resultsJson = json.decode(response.body).cast<Map<String, dynamic>>();
    print(resultsJson);
    if (response.statusCode == 200) {
      setState(() {
        data = jsonDecode(response.body);
        google_goods_count = int.tryParse(data.first['total_review_good'].toString()) ?? 0;
        google_mediums_count = int.tryParse(data.first['total_review_average'].toString()) ?? 0;
        google_lows_count  = int.tryParse(data.first['total_review_bad'].toString()) ?? 0;
        totalgoods += google_goods_count;
        totalmediums += google_mediums_count;
        totallows  += google_lows_count;
        googletotal = google_goods_count + google_mediums_count + google_lows_count;
        if (googletotal != 0) {
          googleScorePercent = (((google_goods_count * 1 + google_mediums_count * 0.75 + google_lows_count * 0)/googletotal ) * 100).toInt();
        } else {
          // Set billingScorePercent to 0 if billingtotal is 0
          googleScorePercent = 0;
        }
      });
    } else {
      throw Exception('Failed to load data');
    }
  }




  @override
  void initState() {
    getWhichStore();
    super.initState();
    selectedYear = widget.newSelectedYear;
    selectedStoreCode = widget.newStoreCode;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    billingtotal = 0;
    trialtotal = 0;
    googletotal = 0;

    totalgoods = 0;
    totalmediums = 0;
    totallows = 0;
    fetchBillingData();
    fetchTrialRoomData();
    fetchGoogleData();
    fetchStores();

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
      appBar: AppBar(title: const Text('Voice Of Customer Summary Report', style: TextStyle(fontSize: 16,color: Colors.white)),
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
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                          fetchBillingData();
                          fetchTrialRoomData();
                          fetchGoogleData();
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
                      hint: const Text('year'),
                      items: <int>[selectedYear - 2, selectedYear - 1, selectedYear, selectedYear + 1, selectedYear + 2].map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                      onChanged: (int? value) {
                        setState(() {
                          selectedYear = value!;
                          billingtotal = 0;
                          trialtotal = 0;
                          googletotal = 0;
                          print(">>>>>>>>>>>>>>>>>>>>>>>>$selectedYear");
                          totalgoods = 0;
                          totalmediums = 0;
                          totallows = 0;
                          fetchBillingData();
                          fetchTrialRoomData();
                          fetchGoogleData();
                        });
                      },
                    ),
                    DropdownButton<int>(
                      value: selectedMonth,
                      hint: Text("month"),
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
                          billingtotal = 0;
                          trialtotal = 0;
                          googletotal = 0;
                          totalgoods = 0;
                          totalmediums = 0;
                          totallows = 0;

                          Month = DateFormat('MMMM').format(DateTime(selectedYear, selectedMonth)).toUpperCase();
                          print(">>>>>>>>>>>>>>>>>>>>>>>>$Month");
                          fetchBillingData();
                          fetchTrialRoomData();
                          fetchGoogleData();
                        });
                      },
                    ),
                    Container(
                      width: 150,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          // Add your button click logic here
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ClusterBillingFeedback(
                                stId:widget.stid,
                                username: username,
                                newSelectedYear: selectedYear, // Pass selected year
                                newSelectedMonth: selectedMonth,
                                newStoreCode: selectedStoreCode.toString(),
                            )),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.black,
                          onPrimary: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                          minimumSize: Size(70, 35), //////// HERE
                        ),

                        child: Text('Detail Report'),
                      ),
                    ),

                  ],
                ),
              ),
              (data.isEmpty) ?
              Container(child:const Center(
                  child: Text('Data is empty')),
              )
                  :  FittedBox(
                child: DataTable(
                  headingRowHeight: 40,
                  dataRowHeight: 40,
                  // columnSpacing: 100,
                  headingRowColor:
                  MaterialStateColor.resolveWith((states) =>
                  Colors.black45),
                  columns: const [
                    DataColumn(label: Text('SENTIMENT' ,style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white))),
                    DataColumn(label: Text('BILLING', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white))),
                    DataColumn(label: Text('TRIAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white))),
                    DataColumn(label: Text('GOOGLE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white))),
                    //   DataColumn(label: Text('PERCENTAGE %', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white))),
                  ],

                  rows: [
                    DataRow(cells: [
                      DataCell(Container(
                          width:40,
                          child: Text('😀', textAlign: TextAlign.right))),
                      DataCell(
                        Container(
                            width:40,
                            child:Text(billing_goods_count.toString(),textAlign: TextAlign.center,)),
                      ),
                      DataCell(
                        Container(
                            width:40,
                            child:Text(trial_goods_count.toString(),textAlign: TextAlign.center,)),
                      ),
                      DataCell(
                        Container(
                            width:40,
                            child:Text(google_goods_count.toString(),textAlign: TextAlign.center,)),
                      ),
                      // DataCell(
                      //   Container(
                      //       width:40,
                      //       child:Text((billingtotal + trialtotal + googletotal) > 0 ?
                      //       ((totalgoods) * 100 / (billingtotal + trialtotal + googletotal)).round().toString()
                      //           : 0.toString(),textAlign: TextAlign.right,)),
                      // ),
                    ]),
                    DataRow(cells: [
                      DataCell(Container(
                          width:40,
                          child: Text('😐', textAlign: TextAlign.right))),
                      DataCell(
                          Container(
                              width:40,
                              child:Text(billing_mediums_count.toString(),textAlign: TextAlign.center,))),
                      DataCell(
                        Container(
                          width:40,
                          child:Text(trial_mediums_count.toString(),textAlign: TextAlign.center,),),
                      ),
                      DataCell(
                        Container(
                          width:40,
                          child:Text(google_mediums_count.toString(),textAlign: TextAlign.center,),),
                      ),
                      // DataCell(
                      //     Container(
                      //       width:40,
                      //       child:Text((billingtotal + trialtotal + googletotal) > 0 ?
                      //       ((totalmediums) * 100 / (billingtotal + trialtotal + googletotal)).round().toString()
                      //           : 0.toString(),textAlign: TextAlign.right,),),
                      //     ),
                    ]),
                    DataRow(cells: [
                      DataCell(Container(
                          width:40,
                          child: Text('😞', textAlign: TextAlign.right))),
                      DataCell(
                        Container(
                          width:40,
                          child:Text(billing_lows_count.toString(),textAlign: TextAlign.center,),),
                      ),
                      DataCell(
                        Container(
                          width:40,
                          child:Text(trial_lows_count.toString(),textAlign: TextAlign.center,),),
                      ),
                      DataCell(
                        Container(
                          width:40,
                          child:Text(google_lows_count.toString(),textAlign: TextAlign.center,),),
                      ),
                      // DataCell(
                      //   Container(
                      //     width:40,
                      //     child:Text((billingtotal + trialtotal + googletotal) > 0 ?
                      //     ((totallows) * 100 / (billingtotal + trialtotal + googletotal)).round().toString()
                      //         : 0.toString(),textAlign: TextAlign.right,),),
                      // ),
                    ]),
                    DataRow(cells: [
                      DataCell(Container(
                          width:50,
                          child: Text('SCORE', textAlign: TextAlign.center))),
                      DataCell(
                        Container(
                          width:40,
                          child:Text(billingScorePercent.toString(),textAlign: TextAlign.center,),),
                      ),
                      DataCell(
                        Container(
                          width:40,
                          child:Text(trialScorePercent.toString(),textAlign: TextAlign.center),),
                      ),
                      DataCell(
                        Container(
                          width:40,
                          child:Text(googleScorePercent.toString(),textAlign: TextAlign.center,),),
                      ),
                      // DataCell(Text('')),
                    ]),

                  ],
                ),
              ),


            ],
          )
      ),

    );

  }

}
