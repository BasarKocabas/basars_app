import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class MessageBox extends StatefulWidget{

  final Widget content;
  final String time;
  final String name;

  const MessageBox({super.key, required this.name,  required this.content, required this.time});

  @override
  State<MessageBox> createState() => _MessageBoxState();
}

class _MessageBoxState extends State<MessageBox> {


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
              widget.name != "" ? Text(widget.name,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.w500, color: Colors.black),): SizedBox(),
              Row( // Use Row instead of Column
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end, // Align text and time
                children: [
                  Flexible( // Ensures text wraps properly
                    child: widget.content,
                  ),
                  const SizedBox(width: 12), // Space between text and time
                  Text(
                    widget.time.substring(0,5),
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                  ),
                  const SizedBox(width: 4,),
                  Icon(Icons.remove_red_eye_outlined, color: Colors.grey,size: 17)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}