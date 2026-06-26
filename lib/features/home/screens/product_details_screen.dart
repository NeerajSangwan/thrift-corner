import 'package:flutter/material.dart';
import 'package:thrift_corner/core/storage/local_storage.dart';
import 'package:thrift_corner/features/cart/screens/cart_items.dart';
import 'package:thrift_corner/features/cart/screens/wishlist_items.dart';
import 'package:thrift_corner/features/home/screens/cart_screen.dart';
import 'package:thrift_corner/features/home/screens/wishlist_screen.dart';

import 'package:thrift_corner/core/utils/snackbar_helper.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductDetailsScreen({required this.product, super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int currentImage = 0;

  bool get isWishlisted {
    return wishlistItems.any((item) => item['id'] == widget.product['id']);
  }

  int getQuantity() {
    for (var item in cartItems) {
      if (item['product']['id'] == widget.product['id']) {
        return item['quantity'];
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: Colors.white,
        title: Text(
          widget.product['title'] ?? '',
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const WishlistScreen()),
              );
              setState(() {});
            },
            icon: Icon(
              isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: isWishlisted ? Colors.red : Colors.black,
              size: 26,
            ),
          ),
          IconButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
              setState(() {});
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
          child: Column(
            children: [
              if (widget.product['images'] != null &&
                  widget.product['images'].isNotEmpty)
                SizedBox(
                  height: 320,
                  child: PageView.builder(
                    onPageChanged: (value) {
                      setState(() {
                        currentImage = value;
                      });
                    },
                    itemCount: widget.product['images'].length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          widget.product['images'][index],
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 5),
              Center(
                child: Text(
                  '${currentImage + 1}/${widget.product['images']?.length ?? 0}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 9),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product['brand'] ?? '',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    widget.product['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        '\$${widget.product['price']}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 5),
                      if (widget.product['discountPercentage'] != null)
                        Text(
                          '(${double.parse(widget.product['discountPercentage'].toString()).toStringAsFixed(0)}% OFF)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '⭐ ${widget.product['rating'] ?? '0.0'}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    (widget.product['stock'] ?? 0) > 0
                        ? 'In Stock'
                        : 'Out of Stock',
                    style: TextStyle(
                      color: (widget.product['stock'] ?? 0) > 0
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () async {
                      if (isWishlisted) {
                        wishlistItems.removeWhere(
                          (item) => item['id'] == widget.product['id'],
                        );
                        await LocalStorage.saveWishlist(wishlistItems);
                        if (mounted) {
                          SnackbarHelper.showError(
                            context,
                            'Removed from wishlist',
                          );
                        }
                      } else {
                        wishlistItems.add(widget.product);
                        await LocalStorage.saveWishlist(wishlistItems);
                        if (mounted) {
                          SnackbarHelper.showSuccess(
                            context,
                            'Added to wishlist',
                          );
                        }
                      }
                      setState(() {});
                    },
                    child: Container(
                      width: double.infinity,
                      height: 58,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isWishlisted ? Colors.red : Colors.black,
                          width: 1.4,
                        ),
                        color: isWishlisted ? Colors.red : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isWishlisted
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isWishlisted ? Colors.white : Colors.black,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isWishlisted ? 'Wishlisted' : 'Wishlist',
                            style: TextStyle(
                              color: isWishlisted ? Colors.white : Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () async {
                      if (getQuantity() == 0) {
                        cartItems.add({
                          'product': widget.product,
                          'quantity': 1,
                        });
                        wishlistItems.removeWhere(
                          (item) => item['id'] == widget.product['id'],
                        );
                        await LocalStorage.saveCart(cartItems);
                        await LocalStorage.saveWishlist(wishlistItems);

                        if (mounted)
                          SnackbarHelper.showSuccess(context, 'Added to cart');
                        setState(() {});
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 58,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1.4, color: Colors.black),
                        color: getQuantity() > 0 ? Colors.white : Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: getQuantity() == 0
                          ? const Center(
                              child: Text(
                                'Add to cart',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    for (var item in cartItems) {
                                      if (item['product']['id'] ==
                                          widget.product['id']) {
                                        if (item['quantity'] > 1) {
                                          item['quantity']--;
                                          await LocalStorage.saveCart(
                                            cartItems,
                                          );
                                          setState(() {});
                                        } else {
                                          _showRemoveDialog(context);
                                        }
                                        break;
                                      }
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.remove,
                                    color: Colors.black,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _showRemoveDialog(context),
                                  child: Text(
                                    'Added to cart ✓ ${getQuantity()}',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    for (var item in cartItems) {
                                      if (item['product']['id'] ==
                                          widget.product['id']) {
                                        item['quantity']++;
                                        await LocalStorage.saveCart(cartItems);
                                        setState(() {});
                                        break;
                                      }
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product['description'] ??
                        'No description available.',
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRemoveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Item'),
        content: const Text('Do you want to remove this item from cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              cartItems.removeWhere(
                (item) => item['product']['id'] == widget.product['id'],
              );
              await LocalStorage.saveCart(cartItems);
              if (mounted) {
                Navigator.pop(context);
                SnackbarHelper.showError(context, 'Removed from cart');
              }
              setState(() {});
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
