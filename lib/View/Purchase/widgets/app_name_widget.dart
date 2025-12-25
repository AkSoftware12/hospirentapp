import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../imports.dart';

class AppNameWidget extends StatelessWidget {
  const AppNameWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: 1 + (0.05 * value),
              child: Container(
                width: 40.sp,
                height: 40.sp,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.0),
                      blurRadius: 10,
                      offset: const Offset(4, 4),
                    ),
                  ],
                ),
                child: Image.asset('assets/hrlogo.png'),
              ),
            );
          },
        ),

        Text(
          'Hospi',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 1.2,
            shadows: [
              // Main deep shadow
              Shadow(
                offset: const Offset(2, 2),
                blurRadius: 3,
                color: Colors.black.withOpacity(0.7),
              ),
              // Inner bright shadow for depth highlight
              const Shadow(
                offset: Offset(-1, -1),
                blurRadius: 1,
                color: Colors.blueAccent,
              ),
            ],
          ),
        ),
        Text(
          'Rent',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 1.2,
            shadows: [
              // Main deep shadow
              Shadow(
                offset: const Offset(2, 2),
                blurRadius: 3,
                color: Colors.black.withOpacity(0.7),
              ),
              // Inner bright shadow for depth highlight
              const Shadow(
                offset: Offset(-1, -1),
                blurRadius: 1,
                color: Colors.blueAccent,
              ),
            ],
          ),
        )

      ],
    );
  }
}
