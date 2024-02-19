import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';
import 'package:intl/intl.dart';
import 'TrialRoomFeedBack.dart';
import 'googlefeedback.dart';
import 'sentimentdetail.dart';

class BillingFeedback extends StatefulWidget {
  const BillingFeedback({Key? key, this.stId, required this.newSelectedYear, required this.newSelectedMonth,}) : super(key: key);
  final String? stId;
  final int newSelectedYear;
  final int newSelectedMonth;
  @override
  _BillingFeedbackState createState() => _BillingFeedbackState();
}

class _BillingFeedbackState extends State<BillingFeedback> {
  List<dynamic> data = [];
  List<dynamic> lmdata = [];
  List<dynamic> lydata = [];
  List<dynamic> stores = [];
  List<String> storecodes = [];
  String? selectedStoreCode;
  List<String> storeNames = [];
  String selectedTypeOfFeedback = "BILLING";
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  int _feedbackYear = 0; // Initialize with default value
  int _feedbackMonth = 0;
  String _formattedMonth = '';
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
  int low_cleanliness_count = 0;
  int score_waiting_time = 0;
  int score_billing_time = 0;
  int score_staff_behaviour = 0;
  String? storecode;
  String? StoreCode;

  Future<void> fetchData() async {
    HttpClient client = HttpClient(context: await globalContext);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => false;
    IOClient ioClient = IOClient(client);
    Uri url = Uri.parse('https://smh-app.trent-tata.com/flask/getBillingSentimentCounts/$StoreCode/$selectedYear/$selectedMonth');
    var response = await ioClient.get(url);
    var resultJson = json.decode(response.body);
    print("https://smh-app.trent-tata.com/flask/getBillingSentimentCounts/$StoreCode/$selectedYear/$selectedMonth");

    if (response.statusCode == 200) {
      setState(() {
        data = jsonDecode(response.body);

        good_waiting_time_count = int.parse(data.first['good_waiting_time_count'].toString());
        good_billing_time_count = int.parse(data.first['good_billing_time_count'].toString());
        good_staff_behaviour_count = int.parse(data.first['good_staff_behaviour_count'].toString());
        good_total_count = int.parse(data.first['good_total_count'].toString());
        good_average = int.parse(data.first['good_average'].toString());

        medium_waiting_time_count = int.parse(data.first['medium_waiting_time_count'].toString());
        medium_billing_time_count = int.parse(data.first['medium_billing_time_count'].toString());
        medium_staff_behaviour_count = int.parse(data.first['medium_staff_behaviour_count'].toString());
        medium_total_count = int.parse(data.first['medium_total_count'].toString());
        medium_average = int.parse(data.first['medium_average'].toString());

        low_waiting_time_count = int.parse(data.first['low_waiting_time_count'].toString());
        low_billing_time_count = int.parse(data.first['low_billing_time_count'].toString());
        low_staff_behaviour_count = int.parse(data.first['low_staff_behaviour_count'].toString());
        low_total_count = int.parse(data.first['low_total_count'].toString());
        low_average = int.parse(data.first['low_average'].toString());

        score_waiting_time = int.parse(data.first['score_waiting_time'].toString());
        score_billing_time = int.parse(data.first['score_billing_time'].toString());
        score_staff_behaviour = int.parse(data.first['score_staff_behaviour'].toString());
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<SecurityContext> get globalContext async {
    final sslCert1 = await rootBundle.load('assets/starttrent.pem');
    SecurityContext sc = SecurityContext(withTrustedRoots: false);
    sc.setTrustedCertificatesBytes(sslCert1.buffer.asInt8List());
    return sc;
  }

  Future<void> getWhichStore() async {
    HttpClient client = HttpClient();
    client.badCertificateCallback =
    ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);
    final storeResponse = await ioClient.post(
      Uri.parse("https://smh-app.trent-tata.com/flask/get_which_store"),
      body: json.encode({"storeId": widget.stId.toString()}),
      headers: {
        "content-type": "application/json",
      },
    );
    var storeJson = json.decode(storeResponse.body);
    setState(() {
      storecode = storeJson[0]['code'];
      StoreCode = storecode ?? '';
    });
    print("storeCode.......$storecode");
    print("STORECODE-$StoreCode");
    fetchData();
  }

  @override
  void initState() {
    getWhichStore();
    super.initState();
    selectedYear = widget.newSelectedYear;
    selectedMonth = widget.newSelectedMonth;
    _formattedMonth = DateFormat('MMMM').format(DateTime(1, selectedMonth)).toUpperCase(); // Format month as full name
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
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
          title: const Text('Voice of Customer Billing Table',
              style: TextStyle(fontSize: 16, color: Colors.white)),
          automaticallyImplyLeading: false,
          leading: IconButton(
              onPressed: () {
                // Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              )),
          titleSpacing: 00.0,
          centerTitle: true,
          toolbarHeight: 50.2,
          toolbarOpacity: 0.8,
          backgroundColor: Colors.black,
          elevation: 0.00,
        ),
        body: Column(children: [
          Container(
            padding:
            const EdgeInsets.only(left: 30, bottom: 0, right: 30, top: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10.0),
                  alignment: Alignment.center,
                  child: StoreCode == null
                      ? const Text(
                    '',
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  )
                      : Text(
                    StoreCode!,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
                DropdownButton<int>(
                  value: selectedYear,
                  items: <int>[
                    selectedYear - 2,
                    selectedYear - 1,
                    selectedYear,
                    selectedYear + 1,
                    selectedYear + 2
                  ].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (int? value) {
                    setState(() {
                      selectedYear = value!;
                      fetchData();
                    });
                  },
                ),
                DropdownButton<int>(
                  value: selectedMonth,
                  items: <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
                      .map((int month) {
                    List<String> monthNames = [
                      '',
                      'January',
                      'February',
                      'March',
                      'April',
                      'May',
                      'June',
                      'July',
                      'August',
                      'September',
                      'October',
                      'November',
                      'December'
                    ];
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
                    });
                  },
                ),
                DropdownButton<String>(
                  value: selectedTypeOfFeedback,
                  items:
                  ["BILLING", "TRIAL ROOM", "GOOGLE"].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedTypeOfFeedback = value!;
                      fetchData();
                      if (selectedTypeOfFeedback == "GOOGLE") {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                googlefeedback(stId: widget.stId,
                                  newSelectedYear: selectedYear, // Use selectedYear
                                  newSelectedMonth:  selectedMonth,

                                ),
                          ),
                        );
                      } else if (selectedTypeOfFeedback == "TRIAL ROOM") {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TrialRoomFeedback(stId: widget.stId,
                                  newSelectedYear: selectedYear, // Use selectedYear
                                  newSelectedMonth: selectedMonth,
                                ),
                          ),
                        );
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          FittedBox(
            child: DataTable(
              headingRowHeight: 50,
              headingRowColor:
              MaterialStateColor.resolveWith((states) => Colors.grey.shade200),
              columns: const [
                DataColumn(
                    label: Center(
                        child: Text('SENTIMENT',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black)))),
                DataColumn(
                    label: Center(
                        child: Text('WAITING TIME',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black)))),
                DataColumn(
                  label: Center(
                      child: Text('BILLING TIME',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black))),
                ),
                DataColumn(
                    label: Center(
                        child: Text('STAFF BEHAVIOUR',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black)))),
                DataColumn(
                    label: Center(
                        child: Text('TOTAL',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black)))),
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
                    dataRowHeight: 45,
                    headingRowColor: MaterialStateColor.resolveWith(
                            (states) => Colors.black45),
                    columns: const [
                      DataColumn(
                          label: Center(
                              child: Text('\t\t\t\t\t\t\t\t\t',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.white)))),
                      DataColumn(
                          label: Center(
                              child: Text('\t\t\t\t\t\t\t\t\t',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.white)))),
                      DataColumn(
                        label: Center(
                            child: Text('\t\t\t\t\t\t\t\t\t',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.white))),
                      ),
                      DataColumn(
                          label: Center(
                              child: Text('\t\t\t\t\t\t\t\t\t',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.white)))),
                      DataColumn(
                          label: Center(
                              child: Text('\t\t\t\t\t\t\t\t\t',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.white)))),
                    ],
                    rows: [
                      DataRow(cells: [
                        DataCell(Container(
                            padding: const EdgeInsets.only(left: 50),
                            width: 100,
                            child: const Text('😀'))),
                        DataCell(
                          Container(
                            // color: Colors.yellow,
                            width: 100,
                            padding: const EdgeInsets.only(left: 50),
                            child: Row(
                              children: [
                                // Space between the arrow icon and the text

                                Text(good_waiting_time_count.toString(),
                                    textAlign: TextAlign.left),
                              ],
                            ),
                          ),
                          onTap: () {
                            // handleShowDetail('good', 'waiting_time', false);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SentimentDetail(
                                  feedbacktype: selectedTypeOfFeedback,
                                  storeid: StoreCode!,
                                  year: selectedYear.toString(),
                                  month: selectedMonth.toString(),
                                  sentimentname: 'good',
                                  sentimenttype: 'waiting_time',
                                ),
                              ),
                            );
                          },
                        ),
                        DataCell(
                          Container(
                            // color: Colors.yellow,
                            width: 100,
                            padding: const EdgeInsets.only(left: 50),
                            child: Row(
                              children: [
                                // Space between the arrow icon and the text

                                Text(good_billing_time_count.toString(),
                                    textAlign: TextAlign.left),
                              ],
                            ),
                          ),
                          onTap: () {
                            // handleShowDetail('good', 'waiting_time', false);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SentimentDetail(
                                  feedbacktype: selectedTypeOfFeedback,
                                  storeid: StoreCode!,
                                  year: selectedYear.toString(),
                                  month: selectedMonth.toString(),
                                  sentimentname: 'good',
                                  sentimenttype: 'billing_time',
                                ),
                              ),
                            );
                          },
                        ),
                        DataCell(
                          Container(
                            // color: Colors.yellow,
                            width: 100,
                            padding: const EdgeInsets.only(left: 60),
                            child: Row(
                              children: [
                                Text(good_staff_behaviour_count.toString(),
                                    textAlign: TextAlign.left),
                              ],
                            ),
                          ),
                          onTap: () {
                            // handleShowDetail('good', 'waiting_time', false);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SentimentDetail(
                                  feedbacktype: selectedTypeOfFeedback,
                                  storeid: StoreCode!,
                                  year: selectedYear.toString(),
                                  month: selectedMonth.toString(),
                                  sentimentname: 'good',
                                  sentimenttype: 'staff_behaviour',
                                ),
                              ),
                            );
                          },
                        ),
                        DataCell(
                          Container(
                            // color: Colors.yellow,
                            width: 100,
                            padding: const EdgeInsets.only(left: 50),
                            child: Row(
                              children: [
                                Text(good_total_count.toString(),
                                    textAlign: TextAlign.left),
                              ],
                            ),
                          ),
                          onTap: () {
                            // handleShowDetail('good', 'waiting_time', false);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SentimentDetail(
                                  feedbacktype: selectedTypeOfFeedback,
                                  storeid: StoreCode!,
                                  year: selectedYear.toString(),
                                  month: selectedMonth.toString(),
                                  sentimentname: 'good',
                                  sentimenttype: 'total',
                                ),
                              ),
                            );
                          },
                        ),
                      ]),
                      DataRow(cells: [
                        DataCell(Container(
                            padding: const EdgeInsets.only(left: 50),
                            child: const Text('😐'))),
                        DataCell(
                          Container(
                            // color: Colors.yellow,
                            width: 100,
                            padding: EdgeInsets.only(left: 50),
                            child: Row(
                              children: [
                                // Space between the arrow icon and the text

                                Text(medium_waiting_time_count.toString(),
                                    textAlign: TextAlign.left),
                              ],
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SentimentDetail(
                                  feedbacktype: selectedTypeOfFeedback,
                                  storeid: StoreCode!,
                                  year: selectedYear.toString(),
                                  month: selectedMonth.toString(),
                                  sentimentname: 'medium',
                                  sentimenttype: 'waiting_time',
                                ),
                              ),
                            );
                          },
                        ),
                        DataCell(
                          Container(
                            // color: Colors.yellow,
                            width: 100,
                            padding: const EdgeInsets.only(left: 50),
                            child: Row(
                              children: [
                                Text(medium_billing_time_count.toString(),
                                    textAlign: TextAlign.left),
                              ],
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SentimentDetail(
                                  feedbacktype: selectedTypeOfFeedback,
                                  storeid: StoreCode!,
                                  year: selectedYear.toString(),
                                  month: selectedMonth.toString(),
                                  sentimentname: 'medium',
                                  sentimenttype: 'billing_time',
                                ),
                              ),
                            );
                          },
                        ),
                        DataCell(
                          Container(
                            // color: Colors.yellow,
                            width: 100,
                            padding: const EdgeInsets.only(left: 60),
                            child: Row(
                              children: [
                                Text(medium_staff_behaviour_count.toString(),
                                    textAlign: TextAlign.left),
                              ],
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SentimentDetail(
                                  feedbacktype: selectedTypeOfFeedback,
                                  storeid: StoreCode!,
                                  year: selectedYear.toString(),
                                  month: selectedMonth.toString(),
                                  sentimentname: 'medium',
                                  sentimenttype: 'staff_behaviour',
                                ),
                              ),
                            );
                          },
                        ),
                        DataCell(
                          Container(
                            // color: Colors.yellow,
                            width: 100,
                            padding: const EdgeInsets.only(left: 50),
                            child: Row(
                              children: [
                                Text(medium_total_count.toString(),
                                    textAlign: TextAlign.left),
                                const SizedBox(width: 10),
                              ],
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SentimentDetail(
                                  feedbacktype: selectedTypeOfFeedback,
                                  storeid: StoreCode!,
                                  year: selectedYear.toString(),
                                  month: selectedMonth.toString(),
                                  sentimentname: 'medium',
                                  sentimenttype: 'total',
                                ),
                              ),
                            );
                          },
                        ),
                      ]),
                      DataRow(cells: [
                        DataCell(Container(
                            padding: const EdgeInsets.only(left: 50),
                            child: const Text('😞'))),
                        DataCell(
                          Container(
                            // color: Colors.yellow,
                            width: 100,
                            padding: const EdgeInsets.only(left: 50),
                            child: Row(
                              children: [
                                Text(low_waiting_time_count.toString(),
                                    textAlign: TextAlign.left),
                              ],
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SentimentDetail(
                                  feedbacktype: selectedTypeOfFeedback,
                                  storeid: StoreCode!,
                                  year: selectedYear.toString(),
                                  month: selectedMonth.toString(),
                                  sentimentname: 'low',
                                  sentimenttype: 'waiting_time',
                                ),
                              ),
                            );
                          },
                        ),
                        DataCell(
                          Container(
                            // color: Colors.yellow,
                            width: 100,
                            padding: const EdgeInsets.only(left: 50),
                            child: Row(
                              children: [
                                Text(low_billing_time_count.toString(),
                                    textAlign: TextAlign.left),
                              ],
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SentimentDetail(
                                  feedbacktype: selectedTypeOfFeedback,
                                  storeid: StoreCode!,
                                  year: selectedYear.toString(),
                                  month: selectedMonth.toString(),
                                  sentimentname: 'low',
                                  sentimenttype: 'billing_time',
                                ),
                              ),
                            );
                          },
                        ),
                        DataCell(
                          Container(
                            // color: Colors.yellow,
                            width: 100,
                            padding: const EdgeInsets.only(left: 60),
                            child: Row(
                              children: [
                                // Space between the arrow icon and the text

                                Text(low_staff_behaviour_count.toString(),
                                    textAlign: TextAlign.left),
                              ],
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SentimentDetail(
                                  feedbacktype: selectedTypeOfFeedback,
                                  storeid: StoreCode!,
                                  year: selectedYear.toString(),
                                  month: selectedMonth.toString(),
                                  sentimentname: 'low',
                                  sentimenttype: 'staff_behaviour',
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
                                Text(low_total_count.toString(),
                                    textAlign: TextAlign.left),
                              ],
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SentimentDetail(
                                  feedbacktype: selectedTypeOfFeedback,
                                  storeid: StoreCode!,
                                  year: selectedYear.toString(),
                                  month: selectedMonth.toString(),
                                  sentimentname: 'low',
                                  sentimenttype: 'total',
                                ),
                              ),
                            );
                          },
                        ),
                      ]),
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

                                Text(score_waiting_time.toString(),
                                    textAlign: TextAlign.left),
                                const SizedBox(width: 10),
                              ],
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                              width: 100,
                              padding: EdgeInsets.only(left: 50),
                              child: Text(score_billing_time.toString())),
                        ),
                        DataCell(
                          Container(
                              width: 100,
                              padding: EdgeInsets.only(left: 60),
                              child: Text(
                                score_staff_behaviour.toString(),
                                textAlign: TextAlign.left,
                              )),
                        ),
                        DataCell(
                          Container(
                              width: 100,
                              padding: EdgeInsets.only(left: 50),
                              child: Text(
                                " ",
                                textAlign: TextAlign.left,
                              )),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SentimentDetail(
                                  feedbacktype: selectedTypeOfFeedback,
                                  storeid: StoreCode!,
                                  year: selectedYear.toString(),
                                  month: selectedMonth.toString(),
                                  sentimentname: 'low',
                                  sentimenttype: 'total',
                                ),
                              ),
                            );
                          },
                        ),
                      ]),
                    ]),
              )),
        ]));
  }
}
