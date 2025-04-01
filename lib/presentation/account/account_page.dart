import 'package:flutter/material.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  static const String path = '/account';
  static const String name = 'account';
  static const String label = 'Account';
  static const IconData icon = Icons.account_circle;

  @override
  AccountPageState createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Account Page',
        style: Theme.of(context).textTheme.displayMedium,
      ),
    );
  }
}