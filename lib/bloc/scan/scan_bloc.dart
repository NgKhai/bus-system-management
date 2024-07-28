import 'package:bus_system_management/bloc/scan/scan_event.dart';
import 'package:bus_system_management/bloc/scan/scan_state.dart';
import 'package:bus_system_management/model/bus_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../model/attendance_data.dart';
import '../../model/student_data.dart';
import '../../util/id_student.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  ScannerBloc() : super(ScannerInitial()) {
    on<BarcodeScanned>(_onBarcodeScanned);
  }

  final busCollection = FirebaseFirestore.instance.collection('Bus');
  final studentCollection = FirebaseFirestore.instance.collection('Students');
  BusData? busData;
  AttendanceData? attendanceData;
  final int _distanceTime = 10;
  String _busTime = '';
  bool _checkTime = true;

  bool _isScanning = false;

  Future<void> _onBarcodeScanned(BarcodeScanned event, Emitter<ScannerState> emit) async {
    if (_isScanning) return; // Prevent multiple scans
    _isScanning = true;

    emit(ScannerLoading());
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      emit(const ScannerError('Sinh viên chưa xác thực'));
      _isScanning = false;
      return;
    }

    String studentID = IDStudent(user.email!).getID();

    try {


      busData = await getBusData(event.busID); // lấy dữ liệu bus

      _checkTime = checkTime(); // check + lấy dữ liệu thời gian di chuyển bus

      // check dữ liệu đã tồn tại hay chưa
      final bool attendanceExists = await isAttendanceExist(
          studentID,
          event.busID,
          getDate(DateTime.now()),
          _busTime,
      );

      if (attendanceExists) {
        emit(ScannerError('Sinh viên đã điểm danh ${busData!.busName} vào lúc $_busTime'));
      } else if(_checkTime) {
        emit(ScannerError('Chưa đến giờ điểm danh ${busData!.busName}'));
      }
      else {

        // Lưu dữ liệu
        DocumentSnapshot documentSnapshot = await studentCollection.doc(studentID).get();
        final studentData = StudentData.fromFirestore(documentSnapshot);
        final busIDs = studentData.studentAssignBus;

        // check sv dăng ký tuyến có trùng với mã qr
        if (busIDs.contains(event.busID)) {

          emit(ScannerSuccess(busData!));
        } else if (busData == null) {
          emit(const ScannerError('Mã QR không hợp lệ'));
        } else {
          emit(ScannerError('Sinh viên chưa đăng ký ${busData!.busName}'));
        }
      }
    } catch (e) {
      emit(ScannerError(e.toString()));
    } finally {
      _isScanning = false;
    }
  }

  Future<BusData?> getBusData(String busID) async {

    // Document id là bus id
    DocumentSnapshot doc = await busCollection.doc(busID).get();
    if(doc.exists) {
      return BusData.fromFirestore(doc);
    }
    return null;
  }

  Future<bool> isAttendanceExist(String studentID, String busID, String currentDate, String busTime) async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Attendances')
          .where('StudentID', isEqualTo: studentID)
          .where('BusID', isEqualTo: busID)
          .where('CurrentDate', isEqualTo: currentDate)
          .where('BusTime', isEqualTo: busTime)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      // Handle errors
      print('Error checking attendance existence: $e');
      return false;
    }
  }

  bool checkTime() {

    List<String> busForwardTime = busData!.busForwardTime;
    List<String> busBackwardTime = busData!.busBackwardTime;

    // TimeOfDay currentTimeOfDay = TimeOfDay.now(); // lấy giờ hiện tại
    TimeOfDay currentTimeOfDay = const TimeOfDay(hour: 11, minute: 10); //test
    final currentMinutes = currentTimeOfDay.hour * 60 + currentTimeOfDay.minute;

    // vòng lặp để check, distanceTime là thời gian giãn cách (ex: 10h giãn cách 10p là 9h50 đến 10h10)

    // check lượt đi
    for(int i = 0 ; i < busForwardTime.length; i++) {
      TimeOfDay busTimeOfDay = _parseTimeOfDay(busForwardTime[i]);
      final busMinutes = busTimeOfDay.hour * 60 + busTimeOfDay.minute;
      if(currentMinutes >= busMinutes - _distanceTime && currentMinutes <= busMinutes + _distanceTime) {
        _busTime = busBackwardTime[i];
        return false;
      }
    }

    // check lượt về
    for(int i = 0 ; i < busBackwardTime.length; i++) {
      TimeOfDay busTimeOfDay = _parseTimeOfDay(busBackwardTime[i]);
      final busMinutes = busTimeOfDay.hour * 60 + busTimeOfDay.minute;
      if(currentMinutes >= busMinutes - _distanceTime && currentMinutes <= busMinutes + _distanceTime) {
        _busTime = busBackwardTime[i];
        return false;
      }
    }

    return true;
  }

  TimeOfDay _parseTimeOfDay(String time) {
    final format = DateFormat.Hms();
    final dateTime = format.parse(time);
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  String getDate(DateTime selectedDate) {
    return DateFormat('dd/MM/yyyy').format(selectedDate);
  }

  String getTime(DateTime selectedDate) {
    return DateFormat('HH:mm:ss').format(selectedDate);
  }
}