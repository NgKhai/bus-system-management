import 'package:bus_system_management/model/bus_data.dart';
import 'package:equatable/equatable.dart';

abstract class ScannerState extends Equatable {
  const ScannerState();

  @override
  List<Object?> get props => [];
}

class ScannerInitial extends ScannerState {}

class ScannerLoading extends ScannerState {}

class ScannerSuccess extends ScannerState {
  final BusData busData;

  const ScannerSuccess(this.busData);

  @override
  // TODO: implement props
  List<Object?> get props => [busData];
}

class ScannerError extends ScannerState {
  final String message;

  const ScannerError(this.message);

  @override
  List<Object?> get props => [message];
}