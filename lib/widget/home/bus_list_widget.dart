import 'package:bus_system_management/util/Constant.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../model/bus_data.dart';
import '../../util/hex_color.dart';


class BusListWidget extends StatefulWidget {
  const BusListWidget(
      {Key? key, this.mainScreenAnimationController, this.mainScreenAnimation})
      : super(key: key);

  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;

  @override
  _BusListWidgetState createState() => _BusListWidgetState();
}

class _BusListWidgetState extends State<BusListWidget>
    with TickerProviderStateMixin {
  AnimationController? animationController;
  late List<BusData> busListData = [];

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    getData();

    super.initState();
  }

  Future<bool> getData() async {
    // await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    // return true;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Bus')
        .get();
    setState(() {
      busListData = querySnapshot.docs.map((doc) => BusData.fromFirestore(doc)).toList();
    });

    return true;
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.mainScreenAnimationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.mainScreenAnimation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - widget.mainScreenAnimation!.value), 0.0),
            child: Container(
              height: 216,
              width: double.infinity,
              child: ListView.builder(
                padding: const EdgeInsets.only(
                    top: 0, bottom: 0, right: 16, left: 16),
                itemCount: busListData.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  final int count =
                      busListData.length > 10 ? 10 : busListData.length;
                  final Animation<double> animation =
                      Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                              parent: animationController!,
                              curve: Interval((1 / count) * index, 1.0,
                                  curve: Curves.fastOutSlowIn)));
                  animationController?.forward();

                  return BusView(
                    busData: busListData[index],
                    animation: animation,
                    animationController: animationController!,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class BusView extends StatelessWidget {
  const BusView(
      {Key? key, this.busData, this.animationController, this.animation})
      : super(key: key);

  final BusData? busData;
  final AnimationController? animationController;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/home/route', extra: busData),
      child: AnimatedBuilder(
        animation: animationController!,
        builder: (BuildContext context, Widget? child) {
          return FadeTransition(
            opacity: animation!,
            child: Transform(
              transform: Matrix4.translationValues(
                  100 * (1.0 - animation!.value), 0.0, 0.0),
              child: SizedBox(
                width: 200,
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 32, left: 8, right: 8, bottom: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: HexColor(busData!.busEndColor)
                                    .withOpacity(0.6),
                                offset: const Offset(1.1, 4.0),
                                blurRadius: 8.0),
                          ],
                          gradient: LinearGradient(
                            colors: <HexColor>[
                              HexColor(busData!.busStartColor),
                              HexColor(busData!.busEndColor),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(8.0),
                            bottomLeft: Radius.circular(8.0),
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(54.0),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 54, left: 16, right: 16, bottom: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                busData!.busName,
                                textAlign: TextAlign.start,
                                style: GoogleFonts.getFont(
                                  Constant.fontName,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 0.2,
                                  color: Constant.white,
                                ),
                              ),
                              // Row(
                              //   children: [
                              //     Container(
                              //       width: 8,
                              //       height: 8,
                              //       decoration: BoxDecoration(
                              //         color: (busListData!.status != "Không hoạt động")
                              //             ? Colors.green
                              //             : Colors.grey,
                              //         shape: BoxShape.circle,
                              //         boxShadow: [
                              //           BoxShadow(
                              //             color: (busListData!.status != "Không hoạt động")
                              //                 ? Colors.green.withOpacity(0.6)
                              //                 : Colors.grey.withOpacity(0.6),
                              //             spreadRadius: 3,
                              //             blurRadius: 5,
                              //           ),
                              //         ],
                              //       ),
                              //     ),
                              //     Padding(
                              //       padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8),
                              //       child: Text(
                              //         busListData!.status,
                              //         style: GoogleFonts.getFont(
                              //           Constant.fontName,
                              //           fontWeight: FontWeight.w500,
                              //           fontSize: 14,
                              //           letterSpacing: 0.2,
                              //           color: Constant.white,
                              //         ),
                              //       ),
                              //     ),
                              //   ],
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: Constant.nearlyWhite.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 8,
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: CachedNetworkImage(
                          imageUrl: busData!.busImage,
                          placeholder: (context, url) => Image.asset("assets/images/bus.png"),
                          errorWidget: (context, url, error) => Image.asset("assets/images/bus.png"),
                        ),
                      ),
                    ),
                    // Add the dot indicator
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
