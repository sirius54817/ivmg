import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/product_service.dart';
import '../../models/product.dart';

class ProductDetailsDialog extends StatefulWidget {
  final Product product;

  const ProductDetailsDialog({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsDialog> createState() => _ProductDetailsDialogState();
}

class _ProductDetailsDialogState extends State<ProductDetailsDialog> {
  final _productService = ProductService();
  final _increaseController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _increaseController.dispose();
    super.dispose();
  }

  Future<void> _increaseStock() async {
    final amount = int.tryParse(_increaseController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _productService.increaseStock(widget.product.id, amount);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stock updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update stock: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product.name),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Category', widget.product.category.displayName),
            const SizedBox(height: 8),
            _buildInfoRow('Item Code', widget.product.itemCode),
            const SizedBox(height: 8),
            _buildInfoRow('SSLC Code', widget.product.sslcCode),
            const SizedBox(height: 8),
            _buildInfoRow('Current Stock', widget.product.stockCount.toString()),
            const Divider(height: 32),
            Text(
              'Increase Stock',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _increaseController,
              decoration: const InputDecoration(
                labelText: 'Amount to Add',
                prefixIcon: Icon(Icons.add),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _increaseStock,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Update Stock'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
