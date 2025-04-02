import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:wiretap_webclient/constant/api.dart';
import 'package:wiretap_webclient/constant/oscilloscope.dart';
import 'package:wiretap_webclient/data_model/data.dart';
import 'package:wiretap_webclient/data_model/paginable_data.dart';
import 'package:wiretap_webclient/data_model/session/i2c.dart';
import 'package:wiretap_webclient/data_model/session/log.dart';
import 'package:wiretap_webclient/data_model/session/modbus.dart';
import 'package:wiretap_webclient/data_model/session/oscilloscope.dart';
import 'package:wiretap_webclient/data_model/session/session.dart';
import 'package:wiretap_webclient/data_model/session/spi.dart';
import 'package:wiretap_webclient/repo/user/user_repo.dart';

class SessionRepo {
  WebSocketChannel? _webSocketChannel;
  StreamController<String>? inputController = StreamController<String>.broadcast();
  StreamController<String>? outputController = StreamController<String>.broadcast();
  StreamSubscription<String>? _inputSubscription;
  StreamSubscription<dynamic>? _outputSubscription;

  Session? _activeSession;
  Session get activeSession {
    if (_activeSession == null) {
      throw Exception('Session not initialized');
    }
    return _activeSession!;
  }

  Map<String, String> get headerWithAccessToken => UserRepo().headerWithAccessToken;
  Map<String, String> get headerWithRefreshToken => UserRepo().headerWithRefreshToken;

  SessionRepo.createInstance();

  static SessionRepo? _instance;

  factory SessionRepo() {
    _instance ??= SessionRepo.createInstance();
    return _instance!;
  }

  Future<Data> getSession(dynamic param) async {
    final uri = Uri.parse('$baseUri/session/$param');
    final response = await get(uri, headers: headerWithAccessToken);
    if (response.statusCode == HttpStatus.ok) {
      final session = Data.fromJson(response.body);
      return session.copyWith(data: Session.fromMap(session.data));
    } else {
      throw Exception('Failed to load session');
    }
  }

  Future<PaginableData> getSessions(int sessionPerPage, int page, {String? searchParam}) async {
    final uri = Uri.parse('$baseUri/session/search').replace(
      queryParameters: {
        'sessionPerPage': sessionPerPage.toString(),
        'page': page.toString(),
        if (searchParam != null) 'searchParam': searchParam,
      },
    );
    final response = await get(uri, headers: headerWithAccessToken);
    if (response.statusCode == HttpStatus.ok) {
      log('Response: ${response.body}');
      final paginableData = PaginableData.fromJson(response.body);
      return paginableData.copyWith(
        data: paginableData.data.map((e) => Session.fromMap(e)).toList(),
      );
    } else {
      log('Failed to load sessions: ${response.statusCode} ${response.body}');
      throw Exception('Failed to load sessions');
    }
  }

  Future<Data> createSession(String sessionName) async {
    final uri = Uri.parse('$baseUri/session/');
    final response = await post(
      uri,
      headers: headerWithAccessToken,
      body: jsonEncode({'name': sessionName}),
    );
    if (response.statusCode == HttpStatus.ok) {
      final session = Data.fromJson(response.body);
      return session.copyWith(data: Session.fromMap(session.data));
    } else {
      log('Failed to create session: ${response.statusCode} ${response.body}');
      throw Exception('Failed to create session');
    }
  }

  Future<Data> editSession(
    int id, {
    String? name,
    bool? enableI2c,
    bool? enableSpi,
    bool? enableModbus,
    bool? enableOscilloscope,
    String? ip,
    int? port,
    int? activeDecodeMode,
    int? activeDecodeFormat,
  }) async {
    final uri = Uri.parse('$baseUri/session/$id');
    final response = await put(
      uri,
      headers: headerWithAccessToken,
      body: jsonEncode({
        'name': name,
        'enableI2c': enableI2c,
        'enableSpi': enableSpi,
        'enableModbus': enableModbus,
        'enableOscilloscope': enableOscilloscope,
        'ip': ip,
        'port': port,
        'activeDecodeMode':
            activeDecodeMode != null
                ? OscilloscopeDecodeMode.values[activeDecodeMode].convertToWireTapSessionEntity()
                : null,
        'activeDecodeFormat':
            activeDecodeFormat != null
                ? OscilloscopeDecodeFormat.values[activeDecodeFormat].command
                : null,
      }),
    );
    if (response.statusCode == HttpStatus.ok) {
      final session = Data.fromJson(response.body);
      return session.copyWith(data: Session.fromMap(session.data));
    } else {
      log('Failed to edit session: ${response.statusCode} ${response.body}');
      throw Exception('Failed to edit session');
    }
  }

