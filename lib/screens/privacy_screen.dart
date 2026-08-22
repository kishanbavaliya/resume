import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  final String title;
  final String text;
  const PrivacyScreen({super.key, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Text(text, style: const TextStyle(fontSize: 13.5, height: 1.5)),
      ),
    );
  }
}
