import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../imports.dart';
import '../model/cart_model.dart';

class CartProvider with ChangeNotifier {
  final List<CartModel> _items = [];
  static const String _cartKey = 'cart_items';

  CartProvider() {
    _loadCart();
  }

  List<CartModel> get items => [..._items];

  int get itemCount => _items.length;

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cartData = prefs.getString(_cartKey);
    if (cartData != null) {
      final List<dynamic> decodedData = jsonDecode(cartData);
      _items.clear();
      _items.addAll(decodedData.map((item) => CartModel.fromJson(item)).toList());
      notifyListeners();
    }
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(_items.map((item) => item.toJson()).toList());
    await prefs.setString(_cartKey, encodedData);
  }

  void addItem(CartModel cartModel) {
    int index = _items.indexWhere((item) => item.id == cartModel.id);
    if (index != -1) {
      CartModel existingItem = _items[index];
      CartModel updatedItem = existingItem.copyWith(
        quantity: existingItem.quantity! + cartModel.quantity!,
        totalPrice: existingItem.totalPrice! + cartModel.totalPrice!,
      );
      _items[index] = updatedItem;
    } else {
      _items.add(cartModel);
    }
    _saveCart();
    notifyListeners();
  }

  void removeItem(int id) {
    _items.removeWhere((element) => element.id == id);
    _saveCart();
    notifyListeners();
  }

  void increaseQuantity(int id) {
    final index = _items.indexWhere((e) => e.id == id);
    if (index != -1) {
      _items[index].quantity = _items[index].quantity! + 1;
      _items[index].totalPrice = _items[index].rate! * _items[index].quantity!;
      _saveCart();
      notifyListeners();
    }
  }

  void decreaseQuantity(int id) {
    final index = _items.indexWhere((e) => e.id == id);
    if (index != -1 && _items[index].quantity! > 1) {
      _items[index].quantity = _items[index].quantity! - 1;
      _items[index].totalPrice = _items[index].rate! * _items[index].quantity!;
      _saveCart();
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    _saveCart();
    notifyListeners();
  }

  void removeSingleItem(int id) {
    final index = _items.indexWhere((e) => e.id == id);
    if (index != -1) {
      if (_items[index].quantity! > 1) {
        _items[index].quantity = _items[index].quantity! - 1;
        _items[index].totalPrice = _items[index].rate! * _items[index].quantity!;
      } else {
        _items.removeWhere((element) => element.id == id);
      }
      _saveCart();
      notifyListeners();
    }
  }

  // Newly added incrementItem method with String id (from your second class)
  void incrementItem(String id) {
    final index = _items.indexWhere((item) => item.id.toString() == id);
    if (index != -1) {
      _items[index].quantity = _items[index].quantity! + 1;
      _items[index].totalPrice = _items[index].rate! * _items[index].quantity!;
      _saveCart();
      notifyListeners();
    }
  }

  // Newly added decrementItem method with String id (from your second class)
  void decrementItem(String id) {
    final index = _items.indexWhere((item) => item.id.toString() == id);
    if (index != -1) {
      if (_items[index].quantity! > 1) {
        _items[index].quantity = _items[index].quantity! - 1;
        _items[index].totalPrice = _items[index].rate! * _items[index].quantity!;
      } else {
        _items.removeAt(index);
      }
      _saveCart();
      notifyListeners();
    }
  }

  int totalPrice() {
    double totalPrice = 0;
    for (int i = 0; i < _items.length; i++) {
      // totalPrice += _items[i].totalPrice!;
      totalPrice += ((_items[i].rate! + _items[i].gst!) * _items[i].quantity!).round();
    }
    if (kDebugMode) {
      print('Total Price: $totalPrice');
    }
    return totalPrice.round();
  }
}
