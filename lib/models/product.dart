import 'package:cloud_firestore/cloud_firestore.dart';

enum ProductCategory {
  cat1,
  cat2,
  cat3;

  String get displayName {
    switch (this) {
      case ProductCategory.cat1:
        return 'Category 1';
      case ProductCategory.cat2:
        return 'Category 2';
      case ProductCategory.cat3:
        return 'Category 3';
    }
  }
}

class Product {
  final String id;
  final String name;
  final ProductCategory category;
  final String itemCode;
  final String sslcCode;
  final int stockCount;
  final String createdBy; // User ID who created the product
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.itemCode,
    required this.sslcCode,
    required this.stockCount,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      category: ProductCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => ProductCategory.cat1,
      ),
      itemCode: data['itemCode'] ?? '',
      sslcCode: data['sslcCode'] ?? '',
      stockCount: data['stockCount'] ?? 0,
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category.name,
      'itemCode': itemCode,
      'sslcCode': sslcCode,
      'stockCount': stockCount,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Product copyWith({
    String? id,
    String? name,
    ProductCategory? category,
    String? itemCode,
    String? sslcCode,
    int? stockCount,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      itemCode: itemCode ?? this.itemCode,
      sslcCode: sslcCode ?? this.sslcCode,
      stockCount: stockCount ?? this.stockCount,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
