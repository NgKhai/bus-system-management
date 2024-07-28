import 'package:bus_system_management/util/id_student.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../model/attendance_data.dart';
import '../../model/bus_data.dart';
import '../../util/Constant.dart';
import '../../util/hex_color.dart';

import 'package:xml/xml.dart' as xml;

class ScanSuccessScreen extends StatefulWidget {
  final BusData busData;

  const ScanSuccessScreen({super.key, required this.busData});

  @override
  State<ScanSuccessScreen> createState() => _ScanSuccessScreenState();
}

class _ScanSuccessScreenState extends State<ScanSuccessScreen> {
  final attendanceCollection =
      FirebaseFirestore.instance.collection('Attendances');
  final user = FirebaseAuth.instance.currentUser;

  int distanceTime = 10; // Giờ giãn cách
  String busTime = '12:10:00';
  bool isForwardTime = true;
  bool isChecked = false;
  String address = 'Trạm cuối';

  late AttendanceData attendanceData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchData();
  }

  Future<void> fetchData() async {
    getAttendance();

    isForwardTime = checkTime();

    gpx = _getGpx();

    defaultRoute = await parseGpx('assets/routes/$gpx.gpx');

    setState(() {

      dropMarker = Marker(
        point: defaultRoute.last, child: const Icon(
        Icons.place,
        color: Constant.orangeHuflit,
        size: 40,
        ),
      );

      dropLatLng = defaultRoute.last;
    });
  }

  bool checkTime() {

    List<String> busForwardTime = widget.busData.busForwardTime;
    List<String> busBackwardTime = widget.busData.busBackwardTime;

    // TimeOfDay currentTimeOfDay = TimeOfDay.now();
    TimeOfDay currentTimeOfDay = const TimeOfDay(hour: 11, minute: 10);
    final currentMinutes = currentTimeOfDay.hour * 60 + currentTimeOfDay.minute;

    for(int i = 0 ; i < busForwardTime.length; i++) {
      TimeOfDay busTimeOfDay = _parseTimeOfDay(busForwardTime[i]);
      final busMinutes = busTimeOfDay.hour * 60 + busTimeOfDay.minute;
        if(currentMinutes >= busMinutes - distanceTime && currentMinutes <= busMinutes + distanceTime) {
          busTime = busForwardTime[i];
          return true;
        }
    }

    for(int i = 0 ; i < busBackwardTime.length; i++) {
      TimeOfDay busTimeOfDay = _parseTimeOfDay(busBackwardTime[i]);
      final busMinutes = busTimeOfDay.hour * 60 + busTimeOfDay.minute;
        if(currentMinutes >= busMinutes - distanceTime && currentMinutes <= busMinutes + distanceTime) {
          busTime = busBackwardTime[i];
          return false;
        }
      }

    return true;
  }

  TimeOfDay _parseTimeOfDay(String time) {
    final format = DateFormat.Hms();
    final dateTime = format.parse(time);
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  getAttendance() {
    attendanceData = AttendanceData(
      busID: widget.busData.busID,
      busTime: busTime,
    );
  }

  saveAttandance() async {
    DocumentReference newDocRef = attendanceCollection.doc();
    final String studentID = IDStudent(user!.email).getID();

    attendanceData = AttendanceData(
      attendanceID: newDocRef.id,
      studentID: studentID,
      busID: widget.busData.busID,
      currentDate: getDate(DateTime.now()),
      currentTime: getTime(DateTime.now()),
      busTime: busTime,
      dropLatitude: dropLatLng.latitude,
      dropLongitude: dropLatLng.longitude,
    );

    await newDocRef.set(attendanceData.toJson());
  }

  String getDate(DateTime selectedDate) {
    return DateFormat('dd/MM/yyyy').format(selectedDate);
  }

  String getTime(DateTime selectedDate) {
    return DateFormat('HH:mm:ss').format(selectedDate);
  }

  final MapController _mapController = MapController();
  late Marker dropMarker;

  LatLng dropLatLng = const LatLng(0, 0);

  String? gpx;
  List<LatLng> defaultRoute = [];

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

  Future<String> getPlacemarks(double lat, double long) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;

        String address = [
          placemark.street,
          placemark.subLocality,
          placemark.locality,
          placemark.subAdministrativeArea,
          placemark.administrativeArea,
        ].where((element) => element != null && element.isNotEmpty).join(', ');

        return address;
      } else {
        return "Không tìm thấy địa chỉ";
      }
    } catch (e) {
      print("Error getting placemarks: $e");
      return "Không tìm thấy địa chỉ";
    }
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
          backgroundColor: Constant.background),
      body: Container(
        decoration: const BoxDecoration(color: Constant.background),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color:
                          HexColor(widget.busData.busEndColor).withOpacity(0.6),
                      offset: const Offset(1.1, 4.0),
                      blurRadius: 8.0,
                    ),
                  ],
                  gradient: LinearGradient(
                    colors: <HexColor>[
                      HexColor(widget.busData.busStartColor),
                      HexColor(widget.busData.busEndColor),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60.0),
                  child: CachedNetworkImage(
                    imageUrl: widget.busData.busImage,
                    placeholder: (context, url) =>
                        Image.asset("assets/images/bus.png"),
                    errorWidget: (context, url, error) =>
                        Image.asset("assets/images/bus.png"),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Thông tin sinh viên",
                    style: GoogleFonts.getFont(
                      Constant.fontName,
                      fontSize: 24,
                      color: Constant.nearlyDarkBlue,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "\u2022 Họ và tên: ${user!.displayName ?? ""}",
                        style: GoogleFonts.getFont(
                          Constant.fontName,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Constant.darkText,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "\u2022 MSSV: ${IDStudent(user!.email).getID()}",
                        style: GoogleFonts.getFont(
                          Constant.fontName,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Constant.darkText,
                        ),
                      ),

                      //
                      const SizedBox(height: 10),
                      //

                      Text(
                        "Thông tin tuyến xe",
                        style: GoogleFonts.getFont(
                          Constant.fontName,
                          fontSize: 24,
                          color: Constant.nearlyDarkBlue,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "\u2022 ${widget.busData.busName}",
                            style: GoogleFonts.getFont(
                              Constant.fontName,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Constant.darkText,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "\u2022 Biển số xe: ${widget.busData.busLicense}",
                            style: GoogleFonts.getFont(
                              Constant.fontName,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Constant.darkText,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "\u2022 Thời gian khởi hành: $busTime ${isForwardTime ? "(Lượt đi)" : "(Lượt về)"}",
                            style: GoogleFonts.getFont(
                              Constant.fontName,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: Constant.darkText,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "\u2022 Điểm dừng: $address",
                            style: GoogleFonts.getFont(
                              Constant.fontName,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: Constant.darkText,
                            ),
                          ),
                          const SizedBox(height: 5),
                          GestureDetector(
                            onTap: () => _dialogBuilder(context, (LatLng location, bool checked, String addr) {
                              setState(() {
                                dropLatLng = location;
                                isChecked = checked;
                                address = addr;
                              });
                            }),
                            child: Text(
                              "Thay đổi điểm dừng", // Nhớ fix lượt đi
                              style: GoogleFonts.getFont(
                                Constant.fontName,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Constant.blueHuflit,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Constant.nearlyDarkBlue,
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(colors: [
                    Constant.nearlyDarkBlue,
                    HexColor('#6A88E5'),
                  ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    saveAttandance();
                    context.pop();
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
              const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }





  Future<void> _dialogBuilder(BuildContext context, Function(LatLng, bool, String) onLocationSelected) {

    var tempDropLatLng = dropLatLng;
    var tempDropMarker = dropMarker;
    String tempAddress = address;

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    onTap: (tapPos, LatLng latLng) async {

                      tempAddress = await getPlacemarks(latLng.latitude, latLng.longitude);

                      setState(() {

                        isChecked = true;
                        tempDropLatLng = latLng;
                        tempDropMarker =
                            Marker(
                              alignment: const Alignment(0, -1.25),
                              point: latLng,
                              child:const Icon(
                                Icons.place,
                                color: Constant.orangeHuflit,
                                size: 40,
                              ),
                            );
                      });
                    },
                    initialCenter: dropLatLng,
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
                              points: defaultRoute, // Use defaultRoute here
                              color: Colors.blue,
                              strokeWidth: 6,
                            ),
                          ],
                        ),
                    MarkerLayer(
                        rotate: true,
                        alignment: const Alignment(0.0, -0.25),
                        markers:
                        [
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
                          ),
                          tempDropMarker,
                        ]),
                  ],
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 40.0, horizontal: 10.0),
                    child: GestureDetector(
                      onTap: () {
                        isChecked = false;
                        context.pop();
                      },
                      child: const CircleAvatar(
                        radius: 25.0,
                        backgroundColor: Constant.purpleHuflit,
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20.0,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Constant.orangeHuflit,
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
                                  color: Constant.white,
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
                                  color: Constant.white,
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
                                Icons.place,
                                color: Constant.purpleHuflit,
                              ),
                              Text(
                                ' Điểm dừng',
                                style: GoogleFonts.getFont(
                                  decoration: TextDecoration.none,
                                  Constant.fontName,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: Constant.white,
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
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 80.0, horizontal: 10.0),
                    child: FloatingActionButton(
                      backgroundColor: Constant.purpleHuflit,
                      onPressed: () {

                        _mapController.move(tempDropLatLng, 16);
                      },
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                      onTap: () {
                        onLocationSelected(tempDropLatLng, true, tempAddress);
                        dropMarker = tempDropMarker;

                        context.pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Constant.orangeHuflit,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            tempAddress,
                            style: GoogleFonts.getFont(
                              decoration: TextDecoration.none,
                              Constant.fontName,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
