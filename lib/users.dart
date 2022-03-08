import 'package:cloud_firestore/cloud_firestore.dart';

class Users{
  String uid,Lastname,Firstname,Bio,Age,Email,Imageurl,Hometown;
  Timestamp date;
  String rating;
  Users({required this.uid, required this.Age,required this.Bio, required this.date,
    required this.Email, required this.Firstname, required this.Hometown,required
    this.Imageurl,required this.Lastname,required this.rating});
}