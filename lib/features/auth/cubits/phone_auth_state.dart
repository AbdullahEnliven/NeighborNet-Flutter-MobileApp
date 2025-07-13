abstract class PhoneAuthState {}

class PhoneAuthInitial extends PhoneAuthState {}

class PhoneAuthCodeSentLoading extends PhoneAuthState {}

class PhoneAuthVerifyingOtp extends PhoneAuthState {}

class PhoneAuthOtpSent extends PhoneAuthState {}

class PhoneAuthVerified extends PhoneAuthState {}

class PhoneAuthOtpError extends PhoneAuthState {
  final String message;
  PhoneAuthOtpError(this.message);
}

class PhoneAuthPhoneError extends PhoneAuthState {
  final String message;
  PhoneAuthPhoneError(this.message);
}
