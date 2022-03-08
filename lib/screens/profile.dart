import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/authentication.dart';
import 'package:chatapp/screens/home.dart';
import 'package:transparent_image/transparent_image.dart';

class Profile extends StatefulWidget {

  const Profile({Key? key}) : super(key: key);
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    Random rand=new Random();
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black45,
          leading: BackButton(onPressed: () {  Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>Home()));},
          ),
        ),
        body:StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('Users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot>snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text("Loading");
              }
              return
                Center(child:
                ListView(
                    children: [
                      SizedBox(height:20),
                      InkWell(
                        child: CircleAvatar(
                          backgroundColor: Colors.black,
                          radius: 100.0,
                          child: CircleAvatar(
                            radius: 98.0,
                            child: ClipOval(
                                child:FadeInImage.memoryNetwork(placeholder: kTransparentImage, image:snapshot.data!['Imageurl'], width: 200, height: 200, fit: BoxFit.cover) ),
                            backgroundColor: Colors.white,

                          ),
                        ),
                      ),
                      SizedBox(height: 70),

                      Card(
                        child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
                          Container(
                              padding: EdgeInsets.all(10),
                              child: Icon(Icons.person,color: Colors.green)),
                          Container(
                              padding: EdgeInsets.all(10),
                              child:Text(snapshot.data!['First name']+ " "+ snapshot.data!['Last name'],style: TextStyle(height: 1, fontSize: 20), ))]
                        ),
                      ),
                      Card(
                        child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
                          Container(
                              padding: EdgeInsets.all(10),
                              child: Icon(Icons.email,color: Colors.red)),
                          Container(
                              padding: EdgeInsets.all(10),
                              child:Text(snapshot.data!['Email'],style: TextStyle(height: 1, fontSize: 20),))]
                        ),
                      ),
                      Card(
                        child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
                          Container(
                              padding: EdgeInsets.all(10),
                              child: Icon(Icons.date_range,color: Colors.orange)),
                          Container(
                              padding: EdgeInsets.all(10),
                              child:Text(snapshot.data!['Age'],style: TextStyle(height: 1, fontSize: 20),))]
                        ),
                      ),
                      Card(
                        child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
                          Container(
                              padding: EdgeInsets.all(10),
                              child: Icon(Icons.location_on,color: Colors.blueAccent,)),
                          Container(
                              padding: EdgeInsets.all(10),
                              child:Text(snapshot.data!['Hometown'],style: TextStyle(height: 1, fontSize: 20),))]
                        ),
                      ),
                      Card(
                        child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
                          Container(
                              padding: EdgeInsets.all(10),
                              child: Icon(Icons.star,color: Colors.red,)),
                          Container(
                              padding: EdgeInsets.all(10),
                              child:Text((rand.nextInt(5)).toString(),style:TextStyle(fontSize: 20),))]
                        ),
                      ),
                      Card(child:
                      ExpansionTile(title: Text('Bio'),leading: Icon(Icons.info_outline,color: Colors.black45,),subtitle: Text("Click to show"),
                          children:[
                            SingleChildScrollView(
                              padding: EdgeInsets.all(20),
                              scrollDirection: Axis.vertical,
                              child: Text(snapshot.data!['Bio'],style: TextStyle(height: 1, fontSize: 18),maxLines: null,),
                            ),

                          ]
                      )
                      )
                    ]


                ),
                );
            }));
  }
}
