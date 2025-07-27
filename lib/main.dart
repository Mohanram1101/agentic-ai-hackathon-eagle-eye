import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'live_dashboard.dart'; // <--- Important
//import 'chatscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Comes from firebase_options.dart
  );
  runApp(const DrishtiApp());
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}


class DrishtiApp extends StatelessWidget {
  const DrishtiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agent Drishti Debug',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: ChatScreen('default_session_id'), // your chat screen
    );
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Drishti',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LiveDashboard(),
    );
  }
}

class ChatScreen extends StatelessWidget {
  final String sessionId;

  const ChatScreen(this.sessionId, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat - $sessionId")),
      body: Center(child: Text("Chat session: $sessionId")),
    );
  }
}