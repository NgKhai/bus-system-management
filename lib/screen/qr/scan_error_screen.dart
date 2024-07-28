import 'package:bus_system_management/util/Constant.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../util/hex_color.dart';

class ScanErrorScreen extends StatelessWidget {
  final String message;

  const ScanErrorScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(
        color: Constant.nearlyDarkBlue,
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onPressed: () => context.pop(),
      ),
          backgroundColor: Constant.background),
      body: Container(
        decoration: const BoxDecoration(color: Constant.background),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Image.asset('assets/images/bus_error.png'),
              ),
              Column(
                children: [
                  Text(
                    "Có lỗi xảy ra",
                    style: GoogleFonts.getFont(
                      Constant.fontName,
                      fontSize: 24,
                      color: Constant.nearlyDarkBlue,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20,),
                  Text(
                    message,
                    style: GoogleFonts.getFont(
                      Constant.fontName,
                      fontSize: 16,
                      color: Constant.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Constant.nearlyDarkBlue,
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(colors: [
                    Constant.nearlyDarkBlue,
                    HexColor('#6A88E5'),
                  ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                  ),
                  child: Text('Quay về trang chủ', style: GoogleFonts.getFont(
                    Constant.fontName,
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),),
                ),
              ),
              const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
