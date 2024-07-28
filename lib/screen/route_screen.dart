import 'package:bus_system_management/model/bus_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import 'package:xml/xml.dart' as xml;

import '../util/Constant.dart';

class RouteScreen extends StatefulWidget {
  final BusData busData;

  const RouteScreen({super.key, required this.busData});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  final _mapController = MapController();
  Stream<List<LatLng>>? _routeStream;
  bool isForwardTime = true;
  LatLng firstPosition = const LatLng(10.866926439504674, 106.60419919843947);
  LatLng lastPosition = const LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    _routeStream = fetchData();
  }

  Stream<List<LatLng>> fetchData() async* {
    final gpx = _getGpx();
    final defaultRoute = await parseGpx('assets/routes/$gpx.gpx');

    firstPosition = defaultRoute.first;
    lastPosition = defaultRoute.last;

    yield defaultRoute;
  }

  String _getGpx() {
    final Map<String, String> forwardRoutes = {
      'BusLTR1': 'ltr-hm',
      'BusLTR2': 'ltr-hm',
      'BusPT1': 'pt-hm',
      'BusPT2': 'pt-hm',
      'BusGD1': 'gd-hm',
      'BusGD2': 'gd-hm',
      'BusVT1': 'vt-hm'
    };

    final Map<String, String> backwardRoutes = {
      'BusLTR1': 'hm-ltr',
      'BusLTR2': 'hm-ltr',
      'BusPT1': 'hm-pt',
      'BusPT2': 'hm-pt',
      'BusGD1': 'hm-gd',
      'BusGD2': 'hm-gd',
      'BusVT1': 'hm-vt'
    };

    return isForwardTime
        ? forwardRoutes[widget.busData.busID] ?? ''
        : backwardRoutes[widget.busData.busID] ?? '';
  }

  Future<List<LatLng>> parseGpx(String assetPath) async {
    final gpxString = await rootBundle.loadString(assetPath);
    final gpxXml = xml.XmlDocument.parse(gpxString);
    final coordinates = <LatLng>[];

    for (var element in gpxXml.findAllElements('trkpt')) {
      final lat = double.parse(element.getAttribute('lat')!);
      final lon = double.parse(element.getAttribute('lon')!);
      coordinates.add(LatLng(lat, lon));
    }

    return coordinates;
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          color: Constant.nearlyDarkBlue,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onPressed: () => context.pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Constant.purpleHuflit,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isForwardTime ? "Lượt đi" : "Lượt về",
                textAlign: TextAlign.center,
                style: GoogleFonts.getFont(
                  'Montserrat',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                isForwardTime = !isForwardTime;
                _routeStream = fetchData();
              });
            },
            child: const Icon(
              CupertinoIcons.arrow_2_circlepath,
              color: Constant.purpleHuflit,
              size: 36,
            ),
          ),
          const SizedBox(width: 20),
        ],
        backgroundColor: Constant.background,
      ),
      body: Stack(
        children: [
          StreamBuilder<List<LatLng>>(
            stream: _routeStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Constant.orangeHuflit));
              } else if (snapshot.hasError) {
                return Center(child: Text(
                  'Có lỗi xảy ra, vui lòng thử lại',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.getFont(
                    Constant.fontName,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Constant.grey.withOpacity(0.5),
                  ),
                ),);
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text(
                  "Có lỗi xảy ra, vui lòng thử lại",
                  textAlign: TextAlign.start,
                  style: GoogleFonts.getFont(
                    Constant.fontName,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Constant.darkText,
                  ),
                ),
                );
              }

              final routeData = snapshot.data!;
              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: firstPosition,
                  initialZoom: 16,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routeData,
                        color: Colors.blue,
                        strokeWidth: 6,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    rotate: true,
                    alignment: const Alignment(0.0, -0.25),
                    markers: [
                      Marker(
                        point: firstPosition,
                        child: const Icon(
                          Icons.directions_bus,
                          color: Constant.purpleHuflit,
                          size: 40,
                        ),
                      ),
                      Marker(
                        point: lastPosition,
                        child: const Icon(
                          CupertinoIcons.map_pin_ellipse,
                          color: Constant.purpleHuflit,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Constant.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.directions_bus,
                                  color: Constant.purpleHuflit,
                                ),
                                Text(
                                  " Trạm đầu",
                                  style: GoogleFonts.getFont(
                                    decoration: TextDecoration.none,
                                    Constant.fontName,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: Constant.darkText,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  CupertinoIcons.map_pin_ellipse,
                                  color: Constant.purpleHuflit,
                                ),
                                Text(
                                  ' Trạm cuối',
                                  style: GoogleFonts.getFont(
                                    decoration: TextDecoration.none,
                                    Constant.fontName,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: Constant.darkText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: FloatingActionButton(
                            heroTag: UniqueKey(),
                            backgroundColor: Constant.purpleHuflit,
                            onPressed: () {

                              _mapController.move(firstPosition, 16);
                            },
                            child: const Icon(
                              Icons.directions_bus,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: FloatingActionButton(
                            heroTag: UniqueKey(),
                            backgroundColor: Constant.purpleHuflit,
                            onPressed: () {

                              _mapController.move(lastPosition, 16);
                            },
                            child: const Icon(
                              CupertinoIcons.map_pin_ellipse,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: const BoxDecoration(
                            color: Constant.background,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 5),
                                Text(
                                  widget.busData.busName,
                                  textAlign: TextAlign.start,
                                  style: GoogleFonts.getFont(
                                    Constant.fontName,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Constant.darkerText,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Text(
                                      'Biển số xe: ',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.getFont(
                                        Constant.fontName,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        color: Constant.grey.withOpacity(0.5),
                                      ),
                                    ),
                                    Text(
                                      widget.busData.busLicense,
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
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Text(
                                      'Giờ đi: ',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.getFont(
                                        Constant.fontName,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        color: Constant.grey.withOpacity(0.5),
                                      ),
                                    ),
                                    Text(
                                      "${widget.busData.busForwardTime.toList()}",
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
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Text(
                                      'Giờ về: ',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.getFont(
                                        Constant.fontName,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        color: Constant.grey.withOpacity(0.5),
                                      ),
                                    ),
                                    Text(
                                      "${widget.busData.busBackwardTime.toList()}",
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
                                const SizedBox(height: 5),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
