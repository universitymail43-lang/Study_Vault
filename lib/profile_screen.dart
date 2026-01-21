import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? "No Email";

    return Scaffold(
      backgroundColor: Color(0xFFF8E8EE),
      appBar: AppBar(
        title: Text("Profile", style: TextStyle(color: Color(0xFF4A4A4A))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF4A4A4A)),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 40),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(Icons.person, size: 60, color: Color(0xFFD8B9FF)),
            ),
            SizedBox(height: 20),
            Text(
              user?.userMetadata?['full_name'] ?? "Scholar",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4A4A),
              ),
            ),
            SizedBox(height: 5),
            Text(email, style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 40),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 40),
              padding: EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.settings, color: Color(0xFFD8B9FF)),
                  SizedBox(width: 10),
                  Text(
                    "Settings",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A4A4A),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            GestureDetector(
              onTap: () async {
                await Supabase.instance.client.auth.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 40),
                padding: EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Color(0xFFFFE0E0),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Color(0xFFFF8080)),
                    SizedBox(width: 10),
                    Text(
                      "Log Out",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF8080),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
