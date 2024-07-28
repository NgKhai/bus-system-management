import 'package:bus_system_management/bloc/scan/scan_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../screen/qr/qr_scan_screen.dart';

class ScanProvider extends StatelessWidget {
  const ScanProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScannerBloc(),
      child: ScanScreen(),
    );
  }
}