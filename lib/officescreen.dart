import 'dart:convert';
import 'package:attendanceapp/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:attendanceapp/utils/prefs.dart';

class OfficeScreen extends StatefulWidget {
  const OfficeScreen({Key? key}) : super(key: key);

  @override
  _OfficeScreenState createState() => _OfficeScreenState();
}

class _OfficeScreenState extends State<OfficeScreen> {
  List data = [];
  bool isLoading = false;

  Future getData() async {
    setState(() {
      isLoading = true;
    });
    var url = Uri.parse('https://nucleus.actofit.com:7000/api/gym/get_all');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      setState(() {
        data = jsonResponse['data'];
        isLoading = false;
      });
      print(data);
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        automaticallyImplyLeading: false, // remove back button
        title: Center(
          child: Text(
            'Select your gym',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Prefs.setString('latitude', data[index]['GymLatitude']);
                    Prefs.setString('longitude', data[index]['GymLongtitude']);
                    print(Prefs.getString('latitude'));
                    print(Prefs.getString('longitude'));
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                  child: SingleChildScrollView(
                    child: ListTile(
                      title: Text(data[index]['GymName']),
                      subtitle: Text(data[index]['GymAddress']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
