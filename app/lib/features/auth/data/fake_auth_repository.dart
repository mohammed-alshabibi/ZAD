import '../domain/app_user.dart';
import 'auth_repository.dart';

/// In-memory stand-in for the auth API during P1. Answers in the exact §5 JSON
/// shapes and parses them with the same `fromJson` the real repository will use.
///
/// Demo accounts (password `zad12345` for all):
/// aisha@example.com (user) · khubz@example.com (restaurant, approved) ·
/// karak@example.com (restaurant, waiting for review) · admin@zad.om (admin).
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.latency = const Duration(milliseconds: 500)});

  final Duration latency;

  static const demoPassword = 'zad12345';

  final Map<String, _Account> _accounts = {
    'aisha@example.com': _Account(
      password: demoPassword,
      json: {
        'id': 'u_aisha',
        'email': 'aisha@example.com',
        'role': 'user',
        'full_name': 'Aisha Al-Balushi',
        'phone': null,
        'status': 'active',
        'notify_enabled': true,
        // Al Khuwair, Muscat. GeoJSON: [lng, lat].
        'location': {'type': 'Point', 'coordinates': [58.396, 23.583]},
        'created_at': '2026-09-14T16:20:00Z',
      },
    ),
    'khubz@example.com': _Account(
      password: demoPassword,
      json: {
        'id': 'u_khubz',
        'email': 'khubz@example.com',
        'role': 'restaurant',
        'full_name': 'Salim Al-Hinai',
        'phone': '+968 9123 4567',
        'status': 'active',
        'notify_enabled': true,
        'location': null,
        'created_at': '2026-09-02T10:05:00Z',
      },
    ),
    'karak@example.com': _Account(
      password: demoPassword,
      json: {
        'id': 'u_karak',
        'email': 'karak@example.com',
        'role': 'restaurant',
        'full_name': 'Maryam Al-Rawahi',
        'phone': null,
        'status': 'active',
        'notify_enabled': true,
        'location': null,
        'created_at': '2026-10-21T06:58:00Z',
      },
    ),
    'admin@zad.om': _Account(
      password: demoPassword,
      json: {
        'id': 'u_admin',
        'email': 'admin@zad.om',
        'role': 'admin',
        'full_name': 'ZAD Admin',
        'phone': null,
        'status': 'active',
        'notify_enabled': false,
        'location': null,
        'created_at': '2026-08-30T08:00:00Z',
      },
    ),
  };

  String? _signedInEmail;
  var _nextId = 1;

  @override
  Future<AuthTokens> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    await Future<void>.delayed(latency);
    final key = email.trim().toLowerCase();
    if (_accounts.containsKey(key)) throw const AuthException(AuthException.emailTaken);
    _accounts[key] = _Account(
      password: password,
      json: {
        'id': 'u_new_${_nextId++}',
        'email': key,
        'role': role.toJson(),
        'full_name': fullName.trim(),
        'phone': null,
        'status': 'active',
        'notify_enabled': true,
        'location': null,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      },
    );
    _signedInEmail = key;
    return AuthTokens.fromJson(_tokens(key));
  }

  @override
  Future<AuthTokens> login({required String email, required String password}) async {
    await Future<void>.delayed(latency);
    final key = email.trim().toLowerCase();
    final account = _accounts[key];
    if (account == null || account.password != password) {
      throw const AuthException(AuthException.invalidCredentials);
    }
    _signedInEmail = key;
    return AuthTokens.fromJson(_tokens(key));
  }

  @override
  Future<AppUser> me() async {
    await Future<void>.delayed(latency ~/ 2);
    return AppUser.fromJson(_current.json);
  }

  @override
  Future<AppUser> updateMe({String? fullName, bool? notifyEnabled}) async {
    await Future<void>.delayed(latency ~/ 2);
    final json = _current.json;
    if (fullName != null) json['full_name'] = fullName.trim();
    if (notifyEnabled != null) json['notify_enabled'] = notifyEnabled;
    return AppUser.fromJson(json);
  }

  @override
  Future<AppUser> updateLocation({required double lat, required double lng}) async {
    await Future<void>.delayed(latency ~/ 2);
    final account = _current;
    account.json['location'] = {
      'type': 'Point',
      'coordinates': [lng, lat],
    };
    account.json['location_at'] = DateTime.now().toUtc().toIso8601String();
    return AppUser.fromJson(account.json);
  }

  @override
  Future<void> logout() async => _signedInEmail = null;

  _Account get _current {
    final email = _signedInEmail;
    if (email == null) throw const AuthException(AuthException.notSignedIn);
    return _accounts[email]!;
  }

  Map<String, dynamic> _tokens(String email) => {
        'access': 'fake-access.$email',
        'refresh': 'fake-refresh.$email',
      };
}

class _Account {
  _Account({required this.password, required this.json});

  final String password;
  final Map<String, dynamic> json;
}
