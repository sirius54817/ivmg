import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create product
  Future<Product> createProduct({
    required String name,
    required ProductCategory category,
    required String itemCode,
    required String sslcCode,
    required int stockCount,
    required String createdBy,
  }) async {
    final now = DateTime.now();
    final productData = {
      'name': name,
      'category': category.name,
      'itemCode': itemCode,
      'sslcCode': sslcCode,
      'stockCount': stockCount,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    };

    final docRef = await _firestore.collection('products').add(productData);
    final doc = await docRef.get();
    return Product.fromFirestore(doc);
  }

  // Update stock count
  Future<void> updateStock(String productId, int newCount) async {
    await _firestore.collection('products').doc(productId).update({
      'stockCount': newCount,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Increase stock count
  Future<void> increaseStock(String productId, int amount) async {
    final doc = await _firestore.collection('products').doc(productId).get();
    if (doc.exists) {
      final product = Product.fromFirestore(doc);
      await updateStock(productId, product.stockCount + amount);
    }
  }

  // Decrease stock count (for sales)
  Future<void> decreaseStock(String productId, int amount) async {
    final doc = await _firestore.collection('products').doc(productId).get();
    if (doc.exists) {
      final product = Product.fromFirestore(doc);
      final newCount = product.stockCount - amount;
      if (newCount < 0) {
        throw Exception('Insufficient stock');
      }
      await updateStock(productId, newCount);
    }
  }

  // Get all products
  Stream<List<Product>> getProducts() {
    return _firestore
        .collection('products')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  // Get products by category
  Stream<List<Product>> getProductsByCategory(ProductCategory category) {
    return _firestore
        .collection('products')
        .where('category', isEqualTo: category.name)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  // Get single product
  Future<Product?> getProduct(String productId) async {
    final doc = await _firestore.collection('products').doc(productId).get();
    if (doc.exists) {
      return Product.fromFirestore(doc);
    }
    return null;
  }
}
