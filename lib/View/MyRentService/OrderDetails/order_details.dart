import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants.dart';

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> orderDetails = order['order_details'] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        title: Text(
          'Order #${order['order_no']}',
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
              icon:  Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);

              },
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Card
            Card(
              elevation: 6,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.info_outline, color: Color(0xFF0288D1), size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Order Summary',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0288D1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(context, "Customer", order['customer_name'], Icons.person),
                    _buildInfoRow(context, "Address", order['address'], Icons.location_on),
                    _buildInfoRow(context, "Contact", order['contact_no'], Icons.phone),
                    _buildInfoRow(context, "Order Date", order['entry_date'], Icons.calendar_today),
                    _buildInfoRow(context, "Status", order['status'], Icons.check_circle),
                    _buildInfoRow(context, "Total", "₹${order['total_amount']}", Icons.account_balance_wallet),
                    _buildInfoRow(context, "In Words", order['amount_in_words'], Icons.text_fields),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Order Items Table
            Row(
              children: const [
                Icon(Icons.shopping_cart, color: Color(0xFF0288D1), size: 24),
                SizedBox(width: 8),
                Text(
                  'Order Items',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0288D1),
                  ),
                ),
              ],
            ),
            const Divider(
              color: Color(0xFF4FC3F7),
              thickness: 2,
              height: 24,
            ),

            _buildOrderItemsTable(context, orderDetails),
            const SizedBox(height: 16),
            // Action Buttons
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String title, String? value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF4FC3F7), size: 20),
          const SizedBox(width: 12),
          Text(
            "$title: ",
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Color(0xFF212121),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsTable(BuildContext context, List<dynamic> orderDetails) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
                minHeight: constraints.minHeight,
                maxHeight: constraints.maxHeight.isFinite
                    ? constraints.maxHeight
                    : double.infinity,
              ),
              child: DataTable(
                columnSpacing: 16,
                // Set both min and max height to avoid conflicts
                dataRowMinHeight: 48, // Adjusted to avoid exceeding maxHeight
                dataRowMaxHeight: 60, // Allow flexibility up to 60
                headingRowColor: WidgetStateProperty.all(const Color(0xFFF5F6F5)),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                columns: const [
                  DataColumn(
                    label: Text(
                      'Item',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0288D1)),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Branch',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0288D1)),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Qty',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0288D1)),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'MRP',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0288D1)),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'GST',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0288D1)),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0288D1)),
                    ),
                  ),
                ],
                rows: orderDetails.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return DataRow(
                    color: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.hovered)) {
                        return const Color(0xFFE1F5FE).withOpacity(0.5);
                      }
                      return index % 2 == 0 ? Colors.white : Colors.grey[50];
                    }),
                    cells: [
                      DataCell(Text(item['item_name']?.toString() ?? '-', style: TextStyle(color: Colors.grey[700]))),
                      DataCell(Text(item['branch_name']?.toString() ?? '-', style: TextStyle(color: Colors.grey[700]))),
                      DataCell(Text(item['quantity']?.toString() ?? '0', style: TextStyle(color: Colors.grey[700]))),
                      DataCell(Text('₹${item['mrp']?.toString() ?? '0'}', style: TextStyle(color: Colors.grey[700]))),
                      DataCell(Text('${item['gst']?.toString() ?? '0'}%', style: TextStyle(color: Colors.grey[700]))),
                      DataCell(Text('₹${item['line_total']?.toString() ?? '0'}', style: TextStyle(color: Colors.grey[700]))),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }}