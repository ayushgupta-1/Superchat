import 'package:flutter/material.dart';
import 'package:superchat/services/auth.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.lightBlueAccent, Colors.purpleAccent],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Superchat",
              style: TextStyle(
                  fontSize: 82, color: Colors.white, fontFamily: "Signatra"),
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                AuthMethods().signInWithGoogle(context);
              },
              child: Column(
                children: <Widget>[
                  Container(
                    width: 270,
                    height: 65,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            "assets/images/google_signin_button.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Padding(
                  //   padding: EdgeInsets.all(1.0),
                  //   child: isLoading ? circularProgress() : Container(),
                  // )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
