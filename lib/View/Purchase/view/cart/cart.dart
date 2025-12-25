import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hospirent/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Widget/OrderPlacedSuccessfully/order_placed_successfully.dart';
import '../../../../main.dart';
import '../../../AddressScreen/add_address.dart';
import '../../../RentAcc/controller/rent_cart_provider.dart';
import '../../../RentAcc/widgets/card/rent_cart_card.dart';
import '../../controller/cart_provider.dart';
import '../../imports.dart';
import '../../widgets/app_name_widget.dart';
import '../../widgets/card/cart_card.dart';
import '../../widgets/text/text_builder.dart';
import '../drawer/drawer_menu.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Cart extends StatefulWidget {
  final String appBar;

  const Cart({super.key, required this.appBar});

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> with RouteAware {
  bool _isBuyCartSelected = false;
  final TextEditingController _couponController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  String? _selectedAddress;
  String? _selectedCoupon;
  String? _serviceType;
  String? _selectedDuration;
  String? _couponMessage;
  double _discount = 0.0;

  Future<void> _fetchCityState(
    String pin,
    TextEditingController stateController,
    TextEditingController cityController,
  ) async {
    try {
      final url = Uri.parse('https://api.postalpincode.in/pincode/$pin');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (data[0]['Status'] == 'Success') {
          final postOffice = data[0]['PostOffice'][0];
          stateController.text = postOffice['State'] ?? '';
          cityController.text = postOffice['District'] ?? '';
        }
      }
    } catch (e) {
      debugPrint('PIN fetch error: $e');
    }
  }

  void _applyCoupon() {
    setState(() {
      if (_couponController.text.isNotEmpty) {
        // Simple coupon validation (you can expand this logic)
        if (_couponController.text.toUpperCase() == 'SAVE10') {
          _discount = 0.1; // 10% discount
          _couponMessage = 'Coupon applied! 10% off';
        } else {
          _discount = 0.0;
          _couponMessage = 'Invalid coupon code';
        }
      } else {
        _discount = 0.0;
        _couponMessage = 'Please enter a coupon code';
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSelectedAddress();
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  // refresh when coming back
  @override
  void didPopNext() {
    _loadSelectedAddress();
    super.didPopNext();
  }

  // Load the saved address from SharedPreferences
  Future<void> _loadSelectedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedAddress = prefs.getString('selected_address');
    });
  }

  // Navigate to AddAddressScreen and update the selected address
  Future<void> _navigateToAddAddress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddAddressScreen()),
    );
    if (result != null) {
      setState(() {
        _selectedAddress = result as String;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartRent = Provider.of<RentCartProvider>(context);

    Size size = MediaQuery.sizeOf(context);
    double finalPrice = _isBuyCartSelected
        ? cart.totalPrice() * (1 - _discount)
        : cartRent.totalPrice() * (1 - _discount);

    print(cartRent);

    return Scaffold(
      resizeToAvoidBottomInset: true,

      backgroundColor: AppColors.backgroud,
      appBar: widget.appBar != ''
          ? AppBar(
              backgroundColor: AppColors.primary,
              iconTheme: const IconThemeData(color: Colors.white),
              title: const AppNameWidget(),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.sp),
                  bottomRight: Radius.circular(20.sp),
                ),
              ),
              leading: Builder(
                builder: (context) => Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.menu, color: Colors.white),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Container(
                    height: 25,
                    width: 25,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ],
            )
          : null,
      drawer: const DrawerMenu(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: cart.items.isEmpty && cartRent.itemsRent.isEmpty
                  ? Center(
                      child: AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(seconds: 1),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 100.sp,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 20.h),
                            TextBuilder(
                              text: 'Your Cart is Empty!',
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            SizedBox(height: 10.h),
                            TextBuilder(
                              text: 'Add some items to get started.',
                              fontSize: 16.sp,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 20.h),
                            MaterialButton(
                              color: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.sp),
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MainScreen(initialIndex: 0),
                                  ),
                                );
                              },
                              child: TextBuilder(
                                text: 'Shop Now',
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : (cart.items.isNotEmpty && _isBuyCartSelected) ||
                        cartRent.itemsRent.isEmpty
                  ? Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: MaterialButton(
                            height: 20.sp,
                            minWidth: size.width,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                            onPressed: () {
                              setState(() {
                                _isBuyCartSelected = true;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextBuilder(
                                  text: 'Buy Item'.toUpperCase(),
                                  color: AppColors.primary,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Stack(
                            children: [
                              ListView.separated(
                                padding: EdgeInsets.zero,
                                itemCount: cart.items.length,
                                shrinkWrap: true,
                                physics: const ScrollPhysics(),
                                itemBuilder: (BuildContext context, int i) {
                                  return Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: CartCard(cart: cart.items[i]),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                      return const SizedBox(height: 10.0);
                                    },
                              ),
                            ],
                          ),
                        ),
                        // Address Section
                        Container(
                          padding:  EdgeInsets.all(8.sp),

                          decoration: BoxDecoration(
                            // color: Colors.blue.shade100,
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(0.sp),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Delivery Address",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            // Navigate to AddAddressScreen and wait for result
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AddAddressScreen(),
                                              ),
                                            );

                                            // Update selectedAddress if result is valid
                                            if (result != null &&
                                                result is String) {
                                              setState(() {
                                                _selectedAddress = result;
                                              });
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            // Text/icon color
                                            backgroundColor: Colors.red,
                                            // Button background color
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(
                                                8.sp,
                                              ), // Rounded corners
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 5.sp,
                                              vertical: 2.sp,
                                            ),
                                            // Comfortable padding
                                            textStyle: TextStyle(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            minimumSize: const Size(100, 28),
                                            // Ensure sufficient touch area
                                            elevation:
                                            2, // Subtle shadow for depth
                                          ),
                                          child: Text(
                                            _selectedAddress == null
                                                ? "Add Address"
                                                : "Change Address",
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                            // White text for contrast
                                            semanticsLabel:
                                            _selectedAddress == null
                                                ? "Add new address"
                                                : "Change existing address", // Accessibility
                                          ),
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: _navigateToAddAddress,
                                      child: Container(
                                        padding: EdgeInsets.all(5.sp),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          color: Colors.grey.shade50,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              color: Colors.blue.shade900,
                                            ),
                                            SizedBox(width: 5.sp),
                                            Expanded(
                                              child: Text(
                                                _selectedAddress ??
                                                    "Select an address",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12.sp,
                                                  color:
                                                  _selectedAddress != null
                                                      ? Colors.black87
                                                      : Colors.grey.shade500,
                                                ),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Add other cart-related widgets here
                                  ],
                                ),
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0,bottom: 8),
                                    child: Text(
                                      "Billing Name",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.all(0.sp),
                                child: TextField(
                                  controller: _nameController,

                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey.shade200.withOpacity(
                                      0.9,
                                    ),
                                    // labelText: 'Phone Number',
                                    hintText: 'Enter your Name',
                                    labelStyle: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                      fontFamily: 'PoppinsSemiBold',
                                    ),

                                    hintStyle: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade500,
                                      fontFamily: 'Poppins-Medium',
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        12.sp,
                                      ),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        12.sp,
                                      ),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        12.sp,
                                      ),
                                      borderSide: BorderSide(
                                        color: AppColors.primary,
                                        width: 1,
                                      ),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.account_circle,
                                      color: Colors.grey.shade600,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 0.h,
                                      horizontal: 12.w,
                                    ),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                    fontFamily: 'Poppins-Medium',
                                  ),
                                ),
                              ),
                              // service_type
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0,bottom: 8),
                                    child: Text(
                                      "Service Type",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 0.w,
                                  vertical: 0.h,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: _serviceType,
                                        hint: Text(
                                          'Select Service Type',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8.sp,
                                            ),
                                          ),
                                        ),
                                        items: [
                                          DropdownMenuItem(
                                            value: 'MEDICAL EQUIPMENT',
                                            child: TextBuilder(
                                              text: 'MEDICAL EQUIPMENT',
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          DropdownMenuItem(
                                            value: 'NURSING',
                                            child: TextBuilder(
                                              text: 'NURSING',
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          DropdownMenuItem(
                                            value: 'AMBULANCE',
                                            child: TextBuilder(
                                              text: 'AMBULANCE',
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            _serviceType = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Coupon Section
                              // Padding(
                              //   padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                              //   child: Row(
                              //     children: [
                              //       Expanded(
                              //         child: DropdownButtonFormField<String>(
                              //           value: _selectedCoupon,
                              //           hint: Text('Select a coupon',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 14.sp),),
                              //           decoration: InputDecoration(
                              //             border: OutlineInputBorder(
                              //               borderRadius: BorderRadius.circular(8.sp),
                              //             ),
                              //           ),
                              //           items: [
                              //             DropdownMenuItem(
                              //               value: 'SAVE10',
                              //               child: TextBuilder(
                              //                 text: 'SAVE10 - 10% Off',
                              //                 fontSize: 14.sp,
                              //                 fontWeight: FontWeight.bold,
                              //               ),
                              //             ),
                              //             DropdownMenuItem(
                              //               value: 'SAVE20',
                              //               child: TextBuilder(
                              //                 text: 'SAVE20 - 20% Off',
                              //                 fontSize: 14.sp,
                              //                 fontWeight: FontWeight.bold,
                              //               ),
                              //             ),
                              //           ],
                              //           onChanged: (value) {
                              //             setState(() {
                              //               _selectedCoupon = value;
                              //               if (value == 'SAVE10') {
                              //                 _discount = 0.10;
                              //                 _couponMessage = '10% discount applied!';
                              //               } else if (value == 'SAVE20') {
                              //                 _discount = 0.20;
                              //                 _couponMessage = '20% discount applied!';
                              //               } else {
                              //                 _discount = 0.0;
                              //                 _couponMessage = null;
                              //               }
                              //             });
                              //           },
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              // if (_couponMessage != null)
                              //   Padding(
                              //     padding: EdgeInsets.symmetric(horizontal: 16.w),
                              //     child: TextBuilder(
                              //       text: _couponMessage!,
                              //       color: _discount > 0 ? Colors.green : Colors.red,
                              //       fontSize: 12.sp,
                              //     ),
                              //   ),
                              SizedBox(height: 20.sp),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: MaterialButton(
                                  elevation: 0,
                                  height: 40.sp,
                                  color: AppColors.primary,
                                  minWidth: size.width,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),

                                  onPressed: () async {
                                    final ScaffoldMessengerState
                                    messenger = ScaffoldMessenger.of(
                                      context,
                                    );

                                    if (_selectedAddress == null) {
                                      messenger.showSnackBar(
                                        SnackBar(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          backgroundColor:
                                          Theme.of(
                                            context,
                                          ).brightness ==
                                              Brightness.dark
                                              ? Colors.grey[800]
                                              : Colors.red,
                                          behavior: SnackBarBehavior
                                              .floating,
                                          content: TextBuilder(
                                            text:
                                            'Please select an address before placing the order.',
                                            color: Colors.white,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    if (_nameController.text == '') {
                                      messenger.showSnackBar(
                                        SnackBar(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          backgroundColor:
                                          Theme.of(
                                            context,
                                          ).brightness ==
                                              Brightness.dark
                                              ? Colors.grey[800]
                                              : Colors.red,
                                          behavior: SnackBarBehavior
                                              .floating,
                                          content: TextBuilder(
                                            text:
                                            'Please enter your name',
                                            color: Colors.white,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    if (_serviceType == null) {
                                      messenger.showSnackBar(
                                        SnackBar(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          backgroundColor:
                                          Theme.of(
                                            context,
                                          ).brightness ==
                                              Brightness.dark
                                              ? Colors.grey[800]
                                              : Colors.red,
                                          behavior: SnackBarBehavior
                                              .floating,
                                          content: TextBuilder(
                                            text:
                                            'Please select a service type.',
                                            color: Colors.white,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    // Show progress indicator
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return  Center(
                                          child:
                                          CupertinoActivityIndicator(
                                            radius: 20,
                                            color: AppColors.primary,
                                          ),
                                        );
                                      },
                                    );

                                    final Map<String, dynamic>
                                    payload = {
                                      "invoice": {
                                        "name": _nameController.text
                                            .trim(),
                                        "address": _selectedAddress,
                                        "gst_include": "EXCLUDE",
                                        "total_amount": cart
                                            .totalPrice(),
                                        "discount": 0,
                                        "service_type": _serviceType,
                                      },
                                      "products": cart.items
                                          .map(
                                            (item) => item.toJson(),
                                      )
                                          .toList(),
                                    };

                                    print('Payload: $payload');

                                    try {
                                      final prefs =
                                      await SharedPreferences.getInstance();
                                      final token = prefs.getString(
                                        'auth_token',
                                      );
                                      final response = await http
                                          .post(
                                        Uri.parse(
                                          ApiRoutes.buyOrderStore,
                                        ),
                                        headers: {
                                          'Content-Type':
                                          'application/json',
                                          'Authorization':
                                          'Bearer $token',
                                        },
                                        body: json.encode(
                                          payload,
                                        ),
                                      );

                                      Navigator.of(
                                        context,
                                      ).pop(); // Hide loading

                                      if (response.statusCode ==
                                          200) {
                                        cart.clearCart();
                                        cart.notifyListeners();

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                OrderSuccessScreen(),
                                          ),
                                        );
                                      } else {
                                        messenger.showSnackBar(
                                          SnackBar(
                                            content: TextBuilder(
                                              text:
                                              'Failed to place order. Try again.',
                                              color: Colors.white,
                                              fontSize: 14.sp,
                                            ),
                                            backgroundColor:
                                            Colors.red,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      Navigator.of(
                                        context,
                                      ).pop(); // Hide loading

                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: TextBuilder(
                                            text:
                                            'Something went wrong. Please check your connection.',
                                            color: Colors.white,
                                            fontSize: 14.sp,
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    height: 40.sp,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primary,
                                          AppColors.primary
                                              .withOpacity(0.8),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius:
                                      BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        TextBuilder(
                                          text:
                                          '₹ ${cart.totalPrice() * (1 - _discount)}',
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20.sp,
                                        ),
                                        const SizedBox(width: 10.0),
                                        TextBuilder(
                                          text: 'Pay Now',
                                          color: Colors.white,
                                          fontSize: 18.sp,
                                          fontWeight:
                                          FontWeight.normal,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),


                              SizedBox(height: 20.sp),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: MaterialButton(
                            height: 20.sp,
                            minWidth: size.width,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                            onPressed: () {
                              setState(() {
                                _isBuyCartSelected = false;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextBuilder(
                                  text: 'Rent Item'.toUpperCase(),
                                  color: AppColors.primary,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Stack(
                            children: [
                              ListView.separated(
                                padding: EdgeInsets.zero,
                                itemCount: cartRent.itemsRent.length,
                                shrinkWrap: true,
                                physics: const ScrollPhysics(),
                                itemBuilder: (BuildContext context, int i) {
                                  return Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: RentCartCard(
                                      cart: cartRent.itemsRent[i],
                                    ),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                      return const SizedBox(height: 10.0);
                                    },
                              ),
                            ],
                          ),
                        ),

                        // Address Section
                        Container(
                          padding:  EdgeInsets.all(8.sp),

                          decoration: BoxDecoration(
                            // color: Colors.blue.shade100,
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Column(
                            children: [

                              Padding(
                                padding: EdgeInsets.all(0.sp),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Delivery Address",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            // Navigate to AddAddressScreen and wait for result
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AddAddressScreen(),
                                              ),
                                            );

                                            // Update selectedAddress if result is valid
                                            if (result != null &&
                                                result is String) {
                                              setState(() {
                                                _selectedAddress = result;
                                              });
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            // Text/icon color
                                            backgroundColor: Colors.red,
                                            // Button background color
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(
                                                8.sp,
                                              ), // Rounded corners
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 5.sp,
                                              vertical: 2.sp,
                                            ),
                                            // Comfortable padding
                                            textStyle: TextStyle(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            minimumSize: const Size(100, 28),
                                            // Ensure sufficient touch area
                                            elevation:
                                            2, // Subtle shadow for depth
                                          ),
                                          child: Text(
                                            _selectedAddress == null
                                                ? "Add Address"
                                                : "Change Address",
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                            // White text for contrast
                                            semanticsLabel:
                                            _selectedAddress == null
                                                ? "Add new address"
                                                : "Change existing address", // Accessibility
                                          ),
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: _navigateToAddAddress,
                                      child: Container(
                                        padding: EdgeInsets.all(5.sp),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          color: Colors.grey.shade50,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              color: Colors.blue.shade900,
                                            ),
                                            SizedBox(width: 5.sp),
                                            Expanded(
                                              child: Text(
                                                _selectedAddress ??
                                                    "Select an address",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12.sp,
                                                  color:
                                                  _selectedAddress != null
                                                      ? Colors.black87
                                                      : Colors.grey.shade500,
                                                ),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Add other cart-related widgets here
                                  ],
                                ),
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0,bottom: 8),
                                    child: Text(
                                      "Billing Name",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.all(0.sp),
                                child: TextField(
                                  controller: _nameController,

                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey.shade200.withOpacity(
                                      0.9,
                                    ),
                                    // labelText: 'Phone Number',
                                    hintText: 'Enter your Name',
                                    labelStyle: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                      fontFamily: 'PoppinsSemiBold',
                                    ),

                                    hintStyle: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade500,
                                      fontFamily: 'Poppins-Medium',
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        12.sp,
                                      ),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        12.sp,
                                      ),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        12.sp,
                                      ),
                                      borderSide: BorderSide(
                                        color: AppColors.primary,
                                        width: 1,
                                      ),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.account_circle,
                                      color: Colors.grey.shade600,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 0.h,
                                      horizontal: 12.w,
                                    ),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                    fontFamily: 'Poppins-Medium',
                                  ),
                                ),
                              ),

                              // service_type
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0,bottom: 8),
                                    child: Text(
                                      "Service Type",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 0.w,
                                  vertical: 0.h,
                                ),
                                child: SizedBox(
                                  height: 40.sp,

                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          value: _serviceType,
                                          hint: Text(
                                            'Select Service Type',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(
                                                8.sp,
                                              ),
                                            ),
                                          ),
                                          items: [
                                            DropdownMenuItem(
                                              value: 'MEDICAL EQUIPMENT',
                                              child: TextBuilder(
                                                text: 'MEDICAL EQUIPMENT',
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            DropdownMenuItem(
                                              value: 'NURSING',
                                              child: TextBuilder(
                                                text: 'NURSING',
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            DropdownMenuItem(
                                              value: 'AMBULANCE',
                                              child: TextBuilder(
                                                text: 'AMBULANCE',
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                          onChanged: (value) {
                                            setState(() {
                                              _serviceType = value;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // duration
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 0.w,
                                  vertical: 8.h,
                                ),
                                child: SizedBox(
                                  height: 40.sp,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          value: _selectedDuration,
                                          hint: Text(
                                            'Select Duration',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(
                                                8.sp,
                                              ),
                                            ),
                                          ),
                                          items: [

                                            DropdownMenuItem(
                                              value: '30',
                                              child: TextBuilder(
                                                text: '30 Day',
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedDuration = value;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Coupon Section
                              // Padding(
                              //   padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                              //   child: Row(
                              //     children: [
                              //       Expanded(
                              //         child: DropdownButtonFormField<String>(
                              //           value: _selectedCoupon,
                              //           hint: Text('Select a coupon',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 14.sp),),
                              //           decoration: InputDecoration(
                              //             border: OutlineInputBorder(
                              //               borderRadius: BorderRadius.circular(8.sp),
                              //             ),
                              //           ),
                              //           items: [
                              //             DropdownMenuItem(
                              //               value: 'SAVE10',
                              //               child: TextBuilder(
                              //                 text: 'SAVE10 - 10% Off',
                              //                 fontSize: 14.sp,
                              //                 fontWeight: FontWeight.bold,
                              //               ),
                              //             ),
                              //             DropdownMenuItem(
                              //               value: 'SAVE20',
                              //               child: TextBuilder(
                              //                 text: 'SAVE20 - 20% Off',
                              //                 fontSize: 14.sp,
                              //                 fontWeight: FontWeight.bold,
                              //               ),
                              //             ),
                              //           ],
                              //           onChanged: (value) {
                              //             setState(() {
                              //               _selectedCoupon = value;
                              //               if (value == 'SAVE10') {
                              //                 _discount = 0.10;
                              //                 _couponMessage = '10% discount applied!';
                              //               } else if (value == 'SAVE20') {
                              //                 _discount = 0.20;
                              //                 _couponMessage = '20% discount applied!';
                              //               } else {
                              //                 _discount = 0.0;
                              //                 _couponMessage = null;
                              //               }
                              //             });
                              //           },
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              // if (_couponMessage != null)
                              //   Padding(
                              //     padding: EdgeInsets.symmetric(horizontal: 16.w),
                              //     child: TextBuilder(
                              //       text: _couponMessage!,
                              //       color: _discount > 0 ? Colors.green : Colors.red,
                              //       fontSize: 12.sp,
                              //     ),
                              //   ),
                              // SizedBox(height: 20.sp),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: MaterialButton(
                                  elevation: 0,
                                  height: 40.sp,
                                  color: AppColors.primary,
                                  minWidth: size.width,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),

                                  onPressed: () async {
                                    final ScaffoldMessengerState
                                    messenger = ScaffoldMessenger.of(
                                      context,
                                    );

                                    if (_selectedAddress == null) {
                                      messenger.showSnackBar(
                                        SnackBar(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          backgroundColor:
                                          Theme.of(
                                            context,
                                          ).brightness ==
                                              Brightness.dark
                                              ? Colors.grey[800]
                                              : Colors.red,
                                          behavior: SnackBarBehavior
                                              .floating,
                                          content: TextBuilder(
                                            text:
                                            'Please select an address before placing the order.',
                                            color: Colors.white,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    if (_nameController.text == '') {
                                      messenger.showSnackBar(
                                        SnackBar(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          backgroundColor:
                                          Theme.of(
                                            context,
                                          ).brightness ==
                                              Brightness.dark
                                              ? Colors.grey[800]
                                              : Colors.red,
                                          behavior: SnackBarBehavior
                                              .floating,
                                          content: TextBuilder(
                                            text:
                                            'Please enter your name',
                                            color: Colors.white,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    if (_serviceType == null) {
                                      messenger.showSnackBar(
                                        SnackBar(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          backgroundColor:
                                          Theme.of(
                                            context,
                                          ).brightness ==
                                              Brightness.dark
                                              ? Colors.grey[800]
                                              : Colors.red,
                                          behavior: SnackBarBehavior
                                              .floating,
                                          content: TextBuilder(
                                            text:
                                            'Please select a service type.',
                                            color: Colors.white,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    if (_selectedDuration == null) {
                                      messenger.showSnackBar(
                                        SnackBar(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          backgroundColor:
                                          Theme.of(
                                            context,
                                          ).brightness ==
                                              Brightness.dark
                                              ? Colors.grey[800]
                                              : Colors.red,
                                          behavior: SnackBarBehavior
                                              .floating,
                                          content: TextBuilder(
                                            text:
                                            'Please select a duration.',
                                            color: Colors.white,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    // Show progress indicator
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return  Center(
                                          child: CupertinoActivityIndicator(
                                            radius: 20,
                                            color: AppColors.primary,
                                          ),
                                        );
                                      },
                                    );

                                    final Map<String, dynamic>
                                    payload = {
                                      "invoice": {
                                        "name": _nameController.text,
                                        "address": _selectedAddress,
                                        "gst_include": "EXCLUDE",
                                        "total_amount": cartRent
                                            .totalPrice(),
                                        "discount": 0,
                                        "duration": _selectedDuration,
                                        "service_type": _serviceType,
                                      },
                                      "products": cartRent.itemsRent
                                          .map(
                                            (item) => item.toJson(),
                                      )
                                          .toList(),
                                    };

                                    try {
                                      final prefs =
                                      await SharedPreferences.getInstance();
                                      final token = prefs.getString(
                                        'auth_token',
                                      );
                                      final response = await http
                                          .post(
                                        Uri.parse(
                                          ApiRoutes
                                              .rentOrderStore,
                                        ),
                                        headers: {
                                          'Content-Type':
                                          'application/json',
                                          'Authorization':
                                          'Bearer $token',
                                        },
                                        body: json.encode(
                                          payload,
                                        ),
                                      );

                                      Navigator.of(
                                        context,
                                      ).pop(); // Hide loading

                                      if (response.statusCode ==
                                          200) {
                                        cartRent.clearCart();
                                        cartRent.notifyListeners();

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                OrderSuccessScreen(),
                                          ),
                                        );
                                      } else {
                                        messenger.showSnackBar(
                                          SnackBar(
                                            content: TextBuilder(
                                              text:
                                              'Failed to place order. Try again.',
                                              color: Colors.white,
                                              fontSize: 14.sp,
                                            ),
                                            backgroundColor:
                                            Colors.red,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      Navigator.of(
                                        context,
                                      ).pop(); // Hide loading

                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: TextBuilder(
                                            text:
                                            'Something went wrong. Please check your connection.',
                                            color: Colors.white,
                                            fontSize: 14.sp,
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    height: 40.sp,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primary,
                                          AppColors.primary
                                              .withOpacity(0.8),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius:
                                      BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        TextBuilder(
                                          text:
                                          '₹ ${cartRent.totalPrice() * (1 - _discount)}',
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20.sp,
                                        ),
                                        const SizedBox(width: 10.0),
                                        TextBuilder(
                                          text: 'Pay Now',
                                          color: Colors.white,
                                          fontSize: 18.sp,
                                          fontWeight:
                                          FontWeight.normal,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // SizedBox(height: 20.sp),
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
}
