import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hospirent/HexColor.dart';
import 'package:provider/provider.dart';
import '../../../../constants.dart';
import '../../../RentAcc/controller/rent_cart_provider.dart';
import '../../controller/cart_provider.dart'; // CartProvider
import '../../imports.dart';
import '../../model/cart_model.dart';
import '../../model/product_model.dart';
import '../../view/cart/cart.dart';
import '../text/text_builder.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final GlobalKey widgetKey = GlobalKey();
  final int index;
  final void Function(GlobalKey)  onClick;

   ProductCard({super.key, required this.product, required this.index, required this.onClick});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    final cart = Provider.of<CartProvider>(context, listen: true); // CartProvider
    final rentCart = Provider.of<RentCartProvider>(context, listen: false); // RentCartProvider
    final isInCart = cart.items.any((item) => item.id == product.id);

    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: InkWell(
        // onTap: () => openImage(context, size),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(5.sp),
                child: Container(
                  key: widgetKey,
                  height: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: CachedNetworkImage(
                      imageUrl: product.photoUrl ?? 'https://via.placeholder.com/150',
                      height: 80.sp,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Center(
                        child: CupertinoActivityIndicator(
                          radius: 20,
                          color: AppColors.primary,
                        ),
                      ),
                      errorWidget: (context, url, error) => SizedBox(
                        height: 60.sp,
                        width: double.infinity,
                        child: Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/1665px-No-Image-Placeholder.svg.png',fit: BoxFit.fill,),
                      ),
                      fadeInDuration: const Duration(milliseconds: 300),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.sp),
            Padding(
              padding: EdgeInsets.all(5.sp),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: TextBuilder(
                      text: product.title ?? 'No Title',
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                      maxLines: 3,
                      textOverflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.only(left: 2, right: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Stack(
                              children: [
                                Row(
                                  children: [
                                    const TextBuilder(
                                      text: '₹ ',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                    TextBuilder(
                                      text: product.price?.round().toString() ?? '0',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.sp,
                                      color: Colors.blue,
                                    ),


                                  ],
                                ),

                                if(product.gst!=0)
                                SizedBox(
                                  height: 22.sp,
                                  child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: Padding(
                                      padding:  EdgeInsets.only(left: 0.sp),
                                      child: TextBuilder(
                                        text: '+${product.gst?.round().toString()}${' % Gst'}',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 7.sp,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          ],
                        ),
                        isInCart
                            ? Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                cart.decrementItem(product.id.toString());
                              },
                              child: Container(
                                padding: EdgeInsets.all(0.sp),
                                decoration: BoxDecoration(
                                  color: HexColor('#dcfadc'),
                                  border: Border.all(
                                    color: HexColor('#008000'),
                                    width: 1.sp,
                                  ),
                                  borderRadius: BorderRadius.circular(5.sp),
                                ),
                                child: Icon(
                                  Icons.remove,
                                  size: 16.sp,
                                  color: HexColor('#008000'),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.sp),
                              child: TextBuilder(
                                text: cart.items
                                    .firstWhere((item) => item.id == product.id)
                                    .quantity
                                    .toString(),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                onClick(widgetKey);

                                cart.incrementItem(product.id.toString());
                              },
                              child: Container(
                                padding: EdgeInsets.all(0.sp),
                                decoration: BoxDecoration(
                                  color: HexColor('#dcfadc'),
                                  border: Border.all(
                                    color: HexColor('#008000'),
                                    width: 1.sp,
                                  ),
                                  borderRadius: BorderRadius.circular(5.sp),
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: 16.sp,
                                  color: HexColor('#008000'),
                                ),
                              ),
                            ),
                          ],
                        )
                            : GestureDetector(
                          onTap: () async {
                            if (product.id == null ||
                                product.title == null ||
                                product.price == null ||
                                product.photoUrl == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: TextBuilder(text: 'Incomplete product data'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }

                            // Check if RentCartProvider has items
                            if (rentCart.itemsRent.isNotEmpty) {
                              showDialog(
                                context: context,
                                barrierDismissible: true,
                                barrierColor: Colors.black.withOpacity(0.5),
                                builder: (context) {
                                  return TweenAnimationBuilder(
                                    tween: Tween<double>(begin: 0.0, end: 1.0),
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    builder: (context, double value, child) {
                                      return Transform.scale(
                                        scale: value,
                                        child: Opacity(
                                          opacity: value,
                                          child: AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            backgroundColor: Colors.white,
                                            elevation: 10,
                                            insetPadding: const EdgeInsets.all(16),
                                            contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                                            content: Stack(
                                              children: [
                                                Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      margin: const EdgeInsets.only(bottom: 16, top: 32),
                                                      child: Image.asset(
                                                        'assets/clear_cart.jpg',
                                                        height: 130.sp,
                                                        width: 130.sp,
                                                        fit: BoxFit.fill,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Clear Rent Cart?',
                                                      style: GoogleFonts.poppins(
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 20,
                                                        color: Colors.black, // Bolder text color
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      'Your rent cart contains items. Do you want to clear the rent cart to add this item to your purchase cart?',
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 16,
                                                        color: Colors.grey.shade700, // Softer, readable color
                                                        height: 1.6,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                                Positioned(
                                                  right: -8,
                                                  top: -8,
                                                  child: IconButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    icon:  Icon(
                                                      Icons.close,
                                                      color: Colors.grey.shade600,
                                                      size: 24,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            actionsAlignment: MainAxisAlignment.spaceEvenly,
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  'Cancel',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.blue.shade600, // Vibrant cancel button color
                                                  ),
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  rentCart.clearCart();
                                                  Navigator.pop(context);
                                                  CartModel cartModel = CartModel(
                                                    id: product.id!,
                                                    product_id: product.id.toString(),
                                                    measurement: product.measurement.toString(),
                                                    product_name: product.title!,
                                                    rate: product.price!,
                                                    image: product.photoUrl!,
                                                    category: '',
                                                    quantity: 1,
                                                    // Calculate GST amount: (price * gst percentage) / 100
                                                    gst: (product.price! * product.gst!) / 100,
                                                    product_gst: product.gst!?? 0,
                                                    // Total price including GST: price + GST amount
                                                    totalPrice: product.price! + ((product.price! * product.gst!) / 100),
                                                  );
                                                  cart.addItem(cartModel);
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Item added to purchase cart!',
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 14,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      backgroundColor: Colors.green.shade600,
                                                      duration: const Duration(seconds: 2),
                                                      behavior: SnackBarBehavior.floating,
                                                      margin: const EdgeInsets.all(16),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.redAccent.shade400, // Brighter red for action
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                  elevation: 5, // Slightly higher elevation for depth
                                                ),
                                                child: Text(
                                                  'Clear & Add',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white, // Ensure text is white for contrast
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            } else {
                              onClick(widgetKey);

                              // No items in rent cart, add directly to cart
                              CartModel cartModel = CartModel(
                                id: product.id!,
                                product_id: product.id.toString(),
                                measurement: product.measurement.toString(),
                                product_name: product.title!,
                                rate: product.price!,
                                image: product.photoUrl!,
                                category: '',
                                quantity: 1,
                                // Calculate GST amount: (price * gst percentage) / 100
                                gst: (product.price! * product.gst!) / 100,
                                product_gst: product.gst!?? 0,
                                // Total price including GST: price + GST amount
                                totalPrice: product.price! + ((product.price! * product.gst!) / 100),
                              );
                              cart.addItem(cartModel);

                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: HexColor('#dcfadc'),
                              border: Border.all(
                                color: HexColor('#008000'),
                                width: 1.sp,
                              ),
                              borderRadius: BorderRadius.circular(5.sp),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(left: 8.sp, right: 8.sp),
                              child: Text(
                                'Buy'.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: HexColor('#008000'),
                                  fontFamily: 'PoppinsSemiBold',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void openImage(BuildContext context, Size size) {
    showDialog(
      context: context,
      useSafeArea: true,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          actionsPadding: EdgeInsets.zero,
          buttonPadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.all(8),
          elevation: 0,
          title: SizedBox(
            width: size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextBuilder(
                  text: product.title ?? 'No Title',
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  maxLines: 3,
                  textOverflow: TextOverflow.ellipsis,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.close,
                    size: 30,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          content: InteractiveViewer(
            minScale: 0.1,
            maxScale: 1.9,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(8.sp)),
              child: CachedNetworkImage(
                imageUrl: product.photoUrl ?? 'https://via.placeholder.com/150',
                height: size.height * 0.5,
                width: size.width,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: CupertinoActivityIndicator(
                    radius: 20,
                    color: AppColors.primary,
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fadeInDuration: const Duration(milliseconds: 300),
              ),
            ),
          ),
        );
      },
    );
  }
}