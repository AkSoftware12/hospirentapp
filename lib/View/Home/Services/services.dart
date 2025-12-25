import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hospirent/constants.dart';
import 'package:flutter_html/flutter_html.dart'; // Import flutter_html
import 'package:provider/provider.dart';

import '../../Purchase/controller/cart_provider.dart';
import '../../Purchase/view/drawer/drawer_menu.dart';
import '../../Purchase/widgets/app_name_widget.dart';
import '../../Purchase/widgets/text/text_builder.dart';

class XRayAtHomeScreen extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String description;
  final String description2;

  const XRayAtHomeScreen({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.description2,
  });

  @override
  State<XRayAtHomeScreen> createState() => _XRayAtHomeScreenState();
}

class _XRayAtHomeScreenState extends State<XRayAtHomeScreen> {
  final staticAnchorKey = GlobalKey();
  final staticAnchorKey2 = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: AppColors.backgroud,
      appBar: AppBar(
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
                icon: const Icon(Icons.menu, color: Colors.white),
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
                color: Colors.black,
              ),
              child: TextBuilder(
                text: cart.itemCount.toString(),
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
      drawer: const DrawerMenu(),
      body: SingleChildScrollView( // Wrap in SingleChildScrollView for scrollable content
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
        Stack(
        children: [
          CachedNetworkImage(
          imageUrl: widget.imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          placeholder: (context, url) => Container(
            height: 200.h,
            color: Colors.grey[300],
            child:  Center(
              child:  CupertinoActivityIndicator(radius: 20, color: AppColors.primary),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            height: 200.h,
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.error, color: Colors.red),
            ),
          ),

          ),
        ],
      ),            // Buttons
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding:  EdgeInsets.only(left: 8.0),
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
            ),

            // Container(
            //   padding: const EdgeInsets.all(15),
            //   decoration: const BoxDecoration(
            //     border: Border(
            //       bottom: BorderSide(color: Colors.grey),
            //     ),
            //   ),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //     children: [
            //       ElevatedButton(
            //         onPressed: () {},
            //         style: ElevatedButton.styleFrom(
            //           backgroundColor: Colors.blue,
            //           padding: const EdgeInsets.symmetric(
            //             horizontal: 20,
            //             vertical: 10,
            //           ),
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(5),
            //           ),
            //         ),
            //         child: const Text(
            //           'Call Now',
            //           style: TextStyle(
            //             color: Colors.white,
            //             fontSize: 16,
            //             fontWeight: FontWeight.bold,
            //           ),
            //         ),
            //       ),
            //       OutlinedButton(
            //         onPressed: () {},
            //         style: OutlinedButton.styleFrom(
            //           side: const BorderSide(color: Colors.blue, width: 2),
            //           padding: const EdgeInsets.symmetric(
            //             horizontal: 20,
            //             vertical: 10,
            //           ),
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(5),
            //           ),
            //         ),
            //         child: const Text(
            //           'Book Now',
            //           style: TextStyle(
            //             color: Colors.blue,
            //             fontSize: 16,
            //             fontWeight: FontWeight.bold,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // Content Section
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Html(
                    anchorKey: staticAnchorKey,
                    data: widget.description,
                    style: {
                      "p": Style(fontSize: FontSize.large),
                      "h1": Style(fontSize: FontSize.xxLarge),
                      "h2": Style(fontSize: FontSize.xLarge),
                      "td": Style(fontSize: FontSize(14.0)), // Tables
                      "body": Style(fontSize: FontSize(16.0)), // Default body
                    },
                    extensions: [
                      TagWrapExtension(
                        tagsToWrap: {"table"},
                        builder: (child) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: child,
                          );
                        },
                      ),
                      TagExtension.inline(
                        tagsToExtend: {"bird"},
                        child: const TextSpan(text: "🐦"),
                      ),
                      TagExtension(
                        tagsToExtend: {"flutter"},
                        builder: (context) => CssBoxWidget(
                          style: context.styledElement!.style,
                          child: FlutterLogo(
                            style: context.attributes['horizontal'] != null
                                ? FlutterLogoStyle.horizontal
                                : FlutterLogoStyle.markOnly,
                            textColor: context.styledElement!.style.color!,
                            size: context.styledElement!.style.fontSize!.value,
                          ),
                        ),
                      ),
                      ImageExtension(
                        handleAssetImages: false,
                        handleDataImages: false,
                        networkDomains: {"flutter.dev"},
                        child: const FlutterLogo(size: 36),
                      ),
                      ImageExtension(
                        handleAssetImages: false,
                        handleDataImages: false,
                        networkDomains: {"mydomain.com"},
                        networkHeaders: {"Custom-Header": "some-value"},
                      ),
                    ],
                    onLinkTap: (url, _, __) {
                      debugPrint("Opening $url...");
                    },
                    onCssParseError: (css, messages) {
                      debugPrint("css that errored: $css");
                      debugPrint("error messages:");
                      for (var element in messages) {
                        debugPrint(element.toString());
                      }
                      return '';
                    },
                  ),
                Html(
                anchorKey: staticAnchorKey2,
                data: widget.description2,
                  style: {
                    "p": Style(fontSize: FontSize.large),
                    "h1": Style(fontSize: FontSize.xxLarge),
                    "h2": Style(fontSize: FontSize.xLarge),
                    "td": Style(fontSize: FontSize(14.0)), // Tables
                    "body": Style(fontSize: FontSize(16.0)), // Default body
                  },
                  extensions: [
                  TagWrapExtension(
                      tagsToWrap: {"table"},
                      builder: (child) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: child,
                        );
                      }),

                  TagExtension.inline(
                    tagsToExtend: {"bird"},
                    child: const TextSpan(text: "🐦"),
                  ),
                  TagExtension(
                    tagsToExtend: {"flutter"},
                    builder: (context) => CssBoxWidget(
                      style: context.styledElement!.style,
                      child: FlutterLogo(
                        style: context.attributes['horizontal'] != null
                            ? FlutterLogoStyle.horizontal
                            : FlutterLogoStyle.markOnly,
                        textColor: context.styledElement!.style.color!,
                        size: context.styledElement!.style.fontSize!.value,
                      ),
                    ),
                  ),
                  ImageExtension(
                    handleAssetImages: false,
                    handleDataImages: false,
                    networkDomains: {"flutter.dev"},
                    child: const FlutterLogo(size: 36),
                  ),
                  ImageExtension(
                    handleAssetImages: false,
                    handleDataImages: false,
                    networkDomains: {"mydomain.com"},
                    networkHeaders: {"Custom-Header": "some-value"},
                  ),

                ],
                onLinkTap: (url, _, __) {
                  debugPrint("Opening $url...");
                },
                onCssParseError: (css, messages) {
                  debugPrint("css that errored: $css");
                  debugPrint("error messages:");
                  for (var element in messages) {
                    debugPrint(element.toString());
                  }
                  return '';
                },
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