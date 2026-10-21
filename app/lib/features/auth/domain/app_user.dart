/// Account type, chosen at signup (CLAUDE.md §8.1). Admins are made on the server.
enum UserRole {
  user,
  restaurant,
  admin;

  static UserRole fromJson(String value) => UserRole.values.byName(value);
  String toJson() => name;
}

/// The signed-in account, as returned by `GET /me` (CLAUDE.md §4 `users`).
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.role,
    required this.fullName,
    required this.status,
    required this.notifyEnabled,
    this.phone,
    this.lat,
    this.lng,
    this.createdAt,
  });

  final String id;
  final String email;
  final UserRole role;
  final String fullName;
  final String? phone;

  /// `active` or `suspended`.
  final String status;
  final bool notifyEnabled;

  /// Last known location, already rounded to 3 decimals by the app.
  final double? lat;
  final double? lng;

  /// When the account was made (UTC).
  final DateTime? createdAt;

  bool get hasLocation => lat != null && lng != null;
  String get firstName => fullName.trim().split(RegExp(r'\s+')).first;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    // GeoJSON is longitude first.
    final coords = (json['location'] as Map<String, dynamic>?)?['coordinates'] as List<dynamic>?;
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      role: UserRole.fromJson(json['role'] as String),
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      status: json['status'] as String,
      notifyEnabled: json['notify_enabled'] as bool,
      lng: (coords?[0] as num?)?.toDouble(),
      lat: (coords?[1] as num?)?.toDouble(),
      createdAt: json['created_at'] == null ? null : DateTime.parse(json['created_at'] as String),
    );
  }
}

/// JWT pair from `POST /auth/login` and `POST /auth/register`.
class AuthTokens {
  const AuthTokens({required this.access, required this.refresh});

  final String access;
  final String refresh;

  factory AuthTokens.fromJson(Map<String, dynamic> json) =>
      AuthTokens(access: json['access'] as String, refresh: json['refresh'] as String);
}
