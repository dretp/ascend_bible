
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'bible_api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_page.dart';

// Optionally import your generated firebase_options.dart if using FlutterFire CLI
// import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MoodBibleApp());
}


class MoodBibleApp extends StatelessWidget {
  const MoodBibleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Bible',
      theme: AppTheme.mainTheme,
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return MoodSelectorPage();
        }
        return AuthPage();
      },
    );
  }
}

class MoodSelectorPage extends StatefulWidget {
  const MoodSelectorPage({super.key});

  @override
  _MoodSelectorPageState createState() => _MoodSelectorPageState();
}

class _MoodSelectorPageState extends State<MoodSelectorPage> {
  String? selectedMood;
  String? verse;
  bool isLoading = false;

  // List of moods for the dropdown
  final List<String> moods = [
    'anxious',
    'sad',
    'angry',
    'fear',
    'weary',
    'joy',
    'lonely',
    'thankful',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Your Mood'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButton<String>(
              value: selectedMood,
              hint: Text('Choose a mood', style: AppTheme.moodDropdownTextStyle),
              isExpanded: true,
              items: moods.map((mood) {
                return DropdownMenuItem<String>(
                  value: mood,
                  child: Text(mood[0].toUpperCase() + mood.substring(1), style: AppTheme.moodDropdownTextStyle),
                );
              }).toList(),
              onChanged: (value) async {
                setState(() {
                  selectedMood = value;
                  verse = null;
                  isLoading = true;
                });
                if (value != null) {
                  final fetchedVerse = await BibleApiService.fetchVerseForMood(value);
                  setState(() {
                    verse = fetchedVerse;
                    isLoading = false;
                  });
                }
              },
            ),
            SizedBox(height: 32),
            if (isLoading)
              Center(child: CircularProgressIndicator()),
            if (!isLoading && verse != null)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    verse!,
                    style: AppTheme.verseTextStyle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
