import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/library_folder.dart';

class LibraryFolderService {
  static const _foldersKey = 'library_folders';

  Future<List<LibraryFolder>> loadFolders() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonList = prefs.getStringList(_foldersKey) ?? [];

    return jsonList
        .map(
          (item) => LibraryFolder.fromJson(
            jsonDecode(item) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> saveFolders(List<LibraryFolder> folders) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonList = folders
        .map((folder) => jsonEncode(folder.toJson()))
        .toList();

    await prefs.setStringList(_foldersKey, jsonList);
  }

  Future<void> addFolder(String path) async {
    final folders = await loadFolders();

    // Prevent duplicates
    if (folders.any((folder) => folder.path == path)) {
      return;
    }

    folders.add(
      LibraryFolder(path: path),
    );

    await saveFolders(folders);
  }

  Future<void> removeFolder(String path) async {
    final folders = await loadFolders();

    folders.removeWhere(
      (folder) => folder.path == path,
    );

    await saveFolders(folders);
  }
}