import 'package:cloud_firestore/cloud_firestore.dart';

class StudentData {
  final String studentID;
  final String studentName;
  final List<String> studentAssignBus;
  final String dateHistory;

  StudentData(this.studentID, this.studentName, this.studentAssignBus,
      this.dateHistory);

  toJson() {
    return {
      "StudentID": studentID,
      "StudentName": studentName,
      "StudentAssignBus": studentAssignBus,
      "DateHistory": dateHistory,
    };
  }

  factory StudentData.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    return StudentData(
      data?['StudentID'] ?? '',
      data?['StudentName'] ?? '',
      data?['StudentAssignBus'] != null
          ? List<String>.from(data!['StudentAssignBus'])
          : [],
      data?['DateHistory'] ?? '',
    );
  }
}