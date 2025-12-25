import 'dart:convert';
import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hospirent/HexColor.dart';
import 'package:hospirent/constants.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import '../../Widget/Popup/Rent/rent.dart';
import '../Dialog/ambulance_booking.dart';
import '../Dialog/nursing.dart';
import '../Purchase/view/home/buy_product.dart';
import '../Rent/rent_product.dart';
import 'Services/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _scrollController = ScrollController();

  List<dynamic> categories = []; // Declare a list to hold API data
  List<dynamic> product = []; // Declare a list to hold API data
  List<dynamic> services = []; // Declare a list to hold API data
  List<dynamic> banner = []; // Declare a list to hold API data
  bool isLoading = true;


  final List<Map<String, dynamic>> topService = [
    {
      'name': 'All Purchase \nProducts',
      'icon': 'assets/allpurchase.png',
      'color': Colors.blue
    },
    {
      'name': 'All Rental \nServices',
      'icon': 'assets/allrentalservices.png',
      'color': Colors.pink
    },
    {
      'name': 'Book\nAmbulance',
      'icon': 'assets/ambulance.png',
      'color': Colors.green
    },
    {
      'name': 'Nursing\nStaff',
      'icon': 'assets/nursingstaff.png',
      'color': Colors.purple
    },
  ];
  final List<Map<String, dynamic>> services1 = [
    {'color': Colors.teal},
    {'color': Colors.teal},
    {'color': Colors.teal},
    {'color': Colors.teal},
    {'color': Colors.blue},
    {'color': Colors.pink},
    {'color': Colors.green},
    {'color': Colors.purple},
    {'color': Colors.orange},
    {'color': Colors.teal},
    {'color': Colors.teal},
    {'color': Colors.teal},
    {'color': Colors.teal},
    {'color': Colors.teal},
  ];
  final List<Map<String, dynamic>> countItem = [
    {
      'name': 'Nursing Staff',
      'count': '450+',
      'icon': 'assets/doc.png',
      'color': Colors.orangeAccent
    },
    {
      'name': 'Happy Patients',
      'count': '10000+',
      'icon': 'assets/patients.png',
      'color': Colors.blueGrey
    },
    {
      'name': 'Medical Equipments',
      'count': '700+',
      'icon': 'assets/patients.png',
      'color': Colors.redAccent
    },
    {
      'name': 'Years Of Experience',
      'count': '20+',
      'icon': 'assets/awards.png',
      'color': Colors.blueAccent
    },
  ];
  final List<Map<String, dynamic>> bottomService = [
    {
      'name': 'Largest Inventory',
      'icon': 'assets/chooseImg1.png',
      'color': Colors.orangeAccent.shade100
    },
    {
      'name': 'Genuine Products',
      'icon': 'assets/chooseImg2.png',
      'color': Colors.blueGrey.shade100
    },
    {
      'name': 'Patient Counselling',
      'icon': 'assets/chooseImg3.png',
      'color': Colors.brown.shade100
    },
    {
      'name': 'Rental Facility',
      'icon': 'assets/chooseImg4.png',
      'color': Colors.blueAccent.shade100
    },
    {
      'name': 'Pick-up Facility',
      'icon': 'assets/chooseImg5.png',
      'color': Colors.purple.shade100
    },
    {
      'name': 'Offers and Discounts',
      'icon': 'assets/chooseImg6.png',
      'color': Colors.pink.shade100
    },
  ];




  @override
  void initState() {
    super.initState();
    fetchDasboardData();
    fetchserviceData();
    fetchProductData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchDasboardData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print("Token: $token");

      final response = await http.get(
        Uri.parse(ApiRoutes.getDashboard),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Verify that data is a Map and contains the expected keys
        if (data is Map<String, dynamic>) {
          setState(() {
            // Use null-aware operators or provide default values
            categories = data['categories'] is List ? data['categories'] : [];
        // services = data['services'] is List ? data['services'] : [];
            // services = data['services'];
            banner = data['banners'] ?? []; // Adjust based on expected type of banner
            isLoading = false;

            print("Categories: $categories");
            print("Services: $services");
            print("Banner: $banner");
          });
        } else {
          print("Error: Invalid response format");
          // _showErrorDialog("Invalid response format from server");
        }
      } else {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const MaintenanceDialog(),
        );
        print(
            "Error: Failed to fetch data, status code: ${response.statusCode}");
        // _showErrorDialog("Failed to fetch dashboard data");
        // Optionally call _showLoginDialog() if status code is 401 (Unauthorized)
        if (response.statusCode == 401) {}
      }
    } catch (e) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const MaintenanceDialog(),
      );

      setState(() {
        isLoading = false;
      });
    }
  }
  Future<void> fetchserviceData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print("Token: $token");

      final response = await http.get(
        Uri.parse(ApiRoutes.getAllServices),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Verify that data is a Map and contains the expected keys
        if (data is Map<String, dynamic>) {
          setState(() {
            // services = data['services'] is List ? data['services'] : [];
            services = data['services'];
            isLoading = false;

            print("Services: $services");
          });
        } else {
          print("Error: Invalid response format");
          // _showErrorDialog("Invalid response format from server");
        }
      } else {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const MaintenanceDialog(),
        );
        print(
            "Error: Failed to fetch data, status code: ${response.statusCode}");
        // _showErrorDialog("Failed to fetch dashboard data");
        // Optionally call _showLoginDialog() if status code is 401 (Unauthorized)
        if (response.statusCode == 401) {}
      }
    } catch (e) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const MaintenanceDialog(),
      );

      setState(() {
        isLoading = false;
      });
    }
  }
  Future<void> fetchProductData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print("Token: $token");

      final response = await http.get(
        Uri.parse(ApiRoutes.getAllProducts),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Verify that data is a Map and contains the expected keys
        if (data is Map<String, dynamic>) {
          setState(() {
            // Use null-aware operators or provide default values
            product = data['products'] is List ? data['products'] : [];

            isLoading = false;

            print("Categories: $product");
          });
        } else {
          print("Error: Invalid response format");
          // _showErrorDialog("Invalid response format from server");
        }
      } else {
        print(
            "Error: Failed to fetch data, status code: ${response.statusCode}");
        // _showErrorDialog("Failed to fetch dashboard data");


        // Optionally call _showLoginDialog() if status code is 401 (Unauthorized)
        if (response.statusCode == 401) {}
      }
    } catch (e) {
      print("Error fetching dashboard data: $e");
      // _showErrorDialog("An error occurred while fetching data");
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.grey[200],
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: double.infinity,
                  height: 120.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ShimmerCard(),
                  ShimmerCard(),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ShimmerCard(),
                  ShimmerCard(),
                ],
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 150,
                    height: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(16),
                crossAxisSpacing: 8.w,
                mainAxisSpacing: 8.h,
                childAspectRatio: 0.85,
                children: List.generate(6, (index) => ShimmerGridCard()),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      // backgroundColor:  HexColor('c6d7eb'),
      backgroundColor:  Colors.grey.shade200,
      body: isLoading
          ? Center(
              child: CupertinoActivityIndicator(
                radius: 20,
                color: AppColors.primary,
              ),
            )
          : CustomScrollView(
              controller: _scrollController,
              slivers: [

                if(banner.isNotEmpty)
                SliverToBoxAdapter(
                  child:
                      _buildBannerSlider().animate().fadeIn(duration: 500.ms),
                ),

                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 8.h),
                  sliver: SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          EdgeInsets.all(2.w), // Inner padding for the card
                      child: CustomScrollView(
                        shrinkWrap: true,
                        // Prevents unbounded height issues
                        physics: NeverScrollableScrollPhysics(),
                        // Disables scrolling inside the card
                        slivers: [
                          SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 0.w,
                              mainAxisSpacing: 0.h,
                              childAspectRatio: 2.5,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _buildAllServiceItem(index),
                              childCount: topService.length,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Categories Section

                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.h),
                  sliver: SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          EdgeInsets.all(2.w), // Inner padding for the card
                      child: Card(
                        color: Colors.white,
                        child: CustomScrollView(
                          shrinkWrap: true,
                          // Prevents unbounded height issues
                          physics: NeverScrollableScrollPhysics(),
                          // Disables scrolling inside the card
                          slivers: [
                            SliverPadding(
                              padding:
                              EdgeInsets.symmetric(horizontal: 10.w, vertical: 13.h),
                              sliver: SliverToBoxAdapter(
                                child: _buildSectionTitle('EXPLORE CATEGORIES'),
                              ),
                            ),
                            SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                    crossAxisSpacing: 0.0,
                                    mainAxisSpacing: 0.0,
                                childAspectRatio: .7,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => _buildCategoryItem(index),
                                childCount: categories.length,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Services Section


                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 10.h),
                  sliver: SliverToBoxAdapter(
                    child: Padding(
                      padding:
                      EdgeInsets.all(2.w), // Inner padding for the card
                      child: Card(
                        color: Colors.white,
                        child: CustomScrollView(
                          shrinkWrap: true,
                          // Prevents unbounded height issues
                          physics: NeverScrollableScrollPhysics(),
                          // Disables scrolling inside the card
                          slivers: [

                            SliverPadding(
                              padding:
                              EdgeInsets.symmetric(horizontal: 10.w, vertical: 13.h),
                              sliver: SliverToBoxAdapter(
                                child: _buildSectionTitle('Our Services'),
                              ),
                            ),
                            SliverGrid(
                              gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8.w,
                                mainAxisSpacing: 8.h,
                                childAspectRatio: 0.75,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                    (context, index) => _buildServiceItem(index),
                                childCount: services.length,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),


                SliverPadding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 0.w, vertical: 20.h),
                  sliver: SliverToBoxAdapter(
                    child: Card(
                      color: Colors.grey.shade300,
                      margin: EdgeInsets.zero,
                      elevation: 4,
                      // Adjust elevation for shadow
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(0.r), // Rounded corners
                      ),
                      child: Padding(
                        padding:
                            EdgeInsets.all(0.w), // Inner padding for the card
                        child: CustomScrollView(
                          shrinkWrap: true,
                          // Prevents unbounded height issues
                          physics: NeverScrollableScrollPhysics(),
                          // Disables scrolling inside the card
                          slivers: [
                            SliverPadding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 10.h),
                              sliver: SliverToBoxAdapter(
                                child: Center(
                                    child: _buildSectionTitle(
                                        'Featured Products')),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Stack(
                                children: [
                                  SizedBox(
                                    height: 100.h,
                                    // Adjust height based on your item size
                                    child: Row(
                                      children: [
                                        // Left Arrow Button
                                        // Horizontal ListView
                                        Expanded(
                                          child: ListView.builder(
                                            controller: _scrollController,
                                            // Attach ScrollController
                                            scrollDirection: Axis.horizontal,
                                            itemCount: product.length,
                                            itemBuilder: (context, index) =>
                                                Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 4.w),
                                              // Mimics mainAxisSpacing
                                              child: _buildProductItem(index),
                                            ),
                                          ),
                                        ),
                                        // Right Arrow Button
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 0.sp,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.arrow_back_ios,
                                              size: 30.w),
                                          onPressed: () {
                                            // Scroll left
                                            _scrollController.animateTo(
                                              _scrollController.offset - 100.0,
                                              // Adjust scroll distance
                                              duration:
                                                  Duration(milliseconds: 300),
                                              curve: Curves.easeInOut,
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(
                                              Icons.arrow_forward_ios_outlined,
                                              size: 30.w),
                                          onPressed: () {
                                            // Scroll right
                                            _scrollController.animateTo(
                                              _scrollController.offset + 100.0,
                                              // Adjust scroll distance
                                              duration:
                                                  Duration(milliseconds: 300),
                                              curve: Curves.easeInOut,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 8.h),
                  sliver: SliverToBoxAdapter(
                    child: Card(
                      color: HexColor('320d3e').withOpacity(0.7),
                      margin: EdgeInsets.zero,
                      elevation: 4,
                      // Adjust elevation for shadow
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(0.r), // Rounded corners
                      ),
                      child: Padding(
                        padding:
                            EdgeInsets.all(2.w), // Inner padding for the card
                        child: CustomScrollView(
                          shrinkWrap: true,
                          // Prevents unbounded height issues
                          physics: NeverScrollableScrollPhysics(),
                          // Disables scrolling inside the card
                          slivers: [
                            SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 0.w,
                                mainAxisSpacing: 0.h,
                                childAspectRatio: 1.2,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => _buildAllCountItem(index),
                                childCount: countItem.length,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),




                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 8.h),
                  sliver: SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          EdgeInsets.all(2.w), // Inner padding for the card
                      child: CustomScrollView(
                        shrinkWrap: true,
                        // Prevents unbounded height issues
                        physics: NeverScrollableScrollPhysics(),
                        // Disables scrolling inside the card
                        slivers: [
                          SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              crossAxisSpacing: 0.w,
                              mainAxisSpacing: 0.h,
                              childAspectRatio: 4,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _buildAllBottomItem(index),
                              childCount: bottomService.length,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 30.h)),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Transform.rotate(
            angle: 45 * 3.1415926535 / 180, // Convert degrees to radians
            child: Icon(
              Icons.square,
              size: 12.sp,
              color: Colors.blue,
            ),
          ),
        ),

        Text(
          title.toUpperCase(),
          style: GoogleFonts.openSans(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color:HexColor('#1F2937'),
          ),

        ).animate().slideX(
              begin: -0.2,
              end: 0,
              duration: 500.ms,
              curve: Curves.easeOutCubic,
            ),
      ],
    );
  }

  Widget _buildBannerSlider() {
    return Column(
      children: [
        SizedBox(height: 3.h),
        CarouselSlider.builder(
          itemCount: banner.length,
          options: CarouselOptions(
            height: 120.h,
            autoPlay: true,
            enlargeCenterPage: true,
            aspectRatio: 16 / 9,
            autoPlayInterval: 5.seconds,
            viewportFraction: 0.99,
            onPageChanged: (index, reason) {
              setState(() => _currentIndex = index);
            },
          ),
          itemBuilder: (context, index, realIndex) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 0.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      banner[index]['image_url']!,
                      fit: BoxFit.fill,
                      frameBuilder:
                          (context, child, frame, wasSynchronouslyLoaded) {
                        if (wasSynchronouslyLoaded) {
                          return child; // Image is already loaded
                        }
                        return frame != null
                            ? child // Image loaded successfully
                            : const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                      Color(0xFFBBDEFB)), // Colors.blue[200]
                                ),
                              );
                      },
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.broken_image,
                        size: 40.sp,
                        // Assuming you're using a package like flutter_screenutil for .sp
                        color: Colors.grey[300],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            banner.length,
            (index) => AnimatedContainer(
              duration: 300.ms,
              width: _currentIndex == index ? 15.w : 8.w,
              height: 4.h,
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                color: _currentIndex == index
                    ? Colors.blue[800]
                    : Colors.grey[400],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(int index) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(0.5),
          // Semi-transparent overlay
          builder: (BuildContext context) {
            return StylishPopup(
              id: categories[index]['id'],
              catIndex: index,
              catImage:categories[index]['image_url'],
              catName: categories[index]['title'],
            );
          },
        );
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Column(
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Container(
              decoration: BoxDecoration(
                // color: HexColor('#c3d0db'),
                color: HexColor('#E1E7ED'),
                borderRadius: BorderRadius.circular(12.r),
                // gradient: LinearGradient(
                //   colors: [
                //     categories1[index]['color'].withOpacity(0.1),
                //     Colors.white,
                //   ],
                //   begin: Alignment.topLeft,
                //   end: Alignment.bottomRight,
                // ),
              ),
              child: Padding(
                padding: EdgeInsets.all(2.sp),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100.sp,
                      height: 100.sp,
                      padding: EdgeInsets.all(0.sp),
                      // decoration: BoxDecoration(
                      //   color: Colors.white30,
                      //   shape: BoxShape.circle,
                      // ),
                      child: CachedNetworkImage(
                        imageUrl: categories[index]['image_url'],
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            // valueColor:
                            // AlwaysStoppedAnimation(categories1[index]['color']),
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.error_outline,
                          color: categories[index]['color'],
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ).animate().scaleXY(
            begin: 0.8,
            end: 1,
            duration: 500.ms,
            delay: (100 * index).ms,
            curve: Curves.easeOutBack,
          ),

          Expanded(
            child: Center(
              child: Padding(
                padding:  EdgeInsets.only(left:20.sp,right: 20.sp),
                child: Text(
                  categories[index]['title'],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: HexColor('#1F2937'),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );



  }

  Widget _buildAllServiceItem(int index) {
    return InkWell(
      onTap: () {
        if (index == 0) {

          Navigator.push(context, MaterialPageRoute(builder: (_) => BuyProduct(id: 0, catIndex: 0,)));


        }else if(index==1){

          Navigator.push(context, MaterialPageRoute(builder: (_) => RentProduct(id: 0, catIndex: 0,)));


        } else if(index==3){
          showDialog(
            context: context,
            builder: (context) => const NursingStaffForm(),
          );
        }else if(index==2){
          showDialog(
            context: context,
            builder: (context) => const AmbulanceBookingForm(),
          );
        }

        // Handle category tap
        // _showSnackBar('Selected: ${categories[index]['name']}');
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Card(
              // elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: EdgeInsets.all(2.sp),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 1.sp,
                      ),
                      Container(
                        width: 40.sp,
                        height: 40.sp,
                        padding: EdgeInsets.all(2.sp),
                        child: Image.asset(
                          topService[index]['icon'].toString(),
                          // fit: BoxFit.contain, // Ensure the image fits within the container
                        ),
                      ),
                      SizedBox(
                        width: 5.sp,
                      ),
                      Expanded(
                        // Use Expanded to constrain the Text widget
                        child: Text(
                          topService[index]['name'].toString().toUpperCase(),
                          textAlign: TextAlign.start,
                          style: GoogleFonts.openSans(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w900,
                            color: HexColor('#1F2937'),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,

                        ),
                      ),
                    ],
                  ),
                ),
              )).animate().scaleXY(
            begin: 0.8,
            end: 1,
            duration: 500.ms,
            delay: (100 * index).ms,
            curve: Curves.easeOutBack,
          ),
    );
  }

  Widget _buildAllBottomItem(int index) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(0.r),
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0.r),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0.r),
            // gradient: LinearGradient(
            //   colors: [
            //     bottomService[index]['color'],
            //   Colors.white,
            //   ],
            //   begin: Alignment.topCenter,
            //   end: Alignment.bottomCenter,
            // ),
          ),
          child: Padding(
            padding: EdgeInsets.all(5.sp),
            child: Row(
              children: [
                Container(
                  width: 50.sp,
                  height: 50.sp,
                  padding: EdgeInsets.all(5.sp),
                  child: Image.asset(
                    bottomService[index]['icon'].toString(),
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(width: 20.h),
                Expanded(
                  child: Text(
                    bottomService[index]['name'].toString().toUpperCase(),
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                      fontFamily: 'PoppinsBold',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 600.ms,
          delay:
              (300 * index).ms, // Increased delay for clear sequential effect
          curve: Curves.easeOut,
        )
        .slideY(
          begin: 0.2,
          // Slight slide from below
          end: 0.0,
          duration: 600.ms,
          delay: (300 * index).ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildAllCountItem(int index) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(0.r),
      child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  gradient: LinearGradient(
                    colors: [
                      countItem[index]['color'].withOpacity(0.1),
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10.sp),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // SizedBox(width: 8.h),
                      Expanded(
                        // Use Expanded to constrain the Text widget
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 50.sp,
                              height: 50.sp,
                              padding: EdgeInsets.all(0.sp),
                              child: Image.asset(
                                countItem[index]['icon'].toString(),
                                fit: BoxFit
                                    .contain, // Ensure the image fits within the container
                              ),
                            ),
                            SizedBox(
                              height: 5.sp,
                            ),

                            Text(
                              countItem[index]['count']
                                  .toString()
                                  .toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                                fontFamily: 'PoppinsBold',
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              countItem[index]['name'].toString().toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                                fontFamily: 'PoppinsBold',
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )).animate().scaleXY(
            begin: 0.8,
            end: 1,
            duration: 500.ms,
            delay: (100 * index).ms,
            curve: Curves.easeOutBack,
          ),
    );
  }


  Widget _buildServiceItem(int index) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => XRayAtHomeScreen(
              title: services[index]['title'],
              imageUrl: services[index]['image_url'],
              description: services[index]['description'].toString() , // Add description if available
              description2: services[index]['description2'].toString(), // Add description if available
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Column(
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: HexColor('#c3d0db'),
                borderRadius: BorderRadius.circular(12.r),
                // gradient: LinearGradient(
                //   colors: [
                //     categories1[index]['color'].withOpacity(0.1),
                //     Colors.white,
                //   ],
                //   begin: Alignment.topLeft,
                //   end: Alignment.bottomRight,
                // ),
              ),
              child: Padding(
                padding: EdgeInsets.all(2.sp),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100.sp,
                      height: 100.sp,
                      padding: EdgeInsets.all(2.sp),
                      // decoration: BoxDecoration(
                      //   color: Colors.white30,
                      //   shape: BoxShape.circle,
                      // ),
                      child: CachedNetworkImage(
                        imageUrl: services[index]['icon_url'],
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.error_outline,
                          color: categories[index]['color'],
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ).animate().scaleXY(
            begin: 0.8,
            end: 1,
            duration: 500.ms,
            delay: (100 * index).ms,
            curve: Curves.easeOutBack,
          ),

          Expanded(
            child: Center(
              child: Padding(
                padding:  EdgeInsets.only(left:13.sp,right: 13.sp),
                child: Text(
                  services[index]['title'].toString(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: HexColor('#1F2937'),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );



  }


  Widget _buildProductItem(int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        width: 130.sp,
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(16.r),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: CachedNetworkImage(
                  imageUrl: product[index]['first_image'].toString(),
                  fit: BoxFit.fill,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.blue),
                    ),
                  ),
                  errorWidget: (context, url, error) => Image.asset('assets/no_image.jpg'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.45,
          height: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                color: Colors.white,
              ),
              SizedBox(height: 4),
              Container(
                width: 60,
                height: 12,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShimmerGridCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                color: Colors.white,
              ),
              SizedBox(height: 8),
              Container(
                width: 80,
                height: 12,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}








class MaintenanceDialog extends StatelessWidget {
  const MaintenanceDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop(); // Close the app fully
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0E21),
        body: Stack(
          children: [
            // 🔹 Background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0A0E21), Color(0xFF1B1E3C), Color(0xFF0A0E21)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // 🔹 Floating glow orbs
            Positioned(
              top: -50,
              left: -30,
              child: _glowCircle(Colors.blueAccent.withOpacity(0.3), 180),
            ),
            Positioned(
              bottom: -60,
              right: -40,
              child: _glowCircle(Colors.purpleAccent.withOpacity(0.25), 220),
            ),

            // 🔹 Glass effect card
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(
                    width: 330.w,
                    padding: EdgeInsets.all(15.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.r),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.08),
                          Colors.white.withOpacity(0.02),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.2),
                          blurRadius: 25,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Lottie Animation
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Lottie.asset(
                            'assets/appdevp.json',
                            height: 100.sp,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: 5.h),

                        // 🔹 App name
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF00C6FF), Color(0xFF6A5AE0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Text(
                            'Hospirent',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ),

                        SizedBox(height: 2.h),

                        // 🔹 Maintenance title
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF6A5AE0), Color(0xFF00C6FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Text(
                            'Currently Under Maintenance 🔧',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        SizedBox(height: 10.h),

                        // 🔹 Description
                        Text(
                          'We’re improving your experience.\n'
                              'Please be patient — everything will be fixed\n'
                              'within the next 2 hours 🚀',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.white.withOpacity(0.85),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 10.h),

                        // 🔹 Progress pulse bar
                        Container(
                          height: 10.h,
                          width: 180.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.r),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00C6FF), Color(0xFF6A5AE0)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.r),

                            child: const LinearProgressIndicator(
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),

                        SizedBox(height: 20.h),

                        // 🔹 Button (non-clickable)
                        ElevatedButton(
                          onPressed: () {
                            SystemNavigator.pop(); // Close the app fully

                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C6FF),
                            foregroundColor: Colors.white,
                            elevation: 6,
                            shadowColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 25.w,
                              vertical: 5.h,
                            ),
                          ),
                          child: Text(
                            'App in Maintenance Mode',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Glow decoration
  Widget _glowCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 120,
            spreadRadius: 40,
          ),
        ],
      ),
    );
  }
}


