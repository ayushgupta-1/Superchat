import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superchat/helperFunction/sharedpref_helper.dart';
import 'package:superchat/screens/home.dart';
import 'package:superchat/services/database.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool isSigningIn = true;
  getCurrentUser() async {
    return auth.currentUser;
  }

  Future<User> signInWithGoogle(BuildContext context) async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = new GoogleSignIn();

    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    UserCredential result =
        await _firebaseAuth.signInWithCredential(credential);

    User userDetails = result.user;

    if (result == null) {
    } else {
      SharedPreferenceHelper().saveUserEmail(userDetails.email);
      SharedPreferenceHelper()
          .saveUserName(userDetails.email.replaceAll('@gmail.com', ""));
      SharedPreferenceHelper().saveUserId(userDetails.uid);
      SharedPreferenceHelper().saveDisplayName(userDetails.displayName);
      SharedPreferenceHelper().saveUserProfileUrl(userDetails.photoURL);

      Map<String, dynamic> userInfoMap = {
        "email": userDetails.email,
        "username": userDetails.email.replaceAll("@gmail.com", ""),
        "name": userDetails.displayName,
        "profileUrl": userDetails.photoURL,
      };

      DatabaseMethods()
          .addUserInfoToDB(userDetails.uid, userInfoMap)
          .then((value) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Home()));
      });
    }
  }

  Future signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
    await auth.signOut();
  }
}
