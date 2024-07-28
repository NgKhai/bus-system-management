import 'package:equatable/equatable.dart';

import '../../model/bus_data.dart';
import '../../model/student_data.dart';

abstract class BusInfoState extends Equatable {
  const BusInfoState();

  @override
  List<Object> get props => [];
}

class BusInfoLoading extends BusInfoState {}

class BusInfoLoaded extends BusInfoState {
  final List<BusData> busListData;
  final List<bool> busStatus;
  final StudentData studentData;

  const BusInfoLoaded({
    required this.busListData,
    required this.busStatus,
    required this.studentData,
  });

  @override
  List<Object> get props => [busListData, busStatus, studentData];
}

class BusInfoError extends BusInfoState {
  final String error;

  const BusInfoError(this.error);

  @override
  List<Object> get props => [error];
}