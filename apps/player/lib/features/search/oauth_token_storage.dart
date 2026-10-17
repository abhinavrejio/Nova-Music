import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'music_service.dart';

class OAuthTokens {
  const OAuthTokens({
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
    this.scopes = const {},
  });

  final String accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;
  final Set<String> scopes;
}

abstract interface class OAuthTokenStorage {
  Future<OAuthTokens?> read(MusicServiceId service);
  Future<void> write(MusicServiceId service, OAuthTokens tokens);
  Future<void> delete(MusicServiceId service);
}

abstract interface class SecureValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class _FlutterSecureValueStore implements SecureValueStore {
  _FlutterSecureValueStore(this.storage);

  final FlutterSecureStorage storage;

  @override
  Future<String?> read(String key) => storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => storage.delete(key: key);
}

/// Keeps OAuth credentials in OS-protected storage, never in app preferences.
class ProtectedOAuthTokenStorage implements OAuthTokenStorage {
  ProtectedOAuthTokenStorage({
    SecureValueStore? store,
    FlutterSecureStorage? storage,
  }) : _store =
           store ??
           _FlutterSecureValueStore(storage ?? const FlutterSecureStorage());

  final SecureValueStore _store;

  String _key(MusicServiceId service, String field) =>
      'oauth.${service.name}.$field';

  @override
  Future<OAuthTokens?> read(MusicServiceId service) async {
    final accessToken = await _store.read(_key(service, 'access'));
    if (accessToken == null || accessToken.isEmpty) return null;
    final refreshToken = await _store.read(_key(service, 'refresh'));
    final expiresAtValue = await _store.read(_key(service, 'expires'));
    final scopesValue = await _store.read(_key(service, 'scopes'));
    return OAuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAtValue == null
          ? null
          : DateTime.tryParse(expiresAtValue),
      scopes: scopesValue == null || scopesValue.trim().isEmpty
          ? const {}
          : scopesValue.split(' ').where((scope) => scope.isNotEmpty).toSet(),
    );
  }

  @override
  Future<void> write(MusicServiceId service, OAuthTokens tokens) async {
    await _store.write(_key(service, 'access'), tokens.accessToken);
    if (tokens.refreshToken == null) {
      await _store.delete(_key(service, 'refresh'));
    } else {
      await _store.write(_key(service, 'refresh'), tokens.refreshToken!);
    }
    if (tokens.expiresAt == null) {
      await _store.delete(_key(service, 'expires'));
    } else {
      await _store.write(
        _key(service, 'expires'),
        tokens.expiresAt!.toUtc().toIso8601String(),
      );
    }
    if (tokens.scopes.isEmpty) {
      await _store.delete(_key(service, 'scopes'));
    } else {
      await _store.write(_key(service, 'scopes'), tokens.scopes.join(' '));
    }
  }

  @override
  Future<void> delete(MusicServiceId service) async {
    await Future.wait([
      _store.delete(_key(service, 'access')),
      _store.delete(_key(service, 'refresh')),
      _store.delete(_key(service, 'expires')),
      _store.delete(_key(service, 'scopes')),
    ]);
  }
}

final oauthTokenStorageProvider = Provider<OAuthTokenStorage>(
  (ref) => ProtectedOAuthTokenStorage(),
);
