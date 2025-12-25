import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../constants.dart';
import '../Purchase/widgets/text/text_builder.dart';
import '../Home/Services/services.dart';

class Blog {
  final String title;
  final String imageUrl;
  final DateTime date;
  final String description;

  Blog({
    required this.title,
    required this.imageUrl,
    required this.date,
    required this.description,
  });
}

class BlogsScreen extends StatefulWidget {
  const BlogsScreen({super.key});

  @override
  _BlogsScreenState createState() => _BlogsScreenState();
}

class _BlogsScreenState extends State<BlogsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool isLoading = true;
  List<dynamic> blogs = []; // Declare a list to hold API data


  @override
  void initState() {
    super.initState();
    fetchserviceData();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  Future<void> fetchserviceData() async {

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print("Token: $token");

      final response = await http.get(
        Uri.parse(ApiRoutes.getBlog),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Verify that data is a Map and contains the expected keys
        if (data is Map<String, dynamic>) {
          setState(() {
            // services = data['services'] is List ? data['services'] : [];
            blogs = data['blog'];
            isLoading = false;
          });
        } else {
          print("Error: Invalid response format");
          // _showErrorDialog("Invalid response format from server");
        }
      } else {
        print(
          "Error: Failed to fetch data, status code: ${response.statusCode}",
        );
        // _showErrorDialog("Failed to fetch dashboard data");
        // Optionally call _showLoginDialog() if status code is 401 (Unauthorized)
        if (response.statusCode == 401) {}
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroud,
      // Ensure AppColors.background is defined
      body:  SingleChildScrollView(
        child: isLoading
            ? Container(
          height: MediaQuery.of(context).size.height*0.99,
          child: Center(
            child: CupertinoActivityIndicator(
              radius: 20,
              color: AppColors.primary,
            ),
          ),
        )
            : blogs.isNotEmpty
            ? GridView.builder(
          shrinkWrap: true,
          // Makes GridView take only the space it needs
          physics: const NeverScrollableScrollPhysics(),
          // Disable GridView scrolling
          padding: EdgeInsets.all(3.sp),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200.sp, // Maximum width for each item
            crossAxisSpacing: 0.sp,
            mainAxisSpacing: 0.sp,
            mainAxisExtent: 200.sp, // Explicit height for each grid item
          ),
          itemCount: blogs.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.all(0.sp),
              child: Card(
                elevation: 6,
                color: AppColors.backgroud,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => XRayAtHomeScreen(
                          title: blogs[index]['title'].toString(),
                          imageUrl: blogs[index]['photo_url'].toString(),
                          description: blogs[index]['short_description'].toString() , // Add description if available
                          description2: blogs[index]['description'].toString(), // Add description if available
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(5.0)),
                        child: CachedNetworkImage(
                          imageUrl: blogs[index]['photo_url'].toString(),
                          height: 120.sp,
                          width: double.infinity,
                          fit: BoxFit.fill,
                          placeholder: (context, url) => Container(
                            height: 120.sp,
                            color: Colors.grey[300],
                            child: Center(
                              child: CupertinoActivityIndicator(radius: 20, color: AppColors.primary),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 120.sp,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error, color: Colors.red),
                          ),
                          memCacheHeight: 200,
                          memCacheWidth: (MediaQuery.of(context).size.width * 0.8).toInt(),
                          fadeInDuration: const Duration(milliseconds: 300),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(8.sp),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                blogs[index]['title'].toString(),
                                style:TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        )
            : Center(
          child: TextBuilder(
            text: "No products available",
            fontSize: 16.sp,
            color: Colors.grey[800],
          ),
        ),
      ),

    );
  }
}
