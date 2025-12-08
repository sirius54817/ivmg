import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sale.dart';
import 'product_service.dart';

class SalesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProductService _productService = ProductService();

  // Create sale and update stock
  Future<Sale> createSale({
    required String productId,
    required String productName,
    required String itemCode,
    required String customerName,
    required String customerPhone,
    required String customerAddress,
    required String staffId,
    required String staffName,
    required int quantity,
  }) async {
    // Check if product has enough stock
    final product = await _productService.getProduct(productId);
    if (product == null) {
      throw Exception('Product not found');
    }
    if (product.stockCount < quantity) {
      throw Exception('Insufficient stock. Available: ${product.stockCount}');
    }

    // Create sale record
    final saleData = {
      'productId': productId,
      'productName': productName,
      'itemCode': itemCode,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'staffId': staffId,
      'staffName': staffName,
      'quantity': quantity,
      'saleDate': Timestamp.fromDate(DateTime.now()),
    };

    final docRef = await _firestore.collection('sales').add(saleData);

    // Update product stock
    await _productService.decreaseStock(productId, quantity);

    final doc = await docRef.get();
    return Sale.fromFirestore(doc);
  }

  // Get all sales
  Stream<List<Sale>> getSales() {
    return _firestore
        .collection('sales')
        .orderBy('saleDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Sale.fromFirestore(doc)).toList();
    });
  }

  // Get sales by staff
  Stream<List<Sale>> getSalesByStaff(String staffId) {
    return _firestore
        .collection('sales')
        .where('staffId', isEqualTo: staffId)
        .orderBy('saleDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Sale.fromFirestore(doc)).toList();
    });
  }
}
