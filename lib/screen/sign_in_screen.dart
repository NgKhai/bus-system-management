import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../util/Constant.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Container(
      color: Constant.background,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
        child: Column(
          children: [
            Image.asset(
              'assets/images/logo.png',
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "HUFLIT ",
                  style: GoogleFonts.getFont(
                    'Montserrat',
                    fontSize: 40,
                    color: Constant.orangeHuflit,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  "BUS",
                  style: GoogleFonts.getFont(
                    'Montserrat',
                    fontSize: 40,
                    color: Constant.purpleHuflit,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            Text(
              "Phần mềm theo dõi xe buýt tại trường Đại học Ngoại Ngữ - Tin Học TPHCM",
              style: GoogleFonts.getFont(
                Constant.fontName,
                fontSize: 16,
                color: Constant.purpleHuflit,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            _buildSignInButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.read<AuthBloc>().add(SignInRequested());
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        side: const BorderSide(color: Colors.grey, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/microsoft_logo.png',
            width: 36,
            height: 36,
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.05),
          Text(
            'Đăng nhập bằng Microsoft',
            style: GoogleFonts.getFont(
              'Roboto',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}