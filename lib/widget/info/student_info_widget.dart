import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../util/Constant.dart';

class StudentInfoWidget extends StatelessWidget {
  final String? username;
  final String? usermail;
  final AnimationController? animationController;
  final Animation<double>? animation;

  const StudentInfoWidget(
      {Key? key,
      this.username,
      this.usermail,
      this.animationController,
      this.animation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - animation!.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 16, bottom: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: Constant.white,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      bottomLeft: Radius.circular(8.0),
                      bottomRight: Radius.circular(8.0),
                      topRight: Radius.circular(68.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Constant.grey.withOpacity(0.2),
                        offset: const Offset(1.1, 1.1),
                        blurRadius: 10.0),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 16, left: 24, right: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.person, color: Constant.darkerText),
                          const SizedBox(width: 8),
                          Text(
                            'Thông tin sinh viên',
                            textAlign: TextAlign.start,
                            style: GoogleFonts.getFont(
                              Constant.fontName,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Constant.darkText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, top: 24, bottom: 8),
                      child: Container(
                        height: 2,
                        decoration: const BoxDecoration(
                          color: Constant.background,
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                      const EdgeInsets.only(
                          left: 24, right: 24, bottom: 18),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Họ và tên: $username",
                            style: GoogleFonts.getFont(
                              Constant.fontName,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Constant.darkText,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Email: $usermail",
                            style: GoogleFonts.getFont(
                              Constant.fontName,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Constant.darkText,
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
