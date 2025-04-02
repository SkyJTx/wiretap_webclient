import 'package:flutter/material.dart';
import 'package:wiretap_webclient/component/state_manager/widgets/bloc_provider.dart';
import 'package:wiretap_webclient/constant/api.dart';
import 'package:wiretap_webclient/presentation/sessions/sessions_cubit.dart';
import 'package:wiretap_webclient/repo/ui/ui_repo.dart';
import 'package:wiretap_webclient/repo/user/user_repo.dart';

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
  void initState() {
    SessionsCubit().init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final sessionCubit = BlocProvider.of<SessionsCubit>(context);
    final state = sessionCubit.state;
    if (!state.isInitialized) {
      return Center(
        child: Column(
          children: [
            Text(
              'Welcome to WireTap Sessions!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'This is where you can manage your sessions.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Please choose a session from the home page.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          const ListTile(
            title: Text('Sessions'),
            subtitle: Text('Manage your sessions here'),
            leading: Icon(Icons.window),
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
                      child: Column(
                        children: [
                          TextButton(
                            onPressed: () {
                              if (state.selectedSession == null) {
                                UiRepo().showErrorDialog(
                                  context,
                                  'No session selected. Please select a session first',
                                );
                                return;
                              }
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    scrollable: true,
                                    title: const Text('Session Info'),
                                    content: Column(
                                      children: [
                                        Text('Session ID: ${state.selectedSession?.id}'),
                                        Text('Session Name: ${state.selectedSession?.name}'),
                                        Text(
                                          'Session Status: ${state.selectedSession?.isRunning == true ? 'Running' : 'Stopped'}',
                                        ),
                                        Text(
                                          'Session Creation Date: ${state.selectedSession?.createdAt.toLocal()}',
                                        ),
                                        Text(
                                          'Session Last Updated: ${state.selectedSession?.updatedAt.toLocal()}',
                                        ),
                                        Text('Session Logs: ${state.logs.length} Messages'),
                                        Text('Session SPIs: ${state.spis.length} Messages'),
                                        Text('Session I2Cs: ${state.i2cs.length} Messages'),
                                        Text('Session Modbuses: ${state.modbuses.length} Messages'),
                                        Text(
                                          'Session Oscilloscopes: ${state.oscilloscopes.length} Messages',
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text(
                              'Session Info',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child:
                                      state.oscilloscopes.isNotEmpty
                                          ? Image.network(
                                            '$baseUri/${state.oscilloscopes.last.imageFilePath}',
                                            headers: UserRepo().headerWithAccessToken,
                                          )
                                          : Center(
                                            child: Text(
                                              'No Oscilloscope Data',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.labelLarge?.copyWith(
                                                color: Theme.of(context).colorScheme.onSurface,
                                              ),
                                            ),
                                          ),
                                ),
                                Flexible(
                                  child: Column(
                                    children: [
                                      Flexible(
                                        child:
                                            state.spis.isNotEmpty
                                                ? ListView(
                                                  children: [
                                                    Text(
                                                      'SPI Data',
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.labelLarge?.copyWith(
                                                        color:
                                                            Theme.of(context).colorScheme.onSurface,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      'MOSI: ${state.spis.last.mosi}',
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.labelLarge?.copyWith(
                                                        color:
                                                            Theme.of(context).colorScheme.onSurface,
                                                      ),
                                                    ),
                                                    Text(
                                                      'MISO: ${state.spis.last.miso}',
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.labelLarge?.copyWith(
                                                        color:
                                                            Theme.of(context).colorScheme.onSurface,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                                : Center(
                                                  child: Text(
                                                    'No SPI Data',
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.labelLarge?.copyWith(
                                                      color:
                                                          Theme.of(context).colorScheme.onSurface,
                                                    ),
                                                  ),
                                                ),
                                      ),
                                      Flexible(
                                        child:
                                            state.i2cs.isNotEmpty
                                                ? ListView(
                                                  children: [
                                                    Text(
                                                      'I2C Data',
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.labelLarge?.copyWith(
                                                        color:
                                                            Theme.of(context).colorScheme.onSurface,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      'Addressing: ${state.i2cs.last.isTenBitAddressing ? '10-bit' : '7-bit'}',
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.labelLarge?.copyWith(
                                                        color:
                                                            Theme.of(context).colorScheme.onSurface,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Read/Write: ${!state.i2cs.last.isWriteMode ? 'Read' : 'Write'}',
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.labelLarge?.copyWith(
                                                        color:
                                                            Theme.of(context).colorScheme.onSurface,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Data: ${state.i2cs.last.data}',
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.labelLarge?.copyWith(
                                                        color:
                                                            Theme.of(context).colorScheme.onSurface,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                                : Center(
                                                  child: Text(
                                                    'No I2C Data',
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.labelLarge?.copyWith(
                                                      color:
                                                          Theme.of(context).colorScheme.onSurface,
                                                    ),
                                                  ),
                                                ),
                                      ),
                                      Flexible(
                                        child:
                                            state.modbuses.isNotEmpty
                                                ? ListView(
                                                  children: [
                                                    Text(
                                                      'Modbus Data',
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.labelLarge?.copyWith(
                                                        color:
                                                            Theme.of(context).colorScheme.onSurface,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      'Slave ID: ${state.modbuses.last.address}',
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.labelLarge?.copyWith(
                                                        color:
                                                            Theme.of(context).colorScheme.onSurface,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Function Code: ${state.modbuses.last.functionCode}',
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.labelLarge?.copyWith(
                                                        color:
                                                            Theme.of(context).colorScheme.onSurface,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Register Quantity: ${state.modbuses.last.quantity}',
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.labelLarge?.copyWith(
                                                        color:
                                                            Theme.of(context).colorScheme.onSurface,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Data Length: ${state.modbuses.last.dataLength}',
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.labelLarge?.copyWith(
                                                        color:
                                                            Theme.of(context).colorScheme.onSurface,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Data: ${state.modbuses.last.data}',
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.labelLarge?.copyWith(
                                                        color:
                                                            Theme.of(context).colorScheme.onSurface,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Query CRC: ${state.modbuses.last.queryCRC}',
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.labelLarge?.copyWith(
                                                        color:
                                                            Theme.of(context).colorScheme.onSurface,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Response CRC: ${state.modbuses.last.responseCRC}',
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.labelLarge?.copyWith(
                                                        color:
                                                            Theme.of(context).colorScheme.onSurface,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                                : Center(
                                                  child: Text(
                                                    'No Modbus Data',
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.labelLarge?.copyWith(
                                                      color:
                                                          Theme.of(context).colorScheme.onSurface,
                                                    ),
                                                  ),
                                                ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
