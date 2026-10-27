import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/app_user.dart';
import 'fake_auth_repository.dart';

/// Auth and `/me` endpoints (CLAUDE.md §5.1). Screens never call this directly;
/// they go through `sessionProvider`. P2 adds an `ApiAuthRepository` (dio + JWT
/// in secure storage) and swaps it in below.
abstract interface class AuthRepository {
  /// `POST /auth/register`. Throws [AuthException] `email_taken`.
  Future<AuthTokens> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  });

  /// `POST /auth/login`. Throws [AuthException] `invalid_credentials`.
  Future<AuthTokens> login({required String email, required String password});

  /// `GET /me` for the signed-in account.
  Future<AppUser> me();

  /// `PATCH /me`: the name and the "new meals nearby" alerts switch. `role`,
  /// `status` and the email are read-only (§5.1).
  Future<AppUser> updateMe({String? fullName, bool? notifyEnabled});

  /// `PUT /me/location`, coordinates already rounded to 3 decimals.
  Future<AppUser> updateLocation({required double lat, required double lng});

  /// Logout = forget the tokens on the phone (no server blacklist, §2).
  Future<void> logout();
}

/// Error codes the API returns in `{"code": ...}`; screens map them to ARB strings.
class AuthException implements Exception {
  const AuthException(this.code);

  final String code;

  static const emailTaken = 'email_taken';
  static const invalidCredentials = 'invalid_credentials';
  static const notSignedIn = 'not_authenticated';

  @override
  String toString() => 'AuthException($code)';
}

final authRepositoryProvider = Provider<AuthRepository>((ref) => FakeAuthRepository());
