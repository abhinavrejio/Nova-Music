import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LyricsCredentialsService {
  LyricsCredentialsService._();

  static final instance = LyricsCredentialsService._();
  static const _storage = FlutterSecureStorage();

  Future<String?> readMusixmatchKey() =>
      _storage.read(key: 'musixmatch_api_key');
  Future<void> saveMusixmatchKey(String value) =>
      _storage.write(key: 'musixmatch_api_key', value: value.trim());
  Future<void> removeMusixmatchKey() =>
      _storage.delete(key: 'musixmatch_api_key');

  Future<String?> readGeniusToken() =>
      _storage.read(key: 'genius_access_token');
  Future<void> saveGeniusToken(String value) =>
      _storage.write(key: 'genius_access_token', value: value.trim());
  Future<void> removeGeniusToken() =>
      _storage.delete(key: 'genius_access_token');

  Future<String?> readSpotifyClientId() =>
      _storage.read(key: 'spotify_client_id');
  Future<void> saveSpotifyClientId(String value) =>
      _storage.write(key: 'spotify_client_id', value: value.trim());
  Future<void> removeSpotifyClientId() =>
      _storage.delete(key: 'spotify_client_id');

  Future<String?> readAppleMusicDeveloperToken() =>
      _storage.read(key: 'apple_music_developer_token');
  Future<void> saveAppleMusicDeveloperToken(String value) =>
      _storage.write(key: 'apple_music_developer_token', value: value.trim());
  Future<void> removeAppleMusicDeveloperToken() =>
      _storage.delete(key: 'apple_music_developer_token');
}
