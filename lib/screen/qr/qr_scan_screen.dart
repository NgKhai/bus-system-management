import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../bloc/scan/scan_bloc.dart';
import '../../bloc/scan/scan_event.dart';
import '../../bloc/scan/scan_state.dart';
import '../../util/Constant.dart';
import '../../util/qr_overlay.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );

  @override
  Widget build(BuildContext context) {
    final double scanArea = MediaQuery.of(context).size.width * 3 / 4;
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.sizeOf(context).center(Offset.zero),
      width: scanArea,
      height: scanArea,
    );

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            fit: BoxFit.fitHeight,
            controller: controller,
            scanWindow: scanWindow,
            errorBuilder: (context, error, child) {
              return ScannerErrorWidget(error: error);
            },
            onDetect: (capture) {
              final barcode = capture.barcodes.first;
              context
                  .read<ScannerBloc>()
                  .add(BarcodeScanned(barcode.displayValue ?? ''));
            },
          ),
          BlocConsumer<ScannerBloc, ScannerState>(
            listener: (context, state) {
              if (state is ScannerSuccess) {
                controller.stop(); // Stop the scanner

                // WidgetsBinding.instance.addPostFrameCallback((_) {
                //   context.go('/home');
                // });
                // context.pop();
                // context.go('/home/scan_success');
                context.go('/home/scan_success', extra: state.busData);

              } else if (state is ScannerError) {
                // Handle error if needed
                controller.stop(); // Stop the scanner
                context.go('/home/scan_error', extra: state.message);
              }
            },
            builder: (context, state) {
              if (state is ScannerLoading) {
                return Stack(children: [
                  Container(
                    decoration: ShapeDecoration(
                      shape: QrScannerOverlayShape(
                        borderColor: Constant.white,
                        borderRadius: 10,
                        borderLength: 25,
                        borderWidth: 8,
                        cutOutSize: scanArea,
                      ),
                    ),
                  ),
                  const Center(child: CircularProgressIndicator(color: Colors.white)),
                ]);
              }
              // else if (state is ScannerError) {
              //   return Center(child: Text(state.message, style: const TextStyle(color: Colors.white)));
              // }

              return Container(
                decoration: ShapeDecoration(
                  shape: QrScannerOverlayShape(
                    borderColor: Constant.white,
                    borderRadius: 10,
                    borderLength: 25,
                    borderWidth: 8,
                    cutOutSize: scanArea,
                  ),
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 40.0, horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      context.pop();
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_outlined,
                      color: Colors.white,
                    ),
                  ),
                  ToggleFlashlightButton(controller: controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class ToggleFlashlightButton extends StatelessWidget {
  const ToggleFlashlightButton({required this.controller, super.key});

  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, state, child) {
        if (!state.isInitialized || !state.isRunning) {
          return const SizedBox.shrink();
        }

        switch (state.torchState) {
          case TorchState.auto:
            return IconButton(
              color: Colors.white,
              iconSize: 32.0,
              icon: const Icon(Icons.flash_auto),
              onPressed: () async {
                await controller.toggleTorch();
              },
            );
          case TorchState.off:
            return IconButton(
              color: Colors.white,
              iconSize: 32.0,
              icon: const Icon(Icons.flash_off),
              onPressed: () async {
                await controller.toggleTorch();
              },
            );
          case TorchState.on:
            return IconButton(
              color: Colors.white,
              iconSize: 32.0,
              icon: const Icon(Icons.flash_on),
              onPressed: () async {
                await controller.toggleTorch();
              },
            );
          case TorchState.unavailable:
            return const Icon(
              Icons.no_flash,
              color: Colors.grey,
            );
        }
      },
    );
  }
}

class ScannerErrorWidget extends StatelessWidget {
  const ScannerErrorWidget({super.key, required this.error});

  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    String errorMessage;

    switch (error.errorCode) {
      case MobileScannerErrorCode.controllerUninitialized:
        errorMessage = 'Lỗi máy ảnh. Vui lòng thử lại';
      case MobileScannerErrorCode.permissionDenied:
        errorMessage = 'Quyền truy cập máy ảnh bị từ chối';
      case MobileScannerErrorCode.unsupported:
        errorMessage = 'Thiết bị không hỗ trợ quét mã QR';
      default:
        errorMessage = 'Lỗi máy ảnh. Vui lòng thử lại';
        break;
    }

    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Icon(Icons.error, color: Colors.white),
            ),
            Text(
              errorMessage,
              style:
                  GoogleFonts.getFont(Constant.fontName, color: Colors.white),
            ),
            Text(
              error.errorDetails?.message ?? '',
              style:
                  GoogleFonts.getFont(Constant.fontName, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
