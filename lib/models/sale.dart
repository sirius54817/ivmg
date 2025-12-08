import 'package:cloud_firestore/cloud_firestore.dart';

class Sale {
  final String id;
  final String productId;
  final String productName;
  final String itemCode;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String staffId;
  final String staffName;
  final int quantity;
  final DateTime saleDate;

  Sale({
    required this.id,
    required this.productId,
    required this.productName,
    required this.itemCode,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.staffId,
    required this.staffName,
    required this.quantity,
    required this.saleDate,
  });

  factory Sale.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Sale(
      id: doc.id,
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      itemCode: data['itemCode'] ?? '',
      customerName: data['customerName'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      customerAddress: data['customerAddress'] ?? '',
      staffId: data['staffId'] ?? '',
      staffName: data['staffName'] ?? '',
      quantity: data['quantity'] ?? 1,
      saleDate: (data['saleDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'productName': productName,
      'itemCode': itemCode,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'staffId': staffId,
      'staffName': staffName,
      'quantity': quantity,
      'saleDate': Timestamp.fromDate(saleDate),
    };
  }
}
