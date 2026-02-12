class MoodVerses {
  final String mood;
  final List<String> verses;

  const MoodVerses({required this.mood, required this.verses});
}

const List<MoodVerses> moodVersesList = [
  MoodVerses(
    mood: 'anxious',
    verses: [
      'Philippians 4:6-7',
      '1 Peter 5:7',
      'Matthew 6:34',
    ],
  ),
  MoodVerses(
    mood: 'sad',
    verses: [
      'Psalm 34:18',
      'Psalm 30:5',
      'Matthew 5:4',
    ],
  ),
  MoodVerses(
    mood: 'angry',
    verses: [
      'Ephesians 4:26',
      'James 1:19-20',
      'Proverbs 15:1',
    ],
  ),
  MoodVerses(
    mood: 'fear',
    verses: [
      'Isaiah 41:10',
      'Joshua 1:9',
      '2 Timothy 1:7',
    ],
  ),
  MoodVerses(
    mood: 'weary',
    verses: [
      'Matthew 11:28',
      'Isaiah 40:31',
    ],
  ),
  MoodVerses(
    mood: 'joy',
    verses: [
      'Nehemiah 8:10',
      '1 Timothy 6:6',
      'Psalm 16:11',
    ],
  ),
  MoodVerses(
    mood: 'lonely',
    verses: [
      'Deuteronomy 31:6',
      'Psalm 25:16',
      'Psalm 68:6',
      'Isaiah 41:10',
      'Matthew 28:20',
      'Hebrews 13:5',
      '2 Timothy 4:16-17',
    ],
  ),
  MoodVerses(
    mood: 'thankful',
    verses: [
      'Psalm 107:1',
      '1 Thessalonians 5:18',
      'Colossians 3:15-17',
      'Psalm 100:4',
      'Ephesians 5:20',
      'James 1:17',
      'Philippians 4:6',
    ],
  ),
];
