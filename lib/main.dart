import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://osuysndbnltrluqlhxbk.supabase.co',
    anonKey: 'sb_publishable_JJ4lm8Vo_TuhYYxDMptpXw_IZxBmGeB',
  );

  runApp(StudyNestApp());
}

class StudyNestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StudyNest',
      theme: ThemeData(fontFamily: 'Poppins', primarySwatch: Colors.blue),
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFFD8B9FF)),
              ),
            );
          }

          final session = Supabase.instance.client.auth.currentSession;
          if (session != null) {
            return HomeScreen();
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}
