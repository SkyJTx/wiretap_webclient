// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:wiretap_webclient/component/state_manager/cubit.dart';
import 'package:wiretap_webclient/data_model/user.dart';
import 'package:wiretap_webclient/repo/error/error_repo.dart';
import 'package:wiretap_webclient/repo/user/user_repo.dart';

class AccountState extends Equatable {
  final bool isInitialized;
  final bool isLoading;
  final UserSafe? user;
  final String? searchParam;
  final int totalSize;
  final int totalPage;
  final int size;
  final int page;
  final List<UserSafe> data;

  const AccountState({
    required this.isInitialized,
    required this.isLoading,
    this.user,
    this.searchParam,
    required this.totalSize,
    required this.totalPage,
    required this.size,
    required this.page,
    required this.data,
  });

  AccountState copyWith({
    bool? isInitialized,
    bool? isLoading,
    UserSafe? user,
    String? searchParam,
    int? totalSize,
    int? totalPage,
    int? size,
    int? page,
    List<UserSafe>? data,
  }) {
    return AccountState(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      searchParam: searchParam ?? this.searchParam,
      totalSize: totalSize ?? this.totalSize,
      totalPage: totalPage ?? this.totalPage,
      size: size ?? this.size,
      page: page ?? this.page,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [
    isInitialized,
    isLoading,
    user,
    searchParam,
    totalSize,
    totalPage,
    size,
    page,
    data,
  ];
}

class AccountCubit extends Cubit<AccountState> {
  AccountCubit.createInstance() : super(initialState);

  static AccountState get initialState => const AccountState(
    isInitialized: false,
    isLoading: false,
    user: null,
    totalSize: 0,
    totalPage: 1,
    size: 20,
    page: 1,
    data: [],
  );

  static AccountCubit? _instance;

  factory AccountCubit() {
    _instance ??= AccountCubit.createInstance();
    return _instance!;
  }

  Future<void> init() async {
    var savedState = state;
    try {
      final data = await UserRepo().getSelf();
      final user = data.data as UserSafe;
      final paginableData = await UserRepo().searchUser(state.size, state.page, searchParam: null);
      final paginableUser = paginableData.data as List<UserSafe>;
      state = state.copyWith(
        isInitialized: true,
        isLoading: false,
        user: user,
        totalSize: paginableData.totalSize,
        totalPage: paginableData.totalPage,
        size: paginableData.size,
        page: paginableData.page,
        data: paginableUser,
      );
    } catch (e, s) {
      log('Error in AccountCubit.init: $e\n$s');
      ErrorRepo().addError(e);
      state = savedState;
    }
  }

  Future<void> searchUser(int page, {String? searchParam}) async {
    var savedState = state;
    try {
      state = state.copyWith(
        isLoading: true,
        page: page.clamp(1, state.totalPage),
        searchParam: searchParam,
      );
      final paginableData = await UserRepo().searchUser(state.size, page, searchParam: searchParam);
      final paginableUser = paginableData.data as List<UserSafe>;
      state = state.copyWith(
        isLoading: false,
        totalSize: paginableData.totalSize,
        totalPage: paginableData.totalPage,
        size: paginableData.size,
        page: paginableData.page,
        data: paginableUser,
      );
    } catch (e) {
      ErrorRepo().addError(e);
      state = savedState;
    }
  }

  Future<void> addUser(String username, String password, {String? alias, bool? isAdmin}) async {
    if (state.user?.isAdmin != true) {
      ErrorRepo().addError('You do not have permission to add user');
      return;
    }
    if (username.isEmpty || password.isEmpty) {
      ErrorRepo().addError('Username and password cannot be empty');
      return;
    }
    if (username.length < 3 || password.length < 6) {
      ErrorRepo().addError(
        'Username must be at least 3 characters and password at least 6 characters',
      );
      return;
    }
    if (username.length > 20 || password.length > 20) {
      ErrorRepo().addError('Username and password cannot be more than 20 characters');
      return;
    }
    if (alias != null && alias.length > 20) {
      ErrorRepo().addError('Alias cannot be more than 20 characters');
      return;
    }
    var savedState = state;
    try {
      state = state.copyWith(isLoading: true);
      await UserRepo().addUser(username, password, alias: alias, isAdmin: isAdmin);
      final paginableData = await UserRepo().searchUser(
        state.size,
        state.page,
        searchParam: state.searchParam,
      );
      final paginableUser = paginableData.data as List<UserSafe>;
      state = state.copyWith(
        isLoading: false,
        totalSize: paginableData.totalSize,
        totalPage: paginableData.totalPage,
        size: paginableData.size,
        page: paginableData.page,
        data: paginableUser,
      );
    } catch (e) {
      ErrorRepo().addError(e);
      state = savedState;
    }
  }

  Future<void> updateUser(int id, {String? username, String? alias, bool? isAdmin}) async {
    if (state.user?.isAdmin != true) {
      ErrorRepo().addError('You do not have permission to update user');
      return;
    }
    if (username != null && username.isEmpty) {
      ErrorRepo().addError('Username cannot be empty');
      return;
    }
    if (alias != null && alias.isEmpty) {
      ErrorRepo().addError('Alias cannot be empty');
      return;
    }
    if (username != null && username.length < 3) {
      ErrorRepo().addError('Username must be at least 3 characters');
      return;
    }
    if (username != null && username.length > 20) {
      ErrorRepo().addError('Username cannot be more than 20 characters');
      return;
    }
    if (alias != null && alias.length > 20) {
      ErrorRepo().addError('Alias cannot be more than 20 characters');
      return;
    }
    var savedState = state;
    try {
      state = state.copyWith(isLoading: true);
      await UserRepo().updateUser(id, username: username, alias: alias, isAdmin: isAdmin);
      final paginableData = await UserRepo().searchUser(
        state.size,
        state.page,
        searchParam: state.searchParam,
      );
      final paginableUser = paginableData.data as List<UserSafe>;
      state = state.copyWith(
        isLoading: false,
        totalSize: paginableData.totalSize,
        totalPage: paginableData.totalPage,
        size: paginableData.size,
        page: paginableData.page,
        data: paginableUser,
      );
    } catch (e) {
      ErrorRepo().addError(e);
      state = savedState;
    }
  }

  Future<void> deleteUser(int id) async {
    if (state.user?.isAdmin != true) {
      ErrorRepo().addError('You do not have permission to delete user');
      return;
    }
    var savedState = state;
    try {
      state = state.copyWith(isLoading: true);
      await UserRepo().deleteUser(id);
      final paginableData = await UserRepo().searchUser(
        state.size,
        state.page,
        searchParam: state.searchParam,
      );
      final paginableUser = paginableData.data as List<UserSafe>;
      state = state.copyWith(
        isLoading: false,
        totalSize: paginableData.totalSize,
        totalPage: paginableData.totalPage,
        size: paginableData.size,
        page: paginableData.page,
        data: paginableUser,
      );
    } catch (e) {
      ErrorRepo().addError(e);
      state = savedState;
    }
  }
}
