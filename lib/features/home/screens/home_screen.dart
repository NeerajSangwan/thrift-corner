import 'package:flutter/material.dart';
import 'package:thrift_corner/features/cart/screens/cart_items.dart';
import 'package:thrift_corner/features/cart/screens/wishlist_items.dart';
import 'package:thrift_corner/features/home/screens/cart_screen.dart';
import 'package:thrift_corner/features/home/screens/product_details_screen.dart';
import 'package:thrift_corner/features/home/screens/search_screen.dart';
import 'package:thrift_corner/features/home/services/product_service.dart';
import 'package:thrift_corner/features/home/widgets/app_drawer.dart';
import 'package:thrift_corner/core/storage/local_storage.dart';

import 'package:thrift_corner/core/utils/snackbar_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isWishlisted(int productId) {
    return wishlistItems.any((item) => item['id'] == productId);
  }

  int getQuantity(int productId) {
    for (var item in cartItems) {
      if (item['product']['id'] == productId) {
        return item['quantity'];
      }
    }

    return 0;
  }

  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  List products = [];
  List filteredProducts = [];

  bool isLoading = true;

  void searchProducts(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        filteredProducts = List.from(products);
      } else {
        filteredProducts = products.where((product) {
          return product['title'].toString().toLowerCase().contains(
            query.toLowerCase(),
          );
        }).toList();
      }
    });
  }

  Future<void> fetchProducts() async {
    try {
      final response = await productService.getProducts();
      setState(() {
        products = response.data['products'];
        filteredProducts = List.from(products);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadData() async {
    cartItems.clear();
    wishlistItems.clear();

    final loadedCart = await LocalStorage.loadCart();

    cartItems.addAll(loadedCart.cast<Map<dynamic, dynamic>>());

    final loadedWishlist = await LocalStorage.loadWishlist();

    wishlistItems.addAll(loadedWishlist.cast<Map<dynamic, dynamic>>());

    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    loadData();
    fetchProducts();
  }

  List<String> categories = [
    'All',
    'Beauty',
    'Fragrances',
    'Furniture',
    'Groceries',
  ];

  int selectedIndex = 0;

  final ProductService productService = ProductService();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: searchController.text.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && searchController.text.isNotEmpty) {
          searchController.clear();

          setState(() {
            filteredProducts = List.from(products);
          });

          FocusScope.of(context).unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          centerTitle: true,

          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.black, size: 28),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),

          title: SizedBox(
            height: 170,
            child: Image.asset(
              'assets/logo/full_name.png',
              fit: BoxFit.fitHeight,
            ),
          ),

          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SearchScreen(products: products),
                  ),
                );
              },
              icon: const Icon(Icons.search),
            ),
            IconButton(
              onPressed: () async {
                await Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => CartScreen()));

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

        drawer: AppDrawer(
          onWishlistChanged: () async {
            await loadData();
            setState(() {});
          },
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 0,
                bottom: 20,
              ),
              child: TextField(
                controller: searchController,
                focusNode: searchFocusNode,
                onChanged: (value) {
                  searchProducts(value);
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Search products',
                  prefixIcon: const Icon(Icons.search),

                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            searchController.clear();

                            setState(() {
                              filteredProducts = List.from(products);
                            });

                            FocusScope.of(context).unfocus();
                          },
                          icon: const Icon(Icons.close),
                        )
                      : null,

                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;

                        if (categories[index] == 'All') {
                          filteredProducts = List.from(products);
                        } else {
                          filteredProducts = products.where((product) {
                            return product['category']
                                    .toString()
                                    .toLowerCase() ==
                                categories[index].toLowerCase();
                          }).toList();
                        }
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: selectedIndex == index
                            ? Colors.black
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        categories[index],
                        style: TextStyle(
                          color: selectedIndex == index
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.black),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.60,
                          ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailsScreen(
                                  product: filteredProducts[index],
                                ),
                              ),
                            );

                            setState(() {});
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
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
                                        filteredProducts[index]['thumbnail'],
                                        height: 170,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),

                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () async {
                                          final product =
                                              filteredProducts[index];
                                          if (isWishlisted(product['id'])) {
                                            wishlistItems.removeWhere(
                                              (item) =>
                                                  item['id'] == product['id'],
                                            );
                                            SnackbarHelper.showError(
                                              context,
                                              'Removed from wishlist',
                                            );
                                          } else {
                                            wishlistItems.add(product);
                                            SnackbarHelper.showSuccess(
                                              context,
                                              'Added to wishlist',
                                            );
                                          }
                                          await LocalStorage.saveWishlist(
                                            wishlistItems,
                                          );
                                          setState(() {});
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            isWishlisted(
                                                  filteredProducts[index]['id'],
                                                )
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color:
                                                isWishlisted(
                                                  filteredProducts[index]['id'],
                                                )
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        filteredProducts[index]['title'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      Text(
                                        '\$${filteredProducts[index]['price']}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        '⭐ ${filteredProducts[index]['rating']}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(height: 8),

                                      getQuantity(
                                                filteredProducts[index]['id'],
                                              ) ==
                                              0
                                          ? SizedBox(
                                              width: double.infinity,
                                              height: 36,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.black,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  cartItems.add({
                                                    'product':
                                                        filteredProducts[index],
                                                    'quantity': 1,
                                                  });
                                                  await LocalStorage.saveCart(
                                                    cartItems,
                                                  );
                                                  SnackbarHelper.showSuccess(
                                                    context,
                                                    'Added to cart',
                                                  );
                                                  setState(() {});
                                                },
                                                child: const Text(
                                                  'Add to Cart',
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
                                                border: Border.all(
                                                  color: Colors.black,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  InkWell(
                                                    onTap: () async {
                                                      for (var item
                                                          in cartItems) {
                                                        if (item['product']['id'] ==
                                                            filteredProducts[index]['id']) {
                                                          if (item['quantity'] >
                                                              1) {
                                                            item['quantity']--;
                                                          } else {
                                                            cartItems.remove(
                                                              item,
                                                            );
                                                            SnackbarHelper.showError(
                                                              context,
                                                              'Removed from cart',
                                                            );
                                                          }
                                                          setState(() {});
                                                          await LocalStorage.saveCart(
                                                            cartItems,
                                                          );
                                                          break;
                                                        }
                                                      }
                                                    },
                                                    child: const Icon(
                                                      Icons.remove,
                                                      size: 18,
                                                    ),
                                                  ),

                                                  Text(
                                                    '✓ ${getQuantity(filteredProducts[index]['id'])}',
                                                    style: const TextStyle(
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),

                                                  InkWell(
                                                    onTap: () async {
                                                      for (var item
                                                          in cartItems) {
                                                        if (item['product']['id'] ==
                                                            filteredProducts[index]['id']) {
                                                          item['quantity']++;
                                                          setState(() {});
                                                          await LocalStorage.saveCart(
                                                            cartItems,
                                                          );
                                                          break;
                                                        }
                                                      }
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
            ),
          ],
        ),
      ),
    );
  }
}