  Future<void> deleteSession(int id) async {
    final uri = Uri.parse('$baseUri/session/$id');
    final response = await delete(uri, headers: headerWithAccessToken);
    if (response.statusCode != HttpStatus.ok) {
      log('Failed to delete session: ${response.statusCode} ${response.body}');
      throw Exception('Failed to delete session');
    }
  }

  Future<Data> startSession(int id) async {
    final uri = Uri.parse('$baseUri/session/start/$id');
    final response = await post(uri, headers: headerWithAccessToken);
    if (response.statusCode == HttpStatus.ok) {
      final session = Data.fromJson(response.body);
      _activeSession = Session.fromMap(session.data);
      _webSocketChannel = WebSocketChannel.connect(Uri.parse(wsSessionUri));
      inputController = StreamController<String>.broadcast();
      outputController = StreamController<String>.broadcast();
      await _webSocketChannel?.ready;
      _inputSubscription = inputController?.stream.listen((event) {
        if (_webSocketChannel != null) {
          _webSocketChannel?.sink.add(event);
        }
      });
      _outputSubscription = _webSocketChannel?.stream.listen((event) {
        if (event is String) {
          outputController?.add(event);
        } else {
          try {
            outputController?.add(jsonEncode(event));
          } catch (e) {
            outputController?.add(event.toString());
          }
        }
      });
      return session.copyWith(data: _activeSession);
    } else {
      log('Failed to start session: ${response.statusCode} ${response.body}');
      throw Exception('Failed to start session');
    }
  }

  Future<Data> stopSession() async {
    final uri = Uri.parse('$baseUri/session/stop');
    final response = await post(uri, headers: headerWithAccessToken);
    if (response.statusCode == HttpStatus.ok) {
      final session = Data.fromJson(response.body);
      _activeSession = null;
      await _inputSubscription?.cancel();
      await _outputSubscription?.cancel();
      _inputSubscription = null;
      _outputSubscription = null;
      await _webSocketChannel?.sink.close();
      _webSocketChannel = null;
      await inputController?.close();
      await outputController?.close();
      inputController = null;
      outputController = null;
      return session.copyWith(data: session.data != null ? Session.fromMap(session.data) : null);
    } else {
      log('Failed to stop session: ${response.statusCode} ${response.body}');
      throw Exception('Failed to stop session');
    }
  }

  Future<Data> getLatestSpiMsg(int id) async {
    final uri = Uri.parse('$baseUri/session/spi/latest/$id');
    final response = await get(uri, headers: headerWithAccessToken);
    if (response.statusCode == HttpStatus.ok) {
      final spiMsg = Data.fromJson(response.body);
      return spiMsg.copyWith(data: SpiMsg.fromMap(spiMsg.data));
    } else {
      throw Exception('Failed to load latest SPI message');
    }
  }

  Future<Data> getLatestI2cMsg(int id) async {
    final uri = Uri.parse('$baseUri/session/i2c/latest/$id');
    final response = await get(uri, headers: headerWithAccessToken);
    if (response.statusCode == HttpStatus.ok) {
      final i2cMsg = Data.fromJson(response.body);
      return i2cMsg.copyWith(data: I2cMsg.fromMap(i2cMsg.data));
    } else {
      throw Exception('Failed to load latest I2C message');
    }
  }

  Future<Data> getLatestModbusMsg(int id) async {
    final uri = Uri.parse('$baseUri/session/modbus/latest/$id');
    final response = await get(uri, headers: headerWithAccessToken);
    if (response.statusCode == HttpStatus.ok) {
      final modbusMsg = Data.fromJson(response.body);
      return modbusMsg.copyWith(data: ModbusMsg.fromMap(modbusMsg.data));
    } else {
      throw Exception('Failed to load latest Modbus message');
    }
  }

