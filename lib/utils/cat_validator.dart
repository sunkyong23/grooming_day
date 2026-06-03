class CatValidator {
  static bool isValidKoreanName(String name) {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) return false;

    final koreanOnlyRegex = RegExp(r'^[가-힣]+$');

    return koreanOnlyRegex.hasMatch(trimmedName);
  }
}
