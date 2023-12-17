import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserHistoryPage extends StatelessWidget {
  final String userId;
  final _customColor = Colors.purple.withOpacity(0.5);
  UserHistoryPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
        backgroundColor: _customColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("user_records")
            .doc(userId)
            .collection("entry_exit")
            .orderBy("entry_time", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text("No entry/exit records found."),
            );
          }

          List<EntryExitRecord> records = [];
          final docs = snapshot.data!.docs;
          for (var doc in docs) {
            final entryTime = doc["entry_time"].toDate();
            final exitTime = doc["exit_time"]?.toDate();
            records.add(EntryExitRecord(entryTime: entryTime, exitTime: exitTime));
          }

          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return Card(
                elevation: 2,
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text(
                    "Entry Time: ${record.entryTime}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  subtitle: Text(
                    "Exit Time: ${record.exitTime ?? 'Not Available'}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class EntryExitRecord {
  final DateTime entryTime;
  final DateTime? exitTime;

  EntryExitRecord({
    required this.entryTime,
    this.exitTime,
  });
}
