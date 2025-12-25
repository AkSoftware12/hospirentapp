
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hospirent/View/Purchase/widgets/text/text_builder.dart';

import '../../../../constants.dart';
import '../../controller/rent_cart_provider.dart';
import '../../imports.dart';
import '../../model/cart_model.dart';

class RentCartCard extends StatelessWidget {
  final RentCartModel cart;
  const RentCartCard({
    Key? key,
    required this.cart,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // Size size = MediaQuery.of(context).size;
    // final totalPrice = (cart.price! * cart.quantity!);
    final provider = Provider.of<RentCartProvider>(context);
    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400, width: 0.5),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 3.sp,
          ),

          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: CachedNetworkImage(
              imageUrl: cart.image!,
              height: 60.sp,
              width: 60.sp,
              fit: BoxFit.contain,
              placeholder: (context, url) => Center(
                child: CupertinoActivityIndicator(
                  radius: 20,
                  color: AppColors.primary,
                ),
              ),
              errorWidget: (context, url, error) =>SizedBox(
                height: 60.sp,
                width: 60.sp,
                child: Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/1665px-No-Image-Placeholder.svg.png',fit: BoxFit.fill,),
              ),
              fadeInDuration: const Duration(milliseconds: 300),
            ),
          ),

          const SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextBuilder(
                        // text: '${cart.title} X ${cart.quantity}',
                        text: '${cart.product_name}',
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                        maxLines: 2,
                        textOverflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: InkWell(
                        onTap: () {
                          provider.removeItem(cart.id!);
                        },
                        child: Container(
                          height: 25.sp,
                          width: 25.sp,
                          decoration:  BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200),
                          child:  Icon(
                            Icons.delete_forever,
                            color: Colors.red,
                            size: 20.sp,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                 // SizedBox(height: 5.sp),
                Row(
                  children: [
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: TextBuilder(
                          text:  " ₹${cart.rate!.round()}",
                          fontSize: 11.sp,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        )),

                    if(cart.product_gst!=0)
                    SizedBox(
                      height: 22.sp,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding:  EdgeInsets.only(left: 0.sp),
                          child: TextBuilder(
                            text: '  +${cart.product_gst?.round().toString()}${' % GST'}',
                            fontWeight: FontWeight.bold,
                            fontSize: 8.sp,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
                const SizedBox(height: 5),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 0.h, horizontal: 2.w),
                  padding: EdgeInsets.all(5.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        spreadRadius: 3,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligns text better
                              children: [
                                Text(
                                  'Sub Total: '.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 6.sp,
                                    color: Colors.blue.shade800,
                                    // letterSpacing: 0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "₹ ${(cart.rate! * cart.quantity!).toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 8.sp,
                                    color: Colors.blue.shade800,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            if(cart.product_gst!=0)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'GST Amount: '.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 6.sp,
                                    color: Colors.red.shade500,
                                    // letterSpacing: 0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "₹ ${(cart.gst! * cart.quantity!).toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 8.sp,
                                    color: Colors.red.shade500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            // SizedBox(height: 10.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Text(
                                //   'Total: ',
                                //   style: TextStyle(
                                //     fontWeight: FontWeight.w700, // Slightly bolder for emphasis
                                //     fontSize: 15.sp, // Slightly larger for hierarchy
                                //     color: Colors.blue.shade900,
                                //     letterSpacing: 0.5,
                                //   ),
                                //   overflow: TextOverflow.ellipsis,
                                // ),
                                Text(
                                  "₹ ${((cart.rate! + cart.gst!) * cart.quantity!).round()}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.sp,
                                    color: Colors.blue.shade900,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(12.r),
                              onTap: () {
                                provider.decreaseQuantity(cart.id!);
                              },
                              child: Container(
                                padding: EdgeInsets.all(3.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Icon(
                                  Icons.remove,
                                  color: Colors.blue.shade700,
                                  size: 18.sp,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              cart.quantity.toString(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            InkWell(
                              borderRadius: BorderRadius.circular(12.r),
                              onTap: () {
                                provider.increaseQuantity(cart.id!);
                              },
                              child: Container(
                                padding: EdgeInsets.all(3.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: Colors.blue.shade700,
                                  size: 18.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )  ,

              ],
            ),
          )
        ],
      ),
    );
  }
}
