import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/library_folder.dart';
import '../../services/library_folder_service.dart';

class LibraryFolderNotifier extends Notifier<List<LibraryFolder>> {
  final LibraryFolderService _service = LibraryFolderService();

  @override
  List<LibraryFolder> build() {
    _loadFolders();
    return [];
  }

  Future<void> _loadFolders() async {
    state = await _service.loadFolders();
  }

  Future<void> addFolder(String path) async {
    await _service.addFolder(path);
    state = await _service.loadFolders();
  }

  Future<void> removeFolder(String path) async {
    await _service.removeFolder(path);
    state = await _service.loadFolders();
  }

  Future<void> refresh() async {
    state = await _service.loadFolders();
  }
}

final libraryFolderProvider =
    NotifierProvider<LibraryFolderNotifier, List<LibraryFolder>>(
  LibraryFolderNotifier.new,
);