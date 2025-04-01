import 'package:equatable/equatable.dart';
import 'package:wiretap_webclient/component/state_manager/cubit.dart';
import 'package:wiretap_webclient/data_model/token.dart';
import 'package:wiretap_webclient/repo/error/error_repo.dart';
import 'package:wiretap_webclient/repo/user/user_repo.dart';

class AuthenState extends Equatable {
  final bool isInitialized;
  final bool isLoading;
  final bool isAuthenticated;
  final String username;
  final String password;

  const AuthenState({
    required this.isInitialized,
    required this.isLoading,
    required this.isAuthenticated,
    required this.username,
    required this.password,
  });

  AuthenState copyWith({
    bool? isInitialized,
    bool? isLoading,
    bool? isAuthenticated,
    String? username,
    String? password,
  }) {
    return AuthenState(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }

  @override
  List<Object?> get props => [isInitialized, isLoading, isAuthenticated, username, password];
}

class AuthenCubit extends Cubit<AuthenState> {
  static AuthenState get initState => AuthenState(
    isInitialized: false,
    isLoading: true,
    isAuthenticated: false,
    username: '',
    password: '',
  );

  AuthenCubit() : super(initState);

  Future<void> init() async {
    var savedState = state;
    try {
      final hasToken = UserRepo().token != null;
      if (hasToken) {
        await UserRepo().getSelf();
        state = state.copyWith(isInitialized: true, isLoading: false, isAuthenticated: true);
      } else {
        state = state.copyWith(isInitialized: true, isLoading: false, isAuthenticated: false);
      }
    } catch (e) {
      ErrorRepo().errorStreamController.add(e);
      state = savedState.copyWith(isInitialized: true, isLoading: false, isAuthenticated: false);
    }
  }

  Future<void> login(String username, String password) async {
    try {
      state = state.copyWith(isLoading: true, username: username, password: password);
      final data = await UserRepo().login(username, password);
      final token = data.data as Token?;
      if (token != null) {
        state = state.copyWith(isAuthenticated: true, isLoading: false);
      } else {
        throw Exception('Login failed: Token not found');
      }
    } catch (e) {
      ErrorRepo().errorStreamController.add(e);
      state = state.copyWith(isLoading: false, isAuthenticated: false);
    }
  }

  Future<void> logout() async {
    try {
      await UserRepo().logout();
      state = state.copyWith(isAuthenticated: false);
    } catch (e) {
      ErrorRepo().errorStreamController.add(e);
    }
  }
}
