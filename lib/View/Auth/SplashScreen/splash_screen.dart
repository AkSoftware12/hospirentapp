import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../HexColor.dart';
import '../../../constants.dart';
import '../../../main.dart';
import '../../Purchase/imports.dart';
import '../LoginNew/Login/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");
    await Future.delayed(const Duration(seconds: 4)); // splash delay

    if (mounted) {
      if (token != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MainScreen(initialIndex: 0,)),
          );

      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreenNew()),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 150.sp,
                  width: 150.sp,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(15.sp))
                  ),
                  child:   Padding(
                    padding:  EdgeInsets.all(15.sp),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.sp),

                      child: Image.asset(
                        'assets/playstore.png',
                        width: 80.sp,
                        height: 80.sp,
                      ),
                    ),
                  ),
                ),
                // Logo image

                SizedBox(height: 5.sp), // Spacing between logo and app name
                // App name
                Text(
                  'Hospi Rent', // Replace with your app name
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // White text for contrast
                  ),
                ),

                SizedBox(height: 10.sp), // Spacing before loader
                Container(
                  height: 60.sp,
                  width: 60.sp,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(5.sp),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Lottie.asset(
                      'assets/loadingbar.json',
                      height: 50.sp,
                      width: 50.sp,
                      fit: BoxFit.cover,
                      delegates: LottieDelegates(
                        values: [
                          // 🎨 Apply a global color tint (change to your desired color)
                          ValueDelegate.color(
                            const ['**'], // Apply to all layers
                            value: Colors.white, // Change this to any color
                          ),
                        ],
                      ),

                    ),
                  ),
                ),

              ],
            ),
          ),


        ],
      ),
    );
  }
}


class CustomUpgradeDialog extends StatelessWidget {
  final String androidAppUrl = 'https://play.google.com/store/apps/details?id=com.hospirent.hospirent&pcampaignid=web_share';
  final String iosAppUrl = 'https://apps.apple.com/app/idYOUR_IOS_APP_ID'; // Replace with your iOS app URL
  final String currentVersion; // Old version
  final String newVersion; // New version
  final List<String> releaseNotes; // Release notes

  const CustomUpgradeDialog({
    Key? key,
    required this.currentVersion,
    required this.newVersion,
    required this.releaseNotes,
  }) : super(key: key);

  Future<void> _launchStore() async {
    final Uri androidUri = Uri.parse(androidAppUrl);
    final Uri iosUri = Uri.parse(iosAppUrl);

    try {
      if (Platform.isIOS) {
        if (await canLaunchUrl(iosUri)) {
          await launchUrl(
            iosUri,
            mode: LaunchMode.externalApplication,
          );
        } else {
          throw 'Could not launch iOS App Store';
        }
      } else if (Platform.isAndroid) {
        if (await canLaunchUrl(androidUri)) {
          await launchUrl(
            androidUri,
            mode: LaunchMode.externalApplication,
          );
        } else {
          throw 'Could not launch Play Store';
        }
      }
    } catch (e) {
      debugPrint('Launch error: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 20.sp),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.sp)),
      elevation: 12,

      child: Container(
        constraints: BoxConstraints(maxWidth: 420),
        padding: EdgeInsets.all(25.sp),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary,AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25.sp),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      HexColor('#FFFFFF'),
                      AppColors.primary.withOpacity(0.9),
                    ],
                    radius: 0.55,
                    center: Alignment.center,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white60,
                      blurRadius: 30,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                padding: EdgeInsets.all(10.sp),
                child: Icon(
                  Icons.rocket_launch_outlined,
                  size: 52.sp,
                  color:AppColors.primary,
                ),
              ),
              SizedBox(height: 10.sp),
              Text(
                "🚀 New Update Available!",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.4),
                      offset: Offset(1, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.sp),
              Center(
                child: Text(
                  "A new version of Upgrader is available! Version $newVersion is now available - you have $currentVersion",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 5.sp),

              Center(
                child: Text(
                  " Would you like to update it now?",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(height: 5.sp),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10.sp),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15.sp),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "What's New in Version $newVersion",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10.sp),
                    ...releaseNotes.asMap().entries.map((entry) => Padding(
                      padding: EdgeInsets.only(bottom: 8.sp),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "• ",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
              SizedBox(height: 15.sp),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:AppColors.primary,
                  foregroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 28.sp, vertical: 12.sp),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.sp),
                    side: BorderSide(color: Colors.white, width: 1.sp),
                  ),
                ),
                icon: Icon(Icons.rocket_launch, size: 20.sp,color: Colors.white,),
                label: Text(
                  "Update Now".toUpperCase(),
                  style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white
                  ),
                ),
                onPressed: () async {
                  await _launchStore();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// You need to define a global navigator key to access context outside widgets
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();