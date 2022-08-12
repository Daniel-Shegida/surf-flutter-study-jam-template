import 'package:shared_preferences/shared_preferences.dart';
import 'package:surf_practice_chat_flutter/features/auth/exceptions/auth_exception.dart';
import 'package:surf_practice_chat_flutter/features/auth/models/token_dto.dart';

/// Basic interface of token logic.
///
/// Has 3 methods: [saveToken] & [getToken] & [deleteToken].
abstract class ILocalRepository {
  /// [TokenDto] is a model, containing its' value, that should be
  /// retrieved in the end of authorization process.
  ///
  /// May throw an [AuthException].
  /// Save user's token .
  void saveToken({
    required TokenDto token,
  });

  /// get user's token .
  TokenDto getToken();

  /// delete user's token .
  void deleteToken();

  /// Save user's token .
  void saveUserName({
    required String username,
  });

  /// get user's token .
  String? getUserName();

  /// delete user's token .
  void deleteUserName();
}

/// Simple implementation of [IAuthRepository], using [SharedPreferences].
class LocalRepository implements ILocalRepository {
  final SharedPreferences _localStorage;

  /// Constructor for [LocalRepository].
  LocalRepository(this._localStorage);

  @override
  void saveToken({
    required TokenDto token,
  }) async {
    _localStorage.setString('token', token.token);
  }

  @override
  TokenDto getToken() {
    final String? tokenString = _localStorage.getString(
      'token',
    );
    if (tokenString != null) {
      return TokenDto(token: tokenString);
    } else {
      throw const AuthException("");
    }
  }

  @override
  void deleteToken() {
    _localStorage.remove(
      'token',
    );
  }

  @override
  void saveUserName({
    required String username,
  }) async {
    _localStorage.setString('user', username);
  }

  @override
  String? getUserName() {
    final String? tokenString = _localStorage.getString(
      'user',
    );
    return tokenString;
  }

  @override
  void deleteUserName() {
    _localStorage.remove(
      'user',
    );
  }
}
