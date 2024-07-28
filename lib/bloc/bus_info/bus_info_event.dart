import 'package:equatable/equatable.dart';

abstract class BusInfoEvent extends Equatable {
  const BusInfoEvent();

  @override
  List<Object> get props => [];
}

class LoadBusInfo extends BusInfoEvent {
  final String studentID;

  const LoadBusInfo(this.studentID);

  @override
  List<Object> get props => [studentID];
}

class UpdateBusStatus extends BusInfoEvent {
  final String busID;
  final bool status;

  const UpdateBusStatus(this.busID, this.status);

  @override
  List<Object> get props => [busID, status];
}