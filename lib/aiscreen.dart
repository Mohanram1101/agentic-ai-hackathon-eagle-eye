import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const DrishtiApp());
}

class DrishtiApp extends StatelessWidget {
  const DrishtiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agent Drishti Debug',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

/// AUTH WRAPPER
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const AgentDrishtiChatScreen();
        }
        return const AuthScreen();
      },
    );
  }
}

/// --- AUTH SCREEN ---
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _pwdCtrl = TextEditingController();
  String _status = '';
  bool _isLoading = false;

  Future<String?> signUp(String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Colors.blue[700];
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3F8),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 12,
              color: Colors.white,
              shadowColor: primary?.withOpacity(0.25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.visibility_rounded, color: primary, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      "Agent Drishti",
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Sign in to continue",
                      style: GoogleFonts.poppins(fontSize: 17, color: Colors.black54),
                    ),
                    const SizedBox(height: 32),

                    // Email
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Email",
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.grey[700]))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailCtrl,
                      decoration: InputDecoration(
                        hintText: "Enter your email",
                        prefixIcon: Icon(Icons.mail_rounded, color: primary, size: 22),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.poppins(),
                    ),

                    const SizedBox(height: 18),
                    // Password
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Password",
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.grey[700]))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _pwdCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Enter your password",
                        prefixIcon: Icon(Icons.lock_rounded, color: primary, size: 22),
                      ),
                      style: GoogleFonts.poppins(),
                    ),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          elevation: 4,
                        ),
                        onPressed: _isLoading
                            ? null
                            : () async {
                                setState(() {
                                  _isLoading = true;
                                  _status = '';
                                });
                                String? result = await signIn(_emailCtrl.text, _pwdCtrl.text);
                                setState(() {
                                  _isLoading = false;
                                  _status = result == null ? '' : 'Login failed: $result';
                                });
                              },
                        child: _isLoading
                            ? SizedBox(
                                height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Login'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: Divider(thickness: 1, color: Colors.grey[300])),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text("OR", style: GoogleFonts.poppins(color: Colors.grey[500])),
                        ),
                        Expanded(child: Divider(thickness: 1, color: Colors.grey[300])),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primary,
                          side: BorderSide(color: primary!),
                          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        icon: Image.asset('assets/google.png', height: 22, width: 22, errorBuilder: (_, __, ___) => Icon(Icons.g_mobiledata, color: Colors.red, size: 22)),
                        label: const Text("Sign up with Google"),
                        onPressed: () async {
                          // Integrate Google sign-in here if needed
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Google Sign-in not implemented in this demo.")),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primary,
                          side: BorderSide(color: primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        onPressed: _isLoading
                            ? null
                            : () async {
                                setState(() {
                                  _isLoading = true;
                                  _status = '';
                                });
                                String? result = await signUp(_emailCtrl.text, _pwdCtrl.text);
                                setState(() {
                                  _isLoading = false;
                                  _status = result == null
                                      ? 'Account created! You can login now.'
                                      : 'Sign Up failed: $result';
                                });
                              },
                        child: const Text("Create account"),
                      ),
                    ),
                    if (_status.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Text(_status, style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.w500)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// --- CHAT SCREEN ---
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

class AgentDrishtiChatScreen extends StatefulWidget {
  const AgentDrishtiChatScreen({super.key});

  @override
  State<AgentDrishtiChatScreen> createState() => _AgentDrishtiChatScreenState();
}

class _AgentDrishtiChatScreenState extends State<AgentDrishtiChatScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final List<_ChatSession> chatSessions = [];

  String? currentSessionId;
  String? currentSessionTitle;

  OverlayEntry? _popupEntry;

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _lastWords = '';

  bool isFirstMessageOfSession = true; // NEW: Track first message

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadSessionsFromFirestore();
  }

  Future<void> _loadSessionsFromFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    chatSessions.clear();

    final querySnapshot = await FirebaseFirestore.instance
        .collection('chat_sessions')
        .where('user_id', isEqualTo: user.uid)
        .get();

    for (var doc in querySnapshot.docs) {
      String sessionId = doc.id;
      String title = doc.data()['title'] ?? "Session";
      List<ChatMessage> messages = [];

      final msgSnapshot = await doc.reference.collection('messages')
          .orderBy('timestamp')
          .get();

      for (var msg in msgSnapshot.docs) {
        var data = msg.data();
        if (data['user'] != null) {
          messages.add(ChatMessage(
            text: data['user'],
            isUser: true,
            timestamp: data['timestamp']?.toDate() ?? DateTime.now(),
          ));
        }
        if (data['agent'] != null) {
          messages.add(ChatMessage(
            text: data['agent'],
            isUser: false,
            timestamp: data['timestamp']?.toDate() ?? DateTime.now(),
          ));
        }
      }

      chatSessions.add(_ChatSession(
        id: sessionId,
        title: title,
        messages: messages,
      ));
    }

    if (chatSessions.isNotEmpty) {
      setState(() {
        currentSessionId = chatSessions.first.id;
        currentSessionTitle = chatSessions.first.title;
        _messages.clear();
        _messages.addAll(chatSessions.first.messages);
      });
    }
  }

  // ---- ZONE STATUS SEARCH FUNCTION ----
  Future<String> getZoneStatus(String userText) async {
    try {
      final match = RegExp(r'zone\s*([0-9]+)', caseSensitive: false).firstMatch(userText);
      if (match != null) {
        final zoneNum = match.group(1);
        final docId = "zone$zoneNum";
        final doc = await FirebaseFirestore.instance.collection('zones').doc(docId).get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          final risk = data['risk'];
          final people = data['peoplecount'];
          final timestamp = data['timestamp'] != null
              ? (data['timestamp'] as Timestamp).toDate().toString()
              : "Unknown time";

          return "Zone $zoneNum Status:\n"
              "Risk: $risk\n"
              "People: $people\n"
              "Last Updated: $timestamp";
        } else {
          return "Sorry, I couldn't find data for Zone $zoneNum.";
        }
      } else {
        return "Please specify a valid zone number (e.g., 'zone 1').";
      }
    } catch (e) {
      return "Error fetching zone info: $e";
    }
  }

  /// SAVE MESSAGE TO FIRESTORE
  Future<void> saveMessageToFirestore({
    required String sessionId,
    required String userId,
    required String userMsg,
    required String agentMsg,
    required String sessionTitle,
  }) async {
    final sessionRef = FirebaseFirestore.instance.collection('chat_sessions').doc(sessionId);
    await sessionRef.set({
      'user_id': userId,
      'title': sessionTitle,
    }, SetOptions(merge: true));

    // Save user message and agent reply as a pair
    await sessionRef.collection('messages').add({
      'user': userMsg,
      'agent': agentMsg,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// LOG TO PYTHON BACKEND (ONLY FIRST MESSAGE OF NEW SESSION)
  Future<void> logToPythonBackend({
    required String sessionId,
    required String userId,
    required String message,
    required String response,
    required String timestamp,
  }) async {
    const pythonApiUrl = "http://YOUR_PYTHON_BACKEND_URL/log"; // Replace with your real backend URL
    try {
      await http.post(
        Uri.parse(pythonApiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "session_id": sessionId,
          "user_id": userId,
          "message": message,
          "response": response,
          "timestamp": timestamp,
        }),
      );
    } catch (e) {
      // Silent fail
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (val) {
          setState(() => _isListening = false);
        },
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _lastWords = val.recognizedWords;
              _messageController.text = _lastWords;
              _messageController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _messageController.text.length));
            });
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Microphone permission denied or not available!")),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _handleSend() async {
    String text = _messageController.text.trim();
    if (text.isEmpty) return;
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // If it's a new session, create it
    if (currentSessionId == null) {
      currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
      currentSessionTitle = _generateTitleFromText(text);
      chatSessions.insert(
        0,
        _ChatSession(
          id: currentSessionId!,
          title: currentSessionTitle!,
          messages: [],
        ),
      );
      isFirstMessageOfSession = true; // Reset flag for first message
    }

    setState(() {
      final msg = ChatMessage(text: text, isUser: true, timestamp: DateTime.now());
      _messages.add(msg);
      _sessionForCurrent()?.messages.add(msg);
      _messageController.clear();
    });

    // Always use Firestore zone lookup!
    String response = await getZoneStatus(text);

    setState(() {
      final aiMsg = ChatMessage(text: response, isUser: false, timestamp: DateTime.now());
      _messages.add(aiMsg);
      _sessionForCurrent()?.messages.add(aiMsg);
    });

    // Save Q&A to Firestore
    await saveMessageToFirestore(
      sessionId: currentSessionId!,
      userId: user.uid,
      userMsg: text,
      agentMsg: response,
      sessionTitle: currentSessionTitle ?? "Session",
    );

    // --- LOG TO PYTHON ONLY FOR FIRST MESSAGE IN SESSION ---
    if (isFirstMessageOfSession) {
      await logToPythonBackend(
        sessionId: currentSessionId!,
        userId: user.uid,
        message: text,
        response: response,
        timestamp: DateTime.now().toIso8601String(),
      );
      isFirstMessageOfSession = false;
    }
  }

  _ChatSession? _sessionForCurrent() {
    if (currentSessionId == null) return null;
    try {
      return chatSessions.firstWhere((s) => s.id == currentSessionId);
    } catch (_) {
      return null;
    }
  }

  void _startNewSession() {
    setState(() {
      currentSessionId = null;
      currentSessionTitle = null;
      _messages.clear();
      isFirstMessageOfSession = true;
    });
  }

  void _removePopup() {
    _popupEntry?.remove();
    _popupEntry = null;
  }

  void _showPopupMenu(BuildContext context, Offset offset, int index) {
    _removePopup();
    _popupEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _removePopup,
        child: Stack(
          children: [
            Positioned(
              left: offset.dx - 140,
              top: offset.dy + 24,
              child: Material(
                borderRadius: BorderRadius.circular(12),
                elevation: 8,
                child: Container(
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _popupMenuItem(Icons.share, 'Share', _removePopup),
                      _popupMenuItem(Icons.edit, 'Edit', _removePopup),
                      _popupMenuItem(Icons.archive, 'Archive', _removePopup),
                      _popupMenuItem(Icons.delete, 'Delete', () {
                        setState(() {
                          if (chatSessions[index].id == currentSessionId) {
                            _startNewSession();
                          }
                          chatSessions.removeAt(index);
                          _removePopup();
                        });
                      }, isDestructive: true),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    Overlay.of(context).insert(_popupEntry!);
  }

  Widget _popupMenuItem(IconData icon, String label, VoidCallback onTap, {bool isDestructive = false}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isDestructive ? Colors.red : Colors.black),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: isDestructive ? Colors.red : Colors.black)),
          ],
        ),
      ),
    );
  }

  void _navigateToSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatSearchPanel(allSessions: chatSessions),
      ),
    );
  }

  String _generateTitleFromText(String text) {
    List<String> words = text.split(RegExp(r'\s+'));
    return words.length >= 2 ? "${words[0]} ${words[1]}" : words.first;
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    final bgColor = Color(0xFFF5F3F8);
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(context, user),
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: _openDrawer,
        ),
        title: Text(
          "Agent Drishti",
          style: GoogleFonts.poppins(
            color: Colors.blue[700], fontWeight: FontWeight.bold, fontSize: 21),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.white,
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              tooltip: 'Sign Out',
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                setState(() {
                  chatSessions.clear();
                  _messages.clear();
                  currentSessionId = null;
                  currentSessionTitle = null;
                  isFirstMessageOfSession = true;
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: bgColor,
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isMe = message.isUser;
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment:
                            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isMe)
                            CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.blue[100],
                              child: Icon(Icons.smart_toy_rounded, color: Colors.blue[700], size: 18),
                            ),
                          if (!isMe) SizedBox(width: 6),
                          Container(
                            constraints: BoxConstraints(maxWidth: 260),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blue[50] : Colors.grey[100],
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(18),
                                topRight: Radius.circular(18),
                                bottomLeft: Radius.circular(isMe ? 18 : 2),
                                bottomRight: Radius.circular(isMe ? 2 : 18),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              message.text,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: isMe ? Colors.blue[900] : Colors.black87,
                              ),
                            ),
                          ),
                          if (isMe) SizedBox(width: 6),
                          if (isMe)
                            CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.blue[700],
                              child: Icon(Icons.person, color: Colors.white, size: 18),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (_isListening)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 8),
                  const Text('Listening...'),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ),
            ),
          Container(
            margin: const EdgeInsets.all(18),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: GoogleFonts.poppins(),
                    decoration: InputDecoration(
                      hintText: "Type your message…",
                      hintStyle: GoogleFonts.poppins(color: Colors.grey),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening ? Colors.red : Colors.blueGrey,
                  ),
                  onPressed: _listen,
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.blueAccent),
                  onPressed: _handleSend,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, User? user) {
    final primary = Colors.blue[700];
    return Drawer(
      width: 280,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
            child: Row(
              children: [
                Icon(Icons.visibility, color: primary, size: 34),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.add_comment_rounded, color: Colors.green),
                  title: const Text("New Chat"),
                  onTap: () {
                    _startNewSession();
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.search, color: Colors.deepPurple),
                  title: const Text("Search chats"),
                  onTap: () => _navigateToSearch(context),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text("Sessions", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ...chatSessions.asMap().entries.map((entry) => _chatTile(entry.key)),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.person),
                const SizedBox(width: 8),
                Text(user?.email ?? "User Name", style: GoogleFonts.poppins()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatTile(int index) {
    return Builder(
      builder: (context) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(chatSessions[index].title, style: GoogleFonts.poppins()),
          trailing: GestureDetector(
            onTapDown: (details) => _showPopupMenu(context, details.globalPosition, index),
            child: const Icon(Icons.more_vert),
          ),
          onTap: () {
            setState(() {
              currentSessionId = chatSessions[index].id;
              currentSessionTitle = chatSessions[index].title;
              _messages.clear();
              _messages.addAll(chatSessions[index].messages);
              isFirstMessageOfSession = false; // Not first message anymore
            });
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}

class _ChatSession {
  final String id;
  String title;
  final List<ChatMessage> messages;

  _ChatSession({required this.id, required this.title, List<ChatMessage>? messages})
      : messages = messages ?? [];
}

class ChatSearchPanel extends StatefulWidget {
  final List<_ChatSession> allSessions;
  const ChatSearchPanel({super.key, required this.allSessions});

  @override
  State<ChatSearchPanel> createState() => _ChatSearchPanelState();
}

class _ChatSearchPanelState extends State<ChatSearchPanel> {
  final TextEditingController _searchController = TextEditingController();
  String searchTerm = '';

  @override
  Widget build(BuildContext context) {
    List<_ChatSession> filteredSessions = widget.allSessions
        .where((session) => session.title.toLowerCase().contains(searchTerm.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Chat"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.poppins(),
              onChanged: (value) {
                setState(() {
                  searchTerm = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Search chats...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchTerm.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            searchTerm = '';
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredSessions.isEmpty
                ? const Center(child: Text("No matching sessions"))
                : ListView.builder(
                    itemCount: filteredSessions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.chat_bubble_outline),
                        title: Text(filteredSessions[index].title, style: GoogleFonts.poppins()),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
