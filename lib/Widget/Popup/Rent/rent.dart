import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hospirent/HexColor.dart';
import 'package:hospirent/View/Purchase/view/home/buy_product.dart';
import 'package:hospirent/constants.dart';
import '../../../View/Rent/rent_product.dart';

class StylishPopup extends StatefulWidget {
  final int id;
  final int catIndex;
  final String catImage;
  final String catName;

  const StylishPopup({
    super.key,
    required this.id,
    required this.catIndex,
    required this.catImage,
    required this.catName,
  });

  @override
  State<StylishPopup> createState() => _StylishPopupState();
}

class _StylishPopupState extends State<StylishPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack);
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
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
    return Center(
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 25.sp),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Frosted glass background
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(22.sp),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 📸 Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18.sp),
                              child: CachedNetworkImage(
                                imageUrl: widget.catImage,
                                height: 160.sp,
                                width: double.infinity,
                                // fit: BoxFit.fill,
                                placeholder: (context, url) => Container(
                                  height: 160.sp,
                                  color: Colors.grey[200],
                                  child: const Center(
                                      child: CircularProgressIndicator()),
                                ),
                                errorWidget: (context, url, error) =>
                                const Icon(Icons.broken_image, size: 50),
                              ),
                            ),
                            SizedBox(height: 20.sp),
                            // 🏷 Category Name
                            Text(
                              widget.catName,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'PoppinsBold',
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 6.sp),
                            Text(
                              "Choose Your Option",
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 4.sp),
                            Text(
                              "Select whether you'd like to rent or buy.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey[600],
                                fontFamily: 'PoppinsRegular',
                              ),
                            ),
                            SizedBox(height: 25.sp),
                            // 🔘 Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildButton(
                                  label: "Rent",
                                  icon: Icons.add_circle_outline,
                                  colors: [HexColor('#1a1a1a'), HexColor('#5f4b8b')],
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => RentProduct(
                                          id: widget.id,
                                          catIndex: widget.catIndex,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(width: 25.sp),
                                _buildButton(
                                  label: "Buy",
                                  icon: Icons.shopping_bag_outlined,
                                  colors: [AppColors.primary, HexColor('#3b4d61')],
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BuyProduct(
                                          id: widget.id,
                                          catIndex: widget.catIndex,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 20.sp),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // ❌ Close Button
                Positioned(
                  top: -12,
                  right: -12,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 115.sp,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(25.sp),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white, size: 20.sp),
        label: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 10.sp),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.sp)),
        ),
        onPressed: onTap,
      ),
    );
  }
}
