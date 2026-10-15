class PersonalizationItem {
  const PersonalizationItem({
    required this.id,
    required this.title,
    this.enabled = true,
  });

  final String id;
  final String title;
  final bool enabled;

  PersonalizationItem copyWith({
    String? id,
    String? title,
    bool? enabled,
  }) {
    return PersonalizationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      enabled: enabled ?? this.enabled,
    );
  }
}