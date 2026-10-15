import 'package:flutter_test/flutter_test.dart';
import 'package:player/features/search/music_service.dart';
import 'package:player/features/search/oauth_token_storage.dart';

class _MemorySecureStore implements SecureValueStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }
}

void main() {
  test('stores and retrieves OAuth tokens per provider', () async {
    final store = _MemorySecureStore();
    final tokens = ProtectedOAuthTokenStorage(store: store);
    final expiresAt = DateTime.utc(2026, 10, 15);

    await tokens.write(
      MusicServiceId.spotify,
      OAuthTokens(
        accessToken: 'access',
        refreshToken: 'refresh',
        expiresAt: expiresAt,
      ),
    );

    final restored = await tokens.read(MusicServiceId.spotify);
    expect(restored?.accessToken, 'access');
    expect(restored?.refreshToken, 'refresh');
    expect(restored?.expiresAt, expiresAt);
    expect(await tokens.read(MusicServiceId.appleMusic), isNull);
    expect(store.values.keys, everyElement(startsWith('oauth.spotify.')));
  });

  test('deletes all token fields for a disconnected provider', () async {
    final store = _MemorySecureStore();
    final tokens = ProtectedOAuthTokenStorage(store: store);
    await tokens.write(
      MusicServiceId.spotify,
      const OAuthTokens(accessToken: 'access', refreshToken: 'refresh'),
    );

    await tokens.delete(MusicServiceId.spotify);

    expect(await tokens.read(MusicServiceId.spotify), isNull);
    expect(store.values, isEmpty);
  });
}
