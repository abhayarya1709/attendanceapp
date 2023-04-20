// ignore_for_file: unnecessary_statements, unused_local_variable, cancel_subscriptions, unused_field, unused_import

import 'dart:async';
import 'package:attendanceapp/model/user.dart';
import 'package:attendanceapp/calendarscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_geofencing/enums/geofence_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
// import 'package:local_auth/local_auth.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:easy_geofencing/easy_geofencing.dart';
import 'api/local_auth_api.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class TodayScreen extends StatefulWidget {
  const TodayScreen({Key? key}) : super(key: key);

  @override
  _TodayScreenState createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  double screenHeight = 0;
  double screenWidth = 0;
  late bool _isInsideGeofence;
  late bool checkedIn = true;
  String checkIn = "--/--";
  String checkOut = "--/--";
  String location = " ";
  String scanResult = " ";
  String officeCode = " ";

  Color primary = const Color(0xffeef444c);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      _getRecord();
      _getOfficeCode();
      _geofencing();
    });

  }

  void _getOfficeCode() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection("Attributes")
        .doc("Office1")
        .get();
    setState(() {
      officeCode = snap['code'];
    });
  }



  // Future<void> scanQRandCheck() async {
  //   String result = " ";
  //
  //   try {
  //     result = await FlutterBarcodeScanner.scanBarcode(
  //       "#ffffff",
  //       "Cancel",
  //       false,
  //       ScanMode.QR,
  //     );
  //   } catch (e) {
  //     print("error");
  //   }
  //
  //   setState(() {
  //     scanResult = result;
  //   });
  //
  //   if (scanResult == officeCode) {
  //     if (User.lat != 0) {
  //       _getLocation();
  //
  //       QuerySnapshot snap = await FirebaseFirestore.instance
  //           .collection("Employee")
  //           .where('id', isEqualTo: User.employeeId)
  //           .get();
  //
  //       DocumentSnapshot snap2 = await FirebaseFirestore.instance
  //           .collection("Employee")
  //           .doc(snap.docs[0].id)
  //           .collection("Record")
  //           .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
  //           .get();
  //
  //       try {
  //         String checkIn = snap2['checkIn'];
  //
  //         setState(() {
  //           checkOut = DateFormat('hh:mm').format(DateTime.now());
  //           checkedIn = false;
  //         });
  //
  //         await FirebaseFirestore.instance
  //             .collection("Employee")
  //             .doc(snap.docs[0].id)
  //             .collection("Record")
  //             .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
  //             .update({
  //           'date': Timestamp.now(),
  //           'checkIn': checkIn,
  //           'checkOut': DateFormat('hh:mm').format(DateTime.now()),
  //           'checkInLocation': location,
  //         });
  //       } catch (e) {
  //         setState(() {
  //           checkIn = DateFormat('hh:mm').format(DateTime.now());
  //           checkedIn = true;
  //         });
  //
  //         await FirebaseFirestore.instance
  //             .collection("Employee")
  //             .doc(snap.docs[0].id)
  //             .collection("Record")
  //             .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
  //             .set({
  //           'date': Timestamp.now(),
  //           'checkIn': DateFormat('hh:mm').format(DateTime.now()),
  //           'checkOut': "--/--",
  //           'checkOutLocation': location,
  //         });
  //       }
  //     } else {
  //       Timer(const Duration(seconds: 3), () async {
  //         _getLocation();
  //
  //         QuerySnapshot snap = await FirebaseFirestore.instance
  //             .collection("Employee")
  //             .where('id', isEqualTo: User.employeeId)
  //             .get();
  //
  //         DocumentSnapshot snap2 = await FirebaseFirestore.instance
  //             .collection("Employee")
  //             .doc(snap.docs[0].id)
  //             .collection("Record")
  //             .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
  //             .get();
  //
  //         try {
  //           String checkIn = snap2['checkIn'];
  //
  //           setState(() {
  //             checkOut = DateFormat('hh:mm').format(DateTime.now());
  //             checkedIn = false;
  //           });
  //
  //           await FirebaseFirestore.instance
  //               .collection("Employee")
  //               .doc(snap.docs[0].id)
  //               .collection("Record")
  //               .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
  //               .update({
  //             'date': Timestamp.now(),
  //             'checkIn': checkIn,
  //             'checkOut': DateFormat('hh:mm').format(DateTime.now()),
  //             'checkInLocation': location,
  //           });
  //         } catch (e) {
  //           setState(() {
  //             checkIn = DateFormat('hh:mm').format(DateTime.now());
  //             checkedIn = true;
  //           });
  //
  //           await FirebaseFirestore.instance
  //               .collection("Employee")
  //               .doc(snap.docs[0].id)
  //               .collection("Record")
  //               .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
  //               .set({
  //             'date': Timestamp.now(),
  //             'checkIn': DateFormat('hh:mm').format(DateTime.now()),
  //             'checkOut': "--/--",
  //             'checkOutLocation': location,
  //           });
  //         }
  //       });
  //     }
  //   }
  // }

  void _getLocation() async {
    List<Placemark> placemark =
        await placemarkFromCoordinates(User.lat, User.long);

    setState(() {
      location =
          "${placemark[0].street}, ${placemark[0].administrativeArea}, ${placemark[0].postalCode}, ${placemark[0].country}";
    });
  }

  void sendCheckInData(String employeeCode, String serialNo, String logDate) async {
    String baseUrl = "http://attendance.actofit.in:8000";
    var url = Uri.parse('$baseUrl/api/user/attendance/add');
    var body = {
      "EmployeeCode":employeeCode,
      "SerialNumber":serialNo,
      "Direction":"in",
      "LogDate":logDate,
    };

    // Await the http get response, then decode the json-formatted response.
    var response = await http.post(url,body: body,);
    if (response.statusCode == 200) {
      debugPrint('CheckIn Time Added');
    } else {
      debugPrint('Error in adding CheckIn Time');
    }
  }
  void sendCheckOutData(String employeeCode, String serialNo, String logDate) async {
    String baseUrl = "http://attendance.actofit.in:8000";
    var url = Uri.parse('$baseUrl/api/user/attendance/add');
    var body = {
      "EmployeeCode":employeeCode,
      "SerialNumber":serialNo,
      "Direction":"out",
      "LogDate":logDate,
    };

    // Await the http get response, then decode the json-formatted response.
    var response = await http.post(url,body: body,);
    if (response.statusCode == 200) {
      debugPrint('CheckOut Time Added');
    } else {
      debugPrint('Error in adding CheckOut Time');
    }
  }

  void _getRecord() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection("Employee")
          .where('id', isEqualTo: User.employeeId)
          .get();

      DocumentSnapshot snap2 = await FirebaseFirestore.instance
          .collection("Employee")
          .doc(snap.docs[0].id)
          .collection("Record")
          .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
          .get();

      setState(() {
        checkIn = snap2['checkIn'];
        checkOut = snap2['checkOut'];
      });
    } catch (e) {
      setState(() {
        checkIn = "--/--";
        checkOut = "--/--";
      });
    }
    print('checkIn: $checkIn');
    if (checkIn == '--/--') {
      setState(() {
        checkedIn = false;
      });
    }
  }

  void _geofencing() async {
    EasyGeofencing.startGeofenceService(
        pointedLatitude: "19.053511",
        pointedLongitude: "72.891398",
        radiusMeter: "30.0",
        eventPeriodInSeconds: 5);
    StreamSubscription<GeofenceStatus> geofenceStatusStream =
        EasyGeofencing.getGeofenceStream()!.listen((GeofenceStatus status) {
      if (status == GeofenceStatus.enter) {
        _isInsideGeofence = true;
      } else if (status == GeofenceStatus.exit) {
        _isInsideGeofence = false;
      }
      print(_isInsideGeofence);
      if (checkedIn == true && _isInsideGeofence == false) {
        Timer(const Duration(seconds: 3), () async {
          _getLocation();

          QuerySnapshot snap = await FirebaseFirestore.instance
              .collection("Employee")
              .where('id', isEqualTo: User.employeeId)
              .get();

          DocumentSnapshot snap2 = await FirebaseFirestore.instance
              .collection("Employee")
              .doc(snap.docs[0].id)
              .collection("Record")
              .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
              .get();

          try {
            String checkIn = snap2['checkIn'];
            sendCheckOutData("0909112221", "QRGEM00001", DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now()));
            setState(() {
              checkOut = DateFormat('hh:mm').format(DateTime.now());
              checkedIn = false;
            });

            await FirebaseFirestore.instance
                .collection("Employee")
                .doc(snap.docs[0].id)
                .collection("Record")
                .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
                .update({
              'date': Timestamp.now(),
              'checkIn': checkIn,
              'checkOut': DateFormat('hh:mm').format(DateTime.now()),
              'checkInLocation': location,
            });
          } catch (e) {
            setState(() {
              checkIn = DateFormat('hh:mm').format(DateTime.now());
              checkedIn = true;
            });
            sendCheckInData("0909112221", "QRGEM00001", DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now()));
            await FirebaseFirestore.instance
                .collection("Employee")
                .doc(snap.docs[0].id)
                .collection("Record")
                .doc(DateFormat('dd MMMM yyyy').format(DateTime.now()))
                .set({
              'date': Timestamp.now(),
              'checkIn': DateFormat('hh:mm').format(DateTime.now()),
              'checkOut': "--/--",
              'checkOutLocation': location,
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(top: 32),
            child: Text(
              "Welcome,",
              style: TextStyle(
                color: Colors.black54,
                fontFamily: "NexaRegular",
                fontSize: screenWidth / 20,
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              "Employee " + User.employeeId,
              style: TextStyle(
                fontFamily: "NexaBold",
                fontSize: screenWidth / 18,
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(top: 32),
            child: Text(
              "Today's Status",
              style: TextStyle(
                fontFamily: "NexaBold",
                fontSize: screenWidth / 18,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 32),
            height: 150,
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(2, 2),
                ),
              ],
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Check In",
                        style: TextStyle(
                          fontFamily: "NexaRegular",
                          fontSize: screenWidth / 20,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        checkIn,
                        style: TextStyle(
                          fontFamily: "NexaBold",
                          fontSize: screenWidth / 18,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Check Out",
                        style: TextStyle(
                          fontFamily: "NexaRegular",
                          fontSize: screenWidth / 20,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        checkOut,
                        style: TextStyle(
                          fontFamily: "NexaBold",
                          fontSize: screenWidth / 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  text: DateTime.now().day.toString(),
                  style: TextStyle(
                    color: primary,
                    fontSize: screenWidth / 18,
                    fontFamily: "NexaBold",
                  ),
                  children: [
                    TextSpan(
                      text: DateFormat(' MMMM yyyy').format(DateTime.now()),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenWidth / 20,
                        fontFamily: "NexaBold",
                      ),
                    ),
                  ],
                ),
              )),
          StreamBuilder(
            stream: Stream.periodic(const Duration(seconds: 1)),
            builder: (context, snapshot) {
              return Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  DateFormat('hh:mm:ss a').format(DateTime.now()),
                  style: TextStyle(
                    fontFamily: "NexaRegular",
                    fontSize: screenWidth / 20,
                    color: Colors.black54,
                  ),
                ),
              );
            },
          ),
          checkOut == "--/--"
              ?
          Container(
                  margin: const EdgeInsets.only(top: 24, bottom: 12),
                  child: Builder(
                    builder: (context) {
                      final GlobalKey<SlideActionState> key = GlobalKey();

                      return Column(
                        children: [
                          // buildAvailability(context),
                          // SizedBox(height: 24),
                          // buildAuthenticate(context),
                          SizedBox(height: 24),
                          SlideAction(
                            text: checkIn == "--/--"
                                ? "Slide to Check In"
                                : "Slide to Check Out",
                            textStyle: TextStyle(
                              color: Colors.black54,
                              fontSize: screenWidth / 20,
                              fontFamily: "NexaRegular",
                            ),
                            outerColor: Colors.white,
                            innerColor: primary,
                            key: key,
                            onSubmit: () async {
                              // final isAuthenticated =
                              //     await LocalAuthApi.authenticate();
                              final bool isAuthenticated = true;
                              if (User.lat != 0 && isAuthenticated) {
                                if (!_isInsideGeofence) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text("You are not inside the office"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  key.currentState!.reset();
                                } else {
                                  _getLocation();
                                  QuerySnapshot snap = await FirebaseFirestore
                                      .instance
                                      .collection("Employee")
                                      .where('id', isEqualTo: User.employeeId)
                                      .get();

                                  DocumentSnapshot snap2 =
                                      await FirebaseFirestore.instance
                                          .collection("Employee")
                                          .doc(snap.docs[0].id)
                                          .collection("Record")
                                          .doc(DateFormat('dd MMMM yyyy')
                                              .format(DateTime.now()))
                                          .get();

                                  try {
                                    String checkIn = snap2['checkIn'];
                                    sendCheckOutData("0909112221", "QRGEM00001", DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now()));
                                    setState(() {
                                      checkOut = DateFormat('hh:mm')
                                          .format(DateTime.now());
                                      checkedIn = false;
                                    });

                                    await FirebaseFirestore.instance
                                        .collection("Employee")
                                        .doc(snap.docs[0].id)
                                        .collection("Record")
                                        .doc(DateFormat('dd MMMM yyyy')
                                            .format(DateTime.now()))
                                        .update({
                                      'date': Timestamp.now(),
                                      'checkIn': checkIn,
                                      'checkOut': DateFormat('hh:mm')
                                          .format(DateTime.now()),
                                      'checkInLocation': location,
                                    });
                                  } catch (e) {
                                    sendCheckInData("0909112221", "QRGEM00001",DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now()));
                                    setState(() {
                                      checkIn = DateFormat('hh:mm')
                                          .format(DateTime.now());
                                      checkedIn = true;
                                    });

                                    await FirebaseFirestore.instance
                                        .collection("Employee")
                                        .doc(snap.docs[0].id)
                                        .collection("Record")
                                        .doc(DateFormat('dd MMMM yyyy')
                                            .format(DateTime.now()))
                                        .set({
                                      'date': Timestamp.now(),
                                      'checkIn': DateFormat('hh:mm')
                                          .format(DateTime.now()),
                                      'checkOut': "--/--",
                                      'checkOutLocation': location,
                                    });
                                  }

                                  key.currentState!.reset();
                                }
                              } else {
                                Timer(const Duration(seconds: 3), () async {
                                  _getLocation();
                                  sendCheckOutData("0909112221", "QRGEM00001", DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now()));
                                  QuerySnapshot snap = await FirebaseFirestore
                                      .instance
                                      .collection("Employee")
                                      .where('id', isEqualTo: User.employeeId)
                                      .get();

                                  DocumentSnapshot snap2 =
                                      await FirebaseFirestore.instance
                                          .collection("Employee")
                                          .doc(snap.docs[0].id)
                                          .collection("Record")
                                          .doc(DateFormat('dd MMMM yyyy')
                                              .format(DateTime.now()))
                                          .get();

                                  try {
                                    String checkIn = snap2['checkIn'];

                                    setState(() {
                                      checkOut = DateFormat('hh:mm')
                                          .format(DateTime.now());
                                      checkedIn = false;
                                    });

                                    await FirebaseFirestore.instance
                                        .collection("Employee")
                                        .doc(snap.docs[0].id)
                                        .collection("Record")
                                        .doc(DateFormat('dd MMMM yyyy')
                                            .format(DateTime.now()))
                                        .update({
                                      'date': Timestamp.now(),
                                      'checkIn': checkIn,
                                      'checkOut': DateFormat('hh:mm')
                                          .format(DateTime.now()),
                                      'checkInLocation': location,
                                    });
                                  } catch (e) {
                                    setState(() {
                                      checkIn = DateFormat('hh:mm')
                                          .format(DateTime.now());
                                      checkedIn = true;
                                    });
                                    sendCheckInData("0909112221", "QRGEM00001",DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now()));
                                    await FirebaseFirestore.instance
                                        .collection("Employee")
                                        .doc(snap.docs[0].id)
                                        .collection("Record")
                                        .doc(DateFormat('dd MMMM yyyy')
                                            .format(DateTime.now()))
                                        .set({
                                      'date': Timestamp.now(),
                                      'checkIn': DateFormat('hh:mm')
                                          .format(DateTime.now()),
                                      'checkOut': "--/--",
                                      'checkOutLocation': location,
                                    });
                                  }

                                  key.currentState!.reset();
                                });
                              }
                            },
                          ),
                          SizedBox(height: 24),
                        ],
                      );
                    },
                  ),
                )
              : Container(
                  margin: const EdgeInsets.only(top: 32, bottom: 32),
                  child: Text(
                    "You have completed this day!",
                    style: TextStyle(
                      fontFamily: "NexaRegular",
                      fontSize: screenWidth / 20,
                      color: Colors.black54,
                    ),
                  ),
                ),
          location != " "
              ? Text(
                  "Location: " + location,
                )
              : const SizedBox(),
          // GestureDetector(
          //   onTap: () {
          //     scanQRandCheck();
          //   },
          //   child: Container(
          //     height: screenWidth / 2,
          //     width: screenWidth / 2,
          //     decoration: BoxDecoration(
          //       color: Colors.white,
          //       borderRadius: BorderRadius.circular(20),
          //       boxShadow: const [
          //         BoxShadow(
          //           color: Colors.black26,
          //           offset: Offset(2, 2),
          //           blurRadius: 10,
          //         ),
          //       ],
          //     ),
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       crossAxisAlignment: CrossAxisAlignment.center,
          //       children: [
          //         Stack(
          //           alignment: Alignment.center,
          //           children: [
          //             Icon(
          //               FontAwesomeIcons.expand,
          //               size: 70,
          //               color: primary,
          //             ),
          //             Icon(
          //               FontAwesomeIcons.camera,
          //               size: 25,
          //               color: primary,
          //             ),
          //           ],
          //         ),
          //         Container(
          //           margin: const EdgeInsets.only(
          //             top: 8,
          //           ),
          //           child: Text(
          //             checkIn == "--/--"
          //                 ? "Scan to Check In"
          //                 : "Scan to Check Out",
          //             style: TextStyle(
          //               fontFamily: "NexaRegular",
          //               fontSize: screenWidth / 20,
          //               color: Colors.black54,
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    ));
  }

  // Widget buildAvailability(BuildContext context) => buildButton(
  //       text: 'Check Availability',
  //       icon: Icons.event_available,
  //       onClicked: () async {
  //         final isAvailable = await LocalAuthApi.hasBiometrics();
  //         final biometrics = await LocalAuthApi.getBiometrics();
  //
  //         final hasFingerprint = biometrics.contains(BiometricType.fingerprint);
  //
  //         showDialog(
  //           context: context,
  //           builder: (context) => AlertDialog(
  //             title: Text('Availability'),
  //             content: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 buildText('Biometrics', isAvailable),
  //                 buildText('Fingerprint', hasFingerprint),
  //               ],
  //             ),
  //           ),
  //         );
  //       },
  //     );

  Widget buildText(String text, bool checked) => Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            checked
                ? Icon(Icons.check, color: Colors.green, size: 24)
                : Icon(Icons.close, color: Colors.red, size: 24),
            const SizedBox(width: 12),
            Text(text, style: TextStyle(fontSize: 24)),
          ],
        ),
      );

  // Widget buildAuthenticate(BuildContext context) => buildButton(
  //       text: 'Authenticate',
  //       icon: Icons.lock_open,
  //       onClicked: () async {
  //         print('clicked');
  //         final isAuthenticated = await LocalAuthApi.authenticate();
  //         print('working: $isAuthenticated');
  //
  //         if (isAuthenticated == true) {
  //           print('working: should work');
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(builder: (context) => CalendarScreen()),
  //           );
  //         } else
  //           () {
  //             print('working: should work2');
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(builder: (context) => CalendarScreen()),
  //             );
  //           };
  //       },
  //     );

  Widget buildButton({
    required String text,
    required IconData icon,
    required VoidCallback onClicked,
  }) =>
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          minimumSize: Size.fromHeight(50),
        ),
        icon: Icon(icon, size: 26),
        label: Text(
          text,
          style: TextStyle(fontSize: 20),
        ),
        onPressed: onClicked,
      );
}
