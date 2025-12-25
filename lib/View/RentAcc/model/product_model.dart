import 'dart:convert';

class RentProductModel {
  final int? id;
  final String? title;
  final String? slug;
  final String? photo;
  final Category? category;
  final double? price;
  final double? gst;
  final double? buyPrice;
  final double? rentPrice;
  final int? quantity;
  final double? weight;
  final String? description;
  final String? photoUrl;
  final String? measurement;

  RentProductModel({
    this.id,
    this.title,
    this.slug,
    this.photo,
    this.category,
    this.price,
    this.gst,
    this.buyPrice,
    this.rentPrice,
    this.quantity,
    this.weight,
    this.description,
    this.photoUrl,
    this.measurement,
  });

  factory RentProductModel.fromJson(Map<String, dynamic> json) {
    return RentProductModel(
      id: json['id'] as int?,
      title: json['name'] as String?,
      slug: json['slug'] as String?,
      photo: json['photo'] as String?,
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
      price: json['rate'] != null ? (json['rate'] as num?)?.toDouble() : null,
      gst: json['gst'] != null ? (json['gst'] as num?)?.toDouble() : null,
      buyPrice: json['buy_price'] != null ? (json['buy_price'] as num?)?.toDouble() : null,
      rentPrice: json['rent_price'] != null ? (json['rent_price'] as num?)?.toDouble() : null,
      quantity: json['quantity'] as int?,
      weight: json['weight'] != null ? (json['weight'] as num?)?.toDouble() : null,
      description: json['description'] as String?,
      photoUrl: json['first_image'] as String?,
      measurement: json['measurement'] as String?,
    );
  }
}

class Category {
  final int? id;
  final String? title;
  final String? photoUrl;

  Category({this.id, this.title, this.photoUrl});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int?,
      title: json['title'] as String?,
      photoUrl: json['photo_url'] as String?,
    );
  }
}