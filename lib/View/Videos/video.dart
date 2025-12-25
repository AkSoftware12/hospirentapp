import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hospirent/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Purchase/imports.dart';
import '../Purchase/widgets/text/text_builder.dart';

class Video {
  final String title;
  final String imageUrl;
  final String link;
  final String description;

  Video({
    required this.title,
    required this.imageUrl,
    required this.link,
    required this.description,
  });
}

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> with SingleTickerProviderStateMixin {
  bool isLoading = true;
  List<dynamic> videos = [];

  @override
  void initState() {
    super.initState();
    fetchVideoData();
  }

  Future<void> fetchVideoData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print("Token: $token");

      final response = await http.get(
        Uri.parse(ApiRoutes.getVideo),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          setState(() {
            videos = data['video'] is List ? data['video'] : [];
            isLoading = false;

            print('$videos'.toString());
          });
        } else {
          print("Error: Invalid response format");
        }
      } else {
        print("Error: Failed to fetch data, status code: ${response.statusCode}");
        if (response.statusCode == 401) {}
      }
    } catch (e) {
      print("Error fetching dashboard data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void openYouTube(String url) async {
    final Uri uri = Uri.parse(url);

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication, // YouTube App open
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroud,
      body: SingleChildScrollView(
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
            : videos.isNotEmpty
            ? GridView.builder(
          padding: EdgeInsets.all(3.sp),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 185.sp,
            crossAxisSpacing: 0.sp,
            mainAxisSpacing: 0.sp,
            mainAxisExtent: 185.sp,
          ),
          itemCount: videos.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            // // Create a Video object from the map
            // final video = Video(
            //   title: videos[index]['title'].toString(),
            //   imageUrl: videos[index]['photo_url'].toString(),
            //   link: videos[index]['link'].toString(),
            //   description: videos[index]['description'].toString(),
            // );

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
                    // String videoUrl = videos[index]["link"].toString();  // API से आए Google/Youtube URL
                    openYouTube(videos[index]["link"].toString());
                  },

                  // onTap: () {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (_) => YoutubePlayerDemoApp(video: videos, playlist: videos, count: index,),
                  //     ),
                  //   );
                  // },
                  borderRadius: BorderRadius.circular(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(5.0)),
                        child: CachedNetworkImage(
                          imageUrl: videos[index]['photo_url'].toString(),
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
                                videos[index]['title'].toString(),
                                style:TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2.sp),
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