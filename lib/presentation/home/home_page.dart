import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const String path = '/';
  static const String name = 'home';
  static const String label = 'Home';
  static const IconData icon = Icons.home;

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Home Page',
        style: Theme.of(context).textTheme.displayMedium,
      ),
    );
  }
}
