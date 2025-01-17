import 'package:attendanceapp/loginscreen.dart';
import 'package:attendanceapp/model/user.dart';
import 'package:attendanceapp/homescreen.dart';
import 'package:attendanceapp/officescreen.dart';
import 'package:attendanceapp/registerscreen.dart';
import 'package:attendanceapp/utils/prefs.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Prefs.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const KeyboardVisibilityProvider(
        // child: AuthCheck(),
        // child: OfficeSelectionPage(),
        child: LoginScreen(),
        // child: RegisterScreen(),
      ),
      localizationsDelegates: const [
        MonthYearPickerLocalizations.delegate,
      ],
    );
  }
}

// class AuthCheck extends StatefulWidget {
//   const AuthCheck({Key? key}) : super(key: key);
//
//   @override
//   _AuthCheckState createState() => _AuthCheckState();
// }
//
// class _AuthCheckState extends State<AuthCheck> {
//   bool userAvailable = false;
//   late SharedPreferences sharedPreferences;
//
//   get authenticated => false;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _getCurrentUser();
//     });
//   }
//
//   void _getCurrentUser() async {
//     sharedPreferences = await SharedPreferences.getInstance();
//
//     try {
//       if(sharedPreferences.getString('employeeId') != null) {
//         setState(() {
//           User.employeeId = sharedPreferences.getString('employeeId')!;
//           userAvailable = true;
//         });
//       }
//     } catch(e) {
//       setState(() {
//         userAvailable = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return authenticated ? HomeScreen() : LoginScreen();
//     // return authenticated ? HomeScreen() : LoginScreen();
//   }
// }
