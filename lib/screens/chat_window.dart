import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:chatapp/authentication.dart';
import 'package:chatapp/users.dart';

import 'message.dart';

class chats extends StatefulWidget {
  final Users user;
  final String rating;
  const chats({Key? key,required Users this.user,required this.rating} ) : super(key: key);

  @override
  _chatsState createState() => _chatsState();
}

class _chatsState extends State<chats> {
  var _current_user=FirebaseAuth.instance.currentUser!.uid;
  ScrollController _scrollController = new ScrollController();
  TextEditingController textController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    print(widget.rating);
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          elevation: 5,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          flexibleSpace: SafeArea(
            child: Container(
              padding: EdgeInsets.only(right: 16),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back,color: Colors.black45,),
                  ),
                  SizedBox(width: 2,),
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.user.Imageurl),
                    maxRadius: 20,
                  ),
                  SizedBox(width: 12,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(widget.user.Firstname+" "+widget.user.Lastname,style: TextStyle( fontSize: 16 ,fontWeight: FontWeight.w600),),
                        SizedBox(height: 6,),
                        //Text("Online",style: TextStyle(color: Colors.grey.shade600, fontSize: 13),),
                        RatingBar.builder(
                          itemSize: 20,
                          initialRating:double.parse(widget.rating),
                          minRating: 0,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: Colors.green,
                          ),
                          onRatingUpdate: (rating) {
                            FirebaseFirestore.instance.collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).collection('Contacts').doc(widget.user.uid).update({'Ratings':rating.toString()});
                          },
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('messages').doc(Authentication().getConversationID(_current_user, widget.user.uid)).collection('message').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text("Loading");
              }
              return Stack(
                children: <Widget>[
                  ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    shrinkWrap: true,
                    controller: _scrollController,
                    physics: ClampingScrollPhysics(),
                    padding: EdgeInsets.only(top: 10, bottom: 60),
                    itemBuilder: (context, index) {
                      return Container(
                        padding: EdgeInsets.only(
                            left: 16, right: 16, top: 5, bottom: 5),
                        child: Align(
                          alignment: (snapshot.data!.docs[index].get('lastMessage')[0]['recieverId'] == _current_user
                              ? Alignment.topLeft
                              : Alignment.topRight),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: (snapshot.data!.docs[index].get('lastMessage')[0]['recieverId']== _current_user
                                  ? Colors.grey.shade200
                                  : Colors.amber.shade100),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Text(snapshot.data!.docs[index].get('lastMessage')[0]['content'],
                              style: TextStyle(fontSize: 15),),
                          ),
                        ),
                      );
                    },
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
                      height: 60,
                      width: double.infinity,
                      color: Colors.white,
                      child: Row(
                        children: <Widget>[
                          SizedBox(width: 15,),
                          Expanded(
                            child: TextField(
                                decoration: InputDecoration(
                                    hintText: "Write message...",
                                    hintStyle: TextStyle(color: Colors.black54),
                                    border: InputBorder.none
                                ),
                                controller: textController
                            ),
                          ),
                          SizedBox(width: 15,),
                          FloatingActionButton(
                            onPressed: () async {
                              if(textController.text.isNotEmpty) {
                                if (await Authentication().doc(
                                    _current_user, widget.user.uid)) {
                                  FirebaseFirestore.instance.collection('messages')
                                      .doc(
                                      Authentication().getConversationID(
                                          _current_user, widget.user.uid))
                                      .collection("message")
                                      .doc(
                                      Timestamp.fromDate(DateTime.now())
                                          .toDate()
                                          .toString())
                                      .
                                  set({
                                    "lastMessage": [{"content": textController.text,
                                      "recieverId": widget.user.uid,
                                      "senderId": _current_user,
                                      "timestamp": Timestamp.fromDate(DateTime.now()).toString().substring(0,20)}
                                    ]
                                  })
                                      .then((value) => textController.clear());
                                }
                                else {
                                  FirebaseFirestore.instance.collection('messages')
                                      .doc(Authentication().getConversationID(
                                      _current_user, widget.user.uid)).
                                  set({
                                    "users": [
                                      {
                                        "senderId": _current_user,
                                        "recieverId": widget.user.uid
                                      }
                                    ]
                                  })
                                      .then((value) =>
                                  {
                                    FirebaseFirestore.instance.collection('messages')
                                        .doc(
                                        Authentication().getConversationID(
                                            _current_user, widget.user.uid))
                                        .collection("message").doc(
                                        Timestamp.fromDate(DateTime.now())
                                            .toDate()
                                            .toString())
                                        .
                                    set({
                                      "lastMessage": [{"content": textController.text,
                                        "recieverId": widget.user.uid,
                                        "senderId": _current_user,
                                        "timestamp": Timestamp.fromDate(
                                            DateTime.now())}
                                      ],
                                      "users": [
                                        {
                                          "senderId": _current_user,
                                          "recieverId": widget.user.uid
                                        }
                                      ]
                                    }).then((value) => textController.clear())
                                  }
                                  ).then((value) => FirebaseFirestore.instance.collection('Users').doc(_current_user).collection('Contacts').
                                  doc(widget.user.uid).set({"Imageurl":widget.user.Imageurl,"Firstname":widget.user.Firstname,"Lastname":widget.user.Lastname,"Ratings":0,'UserId':widget.user.uid}));
                                }
                                _scrollController.animateTo(
                                  _scrollController.position.maxScrollExtent,
                                  curve: Curves.easeOut,
                                  duration: const Duration(milliseconds: 500),
                                );
                              }else{
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text("Enter something to send"),
                                ));
                              } },
                            child: Icon(Icons.send, color: Colors.white, size: 18,),
                            backgroundColor: Colors.black45,
                            elevation: 0,
                          ),
                        ],

                      ),
                    ),
                  ),
                ],
              );
            })
    );
  }
}
