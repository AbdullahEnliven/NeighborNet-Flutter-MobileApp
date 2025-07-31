import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbornet/features/auth/cubits/phone_auth_cubit.dart';
import 'package:neighbornet/features/auth/cubits/phone_auth_state.dart';
import 'package:neighbornet/features/auth/widget/otp_fields.dart';

import '../core/validator.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String otpCode = '';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: BlocConsumer<PhoneAuthCubit, PhoneAuthState>(
        listener: (context, state) {
          // if (state is PhoneAuthVerified) {
          //   //context.go('/profileform');
          // } 
          if (state is PhoneAuthPhoneError ||
              state is PhoneAuthOtpError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.toString())));
          }
        },
        builder: (context, state) {
          final bool showOtp =
              state is PhoneAuthOtpSent ||
              state is PhoneAuthOtpError ||
              state is PhoneAuthVerifyingOtp;
          final bool isLoading =
              state is PhoneAuthCodeSentLoading ||
              state is PhoneAuthVerifyingOtp;

          return SingleChildScrollView(
            child: Column(
              children: [
                /// Banner
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: Image.asset(
                    isDarkMode
                        ? "assets/auth_dark_mode.png"
                        : "assets/auth_b.png",
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  "Welcome to NeighborNet",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  showOtp
                      ? "Enter the OTP sent to your number"
                      : "Enter your phone number to continue",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: screenHeight * 0.09),

                /// Phone Field
                if (!showOtp)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number (without +92)',
                        border: OutlineInputBorder(),
                        prefixText: '+92 ',
                      ),
                    ),
                  ),

                /// OTP Field
                if (showOtp)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: OtpField(
                      onCompleted: (otp) {
                        otpCode = otp;
                      },
                    ),
                  ),

                SizedBox(height: screenHeight * 0.05),

                /// Action Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null // Disable the button while loading
                        : () {
                            final phone = _phoneController.text.trim();
                            final error = PhoneValidator.validate(phone);

                            if (!showOtp) {
                              if (error == null) {
                                context.read<PhoneAuthCubit>().sendOtp(phone);
                              } else {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text(error)));
                              }
                            } else {
                              if (otpCode.length == 6) {
                                context.read<PhoneAuthCubit>().verifyOtp(
                                  otpCode,
                                  context,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Invalid OTP")),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: isLoading
                          // ignore: deprecated_member_use
                          ? Theme.of(context).primaryColor.withOpacity(0.7)
                          : Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                showOtp ? "Verifying..." : "Sending OTP...",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          )
                        : Text(showOtp ? "Verify OTP" : "Continue"),
                  ),
                ),

                const SizedBox(height: 15),
                if (showOtp)
                  TextButton(
                    onPressed: () {
                      context.read<PhoneAuthCubit>().reset();
                      _phoneController.clear();
                      otpCode = '';
                    },
                    child: Text(
                      'Change Phone Number',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.blue),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'By continuing, you agree to our Terms of Service and Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
