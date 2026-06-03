class SettingsMenuItemModel {
  const SettingsMenuItemModel({
    required this.id,
    required this.title,
    required this.iconCodePoint,
    this.showChevron = true,
  });

  final String id;
  final String title;
  final int iconCodePoint;
  final bool showChevron;
}
