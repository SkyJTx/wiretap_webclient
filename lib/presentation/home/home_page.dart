import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wiretap_webclient/component/paginator.dart';
import 'package:wiretap_webclient/component/state_manager/widgets/bloc_provider.dart';
import 'package:wiretap_webclient/constant/oscilloscope.dart';
import 'package:wiretap_webclient/presentation/home/home_cubit.dart';
import 'package:wiretap_webclient/repo/ui/ui_repo.dart';

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
  final searchController = TextEditingController();

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
          Row(
            children: [
              Flexible(
                child: const ListTile(
                  title: Text('Home'),
                  subtitle: Text('Welcome to WireTap!'),
                  leading: Icon(Icons.home),
                ),
              ),
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () async {
                        final textController = TextEditingController();
                        final name = await showDialog<String?>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Add Session'),
                              content: TextField(
                                controller: textController,
                                decoration: const InputDecoration(hintText: 'Session name'),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.pop(context, null),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, textController.text);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                        if (name != null && name.isNotEmpty) {
                          homeCubit.addSession(name);
                        }
                      },
                      child: Text(
                        'Add Session',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onError,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(32),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                boxShadow: [BoxShadow(blurRadius: 32, spreadRadius: 2)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 32,
                children: [
                  SearchBar(
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.search),
                    ),
                    controller: searchController,
                    hintText: 'Search sessions',
                    onSubmitted: (value) {
                      homeCubit.search(state.size, state.page, searchParam: value);
                    },
                  ),
                  Expanded(
                    child:
                        state.sessions.isNotEmpty
                            ? ListView.builder(
                              itemCount: state.sessions.length,
                              itemBuilder: (context, index) {
                                final item = state.sessions[index];
                                return Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                                    boxShadow:
                                        state.selectedSession == item
                                            ? [BoxShadow(blurRadius: 8, spreadRadius: 0.5)]
                                            : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: ListTile(
                                          leading:
                                              item.isRunning
                                                  ? const Icon(Icons.play_arrow)
                                                  : const Icon(Icons.stop),
                                          title: Text(item.name),
                                          subtitle: Text(
                                            item.lastUsedAt != null
                                                ? '${item.lastUsedAt?.year}/${item.lastUsedAt?.month}/${item.lastUsedAt?.day} ${item.lastUsedAt?.hour}:${item.lastUsedAt?.minute}:${item.lastUsedAt?.second}'
                                                : 'Never used',
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Column(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.arrow_forward),
                                                onPressed: () {
                                                  homeCubit.selectSession(item);
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.arrow_back),
                                                onPressed: () {
                                                  homeCubit.unselectSession();
                                                },
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.delete),
                                                onPressed: () {
                                                  UiRepo().showConfirmDialog(
                                                    context,
                                                    'Are you sure you want to delete this session?',
                                                    title: 'Delete Session',
                                                    onConfirm: () {
                                                      homeCubit.deleteSession(item);
                                                    },
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.edit),
                                                onPressed: () {
                                                  final nameController = TextEditingController(
                                                    text: item.name,
                                                  );
                                                  final enableI2cController = ValueNotifier(
                                                    item.i2c.isEnabled,
                                                  );
                                                  final enableSpiController = ValueNotifier(
                                                    item.spi.isEnabled,
                                                  );
                                                  final enableModbusController = ValueNotifier(
                                                    item.modbus.isEnabled,
                                                  );
                                                  final enableOscilloscopeController =
                                                      ValueNotifier(item.oscilloscope.isEnabled);
                                                  final ipController = TextEditingController(
                                                    text: item.oscilloscope.ip,
                                                  );
                                                  final portController = TextEditingController(
                                                    text:
                                                        item.oscilloscope.port != null
                                                            ? item.oscilloscope.port.toString()
                                                            : '',
                                                  );
                                                  final activeDecodeModeController = ValueNotifier(
                                                    OscilloscopeDecodeMode.tryParse(
                                                      item.oscilloscope.activeDecodeMode ?? '',
                                                    ),
                                                  );
                                                  final activeDecodeFormatController =
                                                      ValueNotifier(
                                                        OscilloscopeDecodeFormat.tryParse(
                                                          item.oscilloscope.activeDecodeFormat ??
                                                              '',
                                                        ),
                                                      );
                                                  showDialog<String?>(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return AlertDialog(
                                                        scrollable: true,
                                                        title: const Text('Edit Session'),
                                                        content: Container(
                                                          constraints: BoxConstraints(
                                                            maxHeight: context.h(0.8),
                                                          ),
                                                          child: Column(
                                                            children: [
                                                              Container(
                                                                constraints: const BoxConstraints(
                                                                  maxHeight: 80,
                                                                ),
                                                                child: TextField(
                                                                  controller: nameController,
                                                                  decoration: const InputDecoration(
                                                                    hintText: 'Session name',
                                                                  ),
                                                                ),
                                                              ),
                                                              ValueListenableBuilder(
                                                                valueListenable:
                                                                    enableI2cController,
                                                                builder: (context, value, child) {
                                                                  return Container(
                                                                    constraints:
                                                                        const BoxConstraints(
                                                                          maxHeight: 80,
                                                                        ),
                                                                    child: SwitchListTile(
                                                                      title: const Text(
                                                                        'Enable I2C',
                                                                      ),
                                                                      value:
                                                                          enableI2cController.value,
                                                                      onChanged: (value) {
                                                                        enableI2cController.value =
                                                                            value;
                                                                        if (value) {
                                                                          enableSpiController
                                                                              .value = false;
                                                                          enableModbusController
                                                                              .value = false;
                                                                        }
                                                                      },
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                              ValueListenableBuilder(
                                                                valueListenable:
                                                                    enableSpiController,
                                                                builder: (context, value, child) {
                                                                  return Container(
                                                                    constraints:
                                                                        const BoxConstraints(
                                                                          maxHeight: 80,
                                                                        ),
                                                                    child: SwitchListTile(
                                                                      title: const Text(
                                                                        'Enable SPI',
                                                                      ),
                                                                      value:
                                                                          enableSpiController.value,
                                                                      onChanged: (value) {
                                                                        enableSpiController.value =
                                                                            value;
                                                                        if (value) {
                                                                          enableI2cController
                                                                              .value = false;
                                                                          enableModbusController
                                                                              .value = false;
                                                                        }
                                                                      },
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                              ValueListenableBuilder(
                                                                valueListenable:
                                                                    enableModbusController,
                                                                builder: (context, value, child) {
                                                                  return Container(
                                                                    constraints:
                                                                        const BoxConstraints(
                                                                          maxHeight: 80,
                                                                        ),
                                                                    child: SwitchListTile(
                                                                      title: const Text(
                                                                        'Enable Modbus',
                                                                      ),
                                                                      value:
                                                                          enableModbusController
                                                                              .value,
                                                                      onChanged: (value) {
                                                                        enableModbusController
                                                                            .value = value;
                                                                        if (value) {
                                                                          enableI2cController
                                                                              .value = false;
                                                                          enableSpiController
                                                                              .value = false;
                                                                        }
                                                                      },
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                              ValueListenableBuilder(
                                                                valueListenable:
                                                                    enableOscilloscopeController,
                                                                builder: (context, value, child) {
                                                                  return Container(
                                                                    constraints:
                                                                        const BoxConstraints(
                                                                          maxHeight: 80,
                                                                        ),
                                                                    child: SwitchListTile(
                                                                      title: const Text(
                                                                        'Enable Oscilloscope',
                                                                      ),
                                                                      value:
                                                                          enableOscilloscopeController
                                                                              .value,
                                                                      onChanged: (value) {
                                                                        enableOscilloscopeController
                                                                            .value = value;
                                                                      },
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                              Container(
                                                                constraints: const BoxConstraints(
                                                                  maxHeight: 80,
                                                                ),
                                                                child: TextField(
                                                                  controller: ipController,
                                                                  decoration: const InputDecoration(
                                                                    hintText: 'IP Address',
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                constraints: const BoxConstraints(
                                                                  maxHeight: 80,
                                                                ),
                                                                child: TextField(
                                                                  controller: portController,
                                                                  decoration: const InputDecoration(
                                                                    hintText: 'Port',
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                constraints: const BoxConstraints(
                                                                  maxHeight: 80,
                                                                ),
                                                                child: ValueListenableBuilder(
                                                                  valueListenable:
                                                                      activeDecodeModeController,
                                                                  builder: (context, value, child) {
                                                                    return DropdownButtonFormField(
                                                                      decoration:
                                                                          const InputDecoration(
                                                                            hintText:
                                                                                'Active Decode Mode',
                                                                          ),
                                                                      items:
                                                                          OscilloscopeDecodeMode
                                                                              .values
                                                                              .map((mode) {
                                                                                return DropdownMenuItem(
                                                                                  value: mode,
                                                                                  child: Text(
                                                                                    mode.convertToWireTapSessionEntity(),
                                                                                  ),
                                                                                );
                                                                              })
                                                                              .toList(),
                                                                      onChanged: (value) {
                                                                        activeDecodeModeController
                                                                            .value = value;
                                                                      },
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                              Container(
                                                                constraints: const BoxConstraints(
                                                                  maxHeight: 80,
                                                                ),
                                                                child: ValueListenableBuilder(
                                                                  valueListenable:
                                                                      activeDecodeFormatController,
                                                                  builder: (context, value, child) {
                                                                    return DropdownButtonFormField(
                                                                      decoration:
                                                                          const InputDecoration(
                                                                            hintText:
                                                                                'Active Decode Format',
                                                                          ),
                                                                      items:
                                                                          OscilloscopeDecodeFormat
                                                                              .values
                                                                              .map((format) {
                                                                                return DropdownMenuItem(
                                                                                  value: format,
                                                                                  child: Text(
                                                                                    format.name,
                                                                                  ),
                                                                                );
                                                                              })
                                                                              .toList(),
                                                                      onChanged: (value) {
                                                                        activeDecodeFormatController
                                                                            .value = value;
                                                                      },
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            onPressed:
                                                                () => Navigator.pop(context, null),
                                                            child: const Text('Cancel'),
                                                          ),
                                                          TextButton(
                                                            onPressed: () async {
                                                              final isAppropriate1 =
                                                                  (enableI2cController.value ||
                                                                      enableSpiController.value ||
                                                                      enableModbusController.value);
                                                              if (!isAppropriate1) {
                                                                UiRepo().showErrorDialog(
                                                                  context,
                                                                  'Please enable at least one protocol. \n',
                                                                  title: 'Error',
                                                                );
                                                                return;
                                                              }
                                                              final isAppropriate2 =
                                                                  enableOscilloscopeController
                                                                      .value ==
                                                                  (ipController.text.isNotEmpty &&
                                                                      portController
                                                                          .text
                                                                          .isNotEmpty);
                                                              if (!isAppropriate2) {
                                                                UiRepo().showErrorDialog(
                                                                  context,
                                                                  'Please fill in all fields for the oscilloscope. \n',
                                                                  title: 'Error',
                                                                );
                                                                return;
                                                              }
                                                              final completer = Completer<bool>();
                                                              await UiRepo().showConfirmDialog(
                                                                context,
                                                                'Are you sure you want to edit this session?',
                                                                title: 'Edit Session',
                                                                onConfirm: () {
                                                                  completer.complete(true);
                                                                },
                                                                onCancel: () {
                                                                  completer.complete(false);
                                                                },
                                                              );
                                                              final isConfirmed =
                                                                  await completer.future;
                                                              if (!isConfirmed) {
                                                                return;
                                                              }
                                                              homeCubit.updateSession(
                                                                item,
                                                                name: nameController.text,
                                                                enableI2c:
                                                                    enableI2cController.value,
                                                                enableSpi:
                                                                    enableSpiController.value,
                                                                enableModbus:
                                                                    enableModbusController.value,
                                                                enableOscilloscope:
                                                                    enableOscilloscopeController
                                                                        .value,
                                                                ip: ipController.text,
                                                                port: int.tryParse(
                                                                  portController.text,
                                                                ),
                                                                activeDecodeMode:
                                                                    activeDecodeModeController
                                                                        .value
                                                                        ?.index,
                                                                activeDecodeFormat:
                                                                    activeDecodeFormatController
                                                                        .value
                                                                        ?.index,
                                                              );
                                                              if (context.mounted) {
                                                                Navigator.pop(context);
                                                              }
                                                            },
                                                            child: const Text('OK'),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                            : const Center(child: Text('No sessions found')),
                  ),
                  Paginator(
                    totalPage: state.totalPage,
                    currentPage: state.page,
                    onPageChanged: (page) {
                      homeCubit.search(state.size, page, searchParam: state.searchParam);
                    },
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
