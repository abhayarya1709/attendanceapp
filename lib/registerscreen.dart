// ignore_for_file: non_constant_identifier_names

import 'package:attendanceapp/homescreen.dart';
import 'package:attendanceapp/loginscreen.dart';
import 'package:attendanceapp/services/location_service.dart';
import 'package:attendanceapp/utils/prefs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_field/intl_phone_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController idController = TextEditingController();
  TextEditingController passController = TextEditingController();
  // TextEditingController contactController = TextEditingController();
  CollectionReference employees =
      FirebaseFirestore.instance.collection('Employee');
  double screenHeight = 0;
  double screenWidth = 0;
  String _phoneNumber = '';

  Color primary = const Color(0xffeef444c);
  @override
  void initState() {
    LocationService().initialize();
    super.initState();
  }

  void createUser(
    String EmployeeName,
    String EmployeeCode,
  ) async {
    String baseUrl = "http://attendance.actofit.in:8000";
    var url = Uri.parse('$baseUrl/api/user/add');
    var body = {
      "SerialNumber": 'geo123',
      "EmployeeName": EmployeeName,
      "EmployeeCode": EmployeeCode,
      "Gender": 'Male',
      "StartDate": DateFormat('yyyy-MM-dd').format(DateTime.now()),
      "EndDate": DateFormat('yyyy-MM-dd')
          .format(DateTime.now().add(Duration(days: 1825))),
      "EmployeeCodeInDevice": EmployeeCode,
      "EmployementType": 'TRAINER',
      "Status": 'WORKING',
      "Email": '$EmployeeCode@actofit.in',
    };
    print(body);
    // Await the http get response, then decode the json-formatted response.
    var response = await http.post(
      url,
      body: body,
    );
    if (response.statusCode == 200) {
      debugPrint('User Added');
    } else {
      debugPrint('Error in adding User');
    }
  }

  // late SharedPreferences sharedPreferences;

  @override
  Widget build(BuildContext context) {
    bool isKeyboardVisible = false;
    // isKeyboardVisible =
    //     KeyboardVisibilityProvider.isKeyboardVisible(context);
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    // if (Prefs.getBool("loggedIn")) {
    //   return HomeScreen();
    // } else {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            isKeyboardVisible
                ? SizedBox(
                    height: screenHeight / 16,
                  )
                : Container(
                    height: screenHeight / 2.5,
                    width: screenWidth,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(70),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: screenWidth / 5,
                      ),
                    ),
                  ),
            Container(
              margin: EdgeInsets.only(
                top: screenHeight / 40,
                bottom: screenHeight / 40,
              ),
              child: Text(
                "Register",
                style: TextStyle(
                  fontSize: screenWidth / 18,
                  fontFamily: "NexaBold",
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.symmetric(
                horizontal: screenWidth / 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // fieldTitle("Contact Number"),
                  // Container(
                  //   width: screenWidth,
                  //   margin: EdgeInsets.only(bottom: 12),
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.all(Radius.circular(12)),
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Colors.black26,
                  //         blurRadius: 10,
                  //         offset: Offset(2, 2),
                  //       ),
                  //     ],
                  //   ),
                  //   child: Row(
                  //     children: [
                  //       Expanded(
                  //         child: Padding(
                  //           padding: EdgeInsets.only(
                  //               right: screenWidth / 12, bottom: 5),
                  //           child: IntlPhoneField(
                  //             decoration: InputDecoration(
                  //               contentPadding: EdgeInsets.symmetric(
                  //                 vertical: screenHeight / 35,
                  //               ),
                  //               labelText: 'Phone number',
                  //               border: InputBorder.none,
                  //             ),
                  //             initialCountryCode:
                  //                 'IN', // You can set the initial country code here
                  //             onChanged: (phone) {
                  //               setState(() {
                  //                 _phoneNumber = phone.completeNumber;
                  //                 print(_phoneNumber);
                  //                 String formattedPhoneNumber = _phoneNumber
                  //                     .replaceAll(RegExp(r'^\+?\d+\s?'), "");
                  //                 print(formattedPhoneNumber);
                  //                 idController.text = formattedPhoneNumber;
                  //               });
                  //             },
                  //           ),
                  //         ),
                  //       )
                  //     ],
                  //   ),
                  // ),
                  fieldTitle("Contact no. (Without country code)"),
                  customField("Enter your Contact number", idController, false),
                  fieldTitle("Employee Name"),
                  customField("Enter your Name", nameController, false),
                  fieldTitle("Password"),
                  customField("Enter your password", passController, true),
                  GestureDetector(
                    onTap: () async {
                      FocusScope.of(context).unfocus();
                      String name = nameController.text.trim();
                      String id = idController.text.trim();
                      String password = passController.text.trim();

                      if (id.isEmpty) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Employee id is still empty!"),
                        ));
                      } else if (password.isEmpty) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Password is still empty!"),
                        ));
                      } else if (name.isEmpty) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Name is still empty!"),
                        ));
                      } else {
                        try {
                          QuerySnapshot snap = await FirebaseFirestore.instance
                              .collection("Employee")
                              .where('id', isEqualTo: id)
                              .get();
                          if (snap.size > 0) {
                            String error = " ";
                            error = "Employee id already exist!";
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(error),
                            ));
                          } else {
                            Prefs.setBool('loggedIn', false);
                            await employees.add({
                              'name': name,
                              'id': id,
                              'password': password,
                              'firstName': name
                            }).then((_) {
                              createUser(name, id);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()),
                              );
                            });
                          }
                        } catch (e) {
                          print(e);
                        }
                      }
                    },
                    child: Container(
                      height: 60,
                      width: screenWidth,
                      margin: EdgeInsets.only(top: screenHeight / 40),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30)),
                      ),
                      child: Center(
                        child: Text(
                          "REGISTER",
                          style: TextStyle(
                            fontFamily: "NexaBold",
                            fontSize: screenWidth / 26,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        textStyle: TextStyle(fontSize: 20), // Text style
                        padding: EdgeInsets.symmetric(vertical: 12),
                        elevation: 0, // Button padding
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10), // Button border radius
                        ),
                      ),
                      child: Text('Already Registered? Login',
                          style: TextStyle(color: Colors.black, fontSize: 16)),
                      onPressed: () {
                        // createUser('abhay', '6265171605');
                        if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                          );
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
    // }

    // return Scaffold(
    //   resizeToAvoidBottomInset: false,
    //   body: Column(
    //     children: [
    //       isKeyboardVisible ? SizedBox(height: screenHeight / 16,) : Container(
    //         height: screenHeight / 2.5,
    //         width: screenWidth,
    //         decoration: BoxDecoration(
    //           color: primary,
    //           borderRadius: const BorderRadius.only(
    //             bottomRight: Radius.circular(70),
    //           ),
    //         ),
    //         child: Center(
    //           child: Icon(
    //             Icons.person,
    //             color: Colors.white,
    //             size: screenWidth / 5,
    //           ),
    //         ),
    //       ),
    //       Container(
    //         margin: EdgeInsets.only(
    //           top: screenHeight / 15,
    //           bottom: screenHeight / 20,
    //         ),
    //         child: Text(
    //           "Login",
    //           style: TextStyle(
    //             fontSize: screenWidth / 18,
    //             fontFamily: "NexaBold",
    //           ),
    //         ),
    //       ),
    //       Container(
    //         alignment: Alignment.centerLeft,
    //         margin: EdgeInsets.symmetric(
    //           horizontal: screenWidth / 12,
    //         ),
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             fieldTitle("Employee ID"),
    //             customField("Enter your employee id", idController, false),
    //             fieldTitle("Password"),
    //             customField("Enter your password", passController, true),
    //             GestureDetector(
    //               onTap: () async {
    //                 FocusScope.of(context).unfocus();
    //                 String id = idController.text.trim();
    //                 String password = passController.text.trim();
    //
    //                 if(id.isEmpty) {
    //                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    //                     content: Text("Employee id is still empty!"),
    //                   ));
    //                 } else if(password.isEmpty) {
    //                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    //                     content: Text("Password is still empty!"),
    //                   ));
    //                 } else {
    //                   QuerySnapshot snap = await FirebaseFirestore.instance
    //                       .collection("Employee").where('id', isEqualTo: id).get();
    //
    //                   try {
    //                     if(password == snap.docs[0]['password']) {
    //                       // sharedPreferences = await SharedPreferences.getInstance();
    //                       Prefs.setBool('loggedIn', true);
    //                       Prefs.setString('employeeId', id)
    //                           .then((_) {
    //                         Navigator.pushReplacement(context,
    //                             MaterialPageRoute(builder: (context) => HomeScreen())
    //                         );
    //                       });
    //                     } else {
    //                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    //                         content: Text("Password is not correct!"),
    //                       ));
    //                     }
    //                   } catch(e) {
    //                     String error = " ";
    //
    //                     if(e.toString() == "RangeError (index): Invalid value: Valid value range is empty: 0") {
    //                       setState(() {
    //                         error = "Employee id does not exist!";
    //                       });
    //                     } else {
    //                       setState(() {
    //                         error = "Error occurred!";
    //                       });
    //                     }
    //
    //                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //                       content: Text(error),
    //                     ));
    //                   }
    //                 }
    //               },
    //               child: Container(
    //                 height: 60,
    //                 width: screenWidth,
    //                 margin: EdgeInsets.only(top: screenHeight / 40),
    //                 decoration: BoxDecoration(
    //                   color: primary,
    //                   borderRadius: const BorderRadius.all(Radius.circular(30)),
    //                 ),
    //                 child: Center(
    //                   child: Text(
    //                     "LOGIN",
    //                     style: TextStyle(
    //                       fontFamily: "NexaBold",
    //                       fontSize: screenWidth / 26,
    //                       color: Colors.white,
    //                       letterSpacing: 2,
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //             )
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }

  Widget fieldTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth / 26,
          fontFamily: "NexaBold",
        ),
      ),
    );
  }

  Widget customField(
      String hint, TextEditingController controller, bool obscure) {
    return Container(
      width: screenWidth,
      margin: EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: screenWidth / 6,
            child: Icon(
              Icons.person,
              color: primary,
              size: screenWidth / 15,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: screenWidth / 12),
              child: TextFormField(
                controller: controller,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight / 35,
                  ),
                  border: InputBorder.none,
                  hintText: hint,
                ),
                maxLines: 1,
                obscureText: obscure,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget phoneField(
      String hint, TextEditingController controller, bool obscure) {
    return Container(
      width: screenWidth,
      margin: EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: screenWidth / 6,
            child: Icon(
              Icons.person,
              color: primary,
              size: screenWidth / 15,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: screenWidth / 12),
              child: TextFormField(
                controller: controller,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight / 35,
                  ),
                  border: InputBorder.none,
                  hintText: hint,
                ),
                maxLines: 1,
                obscureText: obscure,
              ),
            ),
          )
        ],
      ),
    );
  }
}
