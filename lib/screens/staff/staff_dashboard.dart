import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/product_service.dart';
import '../../services/sales_service.dart';
import '../../services/attendance_service.dart';
import '../../models/product.dart';
import '../../models/sale.dart';
import '../../models/attendance.dart' as attendance_model;
import '../login_screen.dart';
import 'attendance_screen.dart';

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _productService = ProductService();
  final _salesService = SalesService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Attendance', icon: Icon(Icons.fingerprint)),
            Tab(text: 'Sell Product', icon: Icon(Icons.point_of_sale)),
            Tab(text: 'My Sales', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AttendanceTab(authService: _authService),
          _SalesFormTab(),
          _MySalesTab(salesService: _salesService, authService: _authService),
        ],
      ),
    );
  }
}

class _SalesFormTab extends StatefulWidget {
  @override
  State<_SalesFormTab> createState() => _SalesFormTabState();
}

class _SalesFormTabState extends State<_SalesFormTab> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _authService = AuthService();
  final _productService = ProductService();
  final _salesService = SalesService();

  ProductCategory? _selectedCategory;
  String? _selectedProductId; // Store product ID instead of Product object
  Product? _selectedProduct; // Cache the actual product for display
  bool _isLoading = false;

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerAddressController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _submitSale() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a product'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = await _authService.getCurrentAppUser();
      if (currentUser == null) {
        throw Exception('User not found');
      }

      await _salesService.createSale(
        productId: _selectedProduct!.id,
        productName: _selectedProduct!.name,
        itemCode: _selectedProduct!.itemCode,
        customerName: _customerNameController.text.trim(),
        customerPhone: _customerPhoneController.text.trim(),
        customerAddress: _customerAddressController.text.trim(),
        staffId: currentUser.id,
        staffName: currentUser.name,
        quantity: int.parse(_quantityController.text),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sale recorded successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Reset form
        _formKey.currentState!.reset();
        _customerNameController.clear();
        _customerPhoneController.clear();
        _customerAddressController.clear();
        _quantityController.text = '1';
        setState(() {
          _selectedCategory = null;
          _selectedProductId = null;
          _selectedProduct = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to record sale: ${e.toString()}'),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer Information',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _customerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Customer Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter customer name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _customerPhoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _customerAddressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter address';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product Selection',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<ProductCategory>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Select Category',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: ProductCategory.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                          _selectedProductId = null;
                          _selectedProduct = null;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_selectedCategory != null)
                      StreamBuilder<List<Product>>(
                        stream: _productService
                            .getProductsByCategory(_selectedCategory!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final products = snapshot.data ?? [];

                          if (products.isEmpty) {
                            return const Text('No products in this category');
                          }

                          return DropdownButtonFormField<String>(
                            value: _selectedProductId,
                            decoration: const InputDecoration(
                              labelText: 'Select Product',
                              prefixIcon: Icon(Icons.inventory_2),
                            ),
                            items: products.map((product) {
                              return DropdownMenuItem(
                                value: product.id,
                                child: Text(
                                  '${product.name} (Stock: ${product.stockCount})',
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedProductId = value;
                                _selectedProduct = products.firstWhere(
                                  (p) => p.id == value,
                                );
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a product';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter quantity';
                        }
                        final quantity = int.tryParse(value);
                        if (quantity == null || quantity <= 0) {
                          return 'Please enter a valid quantity';
                        }
                        if (_selectedProduct != null &&
                            quantity > _selectedProduct!.stockCount) {
                          return 'Insufficient stock (Available: ${_selectedProduct!.stockCount})';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedProduct != null)
              Card(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Product Details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text('Name: ${_selectedProduct!.name}'),
                      Text('Item Code: ${_selectedProduct!.itemCode}'),
                      Text('SSLC Code: ${_selectedProduct!.sslcCode}'),
                      Text('Available Stock: ${_selectedProduct!.stockCount}'),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitSale,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit Sale'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MySalesTab extends StatelessWidget {
  final SalesService salesService;
  final AuthService authService;

  const _MySalesTab({
    required this.salesService,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = authService.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Please log in'));
    }

    return StreamBuilder<List<Sale>>(
      stream: salesService.getSalesByStaff(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final sales = snapshot.data ?? [];

        if (sales.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No sales yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your sales history will appear here',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sales.length,
          itemBuilder: (context, index) {
            final sale = sales[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.receipt, color: Colors.white),
                ),
                title: Text(sale.productName),
                subtitle: Text(
                  'Customer: ${sale.customerName} | Qty: ${sale.quantity}',
                ),
                trailing: Text(
                  '${sale.saleDate.day}/${sale.saleDate.month}/${sale.saleDate.year}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(context, 'Item Code', sale.itemCode),
                        _buildDetailRow(
                          context,
                          'Customer Phone',
                          sale.customerPhone,
                        ),
                        _buildDetailRow(
                          context,
                          'Customer Address',
                          sale.customerAddress,
                        ),
                        _buildDetailRow(
                          context,
                          'Quantity',
                          sale.quantity.toString(),
                        ),
                        _buildDetailRow(
                          context,
                          'Date',
                          '${sale.saleDate.day}/${sale.saleDate.month}/${sale.saleDate.year} ${sale.saleDate.hour}:${sale.saleDate.minute.toString().padLeft(2, '0')}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceTab extends StatelessWidget {
  final AuthService authService;

  const _AttendanceTab({required this.authService});

  @override
  Widget build(BuildContext context) {
    final currentUser = authService.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Please log in'));
    }

    final attendanceService = AttendanceService();

    return Column(
      children: [
        // Mark Attendance Button
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AttendanceScreen(),
                ),
              );
            },
            icon: const Icon(Icons.fingerprint),
            label: const Text('Mark Attendance'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),

        // Attendance History
        Expanded(
          child: StreamBuilder<List<attendance_model.Attendance>>(
            stream: attendanceService.getStaffAttendance(currentUser.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final attendances = snapshot.data ?? [];

              if (attendances.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_available,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No attendance records',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mark your attendance to see records here',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: attendances.length,
                itemBuilder: (context, index) {
                  final attendance = attendances[index];
                  final dateFormat = DateFormat('MMM dd, yyyy');
                  final timeFormat = DateFormat('hh:mm a');

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: attendance.isWithinRange
                            ? Colors.green
                            : Colors.orange,
                        child: Icon(
                          attendance.isWithinRange
                              ? Icons.check
                              : Icons.warning,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(dateFormat.format(attendance.checkInTime)),
                      subtitle: Text(
                        'Check-in: ${timeFormat.format(attendance.checkInTime)}',
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            attendance.isWithinRange ? 'Valid' : 'Out of Range',
                            style: TextStyle(
                              color: attendance.isWithinRange
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${attendance.latitude.toStringAsFixed(4)}, ${attendance.longitude.toStringAsFixed(4)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
