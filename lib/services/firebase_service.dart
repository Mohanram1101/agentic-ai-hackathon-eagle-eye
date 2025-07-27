import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<void> sendMessage(String sessionId, String role, String content) async {
  await _firestore.collection('chat_sessions')
      .doc(sessionId)
      .collection('messages')
      .add({
    'role': role,
    'content': content,
    'timestamp': FieldValue.serverTimestamp(),
  });
}

Stream<List<Map<String, dynamic>>> getMessagesStream(String sessionId) {
  return _firestore.collection('chat_sessions')
      .doc(sessionId)
      .collection('messages')
      .orderBy('timestamp')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
}
}
