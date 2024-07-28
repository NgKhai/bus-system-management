import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../util/Constant.dart';

class TopInfoWidget extends StatelessWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;

  const TopInfoWidget(
      {Key? key,
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
            child: Column(
              children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 150,
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.fitWidth,
                        ),
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
              ],
            ),
          ),
        );
      },
    );
  }
}
