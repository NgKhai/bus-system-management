import 'package:bus_system_management/model/bus_data.dart';
import 'package:bus_system_management/screen/info_screen.dart';
import 'package:bus_system_management/screen/main_screen.dart';
import 'package:bus_system_management/screen/qr/scan_error_screen.dart';
import 'package:bus_system_management/screen/qr/scan_success_screen.dart';
import 'package:bus_system_management/screen/route_screen.dart';
import 'package:bus_system_management/screen/splash_screen.dart';
import 'package:bus_system_management/screen/tracking_screen.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth/auth_provider.dart';
import '../bloc/scan/scan_provider.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
      // builder: (context, state) => FaceRecognitionScreen(),
    ),
    GoRoute(
      path: '/signIn',
      builder: (context, state) => const AuthenticationProvider(),
    ),

    GoRoute(
      path: '/home',
      builder: (context, state) {
        return MainScreen();
      },
      routes: [
        GoRoute(
            path: 'scan',
            builder: (context, state) {
              return ScanProvider();
            }
        ),
        GoRoute(
            path: 'scan_error',
            builder: (context, state) {
              final message = state.extra as String;
              return ScanErrorScreen(message: message);
            }
        ),
        GoRoute(
            path: 'scan_success',
            builder: (context, state) {
              final busData = state.extra as BusData;
              return ScanSuccessScreen(busData: busData);
            },
        ),
        GoRoute(
            path: 'tracking',
            builder: (context, state) {
              final busData = state.extra as BusData;
              return TrackingScreen(busData: busData);
            }
        ),
        GoRoute(
            path: 'route',
            builder: (context, state) {
              final busData = state.extra as BusData;
              return RouteScreen(busData: busData);
            }
        ),
      ]
    ),
    GoRoute(
      path: '/info',
      builder: (context, state) {
        return InfoScreen();
      },
    ),
  ],
);
