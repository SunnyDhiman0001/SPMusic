import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;

import 'spotify_auth_service.dart';

/// Concrete implementation of [SpotifyAuthService] backed by
/// `flutter_web_auth_2` (system browser PKCE flow) and
/// `flutter_secure_storage` (encrypted token storage).
///
/// This is the ONLY file in the app that is allowed to import
/// `flutter_web_auth_2` and `flutter_secure_storage` directly.
class SpotifyAuthServiceImpl implements SpotifyAuthService {
  SpotifyAuthServiceImpl({FlutterSecureStorage? storage, http.Client? httpClient})
      : _storage = storage ?? const FlutterSecureStorage(),
        _httpClient = httpClient ?? http.Client();

  final FlutterSecureStorage _storage;
  final http.Client _httpClient;

  static const _clientId = String.fromEnvironment(
    'SPOTIFY_CLIENT_ID',
    defaultValue: 'c54ccb8efac146ddaaa05d869d956349',
  );
  static const _redirectUri = 'spmusic://callback';
  static const _scopes = 'user-top-read playlist-modify-private';
  static const _authorizeUrl = 'https://accounts.spotify.com/authorize';
  static const _tokenUrl = 'https://accounts.spotify.com/api/token';
  static const _callbackUrlScheme = 'spmusic';

  static const _keyAccessToken = 'spotify_access_token';
  static const _keyRefreshToken = 'spotify_refresh_token';
  static const _keyExpiresAt = 'spotify_expires_at';

  @override
  Future<bool> hasValidSession() async {
    final accessToken = await _storage.read(key: _keyAccessToken);
    if (accessToken == null) return false;

    final expiresAtRaw = await _storage.read(key: _keyExpiresAt);
    final expiresAt = expiresAtRaw != null ? DateTime.tryParse(expiresAtRaw) : null;

    if (expiresAt != null && expiresAt.isAfter(DateTime.now())) {
      return true;
    }

    final refreshToken = await _storage.read(key: _keyRefreshToken);
    if (refreshToken == null) return false;

    try {
      await _refresh(refreshToken);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> login() async {
    final verifier = _generateCodeVerifier();
    final challenge = _codeChallengeFor(verifier);
    final state = _generateCodeVerifier(length: 16);

    final authUri = Uri.parse(_authorizeUrl).replace(queryParameters: {
      'client_id': _clientId,
      'response_type': 'code',
      'redirect_uri': _redirectUri,
      'code_challenge_method': 'S256',
      'code_challenge': challenge,
      'scope': _scopes,
      'state': state,
    });

    final result = await FlutterWebAuth2.authenticate(
      url: authUri.toString(),
      callbackUrlScheme: _callbackUrlScheme,
    );

    final callbackUri = Uri.parse(result);
    final returnedState = callbackUri.queryParameters['state'];
    if (returnedState != state) {
      throw Exception('Spotify auth failed: state mismatch');
    }

    final code = callbackUri.queryParameters['code'];
    if (code == null) {
      throw Exception('Spotify auth failed: no authorization code returned');
    }

    final response = await _httpClient.post(
      Uri.parse(_tokenUrl),
      headers: const {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': _redirectUri,
        'client_id': _clientId,
        'code_verifier': verifier,
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Spotify token exchange failed: ${response.statusCode} ${response.body}');
    }

    await _storeTokenResponse(jsonDecode(response.body) as Map<String, dynamic>);
  }

  @override
  Future<String> getValidAccessToken() async {
    final accessToken = await _storage.read(key: _keyAccessToken);
    if (accessToken == null) {
      throw Exception('Spotify: no active session');
    }

    final expiresAtRaw = await _storage.read(key: _keyExpiresAt);
    final expiresAt = expiresAtRaw != null ? DateTime.tryParse(expiresAtRaw) : null;

    if (expiresAt != null && expiresAt.isAfter(DateTime.now())) {
      return accessToken;
    }

    final refreshToken = await _storage.read(key: _keyRefreshToken);
    if (refreshToken == null) {
      throw Exception('Spotify: session expired and no refresh token available');
    }

    return _refresh(refreshToken);
  }

  @override
  Future<void> logout() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyExpiresAt);
  }

  Future<String> _refresh(String refreshToken) async {
    final response = await _httpClient.post(
      Uri.parse(_tokenUrl),
      headers: const {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
        'client_id': _clientId,
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Spotify token refresh failed: ${response.statusCode} ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    await _storeTokenResponse(json, fallbackRefreshToken: refreshToken);
    return json['access_token'] as String;
  }

  Future<void> _storeTokenResponse(
    Map<String, dynamic> json, {
    String? fallbackRefreshToken,
  }) async {
    final accessToken = json['access_token'] as String;
    final refreshToken = json['refresh_token'] as String? ?? fallbackRefreshToken;
    final expiresIn = json['expires_in'] as int;
    final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));

    await _storage.write(key: _keyAccessToken, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _keyRefreshToken, value: refreshToken);
    }
    await _storage.write(key: _keyExpiresAt, value: expiresAt.toIso8601String());
  }

  /// Exposed for testing: generates a cryptographically random PKCE code
  /// verifier drawn from the unreserved URI character set.
  @visibleForTesting
  static String generateCodeVerifierForTest({int length = 64}) => _generateCodeVerifier(length: length);

  /// Exposed for testing: computes the S256 PKCE code challenge for a given
  /// verifier. Pure function, no I/O.
  @visibleForTesting
  static String codeChallengeForTest(String verifier) => _codeChallengeFor(verifier);

  static String _generateCodeVerifier({int length = 64}) {
    const charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  static String _codeChallengeFor(String verifier) {
    final digest = sha256.convert(utf8.encode(verifier));
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }
}
