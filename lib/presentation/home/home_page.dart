import 'package:flutter/material.dart';
import 'package:wiretap_webclient/component/state_manager/widgets/bloc_provider.dart';
import 'package:wiretap_webclient/presentation/home/home_cubit.dart';

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
  void initState() {
    final homeCubit = HomeCubit();
    final isInitialized = homeCubit.state.isInitialized;
    if (!isInitialized) {
      homeCubit.init();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final homeCubit = BlocProvider.of<HomeCubit>(context);
    final state = homeCubit.state;
    if (!state.isInitialized || state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          const ListTile(
            title: Text('Home'),
            subtitle: Text('Welcome to WireTap!'),
            leading: Icon(Icons.home),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 32,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).colorScheme.surfaceContainerLowest,
                        boxShadow: [BoxShadow(blurRadius: 32, spreadRadius: 2)],
                      ),
                      child: const Center(child: Text('Home Content')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
