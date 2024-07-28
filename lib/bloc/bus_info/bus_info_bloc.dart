import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/bus_data.dart';
import '../../model/student_data.dart';
import 'bus_info_event.dart';
import 'bus_info_state.dart';

class BusInfoBloc extends Bloc<BusInfoEvent, BusInfoState> {
  final studentCollection = FirebaseFirestore.instance.collection('Students');
  final busCollection = FirebaseFirestore.instance.collection('Bus');
  late DatabaseReference routeReference;
  late List<DatabaseReference> busReferences = [];
  // List to store StreamSubscription objects for bus references
  late List<StreamSubscription<DatabaseEvent>> busSubscriptions = [];

  BusInfoBloc() : super(BusInfoLoading()) {
    on<LoadBusInfo>(_onLoadBusDetail);
    on<UpdateBusStatus>(_onUpdateBusStatus);
  }

  Future<void> _onLoadBusDetail(LoadBusInfo event, Emitter<BusInfoState> emit) async {
    emit(BusInfoLoading());

    try {
      // Fetch student data
      DocumentSnapshot documentSnapshot =
      await studentCollection.doc(event.studentID).get();

      final studentData = StudentData.fromFirestore(documentSnapshot);
      final busIDs = studentData.studentAssignBus;
      final List<BusData> tempBusListData = [];
      final List<bool> busStatus = List.generate(busIDs.length, (index) => false);

      if(studentData.studentAssignBus.isEmpty) {
        print('hello');
        emit(const BusInfoError('Sinh viên chưa đăng ký tuyến xe'));
        return;
      }

      for (int i = 0; i < busIDs.length; i++) {
        QuerySnapshot querySnapshot =
        await busCollection.where('BusID', isEqualTo: busIDs[i]).get();

        if (querySnapshot.docs.isNotEmpty) {
          tempBusListData.addAll(querySnapshot.docs.map((doc) => BusData.fromFirestore(doc)));
        }

        // Subscribe to real-time updates for each bus
        final busRef = FirebaseDatabase.instance.ref().child(busIDs[i]);
        busReferences.add(busRef);
        final subscription = busRef.onValue.listen((event) {
          final status = event.snapshot.exists;
          add(UpdateBusStatus(busIDs[i], status));
        });

        // Store the subscription
        busSubscriptions.add(subscription);

        final snapshot = await busRef.get();
        if (snapshot.exists) {
          busStatus[i] = true;
        }
      }

      emit(BusInfoLoaded(
        busListData: tempBusListData,
        busStatus: busStatus,
        studentData: studentData,
      ));
    } catch (e) {
      emit(BusInfoError(e.toString()));
    }
  }

  void _onUpdateBusStatus(UpdateBusStatus event, Emitter<BusInfoState> emit) {
    if (state is BusInfoLoaded) {
      final currentState = state as BusInfoLoaded;
      final busIndex = currentState.busListData.indexWhere((bus) => bus.busID == event.busID);
      if (busIndex != -1) {
        final updatedBusStatus = List<bool>.from(currentState.busStatus);
        updatedBusStatus[busIndex] = event.status;
        emit(BusInfoLoaded(
          busListData: currentState.busListData,
          busStatus: updatedBusStatus,
          studentData: currentState.studentData,
        ));
      }
    }
  }

  @override
  Future<void> close() {
    // Cancel all subscriptions
    for (var subscription in busSubscriptions) {
      subscription.cancel();
    }
    return super.close();
  }
}
