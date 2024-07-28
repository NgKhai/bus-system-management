import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthBloc() : super(AuthInitial()) {
    on<AppStarted>((event, emit) async {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        emit(Authenticated());
      } else {
        emit(Unauthenticated());
      }
    });

    on<SignInRequested>((event, emit) async {
      try {
        await _signInWithMicrosoft();
        emit(Authenticated());
      } catch (_) {
        emit(Unauthenticated());
      }
    });

    on<SignOutRequested>((event, emit) async {
      await _firebaseAuth.signOut();
      emit(Unauthenticated());
    });
  }

  Future<void> _signInWithMicrosoft() async {
    final provider = OAuthProvider("microsoft.com");
    provider.setCustomParameters({"tenant": "98ada680-e3f4-48cb-8fbb-c8b10cb97aed"});
    provider.addScope('mail.read');
    provider.addScope('calendars.read');
    provider.addScope('openid');

    await _firebaseAuth.signInWithProvider(provider);
  }
}
