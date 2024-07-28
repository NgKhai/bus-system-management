import 'dart:async';

import 'package:bus_system_management/model/bus_data.dart';
import 'package:bus_system_management/model/route_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lottie/lottie.dart' as lottie;

import '../util/Constant.dart';

import 'package:xml/xml.dart' as xml;

import '../util/id_student.dart';

class TrackingScreen extends StatefulWidget {
  final BusData busData;

  const TrackingScreen({super.key, required this.busData});

  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  late final DatabaseReference _databaseReference;
  final user = FirebaseAuth.instance.currentUser;

  String? gpx;
  List<LatLng> defaultRoute = [const LatLng(10.86506148321573, 106.60054066532967)];
  List<LatLng> positions = [];
  Marker? markersDrop;

  late RoutesData routesData;
  List<Marker> markers = [];
  num speed = 0;
  num distance = 0;

  bool isLoading = true;
  bool isTracking = true;
  bool isForwardTime = false;
  bool isAttendance = false;

  final MapController _mapController = MapController();
  final _debouncer =
      Debouncer(Duration(milliseconds: 200)); // Adjusted debounce duration

  @override
  void initState() {
    super.initState();
    fetchData();
    _setupDatabaseListener();
  }

  Future<void> fetchData() async {

    gpx = _getGpx();

    await getRealtimeDatabase();

    defaultRoute = await parseGpx('assets/routes/$gpx.gpx');

    positions = routesData.positions;

    await _fetchMarkerDrop(routesData);

    isLoading = false;
    setState(() {});
  }

  Future<void> getRealtimeDatabase() async {
    _databaseReference =
        FirebaseDatabase.instance.ref().child(widget.busData.busID);
    DataSnapshot snapshot = await _databaseReference.get();
    if (snapshot.exists) {
      final dataMap = snapshot.value as Map<dynamic, dynamic>;
      String uniqueKey = dataMap.keys.first;
      final data = dataMap[uniqueKey];
      routesData = RoutesData.fromRealtime(data);
    } else {
      if(mounted) {
        context.pop();
      }
    }
  }

