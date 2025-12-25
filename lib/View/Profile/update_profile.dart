import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hospirent/constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../HexColor.dart';
import '../../textSize.dart';

class ProfileUpdatePage extends StatefulWidget {
  final VoidCallback onReturn;

  const ProfileUpdatePage({super.key, required this.onReturn});

  @override
  State<ProfileUpdatePage> createState() => _AccountPageState();
}

class _AccountPageState extends State<ProfileUpdatePage> {
  TextEditingController addressController = TextEditingController();
  TextEditingController pinController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  File? file;
  final picker = ImagePicker();
  bool _isLoading = false;
  String photoUrl = '';
  String userEmail = '';
  String userMobile = '';

  final List<String> states = [
    "Andhra Pradesh",
    "Arunachal Pradesh",
    "Assam",
    "Bihar",
    "Chhattisgarh",
    "Goa",
    "Gujarat",
    "Haryana",
    "Himachal Pradesh",
    "Jharkhand",
    "Karnataka",
    "Kerala",
    "Madhya Pradesh",
    "Maharashtra",
    "Manipur",
    "Meghalaya",
    "Mizoram",
    "Nagaland",
    "Odisha",
    "Punjab",
    "Rajasthan",
    "Sikkim",
    "Tamil Nadu",
    "Telangana",
    "Tripura",
    "Uttar Pradesh",
    "Uttarakhand",
    "West Bengal",
    "Andaman and Nicobar Islands",
    "Chandigarh",
    "Dadra and Nagar Haveli and Daman and Diu",
    "Delhi",
    "Jammu and Kashmir",
    "Ladakh",
    "Lakshadweep",
    "Puducherry",
  ];

