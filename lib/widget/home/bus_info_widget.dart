import 'package:bus_system_management/util/Constant.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../bloc/bus_info/bus_info_bloc.dart';
import '../../bloc/bus_info/bus_info_event.dart';
import '../../bloc/bus_info/bus_info_state.dart';
import '../../model/bus_data.dart';

class BusDetailWidget extends StatefulWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;
  final String studentID;

  const BusDetailWidget({
    Key? key,
    this.animationController,
    this.animation,
    required this.studentID,
  }) : super(key: key);

  @override
  State<BusDetailWidget> createState() => _BusDetailWidgetState();
}

class _BusDetailWidgetState extends State<BusDetailWidget> {
  late BusInfoBloc _busDetailBloc;

  @override
  void initState() {
    super.initState();
    _busDetailBloc = BusInfoBloc();
    _busDetailBloc.add(LoadBusInfo(widget.studentID));
  }

  @override
  void dispose() {
    _busDetailBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BusInfoBloc, BusInfoState>(
      bloc: _busDetailBloc,
      builder: (context, state) {
        if (state is BusInfoLoading) {
          return _buildLoading();
        } else if (state is BusInfoLoaded) {
          return _buildBusInfo(state);
        } else if (state is BusInfoError) {
          return _buildError(state);
        }
        return Container();
      },
    );
  }

  Widget _buildLoading() {
    return AnimatedBuilder(
      animation: widget.animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - widget.animation!.value), 0.0),
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
                          const Icon(Icons.directions_bus,
                              color: Constant.darkerText),
                          const SizedBox(width: 8),
                          Text(
                            'Thông tin tuyến xe của bạn',
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
                    Center(
                      child: Column(
                        children: [
                          Lottie.asset(
                            'assets/images/logo.json',
                            width: 200,
                            height: 200,
                            fit: BoxFit.fill,
                          ),
                          Text(
                            'Đang tải dữ liệu...',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.getFont(
                              Constant.fontName,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Constant.grey,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildError(BusInfoError state) {
    return AnimatedBuilder(
      animation: widget.animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - widget.animation!.value), 0.0),
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
                          const Icon(Icons.directions_bus,
                              color: Constant.darkerText),
                          const SizedBox(width: 8),
                          Text(
                            'Thông tin tuyến xe của bạn',
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
                    SizedBox(
                      height: 200,
                      child: Center(
                        child: Text(
                          state.error,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.getFont(
                            Constant.fontName,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Constant.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBusInfo(BusInfoLoaded state) {
    return AnimatedBuilder(
      animation: widget.animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - widget.animation!.value), 0.0),
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
                          const Icon(Icons.directions_bus,
                              color: Constant.darkerText),
                          const SizedBox(width: 8),
                          Text(
                            'Thông tin tuyến xe của bạn',
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
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: state.busListData.length,
                      itemBuilder: (BuildContext context, int index) {
                        return _busItem(
                            state.busListData[index], state.busStatus[index]);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _busItem(BusData busData, bool isRunning) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
          child: Container(
            height: 2,
            decoration: const BoxDecoration(
              color: Constant.background,
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                busData.busName,
                textAlign: TextAlign.start,
                style: GoogleFonts.getFont(
                  Constant.fontName,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Constant.darkText,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Biển số xe',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.getFont(
                          Constant.fontName,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Constant.grey.withOpacity(0.5),
                        ),
                      ),
                      Text(
                        busData.busLicense,
                        textAlign: TextAlign.start,
                        style: GoogleFonts.getFont(
                          Constant.fontName,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Constant.darkText,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Trạng thái',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.getFont(
                          Constant.fontName,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Constant.grey.withOpacity(0.5),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: (isRunning) ? Colors.green : Colors.grey,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (isRunning)
                                      ? Colors.green.withOpacity(0.6)
                                      : Colors.grey.withOpacity(0.6),
                                  spreadRadius: 3,
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isRunning ? 'Đang chạy' : 'Ngoài giờ hoạt động',
                            textAlign: TextAlign.start,
                            style: GoogleFonts.getFont(
                              Constant.fontName,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Constant.darkText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    height: 100,
                    width: 2, // Added width to make it vertical
                    decoration: const BoxDecoration(
                      color: Constant.background,
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CachedNetworkImage(
                      imageUrl: busData.busImage,
                      placeholder: (context, url) =>
                          Image.asset("assets/images/bus.png"),
                      errorWidget: (context, url, error) =>
                          Image.asset("assets/images/bus.png"),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        if(isRunning)
          GestureDetector(
            onTap: () => context.go('/home/tracking', extra: busData),
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Constant.purpleHuflit,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      "Theo dõi",
                      textAlign: TextAlign.start,
                      style: GoogleFonts.getFont(
                        Constant.fontName,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
      ],
    );
  }
}