  Future<void> _fetchMarkerDrop(RoutesData routesData) async {
    final String studentID = IDStudent(user!.email).getID();

    for (final _studentDetail in routesData.studentDetail) {
      if (_studentDetail.studentID == studentID) {
        markersDrop =
          Marker(
            width: 100,
            height: 100,
            point: LatLng(_studentDetail.dropLatitude.toDouble(),
                _studentDetail.dropLongitude.toDouble()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Constant.orangeHuflit,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _studentDetail.studentID,
                    style: GoogleFonts.getFont(
                      'Montserrat',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Icon(
                  Icons.place,
                  color: Constant.purpleHuflit,
                  size: 40,
                ),
              ],
            ),
        );

        isAttendance = true;

        break;
      }
    }
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

  Future<void> updateStudentDropInfo() async {
    if (user == null) {
      return;
    }

    final String studentID = IDStudent(user!.email).getID();
    LatLng currentPosition = positions.isNotEmpty ? positions.last : LatLng(0, 0);
    String currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
    int key = -1;

    StudentDetail? studentDetail;

    for(int i = 0; i < routesData.studentDetail.length; i++) {
      if(routesData.studentDetail[i].studentID == studentID) {
        studentDetail = routesData.studentDetail[i];
        key = i;
        break;
      }
    }

    if (studentDetail != null) {
      studentDetail.dropLatitude = currentPosition.latitude;
      studentDetail.dropLongitude = currentPosition.longitude;
      studentDetail.dropTime = currentTime;

      final snapshot = await _databaseReference.get();

      String uniqueKey = '';

      if(snapshot.exists) {
        final dataMap = snapshot.value as Map<dynamic, dynamic>;
        uniqueKey = dataMap.keys.first;

        final studentRef = _databaseReference.child(uniqueKey).child('StudentDetail').child(key.toString());

        final snapshot2 = await studentRef.get();

        if(snapshot2.exists) {

          Map<String, dynamic> updatedData = studentDetail.toJson();

          await studentRef.update(updatedData);
        }
      }

      setState(() {
        markersDrop = Marker(
          width: 100,
          height: 100,
          point: LatLng(studentDetail!.dropLatitude.toDouble(),
              studentDetail.dropLongitude.toDouble()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Constant.orangeHuflit,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  studentDetail.studentID,
                  style: GoogleFonts.getFont(
                    'Montserrat',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Icon(
                Icons.place,
                color: Constant.purpleHuflit,
                size: 40,
              ),
            ],
          ),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Drop info saved successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Student detail not found!')),
      );
    }
  }


  @override
  void dispose() {
    // TODO: implement dispose
    _debouncer.cancel();

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
        title: Text(
          'Theo dõi lộ trình tuyến xe',
          style: GoogleFonts.getFont(
            Constant.fontName,
            color: Constant.darkText,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Constant.background,
      ),
      body: isLoading ? _buildLoading() : Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              onPositionChanged: (MapPosition position, bool hasGesture) {
                if (hasGesture && isTracking) {
                  isTracking = false;
                }
              },
              initialCenter: LatLng(10.776183323564736, 106.66732187988492),
              initialZoom: 16,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              if (positions.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: defaultRoute, // Use defaultRoute here
                      color: Colors.blue,
                      strokeWidth: 6,
                    ),
                    Polyline(
                      points: positions,
                      color: Constant.orangeHuflit,
                      strokeWidth: 8,
                    ),
                  ],
                ),
              if (positions.isNotEmpty)
                MarkerLayer(
                  rotate: true,
                  markers: [
                    Marker(
                        point: positions.last,
                        child: const CircleAvatar(
                          radius: 25.0,
                          backgroundColor: Constant.orangeHuflit,
                          child: Icon(
                            Icons.circle,
                            size: 20.0,
                            color: Colors.white,
                          ),
                        )
                    ),
                  ],
                ),
              if (markersDrop != null)
                MarkerLayer(
                  rotate: true,
                  markers: [
                    markersDrop!,
                  ],
                ),
              MarkerLayer(
                  rotate: true,
                  alignment: const Alignment(0.0, -0.25),
                  markers: [
                    Marker(
                      point: defaultRoute.first,
                      child: const Icon(
                        Icons.directions_bus,
                        color: Constant.purpleHuflit,
                        size: 40,
                      ),
                    ),
                    Marker(
                      point: defaultRoute.last,
                      child: const Icon(
                        CupertinoIcons.map_pin_ellipse,
                        color: Constant.purpleHuflit,
                        size: 40,
                      ),
                    )
                  ]),
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
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(
                          radius: 12.0,
                          backgroundColor: Constant.orangeHuflit,
                          child: Icon(
                            Icons.circle,
                            size: 12.0,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          ' Vị trí xe buýt',
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
                      isTracking = true;
                      _mapController.move(positions.last, 16);
                    },
                    child: const Icon(
                      Icons.my_location,
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
                                const SizedBox(height: 5),
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
                                const SizedBox(height: 5),
                                Text(
                                  'Giờ khởi hành',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.getFont(
                                    Constant.fontName,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Constant.grey.withOpacity(0.5),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  routesData.busTime,
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Vận tốc',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.getFont(
                                    Constant.fontName,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Constant.grey.withOpacity(0.5),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "${speed.toStringAsFixed(0)} km/h",
                                  textAlign: TextAlign.start,
                                  style: GoogleFonts.getFont(
                                    Constant.fontName,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Constant.darkText,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Quãng đường',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.getFont(
                                    Constant.fontName,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Constant.grey.withOpacity(0.5),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  distance < 1
                                      ? "${(distance * 1000).toStringAsFixed(0)} m"
                                      : "${distance.toStringAsFixed(2)} km",
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ngày chạy',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.getFont(
                                    Constant.fontName,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Constant.grey.withOpacity(0.5),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  routesData.currentDate,
                                  textAlign: TextAlign.start,
                                  style: GoogleFonts.getFont(
                                    Constant.fontName,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Constant.darkText,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Giờ xuất phát',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.getFont(
                                    Constant.fontName,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Constant.grey.withOpacity(0.5),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  routesData.startTime,
                                  textAlign: TextAlign.start,
                                  style: GoogleFonts.getFont(
                                    Constant.fontName,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Constant.darkText,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 5),
                        if(isAttendance)
                          Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Constant.purpleHuflit,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                updateStudentDropInfo();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: Text(
                                'Điểm danh',
                                style: GoogleFonts.getFont(
                                  Constant.fontName,
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
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
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      color: Constant.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            lottie.Lottie.asset(
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
    );
  }

  void _setupDatabaseListener() {

    _databaseReference.onChildChanged.listen((event) {
      _handleDatabaseUpdate(event);
    }).onError((error) {
      if (mounted) {
        context.pop(); // Go back if there is an error
      }
    });

    _databaseReference.onChildRemoved.listen((event) {
      if (mounted) {
        context.pop(); // Go back if the data is removed
      }
    });
  }

  void _handleDatabaseUpdate(DatabaseEvent event) {
    final routeData = event.snapshot.value as Map<dynamic, dynamic>?;
    if (routeData != null) {
      final speed = routeData['Speed'];
      final distance = routeData['Distance'];
      List<dynamic> positionsData = routeData['Positions'] as List<dynamic>;

      if (positionsData.isNotEmpty) {
        var lastPositionData = positionsData.last;
        LatLng lastPosition =
            LatLng(lastPositionData['Latitude'], lastPositionData['Longitude']);

        _debouncer.run(() {
          if (mounted) {
            setState(() {
              positions.add(lastPosition);
              this.speed = speed;
              this.distance = distance;
            });
            if(isTracking) {
              _moveCameraToLastPosition();
            }
          }
        });

      }
    }
  }

  void _moveCameraToLastPosition() {
    if (positions.isNotEmpty) {
      _mapController.move(positions.last, _mapController.camera.zoom);
    }
  }
}

class Debouncer {
  final Duration delay;
  void Function()? action;
  Timer? _timer;

  Debouncer(this.delay);

  run(void Function() action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(delay, action);
  }

  void cancel() {
    if (_timer != null) {
      _timer!.cancel();
    }
  }
}
