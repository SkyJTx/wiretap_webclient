import 'package:flutter/material.dart';
import 'package:wiretap_webclient/bloc/theme_bloc.dart';
import 'package:wiretap_webclient/component/state_manager/state_manager.dart';
import 'package:wiretap_webclient/repo/database/database_repo.dart';

Future<void> init() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseRepo.init();
}

void main() {
  runApp(BlocProvider(bloc: ThemeBloc(), child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Wiretap', themeMode: BlocProvider.of<ThemeBloc>(context).state);
  }
}
