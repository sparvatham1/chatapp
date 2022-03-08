import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chatapp/authentication.dart';
import 'package:chatapp/screens/home.dart';
import 'package:chatapp/screens/register.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:sign_button/sign_button.dart';

class Login extends StatefulWidget{
  @override
  _Login createState()=> _Login();
}

class _Login extends State<Login>{
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController _textFieldController = TextEditingController();
  var instance= Authentication();
  String _verid='';
  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title:Text('Enter your Email address'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  //valueText = value;
                });
              },
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Email address"),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('OK'),
                onPressed: () {
                  setState((){
                    instance.sendresetemail(_textFieldController.text,context);
                    Navigator.pop(context);

                  });
                },
              ),
            ],
          );
        });
  }
  Future<void> _displayPhoneTextInputDialog(BuildContext context) async {
    TextEditingController phone= TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title:Text('Enter your Phone Number'),
              content:Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:<Widget>[
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          //valueText = value;
                        });
                      },
                      controller: phone,
                      decoration: InputDecoration(hintText: "Enter Phone"),
                    ),
                    Expanded(child:
                    OTPTextField(
                      length: 6,
                      width: MediaQuery.of(context).size.width,
                      textFieldAlignment: MainAxisAlignment.spaceAround,
                      fieldWidth: 30,
                      fieldStyle: FieldStyle.underline,
                      outlineBorderRadius: 10,
                      style: TextStyle(fontSize: 20),
                      onChanged: (pin) {
                        print("Changed: " + pin);
                      },
                      onCompleted: (pin) {
                        instance.verify(pin,_verid).then((value) => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Home())));
                      },
                    ),)
                  ]
              ),

              actions:[Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:<Widget>[

                  FlatButton(
                    color: Colors.red,
                    textColor: Colors.white,
                    child: Text('Cancel'),
                    onPressed: () {
                      setState(() {
                        Navigator.pop(context);
                      });
                    },
                  ),
                  FlatButton(
                    color: Colors.blueAccent,
                    textColor: Colors.white,
                    child: Text('Get Code'),
                    onPressed: () {
                      setState(()  {
                        _verid= instance.send_code(phone.text.trim()) as String;
                      });
                    },
                  ),

                ],
              )]);
        });
  }
  Future<void> _displayEmailInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title:Text('Enter your Email address'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  //valueText = value;
                });
              },
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Email address"),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('OK'),
                onPressed: () {
                  setState((){
                    instance.signInEmail(_textFieldController.text,context);
                    Navigator.pop(context);

                  });
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        body: Padding(
            padding: EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'MyFlutterApp',
                      style: TextStyle(
                          color: Colors.black45,
                          fontWeight: FontWeight.w500,
                          fontSize: 30),
                    )),
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Sign in',
                      style: TextStyle(fontSize: 20),
                    )),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'User Name',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: (){
                    _displayTextInputDialog(context);
                  },
                  textColor: Colors.black45,
                  child: Text('Forgot Password'),
                ),
                Container(
                    height: 50,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: RaisedButton(
                        textColor: Colors.white,
                        color: Colors.black45,
                        child: Text('Login'),
                        onPressed: () async {
                          try {
                            Authentication().email_sign_in(nameController.text, passwordController.text,context);
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'user-not-found') {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("No user found"),
                              ));
                            } else if (e.code == 'wrong-password') {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Wrong Password provided"),
                              ));
                            }
                            else{ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(e.code.toString())));}
                          }
                        }
                    )),
                Container(
                    child: Row(
                      children: <Widget>[
                        Text('Does not have account?'),
                        FlatButton(
                          textColor: Colors.black45,
                          child: Text(
                            'Sign in',
                            style: TextStyle(fontSize: 20),
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder:(context)=>Register()));
                            //signup screen
                          },
                        )
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    )),

              ],
            ))
    );
  }
}