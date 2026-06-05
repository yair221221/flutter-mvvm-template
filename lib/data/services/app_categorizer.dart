import '../../domain/entities/app_category.dart';

/// Maps app package names (Android) / bundle IDs (iOS) to wellness categories.
/// Unknown apps fall back to [AppCategory.neutral].
class AppCategorizer {
  AppCategorizer._();

  static AppCategory categorize(String packageName) {
    final pkg = packageName.toLowerCase();

    // ── Short Video ────────────────────────────────────────────────────────
    if (_matchesAny(pkg, _shortVideo)) return AppCategory.shortVideo;

    // ── Social Media ───────────────────────────────────────────────────────
    if (_matchesAny(pkg, _socialMedia)) return AppCategory.socialMedia;

    // ── Gaming ─────────────────────────────────────────────────────────────
    if (_matchesAny(pkg, _gaming) || _isGame(pkg)) return AppCategory.gaming;

    // ── Educational ────────────────────────────────────────────────────────
    if (_matchesAny(pkg, _educational)) return AppCategory.educational;

    // ── Reading ────────────────────────────────────────────────────────────
    if (_matchesAny(pkg, _reading)) return AppCategory.reading;

    // ── Mindfulness ────────────────────────────────────────────────────────
    if (_matchesAny(pkg, _mindfulness)) return AppCategory.mindfulness;

    // ── Productivity ───────────────────────────────────────────────────────
    if (_matchesAny(pkg, _productivity)) return AppCategory.productivity;

    return AppCategory.neutral;
  }

  static bool _matchesAny(String pkg, List<String> patterns) =>
      patterns.any((p) => pkg.contains(p));

  /// Heuristic: package contains "game" or known game publishers.
  static bool _isGame(String pkg) =>
      pkg.contains('game') ||
      pkg.contains('games') ||
      pkg.contains('puzzle') ||
      pkg.contains('clash') ||
      pkg.contains('candy') ||
      pkg.contains('supercell') ||
      pkg.contains('king.com');

  // ── App lists ─────────────────────────────────────────────────────────────

  static const _shortVideo = [
    'com.zhiliaoapp.musically',   // TikTok
    'com.ss.android.ugc.trill',   // TikTok (some regions)
    'com.instagram',               // Instagram (Reels)
    'com.google.android.youtube', // YouTube (Shorts)
    'com.snapchat.android',        // Snapchat
    'com.bereal',                  // BeReal
    'com.triller',                 // Triller
    'tv.reddit',                   // Reddit (video)
    'com.pinterest',               // Pinterest (video pins)
    // iOS bundle IDs
    'com.zhiliaoapp',
    'com.burbn.instagram',
  ];

  static const _socialMedia = [
    'com.facebook.katana',         // Facebook
    'com.facebook.lite',
    'com.twitter.android',         // X / Twitter
    'com.reddit.frontpage',        // Reddit
    'com.linkedin.android',        // LinkedIn
    'com.whatsapp',                // WhatsApp (social)
    'org.telegram.messenger',      // Telegram
    'com.discord',                 // Discord
    'com.tumblr',
    'com.vkontakte.android',       // VK
    'net.sina.weibo',              // Weibo
    // iOS
    'com.facebook.Facebook',
    'com.atebits.Tweetie2',
    'com.reddit.Reddit',
  ];

  static const _gaming = [
    'com.supercell.clashofclans',
    'com.supercell.clashroyale',
    'com.supercell.brawlstars',
    'com.king.candycrushsaga',
    'com.mojang.minecraftpe',      // Minecraft
    'com.roblox.client',           // Roblox
    'com.pubg.krmobile',           // PUBG
    'com.tencent.ig',              // PUBG Global
    'com.activision.callofduty',
    'com.ea.game',
    'com.gameloft',
    'com.zynga',
    'com.glu',
    'com.playrix',
    // iOS
    'com.mojang.minecraftpe',
    'com.roblox.robloxmobile',
  ];

  static const _educational = [
    'com.duolingo',                // Duolingo
    'org.khanacademy.android',     // Khan Academy
    'com.google.android.apps.classroom', // Google Classroom
    'com.coursera.android',        // Coursera
    'com.edx.mobile',              // edX
    'com.memrise.app',             // Memrise
    'com.babbel.mobile.android',   // Babbel
    'com.brainscape',
    'com.brilliant.android',       // Brilliant
    'com.ted',                     // TED
    'com.socratic.android',        // Socratic
    'com.photomath',
    'anki.android',                // Anki
    'com.wolfram.android.alpha',   // Wolfram Alpha
    // iOS
    'com.duolingo.duolingo',
    'org.khanacademy.Khan-Academy',
    'com.coursera.Coursera',
    'com.brilliant.Brilliant',
  ];

  static const _reading = [
    'com.amazon.kindle',           // Kindle
    'com.google.android.apps.books', // Google Play Books
    'com.audible.application',     // Audible
    'com.wattpad.mobile',          // Wattpad
    'com.scribd.app',              // Scribd
    'com.goodreads.android',       // Goodreads
    'com.spreaker.android',
    'com.nytimes.android',         // NYT
    'com.medium.reader',           // Medium
    'com.pocket',                  // Pocket
    'com.instapaper.android',      // Instapaper
    // iOS
    'com.amazon.Kindle',
    'com.audible.AudibleManager',
    'com.apple.iBooks',
  ];

  static const _mindfulness = [
    'com.calm.android',            // Calm
    'com.getsomeheadspace.android', // Headspace
    'com.insighttimer',            // Insight Timer
    'com.ten.percent.happier',     // Ten Percent Happier
    'com.buddhify',
    'com.waking.up',               // Waking Up
    'com.endel',
    // iOS
    'com.calm.Calm',
    'com.getsomeheadspace.Headspace',
  ];

  static const _productivity = [
    'notion.id',                   // Notion
    'com.todoist.android',         // Todoist
    'com.anydo',                   // Any.do
    'com.microsoft.todos',
    'com.ticktick.task',           // TickTick
    'com.google.android.calendar', // Google Calendar
    'com.google.android.keep',     // Google Keep
    'com.evernote.android',        // Evernote
    'com.microsoft.onenote',
    'com.trello',                  // Trello
    'com.atlassian.android.jira',
    'com.habitica.android',        // Habitica
    'com.focusplan',
    // iOS
    'com.notion-so.notion',
    'com.todoist.Todoist',
    'com.apple.mobilecal',
  ];
}
