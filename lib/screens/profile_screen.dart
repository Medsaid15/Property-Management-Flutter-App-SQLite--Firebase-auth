import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('profile', style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.teal[700],
      ),
      body: const Center(child: Text('Profile Screen'),),
    );
  }
}