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

  /// Format số có dấu phẩy (VD: 1,234,567)
  static String formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// Format số rút gọn (VD: 1.2M, 350.5K)
  static String compactNumber(double number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toInt().toString();
  }

  /// Bỏ phần mô tả trong ngoặc đơn khỏi tên tạp chí.
  static String stripParenthetical(String name) {
    return name.replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim();
  }
}
