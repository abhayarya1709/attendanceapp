// // ignore_for_file: unused_catch_clause, dead_code
//
// import 'package:flutter/services.dart';
// import 'package:local_auth/local_auth.dart';
//
// class LocalAuthApi {
//   static final _auth = LocalAuthentication();
//
//   static Future<bool> hasBiometrics() async {
//     try {
//       return await _auth.canCheckBiometrics;
//       print('working 1');
//     } on PlatformException catch (e) {
//       print('working 1');
//       return false;
//     }
//   }
//
//   static Future<List<BiometricType>> getBiometrics() async {
//     try {
//       return await _auth.getAvailableBiometrics();
//       print('working 2');
//     } on PlatformException catch (e) {
//       print('working 2');
//       print(BiometricType);
//       return <BiometricType>[];
//     }
//   }
//
//   static Future<bool> authenticate() async {
//     final isAvailable = await hasBiometrics();
//     if (!isAvailable) return false;
//
//     try {
//       return await _auth.authenticate(
//         localizedReason: 'Scan Fingerprint to Authenticate',
//         options: const AuthenticationOptions(
//           stickyAuth: true,
//           useErrorDialogs: true,
//         ),
//       );
//       print('working 3');
//     } on PlatformException catch (e) {
//       print('working 3');
//       return false;
//     }
//   }
// }
