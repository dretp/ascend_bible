import 'package:flutter/material.dart';
import 'bible_api_service.dart';
import 'theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GuessVersePage extends StatefulWidget {
  const GuessVersePage({super.key});

  @override
  _GuessVersePageState createState() => _GuessVersePageState();
}



class _GuessVersePageState extends State<GuessVersePage> {
  String? verseText;
  String? correctReference;
  String userGuess = '';
  int points = 0;
  int level = 1;
  int streak = 0;
  bool isLoading = false;
  bool showResult = false;
  bool isCorrect = false;
  String? testamentChoice; // 'Old' or 'New'

  @override
  void initState() {
    super.initState();
    _loadPoints();
    // Don't load verse until user picks testament
  }

  Future<void> _loadPoints() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists && doc.data() != null) {
      setState(() {
        points = (doc['points'] ?? 0) as int;
        level = (doc['level'] ?? 1) as int;
      });
    }
  }

  Future<void> _loadNewVerse() async {
    setState(() {
      isLoading = true;
      showResult = false;
      userGuess = '';
    });
    // Call API without testament argument (not supported in current API)
    final verseString = await BibleApiService.fetchRandomVerse();
    // Parse the verse and reference from the returned string
    String? text;
    String? reference;
    if (verseString != null) {
      final parts = verseString.split('\n- ');
      if (parts.length == 2) {
        text = parts[0].replaceAll('"', '');
        reference = parts[1];
      } else {
        text = verseString;
        reference = null;
      }
    }
    setState(() {
      verseText = text;
      correctReference = reference;
      isLoading = false;
    });
  }

  Future<void> _savePoints() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'points': points,
      'level': level,
    }, SetOptions(merge: true));
  }

  void _checkGuess() {
    setState(() {
      showResult = true;
      isCorrect = userGuess.trim().toLowerCase() == (correctReference?.trim().toLowerCase() ?? '');
      if (isCorrect) {
        points++;
        streak++;
        if (streak >= 5) {
          level++;
          streak = 0;
        }
        _savePoints();
      } else {
        streak = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Guess the Verse - Level $level')),
      body: testamentChoice == null
          ? _buildTestamentChoice(context)
          : isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Points: $points', style: AppTheme.verseTextStyle),
                      SizedBox(height: 8),
                      Text('Level: $level', style: AppTheme.verseTextStyle),
                      SizedBox(height: 8),
                      Text('Streak: $streak/5', style: AppTheme.verseTextStyle),
                      SizedBox(height: 24),
                      if (verseText != null)
                        Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              verseText!,
                              style: AppTheme.verseTextStyle,
                            ),
                          ),
                        ),
                      SizedBox(height: 24),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Your Guess (e.g. John 3:16)',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) => userGuess = val,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: showResult ? null : _checkGuess,
                        child: Text('Submit'),
                      ),
                      if (showResult)
                        Column(
                          children: [
                            SizedBox(height: 16),
                            Text(
                              isCorrect ? 'Correct! +1 point' : 'Wrong! The answer was: $correctReference',
                              style: TextStyle(
                                color: isCorrect ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _loadNewVerse,
                              child: Text('Next'),
                            ),
                          ],
                        ),
                      SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            testamentChoice = null;
                            verseText = null;
                            correctReference = null;
                          });
                        },
                        child: Text('Change Testament'),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildTestamentChoice(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Choose a Testament to begin:', style: AppTheme.verseTextStyle),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                testamentChoice = 'Old';
              });
              _loadNewVerse();
            },
            child: Text('Old Testament'),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                testamentChoice = 'New';
              });
              _loadNewVerse();
            },
            child: Text('New Testament'),
          ),
        ],
      ),
    );
  }
}
