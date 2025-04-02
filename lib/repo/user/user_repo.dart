import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:wiretap_webclient/constant/api.dart';
import 'package:wiretap_webclient/data_model/data.dart';
import 'package:wiretap_webclient/data_model/paginable_data.dart';
import 'package:wiretap_webclient/data_model/token.dart';
import 'package:wiretap_webclient/data_model/user.dart';
import 'package:wiretap_webclient/repo/database/database_repo.dart';

class UserRepo {
  UserRepo.create();

  static UserRepo? _instance;

  factory UserRepo() {
    _instance ??= UserRepo.create();
    return _instance!;
  }

  Token? _token;
  UserSafe? _self;
  Token? get token {
    final tokenMap = DatabaseRepo.userBox.get(userBoxKey.token);
    return _token ?? (tokenMap != null ? Token.fromMap(Map<String, dynamic>.from(tokenMap)) : null);
  }

  set token(Token? token) {
    _token = token;
    DatabaseRepo.userBox.put(userBoxKey.token, token?.toMap());
  }

  UserSafe? get self {
    final selfMap = DatabaseRepo.userBox.get(userBoxKey.self);
    return _self ?? (selfMap != null ? UserSafe.fromMap(Map<String, dynamic>.from(selfMap)) : null);
  }

  set self(UserSafe? self) {
    _self = self;
    DatabaseRepo.userBox.put(userBoxKey.self, self?.toMap());
  }

  Map<String, String> get headerWithAccessToken {
    if (token == null) {
      throw Exception('Token not initialized');
    }
    return {'Authorization': 'Bearer ${token!.accessToken}'};
  }

  Map<String, String> get headerWithRefreshToken {
    if (token == null) {
      throw Exception('Token not initialized');
    }
    return {'Authorization': 'Bearer ${token!.refreshToken}'};
  }

  Future<void> init() async {
    final selfInDB = DatabaseRepo.userBox.get(userBoxKey.self) as Map<String, dynamic>?;
    if (selfInDB != null) {
      _self = UserSafe.fromMap(selfInDB);
    }
    final tokenInDB = DatabaseRepo.userBox.get(userBoxKey.token) as Map<String, dynamic>?;
    if (tokenInDB != null) {
      _token = Token.fromMap(tokenInDB);
    }
  }

  Future<Data> login(String username, String password) async {
    final uri = Uri.parse('$baseUri/authen/login');
    final response = await post(
      uri,
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (response.statusCode == HttpStatus.ok) {
      final data = Data.fromJson(response.body);
      token = Token.fromMap(data.data);
      return data.copyWith(data: _token);
    } else {
      throw Exception('Login failed: ${response.statusCode}');
    }
  }

  Future<void> logout() async {
    final uri = Uri.parse('$baseUri/authen/logout');
    final response = await post(uri, headers: headerWithAccessToken);
    if (response.statusCode == HttpStatus.ok) {
      token = null;
    } else {
      throw Exception('Logout failed: ${response.statusCode}');
    }
  }

  Future<Data> refreshToken() async {
    final uri = Uri.parse('$baseUri/authen/refresh');
    final response = await post(uri, headers: headerWithRefreshToken);
    if (response.statusCode == HttpStatus.ok) {
      final data = Data.fromJson(response.body);
      token = Token.fromMap(data.data);
      return data.copyWith(data: _token);
    } else {
      throw Exception('Refresh token failed: ${response.statusCode}');
    }
  }

  Future<Data> getSelf() async {
    final uri = Uri.parse('$baseUri/user/self');
    final response = await get(uri, headers: headerWithAccessToken);
    if (response.statusCode == HttpStatus.ok) {
      final data = response.body;
      final user = Data.fromJson(data);
      final realUser = UserSafe.fromMap(user.data);
      self = realUser;
      return user.copyWith(data: realUser);
    } else {
      throw Exception('Get self failed: ${response.statusCode}');
    }
  }

  Future<Data> getUserById(int id) async {
    final uri = Uri.parse('$baseUri/user/$id');
    final response = await get(uri, headers: headerWithAccessToken);
    if (response.statusCode == HttpStatus.ok) {
      final data = response.body;
      final user = Data.fromJson(data);
      final realUser = UserSafe.fromMap(user.data);
      return user.copyWith(data: realUser);
    } else {
      throw Exception('Get user by id failed: ${response.statusCode}');
    }
  }

  Future<PaginableData> searchUser(int userPerPage, int page, {String? searchParam}) async {
    final uri = Uri.parse('$baseUri/user/search').replace(
      queryParameters: {
        'userPerPage': userPerPage.toString(),
        'page': page.toString(),
        if (searchParam != null) 'searchParam': searchParam,
      },
    );
    final response = await get(uri, headers: headerWithAccessToken);
    if (response.statusCode == HttpStatus.ok) {
      final data = response.body;
      final users = PaginableData.fromJson(data);
      return users.copyWith(data: users.data.map((e) => UserSafe.fromMap(e)).toList());
    } else {
      throw Exception('Get all users failed: ${response.statusCode}');
    }
  }

  Future<Data> addUser(String username, String password, {String? alias, bool? isAdmin}) async {
    final uri = Uri.parse('$baseUri/user/');
    final response = await post(
      uri,
      headers: headerWithAccessToken,
      body: jsonEncode({
        'username': username,
        'password': password,
        'alias': alias,
        'isAdmin': isAdmin,
      }),
    );
    if (response.statusCode == HttpStatus.ok) {
      final data = response.body;
      final user = Data.fromJson(data);
      final realUser = UserSafe.fromMap(user.data);
      return user.copyWith(data: realUser);
    } else {
      throw Exception('Add user failed: ${response.statusCode}');
    }
  }

  Future<Data> updateUser(int id, {String? username, String? alias, bool? isAdmin}) async {
    final uri = Uri.parse('$baseUri/user/$id');
    final response = await put(
      uri,
      headers: headerWithAccessToken,
      body: jsonEncode({'username': username, 'alias': alias, 'isAdmin': isAdmin}),
    );
    if (response.statusCode == HttpStatus.ok) {
      final data = response.body;
      final user = Data.fromJson(data);
      final realUser = UserSafe.fromMap(user.data);
      return user.copyWith(data: realUser);
    } else {
      throw Exception('Update user failed: ${response.statusCode}');
    }
  }

  Future<void> deleteUser(int id) async {
    final uri = Uri.parse('$baseUri/user/$id');
    final response = await delete(uri, headers: headerWithAccessToken);
    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Delete user failed: ${response.statusCode}');
    }
  }
}
