import 'package:bus_system_management/util/Constant.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final AnimationController? animationController;
  final Animation<double>? animation;

  const InfoButtonWidget({Key? key, required this.text, required this.onTap, this.animationController, this.animation})
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
                Padding(
                  padding: const EdgeInsets.only(
                      left: 24, right: 24, top: 0, bottom: 0),
                  child: InkWell(
                    onTap: onTap,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 16),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Constant.white,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8.0),
                                  bottomLeft: Radius.circular(8.0),
                                  bottomRight: Radius.circular(8.0),
                                  topRight: Radius.circular(8.0)),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Constant.grey.withOpacity(0.4),
                                    offset: const Offset(1.1, 1.1),
                                    blurRadius: 10.0),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.topLeft,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 16,
                                    bottom: 16,
                                  ),
                                  child: Center(
                                    child: Text(
                                      text,
                                      textAlign: TextAlign.left,
                                      style: GoogleFonts.getFont(
                                        Constant.fontName,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        letterSpacing: 0.0,
                                        color:
                                        Constant.nearlyDarkBlue,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: -6,
                          left: 0,
                          child: SizedBox(
                            width: 80,
                            height: 80,
                            child: Image.asset("assets/images/bus_error.png"),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
