import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../util/Constant.dart';

class TopViewWidget extends StatelessWidget {
  final String? titleTxt;
  final AnimationController? animationController;
  final Animation<double>? animation;

  const TopViewWidget(
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
              padding: const EdgeInsets.only(left: 24, right: 24, top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Xin chào, ",
                        style: GoogleFonts.getFont(
                          'Montserrat',
                          fontSize: 20,
                          color: Constant.orangeHuflit,
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Flexible(
                        child: Text(
                          titleTxt!,
                          style: GoogleFonts.getFont(
                            'Montserrat',
                            fontSize: 20,
                            color: Constant.purpleHuflit,
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "Chào mừng bạn đến với HUFLIT BUS",
                    style: GoogleFonts.getFont(
                      Constant.fontName,
                      fontSize: 16,
                      color: Constant.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
