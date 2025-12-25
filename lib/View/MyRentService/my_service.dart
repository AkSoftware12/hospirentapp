import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hospirent/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../Purchase/imports.dart';
import '../Purchase/view/drawer/drawer_menu.dart';
import 'OrderDetails/order_details.dart';


class MyServiceScreen extends StatefulWidget {
  const MyServiceScreen({super.key});

  @override
  _MyServiceScreenState createState() => _MyServiceScreenState();
}

class _MyServiceScreenState extends State<MyServiceScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<dynamic> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final response = await http.get(
        Uri.parse(ApiRoutes.getOrderBillingList),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          orders = data['data'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const DrawerMenu(),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        title: Text(
          'My Services',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20.r),
          ),
        ),
        leading: Padding(
          padding: EdgeInsets.all(8.w),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.3),
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: isLoading
            ? _buildShimmerLoading()
            : orders.isEmpty
            ? _buildEmptyState()
            : RefreshIndicator(
          onRefresh: fetchOrders,
          color: AppColors.primary,
          child: ListView.builder(
            padding: EdgeInsets.all(8.w),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderDetails = order['order_details'] as List<dynamic>;
              final entryDate = DateFormat('MMM dd, yyyy').format(
                DateTime.parse(order['entry_date']),
              );

              return AnimatedCard(
                order: order,
                entryDate: entryDate,
                orderDetails: orderDetails,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(order:order),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: EdgeInsets.only(bottom: 16.h),
            height: 120.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_empty,
            size: 80.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            'No orders found',
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: fetchOrders,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: Text(
              'Refresh',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedCard extends StatefulWidget {
  final Map<String, dynamic> order;
  final String entryDate;
  final List<dynamic> orderDetails;
  final VoidCallback? onTap;

  const AnimatedCard({
    super.key,
    required this.order,
    required this.entryDate,
    required this.orderDetails,
    this.onTap,
  });

  @override
  _AnimatedCardState createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle;
      case 'pending':
        return Icons.hourglass_top;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          // margin: EdgeInsets.only(bottom: 16.h),
          child: Container(
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18.r,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text(
                            '#${widget.order['order_no']}',
                            style: GoogleFonts.poppins(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${widget.order['order_no']}',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16.sp,
                              ),
                            ),
                            Text(
                              widget.entryDate,
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                                fontSize: 12.sp,
                              ),
                            ),
                            SizedBox(
                              height: 10.sp,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: _getStatusColor(widget.order['status']).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _getStatusIcon(widget.order['status']),
                                    color: _getStatusColor(widget.order['status']),
                                    size: 16.sp,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    widget.order['status'],
                                    style: GoogleFonts.poppins(
                                      color: _getStatusColor(widget.order['status']),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),


                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            if (widget.order['status'].toLowerCase() == 'confirmed') ...[
                              SizedBox(width: 8.w),
                              IconButton(
                                icon: Icon(
                                  Icons.print,
                                  color: AppColors.primary,
                                  size: 20.sp,
                                ),
                                onPressed: () async {
                                  final Uri uri = Uri.parse('${ApiRoutes.customerChallanPrint}${ widget.order['id']}');
                                  try {
                                    if (!await launchUrl(uri,
                                        mode: LaunchMode.externalApplication)) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Could not open URL')),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')),
                                    );
                                  }
                                },
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [

                            Text(
                              '₹${widget.order['total_amount']}',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.sp,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                // Divider(color: Colors.grey[200], thickness: 1, height: 24.h),
                // ...widget.orderDetails.map((detail) {
                //   return Padding(
                //     padding: EdgeInsets.symmetric(vertical: 4.h),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: [
                //         Expanded(
                //           child: Column(
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: [
                //               Text(
                //                 detail['item_name'],
                //                 style: GoogleFonts.poppins(
                //                   fontWeight: FontWeight.w500,
                //                   fontSize: 14.sp,
                //                 ),
                //               ),
                //               Text(
                //                 'Qty: ${detail['quantity']} ${detail['measurement']}',
                //                 style: GoogleFonts.poppins(
                //                   color: Colors.grey[600],
                //                   fontSize: 12.sp,
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //         Text(
                //           '₹${detail['line_total']}',
                //           style: GoogleFonts.poppins(
                //             fontWeight: FontWeight.w600,
                //             fontSize: 14.sp,
                //             color: AppColors.primary,
                //           ),
                //         ),
                //       ],
                //     ),
                //   );
                // }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

