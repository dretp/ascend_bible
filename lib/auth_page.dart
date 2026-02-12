import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'theme.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
    Future<void> handleGoogleSignIn() async {
      setState(() { isLoading = true; errorMessage = null; });
      try {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          setState(() { isLoading = false; });
          return; // User cancelled
        }
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
        print('Google sign-in successful');
      } on FirebaseAuthException catch (e) {
        print('Google sign-in error: \\${e.code} - \\${e.message}');
        setState(() { errorMessage = e.message; });
      } catch (e) {
        print('Unknown Google sign-in error: \\${e.toString()}');
        setState(() { errorMessage = 'Unknown error: \\${e.toString()}'; });
      } finally {
        setState(() { isLoading = false; });
      }
    }
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLogin = true;
  String? errorMessage;
  bool isLoading = false;

  Future<void> handleAuth() async {
    setState(() { isLoading = true; errorMessage = null; });
    print('Auth action: ' + (isLogin ? 'Sign In' : 'Sign Up'));
    print('Email: ' + emailController.text.trim());
    print('Password: ' + passwordController.text.trim());
    try {
      if (isLogin) {
        print('Attempting sign in...');
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        print('Sign in successful');
      } else {
        print('Attempting sign up...');
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        print('Sign up successful');
      }
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: \\${e.code} - \\${e.message}');
      setState(() { errorMessage = e.message; });
    } catch (e) {
      print('Unknown error: \\${e.toString()}');
      setState(() { errorMessage = 'Unknown error: \\${e.toString()}'; });
    } finally {
      setState(() { isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Sign In' : 'Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 24),
            if (errorMessage != null)
              Text(errorMessage!, style: TextStyle(color: Colors.red)),
            if (isLoading)
              CircularProgressIndicator()
            else ...[
              ElevatedButton(
                onPressed: handleAuth,
                child: Text(isLogin ? 'Sign In' : 'Sign Up'),
              ),
              SizedBox(height: 12),
              ElevatedButton.icon(
                icon: Icon(Icons.login),
                label: Text('Sign in with Google'),
                onPressed: handleGoogleSignIn,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              ),
            ],
            TextButton(
              onPressed: () => setState(() => isLogin = !isLogin),
              child: Text(isLogin ? 'Don\'t have an account? Sign Up' : 'Already have an account? Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
