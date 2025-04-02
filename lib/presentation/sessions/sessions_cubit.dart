import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:wiretap_webclient/component/state_manager/cubit.dart';
import 'package:wiretap_webclient/data_model/data.dart';
import 'package:wiretap_webclient/data_model/session/i2c.dart';
import 'package:wiretap_webclient/data_model/session/log.dart';
import 'package:wiretap_webclient/data_model/session/modbus.dart';
import 'package:wiretap_webclient/data_model/session/oscilloscope.dart';
import 'package:wiretap_webclient/data_model/session/session.dart';
import 'package:wiretap_webclient/data_model/session/spi.dart';
import 'package:wiretap_webclient/presentation/home/home_cubit.dart';
import 'package:wiretap_webclient/repo/session/session_repo.dart';

class SessionState extends Equatable {
  final bool isInitialized;
  final bool isLoading;
  final Session? selectedSession;
  final List<Log> logs;
  final List<SpiMsg> spis;
  final List<I2cMsg> i2cs;
  final List<ModbusMsg> modbuses;
  final List<OscilloscopeMsg> oscilloscopes;

  SessionState({
    required this.isInitialized,
    required this.isLoading,
    this.selectedSession,
    required this.logs,
    required this.spis,
    required this.i2cs,
    required this.modbuses,
    required this.oscilloscopes,
  });

  SessionState copyWith({
    bool? isInitialized,
    bool? isLoading,
    Session? selectedSession,
    List<Log>? logs,
    List<SpiMsg>? spis,
    List<I2cMsg>? i2cs,
    List<ModbusMsg>? modbuses,
    List<OscilloscopeMsg>? oscilloscopes,
  }) {
    return SessionState(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      selectedSession: selectedSession ?? this.selectedSession,
      logs: logs ?? this.logs,
      spis: spis ?? this.spis,
      i2cs: i2cs ?? this.i2cs,
      modbuses: modbuses ?? this.modbuses,
      oscilloscopes: oscilloscopes ?? this.oscilloscopes,
    );
  }

  @override
  List<Object?> get props => [
    isInitialized,
    isLoading,
    selectedSession,
    logs,
    spis,
    i2cs,
    modbuses,
    oscilloscopes,
  ];
}

class SessionsCubit extends Cubit<SessionState> {
  StreamSubscription<String>? _wsSubscription;
  StreamSubscription<Session?>? _sessionSubscription;

  static SessionState get initialState => SessionState(
    isInitialized: false,
    isLoading: false,
    selectedSession: null,
    logs: [],
    spis: [],
    i2cs: [],
    modbuses: [],
    oscilloscopes: [],
  );

  SessionsCubit.createInstance() : super(initialState);

  static SessionsCubit? _instance;

  factory SessionsCubit() {
    _instance ??= SessionsCubit.createInstance();
    return _instance!;
  }

  void init() {
    state = state.copyWith(isLoading: true);
    _sessionSubscription = HomeCubit().selectionController.stream.listen((event) async {
      final session = event;
      state = state.copyWith(
        selectedSession: session,
        isInitialized: session != null,
        isLoading: false,
      );
      if (session != null) {
        await SessionRepo().stopSession();
        SessionRepo().startSession(session.id);
      } else {
        SessionRepo().stopSession();
      }
    });
    _wsSubscription = SessionRepo().outputController?.stream.listen(
      (event) {
        final data = Data.fromJson(event);
        final type = data.message;
        if (type == 'SPI') {
          final spi = SpiMsg.fromMap(data.data);
          state = state.copyWith(spis: [...state.spis, spi]);
        }
        if (type == 'I2C') {
          final i2c = I2cMsg.fromMap(data.data);
          state = state.copyWith(i2cs: [...state.i2cs, i2c]);
        }
        if (type == 'Modbus') {
          final modbus = ModbusMsg.fromMap(data.data);
          state = state.copyWith(modbuses: [...state.modbuses, modbus]);
        }
        if (type == 'Oscilloscope') {
          final oscilloscope = OscilloscopeMsg.fromMap(data.data);
          state = state.copyWith(oscilloscopes: [...state.oscilloscopes, oscilloscope]);
        }
        if (type == 'Serial') {
          final log = Log.fromMap(data.data);
          state = state.copyWith(logs: [...state.logs, log]);
        }
      },
      onDone: () {
        clear();
        state = state.copyWith(isInitialized: false, isLoading: false);
      },
    );
    emit(state.copyWith(isInitialized: true, isLoading: false));
  }

  void dispose() {
    _wsSubscription?.cancel();
    _sessionSubscription?.cancel();
  }

  void clear() {
    state = state.copyWith(logs: [], spis: [], i2cs: [], modbuses: [], oscilloscopes: []);
  }
}