  Future<Data> getLatestOscilloscopeMsg(int id) async {
    final uri = Uri.parse('$baseUri/session/oscilloscope/latest/$id');
    final response = await get(uri, headers: headerWithAccessToken);
    if (response.statusCode == HttpStatus.ok) {
      final oscilloscopeMsg = Data.fromJson(response.body);
      return oscilloscopeMsg.copyWith(data: OscilloscopeMsg.fromMap(oscilloscopeMsg.data));
    } else {
      throw Exception('Failed to load latest Oscilloscope message');
    }
  }

  Future<Data> getLatestLog(int id) async {
    final uri = Uri.parse('$baseUri/session/log/latest/$id');
    final response = await get(uri, headers: headerWithAccessToken);
    if (response.statusCode == HttpStatus.ok) {
      final log = Data.fromJson(response.body);
      return log.copyWith(data: Log.fromMap(log.data));
    } else {
      throw Exception('Failed to load latest log');
    }
  }

  Future<Data> getSpiMsgs(int id) async {
    final uri = Uri.parse('$baseUri/session/spi/all/$id');
    final response = await get(uri, headers: headerWithAccessToken);
    if (response.statusCode == HttpStatus.ok) {
      final spiMsgs = Data.fromJson(response.body);
      return spiMsgs.copyWith(data: (spiMsgs.data as List).map((e) => SpiMsg.fromMap(e)).toList());
    } else {
      throw Exception('Failed to load SPI messages');
    }
  }

  Future<Data> getI2cMsgs(int id) async {
    final uri = Uri.parse('$baseUri/session/i2c/all/$id');
    final response = await get(uri, headers: headerWithAccessToken);
    if (response.statusCode == HttpStatus.ok) {
      final i2cMsgs = Data.fromJson(response.body);
      return i2cMsgs.copyWith(data: (i2cMsgs.data as List).map((e) => I2cMsg.fromMap(e)).toList());
    } else {
      throw Exception('Failed to load I2C messages');
    }
  }

  Future<Data> getModbusMsgs(int id) async {
    final uri = Uri.parse('$baseUri/session/modbus/all/$id');
    final response = await get(uri, headers: headerWithAccessToken);
    if (response.statusCode == HttpStatus.ok) {
      final modbusMsgs = Data.fromJson(response.body);
      return modbusMsgs.copyWith(
        data: (modbusMsgs.data as List).map((e) => ModbusMsg.fromMap(e)).toList(),
      );
    } else {
      throw Exception('Failed to load Modbus messages');
    }
  }

  Future<Data> getOscilloscopeMsgs(int id) async {
    final uri = Uri.parse('$baseUri/session/oscilloscope/all/$id');
    final response = await get(uri, headers: headerWithAccessToken);
    if (response.statusCode == HttpStatus.ok) {
      final oscilloscopeMsgs = Data.fromJson(response.body);
      return oscilloscopeMsgs.copyWith(
        data: (oscilloscopeMsgs.data as List).map((e) => OscilloscopeMsg.fromMap(e)).toList(),
      );
    } else {
      throw Exception('Failed to load Oscilloscope messages');
    }
  }

  Future<Data> getLogs(int id) async {
    final uri = Uri.parse('$baseUri/session/log/all/$id');
    final response = await get(uri, headers: headerWithAccessToken);
    if (response.statusCode == HttpStatus.ok) {
      final logs = Data.fromJson(response.body);
      return logs.copyWith(data: (logs.data as List).map((e) => Log.fromMap(e)).toList());
    } else {
      throw Exception('Failed to load logs');
    }
  }

  Future<Uint8List> getOscilloscopeCaptureImage(int sessionId, int oscilloscopeMsgId) async {
    final uri = Uri.parse('$baseUri/public/oscilloscope/$sessionId/$oscilloscopeMsgId.png');
    final response = await get(uri, headers: headerWithAccessToken);
    if (response.statusCode == HttpStatus.ok) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load Oscilloscope capture image');
    }
  }
}
