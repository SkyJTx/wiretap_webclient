import 'package:flutter/material.dart';
import 'package:wiretap_webclient/bloc/theme_bloc.dart';

import 'package:wiretap_webclient/component/state_manager/state_manager.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  static const String path = '/settings';
  static const String name = 'settings';
  static const String label = 'Settings';
  static const IconData icon = Icons.settings;

  @override
  SettingPageState createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            const ListTile(
              title: Text('Settings'),
              subtitle: Text('Settings for WireTap'),
              leading: Icon(Icons.settings),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: ListTile(
                leading: const Icon(Icons.color_lens),
                title: const Text('Theme'),
                trailing: DropdownMenu<ThemeMode>(
                  initialSelection: BlocProvider.of<ThemeBloc>(context).state,
                  enableSearch: false,
                  dropdownMenuEntries:
                      ThemeMode.values.map((e) {
                        final builder = switch (e) {
                          ThemeMode.system => (label: 'System', icon: Icons.device_unknown),
                          ThemeMode.light => (label: 'Light', icon: Icons.wb_sunny),
                          ThemeMode.dark => (label: 'Dark', icon: Icons.nightlight_round),
                        };
                        return DropdownMenuEntry<ThemeMode>(
                          label: builder.label,
                          leadingIcon: Icon(builder.icon),
                          value: e,
                        );
                      }).toList(),
                  onSelected: (value) {
                    if (value != null) {
                      BlocProvider.of<ThemeBloc>(context).setTheme(value);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
