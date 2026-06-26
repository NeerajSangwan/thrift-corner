import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:thrift_corner/core/storage/local_storage.dart';
import 'package:thrift_corner/features/cart/screens/cart_items.dart';
import 'package:thrift_corner/features/cart/screens/wishlist_items.dart';
import 'package:thrift_corner/features/home/screens/cart_screen.dart';
import 'package:thrift_corner/features/home/screens/product_details_screen.dart';
import 'package:thrift_corner/features/home/screens/wishlist_screen.dart';

import 'package:thrift_corner/core/utils/snackbar_helper.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String category;

  const CategoryProductsScreen({super.key, required this.category});

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;

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

  Future<void> _fetchProducts() async {
    try {
      final response = await Dio().get(
        'https://dummyjson.com/products/category/${widget.category}',
      );

      if (!mounted) return;

      setState(() {
        _products = List<Map<String, dynamic>>.from(response.data['products']);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      SnackbarHelper.showError(context, 'Failed to load products');
    }
  }

  int _getQuantity(int productId) {
    for (var item in cartItems) {
      if (item['product']['id'] == productId) {
        return item['quantity'] as int;
      }
    }
    return 0;
  }

  bool _isWishlisted(int productId) {
    return wishlistItems.any((item) => item['id'] == productId);
  }

  Future<void> _toggleWishlist(Map<String, dynamic> product) async {
    if (_isWishlisted(product['id'] as int)) {
      wishlistItems.removeWhere((item) => item['id'] == product['id']);
      SnackbarHelper.showError(context, 'Removed from wishlist');
    } else {
      wishlistItems.add(product);
      SnackbarHelper.showSuccess(context, 'Added to wishlist');
    }
    setState(() {});
    await LocalStorage.saveWishlist(wishlistItems);
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final titleFormatted = widget.category.replaceAll('-', ' ').toUpperCase();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(titleFormatted),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xfff8f8f8),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : _products.isEmpty
          ? const Center(child: Text('No products found in this category.'))
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              itemCount: _products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 13,
                mainAxisSpacing: 13,
                childAspectRatio: 0.58,
              ),
              itemBuilder: (context, index) {
                final product = _products[index];
                final productId = product['id'] as int;
                final isInWishlist = _isWishlisted(productId);

                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsScreen(product: product),
                      ),
                    );
                    if (mounted) _loadData();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: Image.network(
                                product['thumbnail'] ?? '',
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 160,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => _toggleWishlist(product),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isInWishlist
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isInWishlist
                                        ? Colors.red
                                        : Colors.black,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['title'] ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${product['price']}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '⭐ ${product['rating'] ?? 'N/A'}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.amber,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _getQuantity(productId) == 0
                                  ? SizedBox(
                                      width: double.infinity,
                                      height: 36,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        onPressed: () async {
                                          setState(() {
                                            cartItems.add({
                                              'product': product,
                                              'quantity': 1,
                                            });
                                          });
                                          await LocalStorage.saveCart(
                                            cartItems,
                                          );
                                          SnackbarHelper.showSuccess(
                                            context,
                                            'Added to cart',
                                          );
                                        },
                                        child: const Text(
                                          'Add To Cart',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      height: 36,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          InkWell(
                                            onTap: () async {
                                              final itemIndex = cartItems
                                                  .indexWhere(
                                                    (element) =>
                                                        element['product']['id'] ==
                                                        productId,
                                                  );
                                              if (itemIndex != -1) {
                                                if ((cartItems[itemIndex]['quantity']
                                                        as int) >
                                                    1) {
                                                  cartItems[itemIndex]['quantity'] =
                                                      (cartItems[itemIndex]['quantity']
                                                          as int) -
                                                      1;
                                                } else {
                                                  cartItems.removeAt(itemIndex);
                                                  SnackbarHelper.showError(
                                                    context,
                                                    'Removed from cart',
                                                  );
                                                }
                                              }
                                              setState(() {});
                                              await LocalStorage.saveCart(
                                                cartItems,
                                              );
                                            },
                                            child: const Icon(
                                              Icons.remove,
                                              size: 18,
                                            ),
                                          ),
                                          Text(
                                            '✓ ${_getQuantity(productId)}',
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              setState(() {
                                                final itemIndex = cartItems
                                                    .indexWhere(
                                                      (element) =>
                                                          element['product']['id'] ==
                                                          productId,
                                                    );
                                                if (itemIndex != -1) {
                                                  cartItems[itemIndex]['quantity'] =
                                                      (cartItems[itemIndex]['quantity']
                                                          as int) +
                                                      1;
                                                }
                                              });
                                              await LocalStorage.saveCart(
                                                cartItems,
                                              );
                                            },
                                            child: const Icon(
                                              Icons.add,
                                              size: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
