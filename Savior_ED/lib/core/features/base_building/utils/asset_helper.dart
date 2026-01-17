class AssetHelper {
  static String getAssetPath(String templateId) {
    if (templateId.contains('wall')) return 'assets/images/level1/wall.png';
    if (templateId.contains('tower')) return 'assets/images/level1/tower.png';
    if (templateId.contains('house') ||
        templateId.contains('hall') ||
        templateId.contains('gate')) {
      return 'assets/images/level1/town_hall.png';
    }
    // Default fallback
    return 'assets/images/level1/town_hall.png';
  }
}
