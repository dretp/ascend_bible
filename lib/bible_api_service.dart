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
  static Future<String?> fetchRandomVerse() async {
    // bible-api.com does not support a true random endpoint, so we use a fixed verse for demo
    final url = Uri.parse('https://bible-api.com/john+3:16');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['verses'] != null && data['verses'].isNotEmpty) {
          final verse = data['verses'][0];
          return '"${verse['text'].trim()}"\n- ${verse['book_name']} ${verse['chapter']}:${verse['verse']}';
        }
      }
      return 'No verse found.';
    } catch (e) {
      return 'Error fetching verse.';
    }
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
