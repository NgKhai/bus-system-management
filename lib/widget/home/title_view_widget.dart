import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../util/Constant.dart';

class TitleViewWidget extends StatelessWidget {
  final String titleTxt;
  final AnimationController? animationController;
  final Animation<double>? animation;

  const TitleViewWidget(
      {Key? key,
      this.titleTxt = "",
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
              padding: const EdgeInsets.only(left: 24, right: 24),
              child: Text(
                titleTxt,
                textAlign: TextAlign.left,
                style: GoogleFonts.getFont(
                  Constant.fontName,
                  fontWeight: FontWeight.w500,
                  fontSize: 24,
                  letterSpacing: 0.5,
                  color: Constant.lightText,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
