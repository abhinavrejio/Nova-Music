class LibraryFolder {
  final String path;

  const LibraryFolder({
    required this.path,
  });

  Map<String, dynamic> toJson() => {
        'path': path,
      };

  factory LibraryFolder.fromJson(
    Map<String, dynamic> json,
  ) {
    return LibraryFolder(
      path: json['path'] as String,
    );
  }
}