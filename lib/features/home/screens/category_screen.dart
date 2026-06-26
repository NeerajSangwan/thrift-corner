import 'package:flutter/material.dart';
import 'package:thrift_corner/features/cart/screens/cart_items.dart';
import 'package:thrift_corner/features/home/screens/cart_screen.dart';
import 'package:thrift_corner/features/home/screens/category_products_screen.dart';
import 'package:thrift_corner/features/home/screens/wishlist_screen.dart';
import 'package:thrift_corner/core/storage/local_storage.dart';
import 'package:thrift_corner/features/cart/screens/wishlist_items.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final List<Map<String, dynamic>> _categories = const [
    {'name': 'beauty', 'icon': Icons.face_retouching_natural},
    {'name': 'fragrances', 'icon': Icons.local_florist},
    {'name': 'furniture', 'icon': Icons.chair_alt},
    {'name': 'groceries', 'icon': Icons.shopping_basket},
    {'name': 'smartphones', 'icon': Icons.smartphone},
    {'name': 'laptops', 'icon': Icons.laptop_mac},
    {'name': 'mens-shirts', 'icon': Icons.checkroom},
    {'name': 'mens-shoes', 'icon': Icons.hiking},
    {'name': 'womens-dresses', 'icon': Icons.woman},
    {'name': 'womens-shoes', 'icon': Icons.diamond},
  ];

  Future<void> _loadData() async {
    final loadedCart = await LocalStorage.loadCart();
    final loadedWishlist = await LocalStorage.loadWishlist();

    if (!mounted) return;

    setState(() {
      cartItems.clear();
      cartItems.addAll(List<Map<String, dynamic>>.from(loadedCart));

      wishlistItems.clear();
      wishlistItems.addAll(List<Map<String, dynamic>>.from(loadedWishlist));
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Categories'),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const WishlistScreen()),
              );
              if (mounted) _loadData();
            },
            icon: const Icon(Icons.favorite_border, color: Colors.black),
          ),
          IconButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
              if (mounted) _loadData();
            },
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.black,
                  size: 26,
                ),
                if (cartItems.isNotEmpty)
                  Positioned(
                    right: -8,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Center(
                        child: Text(
                          cartItems.length > 9
                              ? '9+'
                              : cartItems.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: _categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final category = _categories[index];

            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryProductsScreen(
                      category: category['name'] as String,
                    ),
                  ),
                );
                _loadData();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(category['icon'] as IconData, size: 50),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        (category['name'] as String)
                            .replaceAll('-', ' ')
                            .toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