  String? selectedState;

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  @override
  void dispose() {
    addressController.dispose();
    pinController.dispose();
    cityController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<void> fetchProfileData() async {
    setState(() {
      _isLoading = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    final Uri uri = Uri.parse(ApiRoutes.getProfile);
    final Map<String, String> headers = {'Authorization': 'Bearer $token'};
    final response = await http.get(uri, headers: headers);

    setState(() {
      _isLoading = false;
    });
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      setState(() {
        pinController.text = jsonData['user']['pin']?.toString() ?? '';
        addressController.text = jsonData['user']['address']?.toString() ?? '';
        cityController.text = jsonData['user']['district']?.toString() ?? '';
        nameController.text = jsonData['user']['name']?.toString() ?? '';
        emailController.text = jsonData['user']['email'] ?? '';
        userMobile = jsonData['user']['contact']?.toString() ?? '';
        photoUrl = jsonData['user']['picture_data']?.toString() ?? '';
        String? state = jsonData['user']['state']?.toString();
        selectedState = states.contains(state) ? state : null;
      });
    } else {
      Fluttertoast.showToast(
        msg: "Failed to load profile data",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 22.0,
      );
    }
  }

  Future<void> _updateProfile(File? file) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.orangeAccent,
          ),
        );
      },
    );

    setState(() {
      _isLoading = true;
    });

    String name = nameController.text;
    String email = emailController.text;
    String phoneNumber = phoneController.text;
    String address = addressController.text;
    String city = cityController.text;
    String pin = pinController.text;
    String bio = bioController.text;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    String apiUrl = ApiRoutes.getUpdateProfile;

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.fields.addAll({
        'name': name,
        'email': email,
        'contact': phoneNumber,
        'address': address,
        'district': city,
        'state': selectedState ?? '',
        'pin': pin,
        'bio': bio,
      });
      request.headers['Authorization'] = 'Bearer $token';
      if (file != null) {
        request.files.add(await http.MultipartFile.fromPath('photo', file.path));
      }
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        widget.onReturn();
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: "Profile updated successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 22.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Failed to update profile: ${response.statusCode}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 22.0,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error updating profile: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 22.0,
      );
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.pop(context); // Close loading dialog
  }

  void _showPicker({required BuildContext context}) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> getImage(ImageSource img) async {
    setState(() {
      _isLoading = true;
    });

    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile = await imagePicker.pickImage(source: img).catchError((err) {
      Fluttertoast.showToast(
        msg: err.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 22.0,
      );
      setState(() {
        _isLoading = false;
      });
      return null;
    });

    if (pickedFile != null) {
      setState(() {
        file = File(pickedFile.path);
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        title: Text(
          'Profile Update',
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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 50.sp),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(30.sp),
                                bottomRight: Radius.circular(30.sp),
                              ),
                            ),
                            height: 140.sp,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Spacer(),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Spacer(),
                                    Stack(
                                      fit: StackFit.loose,
                                      children: <Widget>[
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(30),
                                            color: Colors.white,
                                          ),
                                          width: 100.sp,
                                          height: 100.sp,
                                          margin: EdgeInsets.all(20),
                                          child: file == null
                                              ? photoUrl.isNotEmpty
                                              ? ClipRRect(
                                            borderRadius: BorderRadius.circular(30),
                                            child: Image.network(
                                              photoUrl,
                                              fit: BoxFit.cover,
                                              width: 100.sp,
                                              height: 100.sp,
                                              errorBuilder: (context, object, stackTrace) {
                                                return Image.network(
                                                  'https://media.istockphoto.com/id/1394514999/photo/woman-holding-a-astrology-book-astrological-wheel-projection-choose-a-zodiac-sign-astrology.jpg?s=612x612&w=0&k=20&c=XIH-aZ13vTzkcGUTbVLwPcp_TUB4hjVdeSSY-taxlOo=',
                                                  fit: BoxFit.cover,
                                                  width: 100.sp,
                                                  height: 100.sp,
                                                );
                                              },
                                              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return Container(
                                                  width: 100.sp,
                                                  height: 100.sp,
                                                  child: Center(
                                                    child: CircularProgressIndicator(
                                                      color: AppColors.primary,
                                                      value: loadingProgress.expectedTotalBytes != null
                                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                          : null,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                              : ClipRRect(
                                            borderRadius: BorderRadius.circular(30),
                                            child: Image.network(
                                              'https://media.istockphoto.com/id/1394514999/photo/woman-holding-a-astrology-book-astrological-wheel-projection-choose-a-zodiac-sign-astrology.jpg?s=612x612&w=0&k=20&c=XIH-aZ13vTzkcGUTbVLwPcp_TUB4hjVdeSSY-taxlOo=',
                                              fit: BoxFit.cover,
                                              width: 100.sp,
                                              height: 100.sp,
                                            ),
                                          )
                                              : ClipRRect(
                                            borderRadius: BorderRadius.circular(30),
                                            child: Image.file(
                                              file!,
                                              width: 100.sp,
                                              height: 100.sp,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 100.sp, left: 20.sp),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              InkWell(
                                                onTap: () {
                                                  _showPicker(context: context);
                                                },
                                                child: const CircleAvatar(
                                                  backgroundColor: Colors.red,
                                                  radius: 15.0,
                                                  child: Icon(
                                                    Icons.camera_alt,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.sp),
                            topRight: Radius.circular(30.sp),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text.rich(
                                  TextSpan(
                                    text: "Full Name",
                                    style: GoogleFonts.radioCanada(
                                      textStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: TextSizes.text12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Container(
                                height: 40.sp,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: HexColor('#f6f6f7'),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    controller: nameController,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Admin",
                                      icon: Icon(Icons.account_circle)
                                    ),
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 0.sp),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text.rich(
                                    TextSpan(
                                      text: "Email Id",
                                      style: GoogleFonts.radioCanada(
                                        textStyle: TextStyle(
                                          color: Colors.black,
                                          fontSize: TextSizes.text12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ),
                              Container(
                                height: 40.sp,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: HexColor('#f6f6f7'),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    controller: emailController,
                                    decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "testing@gmail.com",
                                        icon: Icon(Icons.email)
                                    ),
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 0.sp),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text.rich(
                                    TextSpan(
                                      text: "Contact No",
                                      style: GoogleFonts.radioCanada(
                                        textStyle: TextStyle(
                                          color: Colors.black,
                                          fontSize: TextSizes.text12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ),
                              Container(
                                height: 40.sp,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: HexColor('#f6f6f7'),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(right: 10.0),
                                  child: Row(
                                    children: [
                                      SizedBox(width: 10.sp,),
                                      Icon(
                                        Icons.call,
                                        size: 20,
                                        color: Colors.black,
                                      ),
                                      SizedBox(width: 10.sp,),

                                      Text(
                                        "+91 $userMobile",
                                        style: const TextStyle(color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 0.sp),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text.rich(
                                    TextSpan(
                                      text: "Address",
                                      style: GoogleFonts.radioCanada(
                                        textStyle: TextStyle(
                                          color: Colors.black,
                                          fontSize: TextSizes.text12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ),
                              Container(
                                height: 40.sp,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: HexColor('#f6f6f7'),
                                ),
                                child:Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: TextField(
                                    controller: addressController,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "address",
                                      icon: Icon(
                                        Icons.location_on,
                                        size: 20,
                                        color: Colors.black,
                                      ),
                                    ),

                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 0.sp),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text.rich(
                                    TextSpan(
                                      text: "City",
                                      style: GoogleFonts.radioCanada(
                                        textStyle: TextStyle(
                                          color: Colors.black,
                                          fontSize: TextSizes.text12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ),
                              Container(
                                height: 40.sp,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: HexColor('#f6f6f7'),
                                ),
                                child:Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: TextField(
                                    controller: cityController,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "city",
                                      icon: Icon(
                                        Icons.location_city,
                                        size: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),

                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 0.sp),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text.rich(
                                    TextSpan(
                                      text: "State",
                                      style: GoogleFonts.radioCanada(
                                        textStyle: TextStyle(
                                          color: Colors.black,
                                          fontSize: TextSizes.text12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ),
                              Container(
                                height: 40.sp,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 7,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedState,
                                      hint: const Text("Select a State"),
                                      isExpanded: true,
                                      items: states.map((String state) {
                                        return DropdownMenuItem<String>(
                                          value: state,
                                          child: Text(state),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedState = newValue;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 0.sp),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text.rich(
                                    TextSpan(
                                      text: "Pin Code",
                                      style: GoogleFonts.radioCanada(
                                        textStyle: TextStyle(
                                          color: Colors.black,
                                          fontSize: TextSizes.text12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ),
                              Container(
                                height: 40.sp,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: HexColor('#f6f6f7'),
                                ),
                                child:Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    controller: pinController,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "pin code",
                                      icon: Icon(
                                        Icons.location_city,
                                        size: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),

                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
      bottomSheet: Container(
        height: 50.sp,
        color: Colors.white,
        child:Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              _updateProfile(file);
            },
            child:  Container(
              width: double.infinity,
              height: 40.sp,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.sp),
                color: AppColors.primary,
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(left: 35.sp, right: 35.sp),
                  child: Text(
                    'Update',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: TextSizes.text16,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}