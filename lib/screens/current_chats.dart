import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/authentication.dart';
import 'package:chatapp/screens/newconv.dart';
import 'package:transparent_image/transparent_image.dart';

import '../users.dart';
import 'chat_window.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  var _currentuser=FirebaseAuth.instance.currentUser!.uid;
  bool isSearching = false;
  List<Users> user=[];
  List<Users> filteredUsers=[];
  void _filterUsers(value) {
    setState(() {
      filteredUsers = user
          .where((object) =>
          object.Firstname.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black45,
          title: !isSearching
              ? Text('Conversations')
              : TextField(
            onChanged: (value) {
              _filterUsers(value);
            },
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                hintText: "Search",
                hintStyle: TextStyle(color: Colors.white)),
          ),
          actions: <Widget>[
            isSearching
                ? IconButton(
              icon: Icon(Icons.cancel),
              onPressed: () {
                setState(() {
                  this.isSearching = false;
                });
              },
            )
                : IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                setState(() {
                  this.isSearching = true;
                });
              },
            )
          ],
        ),
        body:StreamBuilder(
            stream: FirebaseFirestore.instance.collection('Users').doc(_currentuser).collection('Contacts').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text("Loading");
              }
              else{
                for (int i = 0; i < snapshot.data!.docs.length; i++) {
                  if (snapshot.data!.docs[i]['UserId'] != _currentuser) {
                    user.add(Users(Firstname: snapshot.data!.docs[i]['Firstname'],
                        Lastname: snapshot.data!.docs[i]['Lastname'],
                        Imageurl: snapshot.data!.docs[i]['Imageurl'],
                        uid: snapshot.data!.docs[i]['UserId'],
                        rating: snapshot.data!.docs[i]['Ratings'],
                        date:Timestamp.fromDate(DateTime.now()), Email: '', Bio: '', Age: '', Hometown: ''
                    ));
                    filteredUsers=user;
                  }
                }
              }
              return
                Scaffold(
                    body: ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                              onTap:(() async{
                                var a=await Authentication().getrating(filteredUsers[index].uid);
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>chats( user: filteredUsers[index],rating: a.toString())));
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
                                                        child:FadeInImage.memoryNetwork(placeholder: kTransparentImage, image: filteredUsers[index].Imageurl, width: 100, height: 100, fit: BoxFit.cover) ),
                                                    backgroundColor: Colors.white,

                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 20),
                                              Column(
                                                  children:[
                                                    Container(
                                                      child:Text("Username :"+filteredUsers[index].Firstname+" " + filteredUsers[index].Lastname),
                                                    ),
                                                    SizedBox(height: 20,),
                                                    Container(
                                                        child: Text("Date Joined: "+(filteredUsers[index].date).toDate().toLocal().toString())
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
                    )
                );
            }
        )

    );
  }
}