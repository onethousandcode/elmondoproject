import 'package:flutter/material.dart';

class LessonScreen extends StatelessWidget {
  final String title;
  final String content;

  LessonScreen({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(content, style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
