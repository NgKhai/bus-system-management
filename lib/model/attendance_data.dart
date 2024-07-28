import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceData {
  String? attendanceID;
  String? studentID;
  String? busID;
  String? currentDate;
  String? currentTime;
  String? busTime;
  num? dropLatitude;
  num? dropLongitude;

  AttendanceData(
      {this.attendanceID,
      this.studentID,
      this.busID,
      this.currentDate,
      this.currentTime,
      this.busTime,
      this.dropLatitude,
      this.dropLongitude});

  toJson() {
    return {
      "AttendanceID": attendanceID,
      "StudentID": studentID,
      "BusID": busID,
      "CurrentDate": currentDate,
      "CurrentTime": currentTime,
      "BusTime": busTime,
      "DropLatitude": dropLatitude,
      "DropLongitude": dropLongitude,
    };
  }

  factory AttendanceData.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    return AttendanceData(
      attendanceID: data?['AttendanceID'] ?? '',
      studentID: data?['StudentID'] ?? '',
      busID: data?['BusID'] ?? '',
      currentDate: data?['CurrentDate'] ?? '',
      currentTime: data?['CurrentTime'] ?? '',
      busTime: data?['BusTime'] ?? '',
      dropLatitude: data?['DropLatitude'] ?? 0,
      dropLongitude: data?['DropLongitude'] ?? 0,
    );
  }
}
