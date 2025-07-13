import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'phone_auth_state.dart';

class PhoneAuthCubit extends Cubit<PhoneAuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;

  PhoneAuthCubit() : super(PhoneAuthInitial());

  void sendOtp(String phoneNumber) async {
    emit(PhoneAuthCodeSentLoading());

    await _auth.verifyPhoneNumber(
      phoneNumber: "+92$phoneNumber",
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        emit(PhoneAuthVerified());
      },
      verificationFailed: (FirebaseAuthException e) {
        emit(PhoneAuthPhoneError(e.message ?? "OTP verification failed."));
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        emit(PhoneAuthOtpSent());
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  void verifyOtp(String otp, BuildContext context) async {
    emit(PhoneAuthVerifyingOtp());

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      await _auth.signInWithCredential(credential);
      emit(PhoneAuthVerified());
    } catch (e) {
      emit(PhoneAuthOtpSent());
      otp='';
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid OTP or verification failed.")),
      );
      // emit(PhoneAuthOtpError("Invalid OTP or verification failed."));
    }
  }

  void reset() {
    emit(PhoneAuthInitial());
  }
}
