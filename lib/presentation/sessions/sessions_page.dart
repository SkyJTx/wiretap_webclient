import 'package:flutter/material.dart';

class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  static const String path = '/sessions';
  static const String name = 'sessions';
  static const String label = 'Sessions';
  static const IconData icon = Icons.window;

  @override
  SessionsPageState createState() => SessionsPageState();
}

class SessionsPageState extends State<SessionsPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Sessions Page',
        style: Theme.of(context).textTheme.displayMedium,
      ),
    );
  }
}
