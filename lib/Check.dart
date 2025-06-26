import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lease_it/main_navigation.dart';
import 'package:lease_it/login_signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Checking extends StatefulWidget {
  const Checking({Key? key}) : super(key: key);

  @override
  _Checking createState() => _Checking();
}

class _Checking extends State<Checking> {
  late SharedPreferences prefs;
  //String email;
  late bool newuser;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIfAlreadyLogin();
  }

  void checkIfAlreadyLogin() async {
    prefs = await SharedPreferences.getInstance();
    //email = prefs.getString('name');
    newuser = (prefs.getBool('login') ?? true);
    print(newuser);
    if (newuser == false) {
      Timer(const Duration(seconds: 3), () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const MainNavigation()));
      });
    } else {
      Timer(const Duration(seconds: 3), () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const LoginSignup()));
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
