import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../imports.dart';
import '../model/cart_model.dart';

class RentCartProvider with ChangeNotifier {
  final List<RentCartModel> _itemsRent = [];
  static const String _cartKeyRent = 'cart_items_rent';

  RentCartProvider() {
    _loadCart();
  }

  List<RentCartModel> get itemsRent => [..._itemsRent];

  int get itemCountRent => _itemsRent.length;

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cartData = prefs.getString(_cartKeyRent);
    if (cartData != null) {
      final List<dynamic> decodedData = jsonDecode(cartData);
      _itemsRent.clear();
      _itemsRent.addAll(decodedData.map((item) => RentCartModel.fromJson(item)).toList());

      notifyListeners();
    }
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(_itemsRent.map((item) => item.toJson()).toList());
    await prefs.setString(_cartKeyRent, encodedData);
  }

  void addItem(RentCartModel cartModel) {
    int index = _itemsRent.indexWhere((item) => item.id == cartModel.id);
    if (index != -1) {
      RentCartModel existingItem = _itemsRent[index];
      RentCartModel updatedItem = existingItem.copyWith(
        quantity: existingItem.quantity! + cartModel.quantity!,
        totalPrice: existingItem.totalPrice! + cartModel.totalPrice!,
      );
      _itemsRent[index] = updatedItem;
    } else {
      _itemsRent.add(cartModel);
    }
    _saveCart();
    notifyListeners();
  }

  void removeItem(int id) {
    _itemsRent.removeWhere((element) => element.id == id);
    _saveCart();
    notifyListeners();
  }
  void increaseQuantity(int id) {
    final index = _itemsRent.indexWhere((e) => e.id == id);
    if (index != -1) {
      _itemsRent[index].quantity = _itemsRent[index].quantity! + 1;

      double price = _itemsRent[index].rate ?? 0;
      double gst = _itemsRent[index].gst ?? 0;

      // Price + GST per quantity
      double priceWithGst = price + gst;

      // Total Price = (price + gst) * quantity
      _itemsRent[index].totalPrice = priceWithGst * _itemsRent[index].quantity!;

      _saveCart();
      notifyListeners();
    }
  }


  void decreaseQuantity(int id) {
    final index = _itemsRent.indexWhere((e) => e.id == id);
    if (index != -1 && _itemsRent[index].quantity! > 1) {
      _itemsRent[index].quantity = _itemsRent[index].quantity! - 1;

      double price = _itemsRent[index].rate ?? 0;
      double gst = _itemsRent[index].gst ?? 0;

      // Price + GST per quantity
      double priceWithGst = price + gst;

      // Total Price = (price + gst) * quantity
      _itemsRent[index].totalPrice = priceWithGst * _itemsRent[index].quantity!;

      _saveCart();
      notifyListeners();
    }
  }

  // void increaseQuantity(int id) {
  //   final index = _itemsRent.indexWhere((e) => e.id == id);
  //   if (index != -1) {
  //     _itemsRent[index].quantity = _itemsRent[index].quantity! + 1;
  //     _itemsRent[index].totalPrice = _itemsRent[index].price! * _itemsRent[index].quantity!;
  //     _saveCart();
  //     notifyListeners();
  //   }
  // }

  // void decreaseQuantity(int id) {
  //   final index = _itemsRent.indexWhere((e) => e.id == id);
  //   if (index != -1 && _itemsRent[index].quantity! > 1) {
  //     _itemsRent[index].quantity = _itemsRent[index].quantity! - 1;
  //     _itemsRent[index].totalPrice = _itemsRent[index].price! * _itemsRent[index].quantity!;
  //     _saveCart();
  //     notifyListeners();
  //   }
  // }

  void clearCart() {
    _itemsRent.clear();
    _saveCart();
    notifyListeners();
  }

  void removeSingleItem(int id) {
    final index = _itemsRent.indexWhere((e) => e.id == id);
    if (index != -1) {
      if (_itemsRent[index].quantity! > 1) {
        _itemsRent[index].quantity = _itemsRent[index].quantity! - 1;
        _itemsRent[index].totalPrice = _itemsRent[index].rate! * _itemsRent[index].quantity!;
      } else {
        _itemsRent.removeWhere((element) => element.id == id);
      }
      _saveCart();
      notifyListeners();
    }
  }
  void incrementItem(String id) {
    final index = _itemsRent.indexWhere((item) => item.id.toString() == id);
    if (index != -1) {
      _itemsRent[index].quantity = _itemsRent[index].quantity! + 1;

      double price = _itemsRent[index].rate ?? 0;
      double gst = _itemsRent[index].gst ?? 0;

      // Price + GST per quantity
      double priceWithGst = price + gst;

      // Total Price = (price + gst) * quantity
      _itemsRent[index].totalPrice = priceWithGst * _itemsRent[index].quantity!;

      _saveCart();
      notifyListeners();
    }
  }


  void decrementItem(String id) {
    final index = _itemsRent.indexWhere((item) => item.id.toString() == id);
    if (index != -1) {
      if (_itemsRent[index].quantity! > 1) {
        _itemsRent[index].quantity = _itemsRent[index].quantity! - 1;

        double price = _itemsRent[index].rate ?? 0;
        double gst = _itemsRent[index].gst ?? 0;

        // Price + GST per quantity
        double priceWithGst = price + gst;

        // Total Price = (price + gst) * quantity
        _itemsRent[index].totalPrice = priceWithGst * _itemsRent[index].quantity!;
      } else {
        _itemsRent.removeAt(index);
      }
      _saveCart();
      notifyListeners();
    }
  }

  int totalPrice() {
    double totalPrice = 0;
    for (int i = 0; i < _itemsRent.length; i++) {
      totalPrice += _itemsRent[i].totalPrice!;
    }
    if (kDebugMode) {
      print('Total Price: $totalPrice');
    }
    return totalPrice.round();
  }

}
