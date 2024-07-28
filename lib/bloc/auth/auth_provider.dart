import 'package:bus_system_management/screen/main_screen.dart';
import 'package:bus_system_management/screen/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthenticationProvider extends StatelessWidget {
  const AuthenticationProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AuthBloc()..add(AppStarted()),
        child: AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // final user = FirebaseAuth.instance.currentUser;
        if (state is Authenticated) {
          return MainScreen();
        } else if (state is Unauthenticated) {
          return const SignInScreen();
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}