import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/authentication.dart';
import 'package:chatapp/users.dart';
import 'package:chatapp/screens/chat_window.dart';
import 'package:transparent_image/transparent_image.dart';

class newConv extends StatefulWidget {
  const newConv({Key? key}) : super(key: key);

  @override
  _newConvState createState() => _newConvState();
}

class _newConvState extends State<newConv> {
  var _currentuser=FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    List<Users> user=[];
    return Scaffold(
      appBar: AppBar(
        title: Text('All Users'),
        backgroundColor: Colors.black45,
      ),

      body:
      StreamBuilder<QuerySnapshot>(
          stream: Authentication().collectionStream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading");
            }
            else {
              for (int i = 0; i < snapshot.data!.docs.length; i++) {
                if (snapshot.data!.docs[i]['User Id'] != _currentuser) {
                  user.add(Users(Firstname: snapshot.data!.docs[i]['First name'],
                      Lastname: snapshot.data!.docs[i]['Last name'],
                      Age: snapshot.data!.docs[i]['Age'],
                      Imageurl: snapshot.data!.docs[i]['Imageurl'],
                      Bio: snapshot.data!.docs[i]['Bio'],
                      date:snapshot.data!.docs[i]['Joined'],
                      Hometown: snapshot.data!.docs[i]['Hometown'],
                      uid: snapshot.data!.docs[i]['User Id'],
                      Email: snapshot.data!.docs[i]['Email'], rating:'0'
                  ));
                }
              }
            }
            return ListView.builder(
                itemCount: user.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                      onTap:(() async{
                        var a=await Authentication().getrating(user[index].uid);
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>chats( user: user[index],rating: a.toString())));
                      }),
                      child:Card(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(height: 10),
                              Container(
                                  child: Row(
                                    children:[
                                      InkWell(
                                        child: CircleAvatar(
                                          backgroundColor: Colors.black,
                                          radius: 45.0,
                                          child: CircleAvatar(
                                            radius: 43.0,
                                            child: ClipOval(
                                                child:FadeInImage.memoryNetwork(placeholder: kTransparentImage, image: user[index].Imageurl, width: 100, height: 100, fit: BoxFit.cover) ),
                                            backgroundColor: Colors.white,

                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      Column(
                                          children:[
                                            Container(
                                              child:Text("Username :"+user[index].Firstname+" " + user[index].Lastname),
                                            ),
                                            SizedBox(height: 20,),
                                            Container(
                                                child: Text("Date Joined: "+user[index].date.toDate().toString().substring(0,19))
                                            )
                                          ]
                                      )

                                    ],
                                  )

                              ),
                              SizedBox(height: 20),
                            ]
                        ),
                      )
                  );
                }
            );
          }
      ),

    );

  }
}
