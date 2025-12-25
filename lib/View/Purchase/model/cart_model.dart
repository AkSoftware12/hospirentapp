class CartModel {
  int? id;
  int? quantity;
  double? totalPrice;
  String? product_name;
  double? rate;
  double? gst;
  double? product_gst;
  String? category;
  String? image;
  String? measurement;
  String? product_id;

  CartModel({
    this.id,
    this.quantity,
    this.totalPrice,
    this.product_name,
    this.rate,
    this.gst,
    this.product_gst,
    this.category,
    this.image,
    this.measurement,
    this.product_id,
  });

  CartModel copyWith({
    int? id,
    int? quantity,
    double? totalPrice,
    String? product_name,
    double? rate,
    double? gst,
    double? gstPer,
    String? category,
    String? image,
    String? measurement,
    String? product_id,
  }) {
    return CartModel(
      id: id ?? this.id,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
      product_name: product_name ?? this.product_name,
      rate: rate ?? this.rate,
      gst: gst ?? this.gst,
      product_gst: gstPer ?? this.product_gst,
      category: category ?? this.category,
      image: image ?? this.image,
      measurement: measurement ?? this.measurement,
      product_id: product_id ?? this.product_id,
    );
  }

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'],
      quantity: json['quantity'],
      totalPrice: json['totalPrice'],
      product_name: json['product_name'],
      rate: json['rate'],
      gst: json['gst'],
      product_gst: json['product_gst'],
      category: json['category'],
      image: json['image'],
      measurement: json['measurement'],
      product_id: json['product_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['quantity'] = quantity;
    data['totalPrice'] = totalPrice;
    data['product_name'] = product_name;
    data['rate'] = rate;
    data['gst'] = gst;
    data['product_gst'] = product_gst;
    data['category'] = category;
    data['image'] = image;
    data['measurement'] = measurement;
    data['product_id'] = product_id;
    return data;
  }
}
