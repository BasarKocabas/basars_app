import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

String formatTimeManually(DateTime time) { //chatgpt den alınma
  int hour = time.hour;
  int minute = time.minute;
  String period = hour >= 12 ? "PM" : "AM";
  // Convert to 12-hour format
  hour = hour % 12;
  if (hour == 0) hour = 12; // Handle midnight and noon
  // Add leading zero to minutes if necessary
  String minuteStr = minute < 10 ? "0$minute" : "$minute";
  return "$hour:$minuteStr $period";
}


class MessageBox extends StatelessWidget{

  final Widget content;
  final Timestamp timeStamp;
  final String name;

  const MessageBox({super.key, required this.name,  required this.content, required this.timeStamp});


  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Card(
        color: Colors.blue.shade200,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              name != "" ? Text(name,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.w500, color: Colors.black),): SizedBox(),
              Row( // Use Row instead of Column
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end, // Align text and time
                children: [
                  Flexible( // Ensures text wraps properly
                    child: content,
                  ),
                  const SizedBox(width: 12), // Space between text and time
                  Text(
                    formatTimeManually(timeStamp.toDate()),
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}