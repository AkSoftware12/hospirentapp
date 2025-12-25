
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hospirent/View/Purchase/widgets/text/text_builder.dart';

import '../imports.dart';

class AppNameWidget extends StatelessWidget {
  const AppNameWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextBuilder(text: 'Hospi ', color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w700),
        TextBuilder(text: 'Rent', color:  Colors.white, fontSize: 20.sp,fontWeight: FontWeight.w700),
      ],
    );
  }
}
