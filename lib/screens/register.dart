import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chatapp/authentication.dart';
import 'package:chatapp/screens/home.dart';

import 'login.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController fnameController = TextEditingController();
  TextEditingController lnameController = TextEditingController();
  TextEditingController passwordController1 = TextEditingController();
  TextEditingController passwordController2 = TextEditingController();
  TextEditingController emailcontroller=TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController homeController = TextEditingController();
  TextEditingController biocontroller=TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File _result=File('');
  Future<void> _showPicker(context) async {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () async {
                        XFile? result=await _picker.pickImage(source:ImageSource.gallery,imageQuality: 70);
                        if(result != null) {
                          File file = File(result.path.toString());
                          _result = file;
                        }
                        Navigator.of(context).pop();
                        setState(() {});
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () async {
                      XFile? result=await _picker.pickImage(source:ImageSource.camera,imageQuality: 70);
                      if(result != null) {
                        File file = File(result.path.toString());
                        _result = file;
                      }
                      Navigator.of(context).pop();
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          );
        }
    );

  }
  @override
  Widget build(BuildContext context) {
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
                InkWell(
                  onTap: () async {
                    _showPicker(context);
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.black,
                    radius: 40.0,
                    child: CircleAvatar(
                      radius: 38.0,
                      child: ClipOval(
                        child: (_result != null)
                            ? Image.file(_result,width: 100, height: 100, fit: BoxFit.cover)
                            : Image.asset("assets/loading.gif",width: 100, height: 100, fit: BoxFit.cover),
                      ),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Sign up',
                      style: TextStyle(fontSize: 20),
                    )),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: fnameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'First Name',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: lnameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Last Name',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: emailcontroller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: biocontroller,
                    maxLines: null,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Bio',

                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: homeController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Hometown',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Age',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    obscureText: true,
                    controller: passwordController1,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    obscureText: true,
                    controller: passwordController2,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Re enter Password',
                    ),
                  ),
                ),
                Container(
                    height: 50,
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: RaisedButton(
                        textColor: Colors.white,
                        color: Colors.black45,
                        child: Text('Register'),
                        onPressed: ()async {
                          if (EmailValidator.validate(emailcontroller.text.trim())) {
                            if(passwordController1.text==passwordController2.text && passwordController2.text!='')
                              if(fnameController.text!='' && lnameController.text!='' && ageController.text!=''&& biocontroller.text!='' )
                                if(int.parse(ageController.text)<=100&&int.parse(ageController.text)>=10)
                                  if(_result.path!='')
                                    Authentication().addUser(fnameController.text,lnameController.text,emailcontroller.text,passwordController2.text,_result,ageController.text,homeController.text,biocontroller.text,context).then((value) => Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>Home())));
                                  else{
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text("Please select a valid image"),
                                    ));
                                  }
                                else{
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text("Invalid Age"),
                                  ));
                                }
                              else{
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text("Data fields can't be empty"),
                                ));
                              }
                            else{
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Invalid Password"),
                              ));
                            }
                          }
                          else{
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Invalid Email"),
                            ));
                          }
                        }
                    )),
                Container(
                    child: Row(
                      children: <Widget>[
                        Text('Already have account?'),
                        FlatButton(
                          textColor: Colors.black45,
                          child: Text(
                            'Login',
                            style: TextStyle(fontSize: 20),
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(context,MaterialPageRoute(builder:(context)=>Login()));
                          },
                        )
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    ))
              ],
            )));
  }
}
