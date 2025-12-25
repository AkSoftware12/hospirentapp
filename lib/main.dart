import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hospirent/View/Profile/profile.dart';
import 'package:hospirent/constants.dart';
import 'package:http/http.dart' as http;
import 'package:new_version_plus/new_version_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'View/Auth/LoginNew/Login/login.dart';
import 'View/Auth/SplashScreen/splash_screen.dart';
import 'View/Blogs/blogs.dart';
import 'View/Purchase/view/cart/cart.dart';
import 'View/Purchase/view/drawer/drawer_menu.dart';
import 'View/Purchase/widgets/app_name_widget.dart';
import 'View/Purchase/widgets/text/text_builder.dart';
import 'View/Home/home.dart';
import 'View/Purchase/controller/cart_provider.dart';
import 'View/RentAcc/controller/rent_cart_provider.dart';
import 'View/Videos/video.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyBmEitw048dJQ7uA-yNuCyxlBucVezwhCk',
        appId: '1:1471086994:android:58984d8043063c5d16c14b',
        messagingSenderId: '1471086994',
        projectId: 'hospirent-cf282',
        storageBucket: 'hospirent-cf282.firebasestorage.app',
        // storageBucket: "hospirent-fdf41.firebasestorage.app",
      ),
    );
  } else {
    await Firebase.initializeApp();

  }

  runApp(MyApp());


  // Run after app load
  Future.delayed(Duration(milliseconds: 300), () {
    NotificationService.initNotifications();
  });
}




class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,

      builder: (_, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<CartProvider>(
                create: (context) => CartProvider()),
            ChangeNotifierProvider<RentCartProvider>(
                create: (context) => RentCartProvider()),
            // ChangeNotifierProvider<LoginProvider>(
            //     create: (context) => LoginProvider()),
          ],

          child:MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            home: SplashScreen(),
            routes: { '/login': (context) => LoginScreenNew(), },
          ),
        );
      },
    );
  }
}



class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, required this.initialIndex});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String currentVersion = '';
  String release = "";

  final List<Widget> _screens = [
    HomeScreen(),
    BlogsScreen(),
    VideoScreen(),
    Cart(appBar: '',),
    ProfileScreen(appBar: '',),

  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }



  @override
  void initState() {
    super.initState();
    checkForVersion(context);

    _selectedIndex = widget.initialIndex; // Set the initial tab index


    final newVersion = NewVersionPlus(
      iOSId: 'com.hospirent.hospirent', androidId: 'com.hospirent.hospirent', androidPlayStoreCountry: "es_ES", androidHtmlReleaseNotes: true, //support country code
    );
    final ver = VersionStatus(
      appStoreLink: '',
      localVersion: '',
      storeVersion: '',
      releaseNotes: '',
      originalStoreVersion: '',
    );
    advancedStatusCheck(newVersion);
}


  basicStatusCheck(NewVersionPlus newVersion) async {
    final version = await newVersion.getVersionStatus();
    if (version != null) {
      release = version.releaseNotes ?? "";
      setState(() {});
    }
    newVersion.showAlertIfNecessary(
      context: context,
      launchModeVersion: LaunchModeVersion.external,
    );
  }

  Future<void> advancedStatusCheck(NewVersionPlus newVersion) async {
    final status = await newVersion.getVersionStatus();
    if (status != null) {
      debugPrint(status.releaseNotes);
      debugPrint(status.appStoreLink);
      debugPrint(status.localVersion);
      debugPrint(status.storeVersion);
      debugPrint(status.canUpdate.toString());

      if (status.canUpdate) {
        // Show the custom dialog instead of the default showUpdateDialog
        showDialog(
          context: navigatorKey.currentContext!,
          barrierDismissible: false, // Matches allowDismissal: false
          builder: (BuildContext context) {
            return WillPopScope(
                onWillPop: () async {
                  SystemNavigator.pop(); // App completely close
                  return false;
                },
                child: CustomUpgradeDialog(currentVersion: status.localVersion, newVersion: status.storeVersion, releaseNotes: [status.releaseNotes.toString()],));
          },
        );
      }
    }
  }
  Future<void> checkForVersion(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    currentVersion = packageInfo.version;
  }
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartRent = Provider.of<RentCartProvider>(context);


    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: IconThemeData(color: Colors.white),
        title: AppNameWidget(),
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
                color: Colors.white, // Set grey background for drawer icon
                shape: BoxShape.circle, // Optional: makes the background circular
              ),
              child: IconButton(
                icon: Icon(Icons.menu, color: Colors.black), // Drawer icon
                onPressed: () {
                  Scaffold.of(context).openDrawer(); // Opens the drawer
                },
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const Cart(appBar: 'Hone')));
            },
            icon: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 8 , right:  8,left: 8 ),
                  child: const Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                    size: 30,
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
                  ),
                if (cartRent.itemCountRent != 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      height: 20,
                      width: 20,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black),
                      child: TextBuilder(
                        text: cartRent.itemCountRent.toString(),
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                      ),
                    ),
                  )
              ],
            ),
          )
        ],
      ),

      drawer: const DrawerMenu(),
      body: _screens[_selectedIndex],
      bottomNavigationBar:Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
        child: ClipRRect(
          child: BottomNavigationBar(
            items:  [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.blog),
                label: 'Blogs',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.play_circle),
                label: 'Gallery',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: 'Cart',
              ),
              BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.user),
                label: 'Profile',
              ),
            ],
            backgroundColor: AppColors.primary, // Your primary color
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: Colors.white, // Color for selected item
            unselectedItemColor: Colors.white70, // Color for unselected items
            type: BottomNavigationBarType.fixed, // Ensures consistent layout
            selectedLabelStyle: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
            elevation: 8, // Adds shadow for depth
            iconSize: 20.sp, // Responsive icon size
          ),
        ),
      ),

    );

  }
}



