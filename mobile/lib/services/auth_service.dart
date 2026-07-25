import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/profile.dart';
import 'api_client.dart';

/// Owns the JWT session and the signed-in user's own profile.
///
/// Other repositories are handed the same [ApiClient] instance so every
/// authenticated request automatically carries the current token.
class AuthService extends ChangeNotifier {
  AuthService(this.apiClient);

  final ApiClient apiClient;
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'access_token';

  MyProfile? currentUser;
  bool isLoading = true;

  bool get isAuthenticated => apiClient.token != null && currentUser != null;

  Future<void> bootstrap() async {
    final savedToken = await _storage.read(key: _tokenKey);
    if (savedToken != null) {
      apiClient.token = savedToken;
      try {
        await refreshProfile();
      } catch (_) {
        await _clearSession();
      }
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String birthdate, // yyyy-MM-dd
    required String gender,
    String interestedIn = 'any',
    String bio = '',
  }) async {
    final response = await apiClient.post('/api/auth/register', body: {
      'email': email,
      'password': password,
      'name': name,
      'birthdate': birthdate,
      'gender': gender,
      'interested_in': interestedIn,
      'bio': bio,
    });
    await _saveToken(response['access_token'] as String);
    await refreshProfile();
  }

  Future<void> login({required String email, required String password}) async {
    final response = await apiClient.post('/api/auth/login', body: {
      'email': email,
      'password': password,
    });
    await _saveToken(response['access_token'] as String);
    await refreshProfile();
  }

  Future<void> refreshProfile() async {
    final response = await apiClient.get('/api/users/me');
    currentUser = MyProfile.fromJson(response as Map<String, dynamic>);
    notifyListeners();
  }

  Future<void> logout() async {
    await _clearSession();
  }

  Future<void> _saveToken(String token) async {
    apiClient.token = token;
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> _clearSession() async {
    apiClient.token = null;
    currentUser = null;
    await _storage.delete(key: _tokenKey);
    notifyListeners();
  }
}
