class CategorizationService {
  static String autoCategorize(String title, String description) {
    final text = '$title $description'.toLowerCase();

    // Theft/Robbery keywords
    if (text.contains('theft') || text.contains('robbery') ||
        text.contains('stole') || text.contains('stolen') ||
        text.contains('wallet') || text.contains('phone') ||
        text.contains('money') || text.contains('valuables')) {
      return 'Theft';
    }

    // Accident keywords
    if (text.contains('accident') || text.contains('crash') ||
        text.contains('collision') || text.contains('hit') ||
        text.contains('vehicle') || text.contains('car') ||
        text.contains('bike') || text.contains('motorcycle')) {
      return 'Accident';
    }

    // Fire keywords
    if (text.contains('fire') || text.contains('burning') ||
        text.contains('smoke') || text.contains('flames') ||
        text.contains('arson')) {
      return 'Fire';
    }

    // Medical emergency
    if (text.contains('medical') || text.contains('hospital') ||
        text.contains('injured') || text.contains('bleeding') ||
        text.contains('unconscious') || text.contains('heart') ||
        text.contains('stroke') || text.contains('emergency')) {
      return 'Medical';
    }

    // Violence/Assault
    if (text.contains('violence') || text.contains('assault') ||
        text.contains('attack') || text.contains('fight') ||
        text.contains('weapon') || text.contains('gun') ||
        text.contains('knife') || text.contains('threat')) {
      return 'Violence';
    }

    // Suspicious activity
    if (text.contains('suspicious') || text.contains('strange') ||
        text.contains('unknown') || text.contains('loitering') ||
        text.contains('following') || text.contains('watching')) {
      return 'Suspicious Activity';
    }

    return 'Other';
  }
}