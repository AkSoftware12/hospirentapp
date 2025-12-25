import 'package:flutter/material.dart';
import 'HexColor.dart';


class AppColors {
  static  Color primary = HexColor('#034da2'); // Example primary color (blue)
  static  Color backgroud  = HexColor('#eef1f6'); // Example primary color (blue)


}


class ApiRoutes {


  // Main App Url
  // static const String baseUrl = "https://hospirenttest.akdesire.com/api";
  static const String baseUrl = "https://api.hospirent.in/api";
  // blog and Video
  static const String baseUrl2 = "https://hospirent.in/api";


// Local  App Url
  // static const String baseUrl = "http://192.168.1.12/hospirentbill/api";



  static const String login = "$baseUrl/login";
  static const String mobileLogin = "$baseUrl/mobile_login";
  static const String mobileOtpVerify = "$baseUrl/mobile_otp_verify";
  static const String signup = "$baseUrl/signup";
  static const String logout = "$baseUrl/logout";
  static const String clear = "$baseUrl/clear";
  static const String getProfile = "$baseUrl/get-profile";
  static const String getUpdateProfile = "$baseUrl/updateProfile";
  static const String getUpdatePassword = "$baseUrl/updatePassword";
  static const String getAddress = "$baseUrl/my-address";
  static const String addAddress = "$baseUrl/add-address";
  static const String deleteAddress = "$baseUrl/delete-address";



  static const String getDashboard = "$baseUrl/dashboard";
  // static const String getDashboard = "$baseUrl/dashboards";
  // static const String getAllProductsMain = "$baseUrl/products";
  static const String getAllProducts = "$baseUrl/products?category_id=";
  static const String getAllProductsRent = "$baseUrl/products?type=rent&category_id=";
  static const String getAllProductsBuy = "$baseUrl/products?type=buy&category_id=";
  static const String getAllServices = "$baseUrl/services";
  static const String getVideo = "$baseUrl2/video";
  static const String getBlog = "$baseUrl2/blog-all";
  static const String getProductsDetail = "$baseUrl/products-detail?id=";



  // Rent


  static const String rentOrderStore = "$baseUrl/rent-order-store";
  static const String getOrderBillingList = "$baseUrl/get-order-list";
  static const String customerChallanPrint = "$baseUrl/customer-challan-print/";

  // Purchase

  static const String buyOrderStore = "$baseUrl/order-store";
  static const String getOrderPurchaseList = "$baseUrl/get-purchase-order-list";
  static const String customerPurchaseChallanPrint = "$baseUrl/customer-purchase-challan-print/";


  static const String notifications = "$baseUrl/notifications";
}