class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// 🔹 Initialize Notifications
  static Future<void> initNotifications() async {
    // Request Permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: true,
      announcement: true,
      carPlay: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      print("✅ Push Notifications Enabled");

      // iOS setup
      if (Platform.isIOS) {
        await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

        String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        print("📱 APNS Token: $apnsToken");
      }

      // Get FCM Token
      String? token = await _firebaseMessaging.getToken();
      print("📲 FCM Token: $token");

      // Background handler must be top-level
      FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
      FirebaseMessaging.onMessage.listen(_onMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

      // Init Local Notifications
      await _initLocalNotifications();
    } else {
      print("❌ Push Notifications Denied");
    }
  }

  /// 🔹 Foreground Notification
  static void _onMessage(RemoteMessage message) {
    print("📩 Foreground Notification: ${message.notification?.title}");
    _showLocalNotification(message);
  }

  /// 🔹 Notification Tap
  static void _onMessageOpenedApp(RemoteMessage message) {
    print("📩 Notification Clicked: ${message.notification?.title}");

    if (navigatorKey.currentContext != null) {
      Map<String, dynamic> data = message.data;
      if (data.containsKey('screen')) {
        String screen = data['screen'];
        if (screen == 'notification') {
          // Example Navigation
          // Navigator.push(
          //   navigatorKey.currentContext!,
          //   MaterialPageRoute(builder: (_) => NotificationScreen()),
          // );
        }
      }
    }
  }

  /// 🔹 Background Notification Handler
  static Future<void> _onBackgroundMessage(RemoteMessage message) async {
    print("📩 Background Notification: ${message.notification?.title}");
  }

  /// 🔹 Initialize Local Notifications
  static Future<void> _initLocalNotifications() async {
    // Create Android Channel (required for Android 8.0+)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // must be unique
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      sound: null, // use default system sound
    );

    // Register the channel
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iOSSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final String? payload = response.payload;
        if (payload != null) {
          print('🔹 Notification payload: $payload');
          // You can parse payload and navigate accordingly
        }
      },
    );

    print("✅ Local Notification Channel Initialized");
  }

  /// 🔹 Show Local Notification
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;
    final apple = message.notification?.apple;
    final imageUrl = android?.imageUrl ?? apple?.imageUrl;

    BigPictureStyleInformation? bigPictureStyle;
    if (Platform.isAndroid && imageUrl != null && imageUrl.isNotEmpty) {
      final String largeIconPath = await _downloadAndSaveFile(imageUrl, 'largeIcon');
      final String bigPicturePath = await _downloadAndSaveFile(imageUrl, 'bigPicture');
      bigPictureStyle = BigPictureStyleInformation(
        FilePathAndroidBitmap(bigPicturePath),
        largeIcon: FilePathAndroidBitmap(largeIconPath),
        contentTitle: notification?.title,
        summaryText: notification?.body,
      );
    }

    // iOS details (optional image)
    DarwinNotificationDetails? iosDetails;
    if (Platform.isIOS) {
      iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        attachments: imageUrl != null && imageUrl.isNotEmpty
            ? [DarwinNotificationAttachment(await _downloadAndSaveFile(imageUrl, 'attach'))]
            : null,
      );
    }

    // Android details
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel', // must match channel id
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      styleInformation: bigPictureStyle,
    );

    NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      notification?.title,
      notification?.body,
      details,
      payload: json.encode(message.data),
    );
  }

  /// 🔹 Download file for image notifications
  static Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  /// 🔹 Optional: Handle silent data notifications
  static Future<void> _handleSilentNotification(Map<String, dynamic> data) async {
    print("🔇 Silent notification received: $data");
    // Do background logic (e.g., fetch new data)
  }
}




