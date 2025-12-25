import 'dart:convert';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hospirent/HexColor.dart';
import 'package:hospirent/View/Purchase/model/cart_model.dart';
import 'package:hospirent/constants.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../RentAcc/imports.dart';
import '../../../RentAcc/widgets/app_name_widget.dart';
import '../../../RentAcc/widgets/text/text_builder.dart';
import '../../controller/cart_provider.dart';
import '../../model/product_model.dart';
import '../../widgets/card/product_card.dart';
import '../cart/cart.dart';
import '../drawer/drawer_menu.dart';


class BuyProduct extends StatefulWidget {
  final int id;
  final int catIndex;
  const BuyProduct({Key? key, required this.id, required this.catIndex}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<BuyProduct> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) runAddToCartAnimation;
  int _cartQuantityItems = 0;


  Future<List<ProductModel>>? futureProduct;
  List<ProductModel> allProducts = []; // Store all products
  List<ProductModel> filteredProducts = []; // Store filtered products
  List categories = [];
  List services = [];
  List banner = [];
  bool isLoading = true;
  bool isProductLoading = false;
  int selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  Future<List<ProductModel>> fetchProducts(int id) async {
    setState(() {
      isProductLoading = true;
    });
    List<ProductModel> products = [];
    var request = http.Request('GET', Uri.parse('${ApiRoutes.getAllProductsBuy}$id'));

    try {
      http.StreamedResponse response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print(responseBody);
        }
        final jsonData = jsonDecode(responseBody);
        final productList = jsonData['products'] as List<dynamic>;
        products = productList.map<ProductModel>((e) => ProductModel.fromJson(e)).toList();
        setState(() {
          allProducts = products; // Store all products
          filteredProducts = products; // Initially, filtered products are the same
        });
      } else {
        if (kDebugMode) {
          print(response.reasonPhrase);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching products: $e");
      }
    }

    setState(() {
      isProductLoading = false;
    });
    return products;
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredProducts = allProducts; // Show all products if query is empty
      } else {
        filteredProducts = allProducts.where((product) {
          return product.title!.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchDasboardData();
    futureProduct = fetchProducts(widget.id);
    selectedIndex = widget.catIndex;
    _searchController.addListener(() {
      _filterProducts(_searchController.text);
    });
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
        if (data is Map<String, dynamic>) {
          setState(() {
            categories = data['categories'] is List ? data['categories'] : [];
            isLoading = false;
            print("Categories: $categories");
          });
        } else {
          print("Error: Invalid response format");
        }
      } else {
        print("Error: Failed to fetch data, status code: ${response.statusCode}");
        if (response.statusCode == 401) {
          // Handle unauthorized access if needed
        }
      }
    } catch (e) {
      print("Error fetching dashboard data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  void listClick(GlobalKey widgetKey) async {
    await runAddToCartAnimation(widgetKey);
    await cartKey.currentState!
        .runCartAnimation((++_cartQuantityItems).toString());
  }


  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return  AddToCartAnimation(
      cartKey: cartKey,
      height: 30,
      width: 30,
      opacity: 0.85,
      dragAnimation: const DragToCartAnimationOptions(rotation: true),
      jumpAnimation: const JumpAnimationOptions(),
      createAddToCartAnimation: (runAddToCartAnimation) {
        this.runAddToCartAnimation = runAddToCartAnimation;
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.backgroud,
        drawer: const DrawerMenu(),
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
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
              ),
            ),
          ),
          actions: [
            Stack(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const Cart(appBar: 'Hone')));
                  },
                  icon: Stack(
                    children: [
                      Container(
                        key: cartKey,
                        child: Padding(
                          padding: EdgeInsets.only(top: cart.itemCount != 0 ? 8 : 0, right: cart.itemCount != 0 ? 8 : 0),
                          child: const Icon(
                            Icons.shopping_cart,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      if (cart.itemCount != 0)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            height: 20,
                            width: 20,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black),
                            child: TextBuilder(
                              text: cart.itemCount.toString(),
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 10,
                            ),
                          ),
                        )
                    ],
                  ),
                ),
                // AddToCartIcon(
                //   key: cartKey,
                //   icon: const Icon(Icons.shopping_cart),
                //   // badgeOptions: const BadgeOptions(
                //   //   active: true,
                //   //   backgroundColor: Colors.red,
                //   // ),
                // ),
              ],
            )

          ],
        ),
        body: SafeArea(
          child: isLoading
              ? Center(
            child: CupertinoActivityIndicator(
              radius: 30,
              color: AppColors.primary,
            ),
          )
              : Column(
            children: [
              // Search Bar
              Padding(
                padding: EdgeInsets.all(10.sp),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: Icon(Icons.search, color: AppColors.primary),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.sp),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 10.sp, horizontal: 15.sp),
                  ),
                ),
              ),
              // Main Content
              Expanded(
                child: Row(
                  children: [
                    // Categories List

                    if(widget.id!=0)
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                          child: ListView.builder(
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final isSelected = index == selectedIndex;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedIndex = index;
                                    futureProduct = fetchProducts(categories[index]['id']);
                                    _searchController.clear(); // Clear search when category changes
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border(
                                      right: BorderSide(
                                        color: isSelected ? AppColors.primary : Colors.white,
                                        width: 5,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 60.sp,
                                        height: 60.sp,
                                        padding: EdgeInsets.all(12.sp),
                                        decoration: BoxDecoration(
                                          color: AppColors.backgroud,
                                          shape: BoxShape.circle,
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: categories[index]['image_url'],
                                          fit: BoxFit.contain,
                                          placeholder: (context, url) => Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation(AppColors.primary),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) => Icon(
                                            Icons.photo,
                                            color: categories[index]['color'],
                                          ),
                                        ),
                                      ),
                                      Text(
                                        categories[index]['title'].toString(),
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[800],
                                          fontFamily: 'PoppinsBold',
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    // Product Grid
                    Expanded(
                      flex: 4,
                      child: isProductLoading
                          ? Center(
                        child: CupertinoActivityIndicator(
                          radius: 30,
                          color: AppColors.primary,
                        ),
                      )
                          : filteredProducts.isNotEmpty
                          ? GridView.builder(
                        padding:  EdgeInsets.only(left: 5.sp,right: 5.sp),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.5 / 4,
                          mainAxisSpacing: 5.sp,
                          crossAxisSpacing: 5.sp,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (BuildContext context, int i) {
                          return ProductCard(product: filteredProducts[i],
                            index: i,
                            onClick: listClick,
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}