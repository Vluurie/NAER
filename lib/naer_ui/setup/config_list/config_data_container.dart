abstract class ConfigDataContainer {
  String get id;
  String get imageUrl;
  String get title;
  String get description;
  bool get isSelected;
  String get level;
  String get stats;
  List<String> get arguments;

  void toggleSelection();
}
