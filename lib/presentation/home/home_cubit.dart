import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:wiretap_webclient/component/state_manager/cubit.dart';
import 'package:wiretap_webclient/data_model/session/session.dart';
import 'package:wiretap_webclient/data_model/user.dart';
import 'package:wiretap_webclient/repo/error/error_repo.dart';
import 'package:wiretap_webclient/repo/session/session_repo.dart';
import 'package:wiretap_webclient/repo/user/user_repo.dart';

class HomeState extends Equatable {
  final bool isInitialized;
  final bool isLoading;
  final int totalSize;
  final int totalPage;
  final int size;
  final int page;
  final String? searchParam;
  final UserSafe? user;
  final List<Session> sessions;
  final Session? selectedSession;

  const HomeState({
    required this.isInitialized,
    required this.isLoading,
    this.totalSize = 0,
    this.totalPage = 1,
    this.size = 20,
    this.page = 1,
    this.searchParam,
    this.user,
    required this.sessions,
    this.selectedSession,
  });

  HomeState copyWith({
    bool? isInitialized,
    bool? isLoading,
    int? totalSize,
    int? totalPage,
    int? size,
    int? page,
    String? searchParam,
    UserSafe? user,
    List<Session>? sessions,
    Session? selectedSession,
  }) {
    return HomeState(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      totalSize: totalSize ?? this.totalSize,
      totalPage: totalPage ?? this.totalPage,
      size: size ?? this.size,
      page: page ?? this.page,
      searchParam: searchParam ?? this.searchParam,
      user: user ?? this.user,
      sessions: sessions ?? this.sessions,
      selectedSession: selectedSession ?? this.selectedSession,
    );
  }

  @override
  List<Object?> get props => [
    isInitialized,
    isLoading,
    totalSize,
    totalPage,
    size,
    page,
    searchParam,
    user,
    sessions,
    selectedSession,
  ];
}

class HomeCubit extends Cubit<HomeState> {
  static HomeState get initialState =>
      const HomeState(isInitialized: false, isLoading: true, sessions: []);

  HomeCubit.createInstance() : super(initialState);

  static HomeCubit? _instance;

  factory HomeCubit() {
    _instance ??= HomeCubit.createInstance();
    return _instance!;
  }

  final selectionController = StreamController<Session?>.broadcast();

  Future<void> init() async {
    var savedState = state;
    try {
      final paginableData = await SessionRepo().getSessions(
        state.size,
        state.page,
        searchParam: state.searchParam,
      );
      final user = await UserRepo().getSelf();
      final paginableSession = paginableData.data as List<Session>;
      final userSafe = user.data as UserSafe;
      state = state.copyWith(
        isInitialized: true,
        isLoading: false,
        totalSize: paginableData.totalSize,
        totalPage: paginableData.totalPage,
        size: paginableData.size,
        page: paginableData.page,
        user: userSafe,
        sessions: paginableSession,
      );
    } catch (e) {
      ErrorRepo().errorStreamController.add(e);
      state = savedState;
    }
  }

  Future<void> search(int sessionPerPage, int page, {String? searchParam}) async {
    var savedState = state;
    try {
      final paginableData = await SessionRepo().getSessions(
        sessionPerPage,
        page,
        searchParam: searchParam,
      );
      final paginableSession = paginableData.data as List<Session>;
      state = state.copyWith(
        isLoading: false,
        totalSize: paginableData.totalSize,
        totalPage: paginableData.totalPage,
        size: paginableData.size,
        page: paginableData.page,
        sessions: paginableSession,
      );
    } catch (e) {
      ErrorRepo().errorStreamController.add(e);
      state = savedState;
    }
  }

  Future<void> selectSession(Session session) async {
    state = state.copyWith(selectedSession: session);
    selectionController.add(session);
  }

  Future<void> unselectSession() async {
    state = state.copyWith(selectedSession: null);
    selectionController.add(null);
  }

  Future<void> addSession(String sessionName) async {
    var savedState = state;
    try {
      await SessionRepo().createSession(sessionName);
      final paginableData = await SessionRepo().getSessions(
        state.size,
        state.page,
        searchParam: state.searchParam,
      );
      final paginableSession = paginableData.data as List<Session>;
      state = state.copyWith(
        isLoading: false,
        totalSize: paginableData.totalSize,
        totalPage: paginableData.totalPage,
        size: paginableData.size,
        page: paginableData.page,
        sessions: paginableSession,
      );
    } catch (e) {
      ErrorRepo().errorStreamController.add(e);
      state = savedState;
    }
  }

  Future<void> updateSession(
    Session sesion, {
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
    var savedState = state;
    try {
      await SessionRepo().editSession(
        sesion.id,
        name: name,
        enableI2c: enableI2c,
        enableSpi: enableSpi,
        enableModbus: enableModbus,
        enableOscilloscope: enableOscilloscope,
        ip: ip,
        port: port,
        activeDecodeMode: activeDecodeMode,
        activeDecodeFormat: activeDecodeFormat,
      );
      final paginableData = await SessionRepo().getSessions(
        state.size,
        state.page,
        searchParam: state.searchParam,
      );
      final paginableSession = paginableData.data as List<Session>;
      state = state.copyWith(
        isLoading: false,
        totalSize: paginableData.totalSize,
        totalPage: paginableData.totalPage,
        size: paginableData.size,
        page: paginableData.page,
        sessions: paginableSession,
      );
    } catch (e) {
      ErrorRepo().errorStreamController.add(e);
      state = savedState;
    }
  }

  Future<void> deleteSession(Session session) async {
    var savedState = state;
    try {
      await SessionRepo().deleteSession(session.id);
      final paginableData = await SessionRepo().getSessions(
        state.size,
        state.page,
        searchParam: state.searchParam,
      );
      final paginableSession = paginableData.data as List<Session>;
      state = state.copyWith(
        isLoading: false,
        totalSize: paginableData.totalSize,
        totalPage: paginableData.totalPage,
        size: paginableData.size,
        page: paginableData.page,
        sessions: paginableSession,
      );
    } catch (e) {
      ErrorRepo().errorStreamController.add(e);
      state = savedState;
    }
  }
}
