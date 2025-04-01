import 'package:flutter/material.dart';
import 'package:wiretap_webclient/bloc/theme_bloc.dart';
import 'package:wiretap_webclient/component/state_manager/state_manager.dart';
import 'package:wiretap_webclient/constant/theme.dart';
import 'package:wiretap_webclient/repo/database/database_repo.dart';
import 'package:wiretap_webclient/repo/setting/setting_repo.dart';
import 'package:wiretap_webclient/repo/ui/ui_repo.dart';

Future<void> init() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseRepo.init();
  await SettingRepo.init();
}

void main() async {
  await init();
  runApp(BlocProvider(bloc: ThemeBloc()..init(), child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: UiRepo().router,
      title: 'WireTap',
      themeMode: BlocProvider.of<ThemeBloc>(context).state,
      theme: lightTheme,
      darkTheme: darkTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
