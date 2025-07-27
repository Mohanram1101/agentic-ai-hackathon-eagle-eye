import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LiveAlertsScreen extends StatelessWidget {
  const LiveAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Crowd Alerts')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('live_alerts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final alerts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final data = alerts[index].data() as Map<String, dynamic>;

              return ListTile(
                leading: const Icon(Icons.warning, color: Colors.red),
                title: Text(data['location'] ?? 'Unknown Location'),
                subtitle: Text('Risk: ${data['risk_level'] ?? 'N/A'} | Time: ${data['timestamp'] ?? ''}'),
              );
            },
          );
        },
      ),
    );
  }
}
