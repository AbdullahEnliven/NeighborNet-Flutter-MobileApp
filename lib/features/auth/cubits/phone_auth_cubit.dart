import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
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

      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        if (context.mounted) {
          if (doc.exists) {
            context.go('/');
          } else {
            context.go('/profileform');
          }
        }
        emit(PhoneAuthVerified());
      }
    } catch (e) {
      emit(PhoneAuthOtpSent());

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid OTP or verification failed.")),
        );
      }
    }
  }

  void reset() {
    emit(PhoneAuthInitial());
  }
}
