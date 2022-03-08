import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class ChatMessage{
  String messageContent,senderId,recieverId;
  Timestamp timestamp;


  ChatMessage({required this.messageContent, required this.senderId,required this.recieverId,required this.timestamp});
}