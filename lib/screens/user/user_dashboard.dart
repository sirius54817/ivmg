import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/product_service.dart';
import '../../models/app_user.dart';
import '../../models/product.dart';
import '../../models/user_role.dart';
import '../login_screen.dart';
import 'create_staff_dialog.dart';
import 'create_product_dialog.dart';
import 'product_details_dialog.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _userService = UserService();
  final _productService = ProductService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

  void _showCreateStaffDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateStaffDialog(
        currentUserId: _authService.currentUser!.uid,
      ),
    );
  }

  void _showCreateProductDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateProductDialog(
        currentUserId: _authService.currentUser!.uid,
      ),
    );
  }

  void _showProductDetails(Product product) {
    showDialog(
      context: context,
      builder: (context) => ProductDetailsDialog(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
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
            Tab(text: 'Staff', icon: Icon(Icons.people)),
            Tab(text: 'Products', icon: Icon(Icons.inventory)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStaffTab(),
          _buildProductsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            _showCreateStaffDialog();
          } else {
            _showCreateProductDialog();
          }
        },
        icon: const Icon(Icons.add),
        label: Text(_tabController.index == 0 ? 'Add Staff' : 'Add Product'),
      ),
    );
  }

  Widget _buildStaffTab() {
    return StreamBuilder<List<AppUser>>(
      stream: _userService.getUsersCreatedBy(_authService.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final staff = snapshot.data ?? [];

        if (staff.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No staff members yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add staff to help manage sales',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: staff.length,
          itemBuilder: (context, index) {
            final member = staff[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  child: Text(
                    member.name[0].toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ),
                title: Text(member.name),
                subtitle: Text(member.email),
                trailing: Chip(
                  label: Text(member.role.displayName),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProductsTab() {
    return StreamBuilder<List<Product>>(
      stream: _productService.getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No products yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add products to start managing inventory',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        // Group products by category
        final cat1 = products.where((p) => p.category == ProductCategory.cat1).toList();
        final cat2 = products.where((p) => p.category == ProductCategory.cat2).toList();
        final cat3 = products.where((p) => p.category == ProductCategory.cat3).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (cat1.isNotEmpty) ...[
              Text(
                ProductCategory.cat1.displayName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              ...cat1.map((product) => _buildProductCard(product)),
              const SizedBox(height: 16),
            ],
            if (cat2.isNotEmpty) ...[
              Text(
                ProductCategory.cat2.displayName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              ...cat2.map((product) => _buildProductCard(product)),
              const SizedBox(height: 16),
            ],
            if (cat3.isNotEmpty) ...[
              Text(
                ProductCategory.cat3.displayName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              ...cat3.map((product) => _buildProductCard(product)),
            ],
          ],
        );
      },
    );
  }

  Widget _buildProductCard(Product product) {
    final isLowStock = product.stockCount < 10;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.inventory_2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(product.name),
        subtitle: Text('Code: ${product.itemCode} | SSLC: ${product.sslcCode}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Stock: ${product.stockCount}',
              style: TextStyle(
                color: isLowStock
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isLowStock)
              Text(
                'Low Stock',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        onTap: () => _showProductDetails(product),
      ),
    );
  }
}
