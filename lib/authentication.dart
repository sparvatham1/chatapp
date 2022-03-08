import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

class Authentication {
  var _verificationId;
  var _firebase_instance = FirebaseAuth.instance;
  var _storage = FirebaseFirestore.instance.collection("Users");
  Stream <QuerySnapshot>collectionStream = FirebaseFirestore.instance
      .collection('Users').snapshots();
  var firstname, lastname, imageurl, email;

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser!
        .authentication;
    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  void email_sign_in(String email, String password, context) async {
    try {
      FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.code),
      ));
    }
  }

  Future<UserCredential> signInWithFacebook() async {
    final LoginResult loginResult = await FacebookAuth.instance.login();

    final OAuthCredential facebookAuthCredential = FacebookAuthProvider
        .credential(loginResult.accessToken!.token);
    return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }

  void sendresetemail(String email, context) async {
    try {
      FirebaseAuth.instance.sendPasswordResetEmail(
          email: email);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Password reset mail sent"),
      ));
    }
    on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.code),
      ));
    }
  }

  void signout() async {
    FirebaseAuth.instance.signOut();
  }

  void anonymous() async {
    await FirebaseAuth.instance.signInAnonymously();
  }

  void signInEmail(String email, context) async {
    var acs = ActionCodeSettings(
      // URL you want to redirect back to. The domain (www.example.com) for this
      // URL must be whitelisted in the Firebase Console.
        url: 'https://madassignment.page.link/6SuK',
        // This must be true
        handleCodeInApp: true,
        iOSBundleId: 'com.example.ios',
        androidPackageName: 'com.example.android',
        // installIfNotAvailable
        androidInstallApp: true,
        // minimumVersion
        androidMinimumVersion: '12');
    var emailAuth = email.trim();
// Confirm the link is a sign-in with email link.
    var emailLink = 'https://madassignment.page.link/6SuK';
    if (_firebase_instance.isSignInWithEmailLink(emailLink)) {
      // The client SDK will parse the code from the link for you.
      _firebase_instance.signInWithEmailLink(
          email: emailAuth, emailLink: emailLink).then((value) {
        // You can access the new user via value.user
        // Additional user info profile *not* available via:
        // value.additionalUserInfo.profile == null
        // You can check if the user is new or existing:
        // value.additionalUserInfo.isNewUser;
        var userEmail = value.user;
        print('Successfully signed in with email link!');
      }).catchError((onError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(onError),
        ));
      });
    }
    FirebaseAuth.instance.sendSignInLinkToEmail(
        email: emailAuth, actionCodeSettings: acs)
        .catchError((onError) =>
        print('Error sending email verification $onError'))
        .then((value) => print('Successfully sent email verification'));
  }

  Future<String> send_code(String phone) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential phoneAuthCredential) {},
      codeSent: (String verificationId, int? forceResendingToken) {
        _verificationId = verificationId;
      },
      verificationFailed: (FirebaseAuthException error) {},
      codeAutoRetrievalTimeout: (String verificationId) {},

    );
    return _verificationId;
  }

  Future<void> verify(String code, String verid) async {
    print('verid: ' + _verificationId);
    // Create a PhoneAuthCredential with the code
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        smsCode: code, verificationId: _verificationId);

    // Sign the user in (or link) with the credential
    await _firebase_instance.signInWithCredential(credential);
  }

  Future<void> addUser(String fname, String lname, String email,
      String password, File file, String age, String home, String bio,
      context) async {
    try {
      UserCredential userCredential = await FirebaseAuth
          .instance.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password);
      CollectionReference users = FirebaseFirestore.instance.collection(
          "Users");
      String id = _firebase_instance.currentUser!.uid;
      print("id:" + id);
      var task = await FirebaseStorage.instance
          .ref("/Images/" + id + "/" + file.path
          .split("/")
          .last)
          .putFile(file);
      String url = (await task.ref.getDownloadURL()).toString();
      var now = new DateTime.now();
      FirebaseAuth.instance.currentUser!.updateDisplayName(fname + " " + lname);
      FirebaseAuth.instance.currentUser!.updatePhotoURL(url);
      users.doc(id).set({
        "First name": fname,
        "Last name": lname,
        "Email": email,
        "User Id": id,
        "Imageurl": url,
        "Joined": now,
        "Age": age,
        "Bio": bio,
        "Hometown": home
      });
    }
    on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.code),
      ));
    }
  }

  void get_data(context) async {
    List<String>l = [];
    _storage.doc(FirebaseAuth.instance.currentUser!.uid).get().then((
        DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        firstname = documentSnapshot["First name"];
        lastname = documentSnapshot["Last name"];
        l.add(documentSnapshot["Joined"]);
        email = documentSnapshot["Email"];
        l.add(documentSnapshot["Hometown"]);
        imageurl = documentSnapshot["Imageurl"];
        l.add(documentSnapshot["Age"]);
        l.add(documentSnapshot["Bio"]);
        l.add(documentSnapshot["User Id"]);
      } else {
        //return ('Document does not exist on the database');
      }
    });
  }

  String getConversationID(String userID, String peerID) {
    return userID.hashCode <= peerID.hashCode
        ? userID + '_' + peerID
        : peerID + '_' + userID;
  }

  Future<bool> doc(String current, String peer) async {
    var usersRef = await FirebaseFirestore.instance.collection('messages').doc(
        getConversationID(current, peer)).get();
    if (usersRef.exists) {
      return true;
    }
    else {
      return false;
    }
  }

  Future<double> getrating(String uid) async {
    var a=0.0;
    await FirebaseFirestore.instance.collection('Users').doc(
        FirebaseAuth.instance.currentUser!.uid).collection('Contacts')
        .doc(uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        a=double.parse(documentSnapshot['Ratings']);
      }
    });
    return a;
  }
  Future<double> getavgrating() async {
    var a=0.0;
    var b;
    await FirebaseFirestore.instance.collection('Users').doc(
        FirebaseAuth.instance.currentUser!.uid).collection('Contacts').get()
        .then((QuerySnapshot documentSnapshot) {
      for(var i in documentSnapshot.docs){
        a+=i.get('Ratings');
      }
      b=documentSnapshot.size;
    });
    return a/b;
  }
}

