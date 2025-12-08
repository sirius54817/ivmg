import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/product_service.dart';
import '../../models/app_user.dart';
import '../../models/product.dart';
import '../login_screen.dart';
import 'create_staff_dialog.dart';
import 'create_product_dialog.dart';
import 'product_details_dialog.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final _authService = AuthService();
  final _userService = UserService();
  final _productService = ProductService();
  
  int _currentNavIndex = 0;
  AppUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _userService.getUser(_authService.currentUser!.uid);
    if (mounted) {
      setState(() => _currentUser = user);
    }
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
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Custom Header Bar
          _buildHeaderBar(theme),
          
          // Main Content
          Expanded(
            child: IndexedStack(
              index: _currentNavIndex,
              children: [
                _buildDashboardTab(theme),
                _buildStaffTab(theme),
                _buildProductsTab(theme),
                _buildReportsTab(theme),
              ],
            ),
          ),
        ],
      ),
      
      // Modern Bottom Navigation
      bottomNavigationBar: _buildBottomNav(theme),
      
      // Floating Action Button
      floatingActionButton: _currentNavIndex == 1 || _currentNavIndex == 2
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: _currentNavIndex == 1 ? _showCreateStaffDialog : _showCreateProductDialog,
                backgroundColor: Colors.transparent,
                elevation: 0,
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: Text(
                  _currentNavIndex == 1 ? 'Add Staff' : 'Add Product',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            )
          : null,
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // HEADER BAR
  // ═══════════════════════════════════════════════════════════════════
  
  Widget _buildHeaderBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Profile Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _currentUser?.name.isNotEmpty == true 
                      ? _currentUser!.name[0].toUpperCase() 
                      : 'U',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Welcome Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome back,',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    _currentUser?.name ?? 'User',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Sign Out Button
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: _signOut,
                icon: Icon(Icons.logout_rounded, color: theme.colorScheme.error),
                tooltip: 'Sign Out',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // DASHBOARD TAB (Home)
  // ═══════════════════════════════════════════════════════════════════
  
  Widget _buildDashboardTab(ThemeData theme) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Card - Inventory Overview
          StreamBuilder<List<Product>>(
            stream: _productService.getProducts(),
            builder: (context, snapshot) {
              final products = snapshot.data ?? [];
              final lowStockCount = products.where((p) => p.stockCount < 10).length;
              final totalStock = products.fold<int>(0, (sum, p) => sum + p.stockCount);
              
              return _buildHeroCard(
                theme: theme,
                label: lowStockCount > 0 ? 'Attention Required' : 'All Good',
                icon: lowStockCount > 0 ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                headline: lowStockCount > 0 
                    ? '$lowStockCount items need restocking'
                    : 'Inventory is healthy',
                subtext: 'Total: ${products.length} SKUs • $totalStock units in stock',
                color: lowStockCount > 0 ? theme.colorScheme.error : theme.colorScheme.primary,
                onTap: () => setState(() => _currentNavIndex = 2),
              );
            },
          ),
          
          const SizedBox(height: 28),
          
          // Quick Actions
          Text(
            'Quick Actions',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildQuickActions(theme),
          
          const SizedBox(height: 28),
          
          // Stats Cards
          Text(
            'Overview',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildStatsRow(theme),
          
          const SizedBox(height: 28),
          
          // Recent Activity
          Text(
            'Recent Products',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildRecentProducts(theme),
        ],
      ),
    );
  }

  Widget _buildHeroCard({
    required ThemeData theme,
    required String label,
    required IconData icon,
    required String headline,
    required String subtext,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withValues(alpha: 0.8)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background decoration
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  headline,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtext,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View Details',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, color: color, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    final actions = [
      _QuickAction(Icons.add_box_outlined, 'Add\nProduct', const Color(0xFFE8F5E9), _showCreateProductDialog),
      _QuickAction(Icons.people_outline, 'Add\nStaff', const Color(0xFFFFF3E0), _showCreateStaffDialog),
      _QuickAction(Icons.inventory_2_outlined, 'View\nInventory', const Color(0xFFE3F2FD), () => setState(() => _currentNavIndex = 2)),
      _QuickAction(Icons.assessment_outlined, 'Reports', const Color(0xFFF3E5F5), () => setState(() => _currentNavIndex = 3)),
    ];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((action) {
        return Expanded(
          child: GestureDetector(
            onTap: action.onTap,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: action.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: action.color.withValues(alpha: 0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      action.icon,
                      color: HSLColor.fromColor(action.color).withLightness(0.3).toColor(),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    action.label,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatsRow(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: StreamBuilder<List<Product>>(
            stream: _productService.getProducts(),
            builder: (context, snapshot) {
              final count = snapshot.data?.length ?? 0;
              return _buildStatCard(theme, 'Total Products', '$count', Icons.inventory_2_outlined, theme.colorScheme.primary);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StreamBuilder<List<AppUser>>(
            stream: _userService.getUsersCreatedBy(_authService.currentUser!.uid),
            builder: (context, snapshot) {
              final count = snapshot.data?.length ?? 0;
              return _buildStatCard(theme, 'Staff Members', '$count', Icons.people_outline, theme.colorScheme.secondary);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(ThemeData theme, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentProducts(ThemeData theme) {
    return StreamBuilder<List<Product>>(
      stream: _productService.getProducts(),
      builder: (context, snapshot) {
        final products = snapshot.data?.take(3).toList() ?? [];
        
        if (products.isEmpty) {
          return _buildEmptyState(
            theme,
            Icons.inventory_2_outlined,
            'No products yet',
            'Add your first product to get started',
          );
        }
        
        return Column(
          children: products.map((product) => _buildModernProductCard(theme, product)).toList(),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // STAFF TAB
  // ═══════════════════════════════════════════════════════════════════
  
  Widget _buildStaffTab(ThemeData theme) {
    return StreamBuilder<List<AppUser>>(
      stream: _userService.getUsersCreatedBy(_authService.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary),
          );
        }

        final staff = snapshot.data ?? [];

        if (staff.isEmpty) {
          return _buildEmptyState(
            theme,
            Icons.people_outline,
            'No staff members yet',
            'Add staff to help manage sales',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: staff.length,
          itemBuilder: (context, index) {
            final member = staff[index];
            return _buildStaffCard(theme, member);
          },
        );
      },
    );
  }

  Widget _buildStaffCard(ThemeData theme, AppUser member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [theme.colorScheme.secondary, theme.colorScheme.primary],
              ),
            ),
            child: Center(
              child: Text(
                member.name[0].toUpperCase(),
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  member.email,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              member.role.displayName,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // PRODUCTS TAB
  // ═══════════════════════════════════════════════════════════════════
  
  Widget _buildProductsTab(ThemeData theme) {
    return StreamBuilder<List<Product>>(
      stream: _productService.getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary),
          );
        }

        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return _buildEmptyState(
            theme,
            Icons.inventory_2_outlined,
            'No products yet',
            'Add products to start managing inventory',
          );
        }

        // Group products by category
        final grouped = <ProductCategory, List<Product>>{};
        for (final p in products) {
          grouped.putIfAbsent(p.category, () => []).add(p);
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: grouped.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    entry.key.displayName,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...entry.value.map((product) => _buildModernProductCard(theme, product)),
                const SizedBox(height: 20),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildModernProductCard(ThemeData theme, Product product) {
    final isLowStock = product.stockCount < 10;

    return GestureDetector(
      onTap: () => _showProductDetails(product),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLowStock 
                ? theme.colorScheme.error.withValues(alpha: 0.3)
                : theme.colorScheme.outline.withValues(alpha: 0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: (isLowStock ? theme.colorScheme.error : theme.colorScheme.primary)
                  .withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: (isLowStock ? theme.colorScheme.error : theme.colorScheme.primary)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.inventory_2_rounded,
                color: isLowStock ? theme.colorScheme.error : theme.colorScheme.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Code: ${product.itemCode}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (isLowStock ? theme.colorScheme.error : theme.colorScheme.primary)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${product.stockCount}',
                    style: TextStyle(
                      color: isLowStock ? theme.colorScheme.error : theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isLowStock) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Low Stock',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // REPORTS TAB
  // ═══════════════════════════════════════════════════════════════════
  
  Widget _buildReportsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Download Reports',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Export your data for analysis',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          
          _buildReportCard(
            theme,
            icon: Icons.people_outline,
            title: 'Staff Attendance Report',
            description: 'Download attendance records for all staff members',
            color: theme.colorScheme.secondary,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Attendance report download coming soon'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          _buildReportCard(
            theme,
            icon: Icons.point_of_sale_outlined,
            title: 'Sales Report',
            description: 'Download sales records and analytics data',
            color: theme.colorScheme.primary,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Sales report download coming soon'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          _buildReportCard(
            theme,
            icon: Icons.inventory_2_outlined,
            title: 'Inventory Report',
            description: 'Export complete inventory stock levels',
            color: Colors.teal,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Inventory report download coming soon'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.download_rounded, color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // BOTTOM NAVIGATION
  // ═══════════════════════════════════════════════════════════════════
  
  Widget _buildBottomNav(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(theme, 0, Icons.dashboard_outlined, Icons.dashboard, 'Home'),
              _buildNavItem(theme, 1, Icons.people_outline, Icons.people, 'Staff'),
              _buildNavItem(theme, 2, Icons.inventory_2_outlined, Icons.inventory_2, 'Products'),
              _buildNavItem(theme, 3, Icons.assessment_outlined, Icons.assessment, 'Reports'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(ThemeData theme, int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentNavIndex == index;
    
    return GestureDetector(
      onTap: () => setState(() => _currentNavIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.5),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // EMPTY STATE
  // ═══════════════════════════════════════════════════════════════════
  
  Widget _buildEmptyState(ThemeData theme, IconData icon, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _QuickAction(this.icon, this.label, this.color, this.onTap);
}
