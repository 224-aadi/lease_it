import 'package:flutter/material.dart';
import 'package:lease_it/login.dart';
import 'package:lease_it/sign_up.dart';

class LoginSignup extends StatefulWidget {
  _loginSignup createState() => _loginSignup();
}

class _loginSignup extends State<LoginSignup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 123, 255, 7),
      body: Container(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "LeaseIT",
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.black,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) => Login()))
                        },
                        icon: const Icon(Icons.login, size: 20),
                        label: const Text('Log In'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(24, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) => SignUp()))
                        },
                        icon: const Icon(Icons.person_add, size: 20),
                        label: const Text('Sign Up'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(24, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
