import 'dart:async';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hospirent/HexColor.dart';
import '../../../../constants.dart';
import '../../../DrawerScreen/privacy.dart';
import '../Otp/otp.dart'; // Assuming OTPVerificationScreen is defined here
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginScreenNew extends StatefulWidget {
  const LoginScreenNew({super.key});

  @override
  State<LoginScreenNew> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<LoginScreenNew> {
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final mobileNo = _phoneController.text.trim();

      final response = await http.post(
        Uri.parse(ApiRoutes.mobileLogin), // <- API URL
        body: {"mobile_no": mobileNo},
      );

      final data = jsonDecode(response.body);

      print('User$data');

      if (data["success"] == true) {
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OTPVerificationScreen(
                mobileNo: mobileNo,
                // otp: data["otp"].toString(), // ✅ OTP pass kar diya
              ),
            ),
          );
        }
      } else {
        _showError(data["message"] ?? "Failed to send OTP");
      }
    } catch (e) {
      _showError("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _clearPhoneNumber() {
    _phoneController.clear();
    setState(() {});
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.sp),
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/loginbg3.jpg',
                        height: MediaQuery.of(context).size.height * 0.5,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                        child: Container(
                          color: Colors.black.withOpacity(0.25),
                        ),
                      ),
                    ],
                  ),
                ),

    // Container(
                //   height:
                //       MediaQuery.of(context).size.height *
                //       0.5, // 0.5% of screen height
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(20.sp),
                //
                //     gradient: LinearGradient(
                //       colors: [AppColors.primary, AppColors.primary],
                //       begin: Alignment.topLeft,
                //       end: Alignment.topRight,
                //     ),
                //   ),
                // ),

                Padding(
                  padding:  EdgeInsets.only(left: 20.sp,right: 20.sp,top: 60.sp),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lets start with your \nmobile number',
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,

                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10.sp,
                      ),

                      Text(
                        'A 6-Digit OTP(One time password) will be sent as WhatsApp to the below provided number.',
                        // 'Enter your phone number to receive a one-time password via WhatsApp.',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 12.sp,

                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(2.0, 2.0),
                            ),
                          ],

                        ),

                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 20.sp),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        clipBehavior: Clip.none,
                        children: [
                          // 🔹 Card with custom notch shape
                          Card(
                            elevation: 4,
                            color: Colors.white,
                            // width: double.infinity,
                             margin: EdgeInsets.only(bottom: 30.sp),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.sp), // 20.sp radius
                            ),
                            child: Padding(
                              padding:  EdgeInsets.all(12.sp),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 120.sp,
                                    height: 120.sp,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(20.sp),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20.sp),
                                      child: Image.asset(
                                        'assets/playstore.png',
                                        width: 100.sp,
                                        height: 100.sp,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10.sp),

                                  Text(
                                    'HospiRent App',
                                    style: GoogleFonts.poppins(
                                      fontSize: 8.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      letterSpacing: 1.5,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 10.0,
                                          color: Colors.black.withOpacity(0.3),
                                          offset: const Offset(2.0, 2.0),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 20.sp),

                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      'Phone number',
                                      style: GoogleFonts.roboto(
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10.sp),
                                  TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    decoration: InputDecoration(
                                      hintText: 'Enter your phone number',
                                      hintStyle: GoogleFonts.roboto(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 13.sp,
                                      ),
                                      prefixIcon: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.sp,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Image.asset(
                                              'assets/flag.png',
                                              width: 25.sp,
                                              height: 25.sp,
                                              fit: BoxFit.contain,
                                              semanticLabel: 'Indian flag',
                                            ),
                                            SizedBox(width: 5.sp),
                                            Text(
                                              '+91',
                                              style: GoogleFonts.roboto(
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13.sp,
                                              ),
                                            ),
                                            SizedBox(width: 8.sp),
                                            Container(
                                              width: 1,
                                              height: 24,
                                              color: Colors.grey.shade400,
                                            ),
                                          ],
                                        ),
                                      ),
                                      suffixIcon: _phoneController.text.isNotEmpty
                                          ? IconButton(
                                              icon: const Icon(
                                                Icons.clear,
                                                color: Colors.grey,
                                              ),
                                              onPressed: _clearPhoneNumber,
                                            )
                                          : null,
                                      filled: true,
                                      fillColor: Colors.grey.shade100,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.sp,
                                        ),
                                        borderSide: BorderSide(
                                          color: AppColors.primary,
                                          width: 1.5,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.sp,
                                        ),
                                        borderSide: BorderSide(
                                          color: AppColors.primary,
                                          width: 1.5,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.sp,
                                        ),
                                        borderSide: BorderSide(
                                          color: AppColors.primary,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.length != 10) {
                                        return 'Please enter a valid 10-digit phone number';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) => setState(() {}),
                                  ),
                                  SizedBox(height: 30.sp),

                                  SizedBox(height: 20.sp),
                                ],
                              ),
                            ),
                          ),

                          // 🔹 Circular button inside notch
                          Positioned(
                            bottom: 10,
                            child: SizedBox(
                              width: 150.sp,
                              height: 40.sp,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  // color: HexColor('d63b7e'),
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      Colors.blue.shade400,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20.sp),
                                ),
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _sendOTP,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        20.sp,
                                      ),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? SizedBox(
                                          height: 20.sp,
                                          width: 20.sp,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Send OTP',
                                        style: GoogleFonts.roboto(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                      SizedBox(width: 8.sp),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.white,
                                        size: 16.sp,
                                      ),
                                    ],
                                  )

                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.sp),

                    // Terms and conditions
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.sp),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'By using your phone number you accept our ',
                          style: GoogleFonts.roboto(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                            fontSize: 11.sp,
                          ),
                          children: [
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: GoogleFonts.roboto(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 11.sp,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const PrivacyPage()),
                                  );
                                  },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 0.sp),
              child: Container(
                height: 50.sp,
                color: AppColors.primary,
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'Provided by ',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 10.sp,
                      ),
                      children: [
                        TextSpan(
                          text: 'Ak Software',
                          style: GoogleFonts.poppins(
                            color: Colors.lightBlueAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.sp,
                            decoration: TextDecoration.none,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              print("Ak Software Clicked");
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

