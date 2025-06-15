import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lease_it/HomePage.dart';
import 'package:lease_it/login_signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class checking extends StatefulWidget {
  _checking createState() => _checking();
}

class _checking extends State<checking> {
  late SharedPreferences prefs;
  //String email;
  late bool newuser;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    check_if_already_login();
  }

  void check_if_already_login() async {
    prefs = await SharedPreferences.getInstance();
    //email = prefs.getString('name');
    newuser = (prefs.getBool('login') ?? true);
    print(newuser);
    if (newuser == false) {
      Timer(const Duration(seconds: 3), () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MyHomePage()));
      });
    } else {
      Timer(const Duration(seconds: 3), () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginSignup()));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromARGB(255, 123, 255, 7),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 10)),
            Align(
              alignment: Alignment.center,
              child: Text(
                "LeaseIT",
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.black,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
