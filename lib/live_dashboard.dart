import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Model class for Firestore alert documents
class Alert {
  final String zone;
  final String riskLevel;
  final String message;
  final String time;

  Alert({
    required this.zone,
    required this.riskLevel,
    required this.message,
    required this.time,
  });

  factory Alert.fromMap(Map<String, dynamic> data) {
    return Alert(
      zone: data['zone'] ?? 'Unknown Zone',
      riskLevel: data['risk_level'] ?? 'low',
      message: data['message'] ?? 'No details available',
      time: data['time'] ?? '',
    );
  }
}

/// Live dashboard UI widget
class LiveDashboard extends StatelessWidget {
  const LiveDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Project Drishti - Live Alerts"),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<List<Alert>>(
        stream: getLiveAlertsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("❌ Error fetching alerts."));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("✅ All clear. No alerts."),
            );
          }

          final alerts = snapshot.data!;

          return ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              final isHighRisk = alert.riskLevel.toLowerCase() == 'high';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: isHighRisk ? Colors.red[100] : Colors.yellow[100],
                child: ListTile(
                  leading: Icon(
                    Icons.warning,
                    color: isHighRisk ? Colors.red : Colors.orange,
                  ),
                  title: Text('${alert.zone} - ${alert.riskLevel.toUpperCase()}'),
                  subtitle: Text(alert.message),
                  trailing: Text(alert.time),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// 🔄 Real-time alert stream from Firestore
  Stream<List<Alert>> getLiveAlertsStream() {
    return FirebaseFirestore.instance
        .collection('alerts')
        .orderBy('time', descending: true) // Optional: latest on top
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Alert.fromMap(doc.data())).toList());
  }
}
