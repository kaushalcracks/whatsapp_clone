class SearchHelper {
  static bool matchesQuery(String text, String query) {
    if (query.isEmpty) return true;
    return text.toLowerCase().contains(query.toLowerCase());
  }

  static String highlightMatch(String text, String query) {
    if (query.isEmpty) return text;
    
    final pattern = RegExp(query, caseSensitive: false);
    final matches = pattern.allMatches(text);
    
    if (matches.isEmpty) return text;
    
    String result = '';
    int lastEnd = 0;
    
    for (final match in matches) {
      result += text.substring(lastEnd, match.start);
      result += '**${text.substring(match.start, match.end)}**';
      lastEnd = match.end;
    }
    
    result += text.substring(lastEnd);
    return result;
  }
}