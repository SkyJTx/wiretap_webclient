import 'package:flutter/material.dart';
import 'package:wiretap_webclient/bloc/theme_bloc.dart';
import 'package:wiretap_webclient/component/state_manager/state_manager.dart';
import 'package:wiretap_webclient/constant/theme.dart';
import 'package:wiretap_webclient/presentation/account/account_cubit.dart';
import 'package:wiretap_webclient/presentation/authen/authen_cubit.dart';
import 'package:wiretap_webclient/presentation/home/home_cubit.dart';
import 'package:wiretap_webclient/presentation/sessions/sessions_cubit.dart';
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
  runApp(
    MultiBlocProvider(
      providers: [
        (child) => BlocProvider<ThemeBloc>(bloc: ThemeBloc()..init(), child: child),
        (child) => BlocProvider<AuthenCubit>(bloc: AuthenCubit()..init(), child: child),
        (child) => BlocProvider<AccountCubit>(bloc: AccountCubit(), child: child),
        (child) => BlocProvider<HomeCubit>(bloc: HomeCubit(), child: child),
        (child) => BlocProvider<SessionsCubit>(bloc: SessionsCubit(), child: child),
      ],
      child: MyApp(),
    ),
  );
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
      scaffoldMessengerKey: UiRepo.scaffoldMessengerKey,
      routerConfig: UiRepo().router,
      title: 'WireTap',
      themeMode: BlocProvider.of<ThemeBloc>(context).state,
      theme: lightTheme,
      darkTheme: darkTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
