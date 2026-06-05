class AppFormatters {
  /// Giải mã abstract_inverted_index
  static String decodeAbstract(Map<String, dynamic>? invertedIndex) {
    if (invertedIndex == null || invertedIndex.isEmpty) {
      return 'No abstract available for this article. Please access the publisher\'s website to read the full text.';
    }
    try {
      int maxIndex = 0;
      for (var positions in invertedIndex.values) {
        for (var pos in (positions as List)) {
          if (pos > maxIndex) maxIndex = pos;
        }
      }
      List<String> words = List.filled(maxIndex + 1, '');
      invertedIndex.forEach((word, positions) {
        for (var pos in (positions as List)) {
          words[pos] = word;
        }
      });
      return words.join(' ').trim();
    } catch (e) {
      return 'Error loading abstract.';
    }
  }

  /// Format Date từ YYYY-MM-DD sang DD Month YYYY
  static String formatDate(String? dateStr, int year) {
    if (dateStr == null || dateStr.isEmpty) return year.toString();
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        const months = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December',
        ];
        final month = months[int.parse(parts[1]) - 1];
        return '${parts[2]} $month ${parts[0]}';
      }
    } catch (_) {}
    return dateStr;
  }

  /// Format thông tin Volume
  static String buildVolumeInfo({
    String? volume,
    String? issue,
    String? firstPage,
    required int year,
  }) {
    List<String> parts = [];
    if (volume != null) parts.add('Volume $volume');
    if (issue != null) parts.add('Issue $issue');
    if (firstPage != null) parts.add('p. $firstPage');
    parts.add('($year)');
    return parts.join(', ');
  }

  /// Viết hoa chữ cái đầu cho Article Type
  static String formatArticleType(String type) {
    return type.isNotEmpty
        ? '${type[0].toUpperCase()}${type.substring(1)}'
        : 'Article';
  }
}
