/// Category of an app for wellness scoring.
enum AppCategory {
  // ── Penalty categories (cost points per minute) ─────────────────────────
  shortVideo,   // TikTok, Reels, YouTube Shorts — highest penalty
  socialMedia,  // Instagram, Facebook, Twitter, Reddit — high penalty
  gaming,       // Any mobile game — medium penalty
  neutral,      // Messaging, browser, utilities — base penalty

  // ── Bonus categories (earn points per minute) ────────────────────────────
  educational,  // Duolingo, Khan Academy, Coursera
  reading,      // Kindle, Audible, Books
  mindfulness,  // Calm, Headspace, Insight Timer
  productivity, // Notion, Todoist, Calendar
}

extension AppCategoryX on AppCategory {
  /// Points per 10 minutes of usage (negative = penalty, positive = bonus).
  double get pointsPer10Min {
    return switch (this) {
      AppCategory.shortVideo   => -3.0,
      AppCategory.socialMedia  => -2.0,
      AppCategory.gaming       => -1.5,
      AppCategory.neutral      => -1.0,
      AppCategory.educational  =>  2.0,
      AppCategory.reading      =>  2.0,
      AppCategory.mindfulness  =>  1.5,
      AppCategory.productivity =>  1.0,
    };
  }

  bool get isPenalty => pointsPer10Min < 0;
  bool get isBonus   => pointsPer10Min > 0;

  String get label {
    return switch (this) {
      AppCategory.shortVideo   => 'Short Video',
      AppCategory.socialMedia  => 'Social Media',
      AppCategory.gaming       => 'Gaming',
      AppCategory.neutral      => 'Other',
      AppCategory.educational  => 'Educational',
      AppCategory.reading      => 'Reading',
      AppCategory.mindfulness  => 'Mindfulness',
      AppCategory.productivity => 'Productivity',
    };
  }

  String get emoji {
    return switch (this) {
      AppCategory.shortVideo   => '🎵',
      AppCategory.socialMedia  => '📱',
      AppCategory.gaming       => '🎮',
      AppCategory.neutral      => '💬',
      AppCategory.educational  => '🎓',
      AppCategory.reading      => '📚',
      AppCategory.mindfulness  => '🧘',
      AppCategory.productivity => '⚙️',
    };
  }
}
