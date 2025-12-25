import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../constants.dart';
import '../../../../main.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String mobileNo;

  const OTPVerificationScreen({super.key, required this.mobileNo});

  @override
  State<OTPVerificationScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  int _secondsRemaining = 60;
  late Timer _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  Future<String?> getDeviceToken() async {
    final fcm = FirebaseMessaging.instance;
    return await fcm.getToken();
  }

  Future<void> _verifyOTP() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 6) return;

    setState(() => _isLoading = true);

    try {
      final deviceToken = await getDeviceToken(); // Get device token
      final response = await http.post(
        Uri.parse(ApiRoutes.mobileOtpVerify),
        body: {
          "contact": widget.mobileNo,
          "otp": otp,
          "device_id": deviceToken ?? "", // Include device token
        },
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("auth_token", data["token"]);
        await prefs.setString("user", jsonEncode(data["user"]));

        await _saveProfileToPrefs(jsonEncode(data["user"]['contact']),jsonEncode(data["user"]['name']),jsonEncode(data["user"]['image']));

        if (mounted) {
          setState(() => _isLoading = false);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => MainScreen(initialIndex: 0,)),
            );

        }

      } else {
        showInvalidOtpDialog(context);
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

  Future<void> _saveProfileToPrefs(number,name,image) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_contact', number ?? '');
    await prefs.setString('user_name', name ?? '');
    await prefs.setString('user_photo_url', image ?? '');

  }



  void showInvalidOtpDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6), // Darker overlay for focus
      builder: (BuildContext context) {
        return AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutBack,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24), // Softer, modern corners
            ),
             backgroundColor: Colors.white, // Transparent for glassmorphism
            elevation: 0,
            child: Container(
              decoration: BoxDecoration(
                // color: Colors.white.withOpacity(0.1), // Glassmorphism effect
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
                gradient: LinearGradient(
                  colors: [
                    Colors.grey.shade100,
                    Colors.grey.shade100,
                    // Colors.red[100]!.withOpacity(0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.error_rounded,
                        color: Color(0xFFFF0000), // Vibrant red
                        size: 40,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Invalid OTP!',
                        style: TextStyle(
                          color: Color(0xFFFF0000), // Vibrant red
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your OTP is not correct. Let’s try that again! 🚀',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:  Color(0xFFFF0000),
                      fontSize: 16,
                      height: 1.5, // Comfortable line spacing
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF0000), // Vibrant red
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                      shadowColor: Colors.red[400]!.withOpacity(0.5),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  void _onOTPChanged(int index) {
    if (_otpControllers[index].text.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (_otpControllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    // Auto-verify if all fields filled
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length == 6) {
      _verifyOTP();
    }
  }

  void _resendOTP() {
    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });
    _startTimer();
    // Simulate resend API call
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('OTP resent!')));
  }

  @override
  void dispose() {
    _timer.cancel();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            /// 🔹 Background Gradient
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                ),
              ),
            ),

            /// 🔹 Main Content with Scroll
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// 🔹 Scrollable Section
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.sp,
                      vertical: 20.sp,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Header Text
                        Padding(
                          padding: EdgeInsets.only(top: 0.sp, bottom: 20.sp),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Verification Code',
                                style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22.sp,
                                ),
                              ),
                              SizedBox(height: 10.sp),
                              RichText(
                                textAlign: TextAlign.start,
                                text: TextSpan(
                                  text:
                                      'A 6-Digit OTP (One time password) has been sent by WhatsApp to ',
                                  style: GoogleFonts.roboto(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13.sp,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: ' +91${widget.mobileNo}',
                                      style: GoogleFonts.roboto(
                                        color: Colors.lightBlueAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.sp),

                        /// 🔹 OTP Card + Verify Button
                        Center(
                          child: Stack(
                            alignment: Alignment.topCenter,
                            clipBehavior: Clip.none,
                            children: [
                              Card(
                                elevation: 4,
                                color: Colors.white,
                                margin: EdgeInsets.only(bottom: 40.sp),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.sp),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(12.sp),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 20.sp),
                                      Text(
                                        'Enter OTP',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'We sent an OTP to your phone',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      SizedBox(height: 40.sp),

                                      /// 🔹 OTP Inputs
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: List.generate(6, (index) {
                                          return SizedBox(
                                            width: 40.sp,
                                            // height: 45.sp,
                                            child: TextField(
                                              controller:
                                                  _otpControllers[index],
                                              focusNode: _focusNodes[index],
                                              keyboardType:
                                                  TextInputType.number,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              inputFormatters: [
                                                LengthLimitingTextInputFormatter(
                                                  1,
                                                ),
                                              ],
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color:
                                                            Colors.blue[600]!,
                                                        width: 2,
                                                      ),
                                                    ),
                                                filled: true,
                                                fillColor: Colors.grey[50],
                                              ),
                                              onChanged: (_) =>
                                                  _onOTPChanged(index),
                                            ),
                                          );
                                        }),
                                      ),
                                      SizedBox(height: 40.sp),
                                    ],
                                  ),
                                ),
                              ),

                              /// 🔹 Verify OTP Button (Same as your UI)
                              Positioned(
                                bottom: 25,
                                child: SizedBox(
                                  width: 150.sp,
                                  height: 40.sp,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primary,
                                          Colors.blue.shade400,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        20.sp,
                                      ),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _verifyOTP,
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
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Verify OTP',
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
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// Resend OTP + Wrong Number
                        SizedBox(height: 20.sp),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!_canResend)
                              Text(
                                'Resend in ${_secondsRemaining}s',
                                style: TextStyle(color:Color(0xFFFF0000),),
                              )
                            else
                              GestureDetector(
                                onTap: _resendOTP,
                                child: Text(
                                  'Resend OTP',
                                  style: TextStyle(
                                    color: Colors.blue[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                'Wrong number? Change',
                                style: TextStyle(color: Colors.blue[600]),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                /// Footer
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 20.sp,
                color: AppColors.primary,
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'Provided by  ',
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
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

// Custom Animated Dialog Widget
class AnimatedScaleDialog extends StatefulWidget {
  final Widget child;

  const AnimatedScaleDialog({required this.child, Key? key}) : super(key: key);

  @override
  _AnimatedScaleDialogState createState() => _AnimatedScaleDialogState();
}

class _AnimatedScaleDialogState extends State<AnimatedScaleDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scaleAnimation, child: widget.child);
  }
}
