import 'package:equatable/equatable.dart';

abstract class ScannerEvent extends Equatable {
  const ScannerEvent();

  @override
  List<Object?> get props => [];
}

class BarcodeScanned extends ScannerEvent {
  final String busID;

  const BarcodeScanned(this.busID);

  @override
  List<Object?> get props => [busID];
}