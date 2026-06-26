import 'package:flutter/material.dart';
import 'package:thrift_corner/core/storage/local_storage.dart';
import 'package:thrift_corner/features/cart/screens/cart_items.dart';
import 'package:thrift_corner/features/cart/screens/wishlist_items.dart';
import 'package:thrift_corner/features/home/screens/cart_screen.dart';
import 'package:thrift_corner/features/home/screens/main_screen.dart';
import 'package:thrift_corner/features/home/screens/product_details_screen.dart';

import 'package:thrift_corner/core/utils/snackbar_helper.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const MainScreen()),
              (route) => false,
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Wishlist'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.black, size: 26),
          ),
          IconButton(
            onPressed: () async {
              await Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => CartScreen()));
              setState(() {});
            },
            icon: Badge(
              label: Text(
                cartItems.length.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              isLabelVisible: cartItems.isNotEmpty,
              backgroundColor: Colors.red,
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.black,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: wishlistItems.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.heart_broken, color: Colors.grey, size: 60),
                  SizedBox(height: 3),
                  Text(
                    'Your Wishlist is Empty',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(10),
              child: GridView.builder(
                itemCount: wishlistItems.length,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.68,
                ),
                itemBuilder: (context, index) {
                  final productData = wishlistItems[index];

                  return GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailsScreen(
                            product: Map<String, dynamic>.from(productData),
                          ),
                        ),
                      );
                      setState(() {});
                    },
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: Image.network(
                                    productData['thumbnail'],
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      productData['title'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '\$${productData['price']}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '⭐ ${productData['rating']}',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    const SizedBox(height: 6),
                                    GestureDetector(
                                      onTap: () async {
                                        bool found = false;
                                        for (var item in cartItems) {
                                          if (item['product']['id'] ==
                                              productData['id']) {
                                            found = true;
                                            break;
                                          }
                                        }
                                        if (!found) {
                                          cartItems.add({
                                            'product':
                                                Map<String, dynamic>.from(
                                                  productData,
                                                ),
                                            'quantity': 1,
                                          });
                                        }
                                        wishlistItems.removeAt(index);
                                        setState(() {});
                                        await LocalStorage.saveCart(cartItems);
                                        await LocalStorage.saveWishlist(
                                          wishlistItems,
                                        );
                                        if (mounted) {
                                          SnackbarHelper.showSuccess(
                                            context,
                                            'Added to cart',
                                          );
                                        }
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        height: 36,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 1.4,
                                          ),
                                        ),
                                        child: const Text(
                                          'Add To Cart',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () async {
                              wishlistItems.removeAt(index);
                              setState(() {});
                              await LocalStorage.saveWishlist(wishlistItems);
                              if (mounted) {
                                SnackbarHelper.showError(
                                  context,
                                  'Removed from wishlist',
                                );
                              }
                            },
                            child: const Icon(Icons.close, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
