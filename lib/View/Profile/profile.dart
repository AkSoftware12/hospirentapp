import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hospirent/View/Auth/LoginNew/Login/login.dart';
import 'package:hospirent/View/Profile/update_profile.dart';
import 'package:hospirent/View/PurchaseItem/purchase.dart';
import 'package:hospirent/View/RentAcc/controller/rent_cart_provider.dart';
import 'package:hospirent/constants.dart';
import 'package:hospirent/main.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Purchase/controller/cart_provider.dart';
import '../Purchase/view/drawer/drawer_menu.dart';
import '../Purchase/widgets/app_name_widget.dart';
import '../Purchase/widgets/text/text_builder.dart';
import '../DrawerScreen/ContactUs.dart';
import '../DrawerScreen/privacy.dart';
import '../DrawerScreen/terms.dart';
import '../MyRentService/my_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class ProfileScreen extends StatefulWidget {
  final String appBar;

  const ProfileScreen({super.key, required this.appBar});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late List<Animation<Offset>> _slideAnimations;
  bool _isDarkMode = false;
  Map<String, dynamic>? studentData;
  bool isLoading = true;
  bool _isLoggingOut = false;


  @override
  void initState() {
    super.initState();
    fetchProfileData();
    // Initialize animations
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Fix: Adjusted interval calculation to ensure end <= 1.0
    _slideAnimations = List.generate(
      6,
          (index) => Tween<Offset>(
        begin: const Offset(0.5, 0.0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            (index / 6), // Start: Spread evenly from 0.0 to 0.833
            (index / 6) + (1.0 - index / 6) * 0.8, // End: Max at 1.0
            curve: Curves.easeInOut,
          ),
        ),
      ),
    );




    _controller.forward();
  }

  Future<void> fetchProfileData() async {

    try{
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      print("token: $token");

      if (token == null) {
        isLoading = false;
        // _showLoginDialog();
        return; // Exit the function early if token is null
      }

      final response = await http.get(
        Uri.parse(ApiRoutes.getProfile),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          studentData = data['user'];
          isLoading = false;
        });
      } else {
        // Handle error response, e.g., show login dialog or error message
        // _showLoginDialog();
      }
    }catch (e) {
      setState(() {
        isLoading = false;
      });
    }

  }

  void _refresh() {
    setState(() {
      fetchProfileData();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    print("ProfileScreen build called");
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,

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
            padding: EdgeInsets.all(8.0), // Adjust padding as needed
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white24, // Set grey background for drawer icon
                shape: BoxShape.circle, // Optional: makes the background circular
              ),
              child: IconButton(
                icon: Icon(Icons.menu, color: Colors.white), // Drawer icon
                onPressed: () {
                  Scaffold.of(context).openDrawer(); // Opens the drawer
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
                  shape: BoxShape.circle, color: Colors.black),
              child: TextBuilder(
                text: cart.itemCount.toString(),
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 10,
              ),
            ),
          ),
        ],
      )
          : null,
      drawer: const DrawerMenu(),
      body: Column(
        children: [
          // Header section
          Container(
            height: screenSize.height * 0.15,
            child: _buildHeader(context, screenSize, theme),
          ),
          // ListView
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: 5, // 6 tiles + 1 logout button
              itemBuilder: (context, index) {

                final tileData = [
                  {
                    'title': 'My Purchase Orders',
                    'subtitle': '',
                    'icon': Iconsax.shopping_bag,
                    'iconColor': Colors.pink,
                    'onTap': (){
                      Navigator.push(context, MaterialPageRoute(builder: (_) =>  PurchaseOrdersScreen()));

                    },
                  },
                  // {
                  //   'title': 'Shipping Addresses',
                  //   'subtitle': '3 saved locations',
                  //   'icon': Iconsax.location,
                  //   'iconColor': Colors.teal,
                  //   'onTap': () {
                  //
                  //   }
                  // },
                  {
                    'title': 'My Rental Services',
                    'subtitle': '',
                    'icon': Icons.card_travel,
                    'iconColor': Colors.purple,
                    'onTap': () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) =>  MyServiceScreen()));

                    },
                  },
                  {
                    'title': 'Terms & Conditions',
                    'subtitle': '',
                    'icon':  Icons.description,
                    'iconColor': Colors.orange,
                    'onTap': () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TermsAndConditionsScreen(
                            lastUpdated: 'May 27, 2025',
                            version: '1.0.0',
                            sections:[
                              {
                                "title": "1. Introduction",
                                "content": "Welcome to our application. By using our services, you agree to these Terms and Conditions. Please read them carefully. These terms govern your access to and use of our platform, including any content, functionality, and services offered."
                              },
                              {
                                "title": "2. User Responsibilities",
                                "content": "You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account. You must notify us immediately of any unauthorized use of your account."
                              },
                              {
                                "title": "3. Prohibited Activities",
                                "content": "You may not use our services for any illegal or unauthorized purpose. This includes, but is not limited to, violating any applicable laws, transmitting harmful code, or engaging in activities that interfere with the operation of our services."
                              },
                              {
                                "title": "4. Intellectual Property",
                                "content": "All content provided through our services, including text, graphics, logos, and software, is the property of the company or its licensors and is protected by intellectual property laws. You may not reproduce, distribute, or create derivative works without permission."
                              },
                              {
                                "title": "5. Termination",
                                "content": "We reserve the right to terminate or suspend your account at our sole discretion, without prior notice, for conduct that we believe violates these Terms or is harmful to other users or third parties."
                              },
                              {
                                "title": "6. Rental Service and Non-Refundable Policy",
                                "content": "Our application offers a rental service for products such as furniture, equipment, or vehicles ('Rental Products'). By renting products through our platform, you agree to the following conditions, including a strict non-refundable policy for all payments: 1. All rental payments, including fees and deposits, are non-refundable unless otherwise stated in writing by us. 2. You must provide valid identification (e.g., Aadhaar, passport, or driver’s license) at the time of booking, which will be verified before product delivery. 3. A refundable security deposit is required, which will be returned within 7-10 business days after the rental period, subject to a quality check confirming no damage to the product. 4. You are responsible for returning the Rental Product in the same condition as received, excluding normal wear and tear; any damage will result in deduction from the security deposit. 5. The minimum rental period is three months, and early termination does not entitle you to a refund of rental fees. 6. You must not sublet, transfer, or allow unauthorized use of the Rental Product by third parties. 7. Products must be used only for their intended purpose and in compliance with all applicable laws and regulations. 8. Late returns will incur a penalty fee of 10% of the daily rental rate per day, deducted from the security deposit. 9. You are responsible for any additional costs, such as cleaning fees (minimum INR 200) if the product is returned in poor condition, or repair costs for damages caused by misuse. 10. We reserve the right to cancel your rental booking if you fail to meet eligibility requirements (e.g., valid ID, payment, or credit check), with no refund of any prepaid amounts. 11. Delivery and pickup of Rental Products are subject to availability and may incur additional fees if your location lacks elevator access or requires special handling. 12. You must notify us at least 48 hours in advance for any changes to the rental agreement, such as extending the rental period; failure to do so may result in additional charges or forfeiture of the rental. These terms ensure a fair and efficient rental process for all users."
                              },
                              {
                                "title": "7. Payment Terms",
                                "content": "All payments for rental services must be made through the approved payment methods on our platform. You agree to provide accurate billing information and authorize us to charge the specified amounts. Late payments may result in additional fees or suspension of services."
                              },
                              {
                                "title": "8. Limitation of Liability",
                                "content": "To the fullest extent permitted by law, we are not liable for any indirect, incidental, or consequential damages arising from your use of our services, including loss of profits, data, or property damage, even if advised of the possibility of such damages."
                              },
                              {
                                "title": "9. Privacy Policy",
                                "content": "We collect and process personal information in accordance with our Privacy Policy. By using our services, you consent to the collection, use, and sharing of your data as outlined therein, including for verification and service delivery purposes."
                              },
                              {
                                "title": "10. Governing Law",
                                "content": "These Terms and Conditions are governed by the laws of India. Any disputes arising under these terms will be subject to the exclusive jurisdiction of the courts located in [Your City], India."
                              }
                            ],

                          ),
                        ),
                      );

                    },
                  },
                  {
                    'title': 'Privacy Policy',
                    'subtitle': '',
                    'icon': Icons.privacy_tip,
                    'iconColor': Colors.amber,
                    'onTap': () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) =>  PrivacyPage()));

                    },                  },
                  {
                    'title': 'Contact Us',
                    'subtitle': '',
                    'icon': Icons.contact_mail,
                    'iconColor': Colors.blue,
                    'onTap': () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ContactUsPage()));
                    }
                  },
                ];
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimations[index],
                    child: _buildAnimatedListTile(
                      context,
                      title: tileData[index]['title'] as String,
                      subtitle: tileData[index]['subtitle'] as String,
                      icon: tileData[index]['icon'] as IconData,
                      iconColor: tileData[index]['iconColor'] as Color,
                      slideAnimation: _slideAnimations[index],
                      onTap: tileData[index]['onTap'] as VoidCallback,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 20.h),
        child:SizedBox(
          height: 35.sp,
          child: FloatingActionButton.extended(
            backgroundColor: Colors.red,
            icon: Icon(Icons.logout, color: Colors.white, size: 15.sp),
            label: Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
            ),
            onPressed: () async {
              _showLogoutDialog(context);

            },
          ),
        ),

      ),



    );
  }

  Future<void> _handleLogout() async {
    setState(() {
      _isLoggingOut = true; // loader show
    });

    // 🔥 Clear Provider FIRST
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final cartProviderRent = Provider.of<RentCartProvider>(context, listen: false);
    cartProvider.clearCart();
    cartProviderRent.clearCart();

    // Optional delay (UI ke liye)
    await Future.delayed(const Duration(seconds: 2));

    // 🔥 Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    // 🔥 Navigate to Login (replace stack)
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreenNew()),
          (route) => false,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.transparent,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout, size: 50, color: AppColors.primary),
                    const SizedBox(height: 20),
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color:  AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Are you sure you want to logout?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _isLoggingOut
                              ? null
                              : () async {
                            setState(() => _isLoggingOut = true);
                            await _handleLogout();
                            setState(() => _isLoggingOut = false);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:  AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: _isLoggingOut
                              ? SizedBox(
                            height: 20,
                            width: 20,
                            child:  CupertinoActivityIndicator(
                              radius: 10,
                              color: AppColors.primary,
                            ),
                          )
                              : const Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  Widget _buildHeader(BuildContext context, Size screenSize, ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              Hero(
                tag: 'profile-avatar',
                child: GestureDetector(
                  // onTap: () => _showAvatarZoom(context),
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(3),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: studentData?['picture_data']??'',
                          memCacheHeight: 200,
                          memCacheWidth: 200,
                          placeholder: (context, url) => CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Iconsax.user,
                            size: 30,
                            color: Colors.black,
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 50.sp,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ProfileUpdatePage(
                              onReturn: _refresh);
                        },
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.indigo.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Iconsax.edit,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
           SizedBox(width: 25.sp),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${studentData?['name']??'User'}",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "${studentData?['contact']??'+919999999999'}",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 11.sp,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  studentData?['email'] ??'testing@gmail.com',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildAnimatedListTile(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color iconColor,
        required Animation<Offset> slideAnimation,
        required VoidCallback onTap,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        borderRadius: BorderRadius.circular(15),
        color: _isDarkMode ? Colors.grey[800] : Colors.white,
        elevation: 2,
        shadowColor: _isDarkMode ? Colors.black : Colors.grey.withOpacity(0.2),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          splashColor: Colors.indigo.withOpacity(0.2),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: _isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Iconsax.arrow_circle_right,
                  color: Colors.indigo,
                  size: 25,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}