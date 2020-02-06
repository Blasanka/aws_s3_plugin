import 'package:aws_s3_example/create_message.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "AWS S3 file upload demo",
      home: Scaffold(body: CreateMessage()),
    );
  }
}