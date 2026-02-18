import 'dart:convert';
import 'package:http/http.dart' as http;
import 'mood_verses.dart';

class BibleApiService {




    /// Fetch a verse by user input (e.g., 'john 3:16'), with optional translation (default: web)
  static Future<String?> fetchVerseByReference(String reference, {String translation = 'web'}) async {
    // Format: https://bible-api.com/BOOK+CHAPTER:VERSE?translation=kjv
    final ref = reference.trim().replaceAll(' ', '+');
    final url = Uri.parse('https://bible-api.com/$ref?translation=$translation');
    print('Fetching verse from: ' + url.toString());
    try {
      final response = await http.get(url);
      print('Status code: \\${response.statusCode}');
      print('Response body: \\${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['verses'] != null && data['verses'].isNotEmpty) {
          final verse = data['verses'][0];
          return '"${verse['text'].trim()}"\n- ${verse['book_name']} ${verse['chapter']}:${verse['verse']}';
        }
      }
      return 'No verse found for "$reference".';
    } catch (e) {
      print('Error: $e');
      return 'Error fetching verse.';
    }
  }
  // Fetch a random verse, optionally from specific books or testaments, using the described endpoint
  static final List<String> _allReferences = [
    // Add a large pool of references for variety
    'John 3:16', 'Romans 8:28', 'Psalm 23:1', 'Philippians 4:13', 'Genesis 1:1',
    'Proverbs 3:5', 'Matthew 6:33', 'Isaiah 40:31', 'Joshua 1:9', 'Psalm 46:10',
    '1 Corinthians 13:4', 'Hebrews 11:1', '2 Timothy 1:7', 'Matthew 11:28',
    'Psalm 119:105', 'Romans 12:2', 'Galatians 5:22', 'James 1:2', '1 Peter 5:7',
    'Ephesians 2:8', 'Psalm 27:1', 'Jeremiah 29:11', 'Psalm 34:8', 'Matthew 5:9',
    'Colossians 3:23', 'Psalm 37:4', 'Romans 5:8', 'John 14:6', 'Psalm 91:1',
    '1 John 4:19', 'Romans 10:9', 'Psalm 51:10', 'Matthew 28:19', 'Proverbs 18:10',
    'Isaiah 41:10', 'Psalm 139:14', 'Romans 15:13', 'Philippians 4:6', 'Psalm 100:4',
    'James 1:5', '1 Thessalonians 5:16', 'Micah 6:8', 'Matthew 7:7', 'Psalm 19:14',
    'Romans 6:23', 'Psalm 121:1', 'John 1:1', 'Proverbs 16:3', 'Psalm 27:14',
    'Matthew 22:37', 'Psalm 55:22', 'Romans 8:38', 'Psalm 30:5', 'Matthew 5:16',
    'Psalm 34:18', 'Ephesians 6:10', 'Psalm 56:3', '1 Corinthians 10:13',
    'Psalm 62:1', 'Romans 3:23', 'Psalm 103:12', 'Matthew 19:26',
    // ...add more as desired
  ];

  static final Set<String> _usedReferences = <String>{};

  static Future<String?> fetchRandomVerse() async {
    // Pick a random reference not used in this session
    final available = _allReferences.where((ref) => !_usedReferences.contains(ref)).toList();
    if (available.isEmpty) {
      _usedReferences.clear();
      available.addAll(_allReferences);
    }
    available.shuffle();
    final ref = available.first;
    _usedReferences.add(ref);
    return fetchVerseByReference(ref);
  }
  // Returns a book name depending on the selected mood
  static String getBookForMood(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return 'Philippians';
      case 'sad':
        return 'Psalms';
      case 'anxious':
        return '1 Peter';
      case 'thankful':
        return 'Psalms';
      case 'angry':
        return 'Ephesians';
      case 'lonely':
        return 'Hebrews';
      default:
        return 'John';
    }
  }

  // Example using bible-api.com (no API key required)
  // This API does not support mood directly, so we use the mapped book name
  static Future<String?> fetchVerseForMood(String mood) async {
    final key = mood.toLowerCase();
    final moodEntry = moodVersesList.firstWhere(
      (m) => m.mood == key,
      orElse: () => MoodVerses(mood: key, verses: []),
    );
    if (moodEntry.verses.isEmpty) {
      // fallback to book 1:1 if mood not mapped
      final book = getBookForMood(mood);
      final reference = '$book 1:1';
      final encodedRef = Uri.encodeComponent(reference);
      final url = Uri.parse('https://bible-api.com/$encodedRef');
      return _fetchVerse(url);
    }
    // Pick a random verse from the list
    final random = DateTime.now().millisecondsSinceEpoch;
    final ref = moodEntry.verses[random % moodEntry.verses.length];
    final encodedRef = Uri.encodeComponent(ref);
    final url = Uri.parse('https://bible-api.com/$encodedRef');
    return _fetchVerse(url);
  }

  static Future<String?> _fetchVerse(Uri url) async {
    try {
      final response = await http.get(url);
      if (response.statusCode != 200) return null;
      final Map<String, dynamic> data = json.decode(response.body);
      final verses = data['verses'];
      if (verses == null || verses.isEmpty) return null;
      final verse = verses.first;
      return '"${verse['text'].trim()}"\n- ${verse['book_name']} ${verse['chapter']}:${verse['verse']}';
    } catch (_) {
      return null;
    }
  }
}
